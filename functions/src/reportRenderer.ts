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

function storagePathFor(uid: string, reportId: string): string {
  // Namespaced by uid so one user's report can never collide with another's,
  // and so a future per-user cleanup is a prefix delete.
  return `detailedReports/${uid}/${reportId}.pdf`;
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
  reportId: string
): Promise<RenderedReport | null> {
  const path = storagePathFor(uid, reportId);
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
export async function renderBrandedReport(params: {
  uid: string;
  reportId: string;
  iframeUrl: string;
}): Promise<RenderedReport> {
  const { uid, reportId, iframeUrl } = params;

  const res = await fetch(iframeUrl);
  if (!res.ok) {
    throw new Error(`report HTML fetch failed: ${res.status}`);
  }
  const branded = rebrandReportHtml(await res.text());
  assertNoVendor(branded);

  const browser = await puppeteer.launch({
    args: chromium.args,
    executablePath: await chromium.executablePath(),
    headless: true,
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

    const path = storagePathFor(uid, reportId);
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
