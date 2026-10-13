import { copyFileSync, existsSync, mkdirSync, readdirSync } from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import * as admin from "firebase-admin";
import chromium from "@sparticuz/chromium";
import puppeteer from "puppeteer-core";
import { rebrandReportHtml, assertNoVendor } from "./reportBranding";

/**
 * Turns a vendor HTML artifact into a Vedadarshi-branded PDF in our own
 * bucket.
 *
 * See `reportBranding.ts` for why the HTML — not the vendor's own PDF — is
 * the source, and why re-rendering rather than patching is the only approach
 * that actually removes the name.
 *
 * ## Why this needs a browser at all
 *
 * The report HTML is a print-styled document: page breaks, running headers,
 * SVG dividers, a cover. Nothing short of a real layout engine reproduces it,
 * and re-implementing the layout ourselves would be rebuilding the product we
 * are paying Vedika for. `@sparticuz/chromium` is the serverless-sized build;
 * `puppeteer-core` is the driver without a bundled browser.
 */

/** The bucket rendered reports live in. Created 20 Sep 2026. */
const REPORTS_BUCKET = "vedadarshi-20989-reports";

/**
 * How long a download link stays valid.
 *
 * Seven days rather than an hour: a user who buys a report expects to reopen
 * it from their email or downloads folder days later. It is not permanent
 * because the URL is unauthenticated once issued — a signed URL IS the
 * credential, so an unbounded one is a permanent public link to someone's
 * birth chart reading.
 */
const SIGNED_URL_DAYS = 7;

export interface RenderedReport {
  storagePath: string;
  downloadUrl: string;
  expiresAtMs: number;
}

/**
 * Deletes every rendered report belonging to [uid].
 *
 * ADDED 23 Sep 2026, closing a real data-deletion gap PROVEN in production:
 * after `deleteAccount` ran to completion — Auth user gone, Firestore
 * subtree gone — `detailedReports/{uid}/career.pdf` was still sitting in
 * this bucket. A full birth-chart reading, behind a signed URL that stays
 * valid for seven days after issue.
 *
 * ⚠️ `deleteAccount`'s own `listCollections()` trick cannot catch this.
 * That mechanism exists so a subcollection added later is not orphaned, and
 * its comment even anticipates "a future `reports` collection" — but it
 * enumerates FIRESTORE. Cloud Storage is a different service, so nothing
 * about this bucket is discoverable from there. **Any future user data put
 * somewhere other than `/users/{uid}` has to be deleted explicitly, here.**
 *
 * Resolves to `false` rather than throwing. The caller records the failure
 * and carries on: blocking the account deletion would not remove these
 * files, it would only leave the Firestore data behind them as well.
 */
export async function deleteRenderedReports(uid: string): Promise<boolean> {
  try {
    await admin
      .storage()
      .bucket(REPORTS_BUCKET)
      // The trailing slash matters: without it this prefix would also match
      // `detailedReports/<uid-with-this-as-a-prefix>/…`, deleting another
      // user's reports. Firebase uids are fixed-length today, so no uid is
      // a prefix of another — but that is an accident of the id format, not
      // a guarantee, and it is not one worth betting someone else's data on.
      .deleteFiles({ prefix: `detailedReports/${uid}/`, force: true });
    return true;
  } catch (e) {
    console.error("deleteRenderedReports failed", { uid }, e);
    return false;
  }
}

function storagePathFor(
  uid: string,
  reportId: string,
  language: string
): string {
  // Namespaced by uid so one user's report can never collide with another's,
  // and so a future per-user cleanup is a prefix delete.
  //
  // ⚠️ The LANGUAGE is part of the filename. Without it, the same report in
  // Telugu would overwrite the English copy (and vice versa) — and, worse,
  // the caller's cache lookup would hand back whichever language happened to
  // be rendered first. See the cache note in `detailedReports.ts`.
  return `detailedReports/${uid}/${reportId}-${language}.pdf`;
}

/**
 * Issues a fresh signed URL for an ALREADY rendered report.
 *
 * Split from the render so re-opening costs nothing: the expensive parts are
 * the Vedika charge and the chromium run, and neither has to repeat just
 * because a link expired.
 */
export async function signExistingReport(
  uid: string,
  reportId: string,
  language: string
): Promise<RenderedReport | null> {
  const path = storagePathFor(uid, reportId, language);
  const file = admin.storage().bucket(REPORTS_BUCKET).file(path);
  const [exists] = await file.exists();
  if (!exists) return null;
  return await signFile(path);
}

async function signFile(path: string): Promise<RenderedReport> {
  const expiresAtMs = Date.now() + SIGNED_URL_DAYS * 24 * 60 * 60 * 1000;
  const [downloadUrl] = await admin
    .storage()
    .bucket(REPORTS_BUCKET)
    .file(path)
    .getSignedUrl({ action: "read", expires: expiresAtMs });
  return { storagePath: path, downloadUrl, expiresAtMs };
}

/**
 * Fetches [iframeUrl], strips the vendor, renders it, and stores the PDF.
 *
 * ⚠️ `assertNoVendor` runs BEFORE chromium is launched. Failing early means a
 * template change that defeats the rewrite costs a cheap error rather than a
 * browser run that produces a wrongly-branded document we would then have to
 * notice was wrong.
 */

/**
 * Makes the Indic fonts available to Chromium before it launches.
 *
 * 🚨 **WITHOUT THIS, TELUGU AND KANNADA REPORTS RENDER AS A PAGE OF EMPTY
 * BOXES.** Found 13 Oct 2026 by rasterising the generated PDFs and looking
 * at them; the client spotted it first.
 *
 * `@sparticuz/chromium` ships a minimal font set — Liberation (Latin) plus
 * GNU FreeFont. FreeSans and FreeSerif happen to cover Devanagari and Tamil,
 * which is why Hindi and Tamil looked perfect, but GNU FreeFont covers
 * NEITHER Telugu NOR Kannada. Confirmed from the output itself: the hi and
 * ta PDFs embed FreeSans/FreeSerif subsets, while te and kn embed nothing
 * but Liberation.
 *
 * ⚠️ **The text layer was correct in every language the whole time.** Only
 * the glyphs were missing, so `pdftotext` extracted perfect Telugu from a
 * document that displayed as boxes — which is exactly why this survived a
 * text-based verification. A rendered document has to be verified by
 * RENDERING it.
 *
 * The mechanism is fontconfig, not CSS: the package sets
 * `FONTCONFIG_PATH=/tmp/fonts` and inflates its own fonts there, so dropping
 * ours into the same directory lets Chromium's ordinary per-character
 * fallback find them — the same path by which it already finds FreeSans for
 * Devanagari. Injecting `@font-face` rules instead would have meant editing
 * every `font-family` declaration in a document we do not control.
 *
 * Must run AFTER `chromium.executablePath()` (which performs the inflation)
 * and BEFORE `puppeteer.launch()`.
 */
function installIndicFonts(): void {
  try {
    const configDir = process.env["FONTCONFIG_PATH"] ?? join(tmpdir(), "fonts");
    // ⚠️ The fonts do NOT go in FONTCONFIG_PATH itself. That directory holds
    // `fonts.conf` plus a NESTED `fonts/` directory, and it is the nested one
    // that fonts.conf actually scans. Dropping ttf files in the parent is
    // silent and useless — the copy succeeds, fontconfig never looks there,
    // and Telugu still renders as boxes. Confirmed from a runtime listing:
    //   /tmp/fonts -> [ ...our ttfs..., 'fonts', 'fonts.conf' ]
    // fonts.conf declares `<dir>/tmp/fonts</dir>` and fontconfig scans a
    // <dir> RECURSIVELY, so the parent is correct and the nested `fonts/`
    // subdirectory (where the package keeps its own Open_Sans) is covered by
    // the same entry. Placement was never the problem.
    const dir = configDir;
    mkdirSync(dir, { recursive: true });
    const src = join(__dirname, "..", "assets", "fonts");
    if (!existsSync(src)) {
      console.error("installIndicFonts: asset dir missing", { src });
      return;
    }
    let copied = 0;
    for (const file of readdirSync(src)) {
      if (!file.endsWith(".ttf")) continue;
      const dest = join(dir, file);
      // Containers are reused between invocations, so skip the copy when the
      // font is already in place rather than rewriting it every request.
      if (!existsSync(dest)) {
        copyFileSync(join(src, file), dest);
        copied += 1;
      }
    }
    console.log("installIndicFonts", { installedInto: dir, copied });
  } catch (e) {
    // Never fail a report over this. A missing font degrades to the old
    // behaviour (boxes for that script); throwing would deny the user a
    // document they paid for in EVERY language.
    console.error("installIndicFonts failed", e);
  }
}

export async function renderBrandedReport(params: {
  uid: string;
  reportId: string;
  language: string;
  iframeUrl: string;
}): Promise<RenderedReport> {
  const { uid, reportId, language, iframeUrl } = params;

  const res = await fetch(iframeUrl);
  if (!res.ok) {
    throw new Error(`report HTML fetch failed: ${res.status}`);
  }
  const branded = rebrandReportHtml(await res.text());
  assertNoVendor(branded);

  // Order is load-bearing: `executablePath()` performs the inflation that
  // creates /tmp/fonts, so the fonts must be copied in after it resolves and
  // before chromium starts reading fontconfig.
  const executablePath = await chromium.executablePath();
  installIndicFonts();

  const browser = await puppeteer.launch({
    args: chromium.args,
    executablePath,
    headless: true,
    // ⚠️ FONTCONFIG_* passed EXPLICITLY.
    //
    // The variables are set on the Node process by the chromium package, and
    // puppeteer does default to inheriting `process.env` — but the evidence
    // said the browser was not reading that config at all: the package's own
    // bundled Open_Sans never appeared in any output either, while Liberation
    // and FreeSans (which live in the read-only system font dirs) did. So the
    // browser was falling back to the system fontconfig and ignoring
    // /tmp/fonts entirely. Naming the config file outright removes the
    // ambiguity.
    env: {
      ...process.env,
      FONTCONFIG_PATH: process.env["FONTCONFIG_PATH"] ?? "/tmp/fonts",
      FONTCONFIG_FILE: join(
        process.env["FONTCONFIG_PATH"] ?? "/tmp/fonts",
        "fonts.conf"
      ),
    },
  });

  try {
    const page = await browser.newPage();
    // `setContent` rather than navigating to the vendor URL: the document is
    // self-contained (fonts and images are inline data URIs), so there is
    // nothing to fetch — and this guarantees chromium renders the REBRANDED
    // copy rather than re-fetching the original.
    // `load`, not `networkidle0` — the latter is not a valid `setContent`
    // state in puppeteer-core 25 anyway, and would be the wrong choice here:
    // every font and image is an inline data URI, so there is no network
    // activity to go idle. `load` fires once those are decoded, which is
    // exactly when the document is ready to paginate.
    await page.setContent(branded, { waitUntil: "load" });
    const pdf = await page.pdf({
      format: "a4",
      printBackground: true,
      // The document brings its own cover, margins and running footers; a
      // browser header/footer would overprint them.
      displayHeaderFooter: false,
      margin: { top: "0", right: "0", bottom: "0", left: "0" },
    });

    const path = storagePathFor(uid, reportId, language);
    await admin
      .storage()
      .bucket(REPORTS_BUCKET)
      .file(path)
      .save(Buffer.from(pdf), {
        contentType: "application/pdf",
        // Private by default — the bucket is uniform-access and nothing here
        // is public. The signed URL is the only way in.
        metadata: { cacheControl: "private, max-age=0" },
      });

    return await signFile(path);
  } finally {
    // Always close, including on a render failure: a leaked chromium holds
    // the whole instance's memory and the next request in that container
    // would OOM rather than simply retrying.
    await browser.close();
  }
}
