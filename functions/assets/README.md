# functions/assets

`logo.png` — the Veda Jyoti cover mark, copied from
`mobile/assets/logo/logo_veda_jyoti.png` (exported from Figma node 88:29).

It is COPIED rather than referenced because Cloud Functions only deploys files
under `functions/`, so a relative path into `mobile/` would resolve locally and
fail in the deployed container.

⚠️ If the brand logo ever changes, this copy must be updated too — nothing
detects the drift, and the only symptom is a stale logo on generated report
covers. It is used by `src/reportBranding.ts`.

## fonts/

Noto Sans Devanagari / Telugu / Tamil / Kannada — copied from
`mobile/assets/google_fonts/`, the SAME faces the app itself renders with, so
a report looks like the app it came from.

⚠️ **Why these exist at all.** The headless Chromium used to render reports
ships a minimal font set: Liberation (Latin) plus GNU FreeFont. FreeSans and
FreeSerif happen to cover Devanagari and Tamil — but cover NEITHER Telugu NOR
Kannada. So Telugu and Kannada reports rendered as a page of empty boxes
while Hindi and Tamil looked perfect, which is exactly the kind of partial
failure nobody notices in a text-extraction check: the text layer was
correct in every language, only the glyphs were missing.

Caught 13 Oct 2026 by rasterising the PDFs and LOOKING at them. Verifying a
rendered document by `pdftotext` alone cannot catch a missing font.

These are inlined as base64 `@font-face` rules by `reportBranding.ts`, so the
render stays fully self-contained — no network fetch during rendering, which
matters because `page.setContent` has no base URL to resolve against.
