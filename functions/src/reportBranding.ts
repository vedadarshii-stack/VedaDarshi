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

/**
 * Every spelling of the vendor name we have actually observed, in the order
 * they must be applied (longest and most specific first).
 *
 * ⚠️ **ADDED 13 Oct 2026 after a real leak reached generated documents.**
 * Until then this was a lone `/vedika/gi` — Latin only. The regional reports
 * print the vendor in their OWN script, so the Hindi report carried
 * "वेदिका इंटेलिजेंस" in the footer of all 15 pages and sailed through
 * `assertNoVendor` untouched. Counts from one Marriage report per language:
 * hi 15, te 5, ta 1, kn 1.
 *
 * 🚨 **THE TRAP: each script has a legitimate near-homograph meaning
 * "Vedic", and it differs by ONE VOWEL.** Replacing it would corrupt the
 * report's own title — "वैदिक विवाह" (Vedic Marriage) is not the vendor.
 *
 *   script       vendor      legitimate "Vedic"   differs by
 *   Devanagari   वेदिका       वैदिक                 वे  vs  वै
 *   Telugu       వేదిక        వైదిక                 వే  vs  వై
 *   Kannada      ವೇದಿಕಾ       ವೈದಿಕ                 ವೇ  vs  ವೈ
 *   Tamil        வேதிகா       வேத                  the trailing ிகா
 *
 * So these are exact strings, never fuzzy stems. Adding a new one means
 * checking its "Vedic" counterpart first.
 */
const VENDOR_PATTERNS: readonly RegExp[] = [
  // Full company name first, so "Intelligence" goes with it rather than
  // being left stranded next to our brand — the same reason the Latin
  // "Vedika Intelligence" rule below precedes the bare name.
  /वेदिका\s*इंटेलिजेंस/g,
  /వేదిక\s*ఇంటెలిజెన్స్/g,
  /ವೇದಿಕಾ\s*ಇಂಟೆಲಿಜೆನ್ಸ್/g,
  /வேதிகா\s*இன்டெலிஜென்ஸ்/g,
  // Then the bare vendor name per script.
  /वेदिका/g,
  /వేదికా/g,
  /వేదిక/g,
  /ವೇದಿಕಾ/g,
  /ವೇದಿಕ/g,
  /வேதிகா/g,
  // Latin last — it is the broadest, and `Vedika Intelligence` is handled
  // separately above it in `rebrandReportHtml`.
  /vedika/gi,
];

/** Kept for the Latin-only callers below. */
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

  // Every non-Latin spelling. Applied after the Latin pass so the ordering
  // comment above still holds for "Vedika Intelligence".
  for (const pattern of VENDOR_PATTERNS) {
    out = out.replace(pattern, "Vedadarshi");
  }

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
  // Checks EVERY script, not just Latin. The Latin-only version of this
  // check passed a Hindi report that said "वेदिका इंटेलिजेंस" on all 15
  // pages — the assertion was real, it was just looking in one alphabet.
  const found: string[] = [];
  for (const pattern of VENDOR_PATTERNS) {
    const hits = html.match(pattern);
    if (hits && hits.length > 0) found.push(`${hits[0]} x${hits.length}`);
  }
  if (found.length > 0) {
    throw new Error(
      `rebrandReportHtml left vendor reference(s) in the document: ${found.join(", ")}`
    );
  }
}
