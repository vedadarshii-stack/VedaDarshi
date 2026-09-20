import { readFileSync } from "node:fs";
import { join } from "node:path";

/**
 * Removes the upstream vendor from a generated report and re-renders it as a
 * Vedadarshi-branded PDF.
 *
 * BUILT 20 Sep 2026. The client's instruction was unambiguous — *"i don't
 * want show vedika anywhere"* — and the rendered PDF Vedika returns cannot
 * satisfy it: its cover carries their logo and the line "Prepared by Vedika
 * Intelligence", and `rebrand.ts` rewrites JSON strings, not PDF bytes.
 *
 * ## Why re-render instead of patching their PDF
 *
 * Patching is lighter — pdf-lib could draw our logo and an opaque rectangle
 * over the byline without any browser. **It would not actually work.** Text
 * hidden behind a rectangle is still in the content stream, so `pdftotext`,
 * copy-paste, and search all still surface "Vedika". Re-rendering from the
 * HTML means the string never exists in the output at all — verified: the
 * rendered PDF greps to zero occurrences.
 *
 * ## Why the HTML is the right source
 *
 * Every prebuilt report is returned twice, as `downloadUrl` (PDF) and
 * `iframeUrl` (HTML). The HTML mentions the vendor exactly FOUR times and
 * inlines its logo as a base64 image, so a targeted rewrite is complete and
 * auditable rather than a best-effort scrub. The four are enumerated below;
 * if a future report template adds a fifth, `assertNoVendor` fails loudly
 * instead of shipping a branded-wrong document.
 */

/** Matches the vendor name in any casing. */
const VENDOR = /vedika/gi;

/**
 * Our cover logo, inlined the same way the vendor inlines theirs.
 *
 * Read from disk once per instance rather than per request: it is ~100 KB and
 * the base64 encoding is pure CPU that would otherwise repeat on every
 * report.
 */
let cachedLogo: string | null = null;
function coverLogoDataUri(): string {
  if (cachedLogo) return cachedLogo;
  // Bundled with the functions source so it deploys with the container. See
  // `functions/assets/README.md` for where it comes from.
  const bytes = readFileSync(join(__dirname, "..", "assets", "logo.png"));
  cachedLogo = `data:image/png;base64,${bytes.toString("base64")}`;
  return cachedLogo;
}

/**
 * Rewrites the vendor out of a report's HTML.
 *
 * The four occurrences, as observed on a live artifact (20 Sep 2026):
 *   1. a CSS comment — `vedika_core::report_style::shared_css`
 *   2. the cover logo — `<img ... alt="Vedika" class="cover-logo">`
 *   3. the cover byline — `<div class="brand">Prepared by Vedika Intelligence</div>`
 *   4. the closing footer — `Prepared by Vedika Intelligence.`
 *
 * Handled in that order, most specific first: the logo `<img>` has to be
 * swapped before the blanket name replacement, or its `alt` would be rewritten
 * while the vendor's artwork stayed.
 */
export function rebrandReportHtml(html: string): string {
  let out = html;

  // 2. The cover logo — replace the whole <img>, artwork included.
  out = out.replace(
    /<img[^>]*alt="Vedika"[^>]*class="cover-logo"[^>]*>/i,
    `<img src="${coverLogoDataUri()}" alt="Vedadarshi" class="cover-logo">`
  );

  // 3 + 4. The two bylines.
  //
  // ⚠️ "Vedika Intelligence" is handled BEFORE the blanket replace, and the
  // order is the whole point. A plain vendor-name swap turns their company
  // name into "Vedadarshi Intelligence" — which is not our brand, reads as a
  // different company, and shipped exactly that way in the first render
  // (caught on the generated cover, not in review). "Intelligence" is part of
  // THEIR name, so it goes with it.
  out = out.replace(/Vedika Intelligence/gi, "Vedadarshi");

  // Anything else that names the vendor. A blanket replace rather than a list
  // of exact strings: the wording is theirs to change, and a missed variant
  // is the failure mode that matters. `assertNoVendor` below is what turns a
  // miss into an error rather than a branded-wrong PDF.
  out = out.replace(VENDOR, "Vedadarshi");

  return out;
}

/**
 * Throws if any trace of the vendor survived.
 *
 * ⚠️ This is deliberately fatal rather than a warning. The whole point of the
 * feature is that the name appears nowhere; shipping a report that quietly
 * still says "Vedika" would be worse than failing, because nobody would look
 * again. If a template change trips this, fix the rewrite — do not downgrade
 * the check.
 */
export function assertNoVendor(html: string): void {
  const hits = html.match(VENDOR);
  if (hits && hits.length > 0) {
    throw new Error(
      `rebrandReportHtml left ${hits.length} vendor reference(s) in the document`
    );
  }
}
