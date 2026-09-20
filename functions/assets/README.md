# functions/assets

`logo.png` — the Veda Jyoti cover mark, copied from
`mobile/assets/logo/logo_veda_jyoti.png` (exported from Figma node 88:29).

It is COPIED rather than referenced because Cloud Functions only deploys files
under `functions/`, so a relative path into `mobile/` would resolve locally and
fail in the deployed container.

⚠️ If the brand logo ever changes, this copy must be updated too — nothing
detects the drift, and the only symptom is a stale logo on generated report
covers. It is used by `src/reportBranding.ts`.
