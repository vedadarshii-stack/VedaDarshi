import { defineSecret, defineString } from "firebase-functions/params";

/**
 * The paid Vedika API key, shared by every function that talks to Vedika
 * directly: the live proxy (index.ts) AND the scheduled pre-warm job
 * (dailyPrewarm.ts) AND the AI credit-reservation callable (aiCredits.ts).
 *
 * `defineSecret` binds to a secret NAME, and Firebase Functions v2 wants
 * one shared object per secret rather than one per file — declaring it
 * again in a second file would technically still work (same secret name,
 * same value at runtime) but would create a second, independent binding
 * object for the same physical secret, which is exactly the kind of
 * footgun the next person touching this code should not have to
 * rediscover. Import THIS constant everywhere the key is needed, and set
 * the actual value once via:
 *
 *   firebase functions:secrets:set VEDIKA_API_KEY
 */
export const VEDIKA_API_KEY = defineSecret("VEDIKA_API_KEY");

/**
 * RevenueCat SECRET API key, used only by `deleteAccount` to remove a
 * customer's purchase records when they delete their account.
 *
 * ⚠️ **This is NOT the `goog_…` public SDK key that ships in the app.** This
 * one can read and DELETE every subscriber's data, so it must never appear
 * in `mobile/.env` (which is bundled into the APK as plain text and is
 * trivially extractable) or in `functions/.env` (which is uploaded verbatim
 * at deploy time). Secret Manager only:
 *
 *   firebase functions:secrets:set REVENUECAT_SECRET_API_KEY
 *
 * Scope it to customer read + delete in the RevenueCat dashboard — nothing
 * here needs project-wide write.
 */
export const REVENUECAT_SECRET_API_KEY = defineSecret(
  "REVENUECAT_SECRET_API_KEY"
);

/**
 * RevenueCat project id, used to build the V2 customer-delete URL. Not a
 * secret — it is visible in the dashboard URL — so it lives here as a plain
 * constant rather than in Secret Manager.
 */
export const REVENUECAT_PROJECT_ID = "proj0503f814";

/**
 * The PLAY STORE app inside that RevenueCat project — "Vedadarshi (Play
 * Store)", package `com.gosewealth.vedadarshi`.
 *
 * ⚠️ The project also contains a second, RETIRED app: `appcbf3207cda`
 * ("Test Store"), which still holds the archived scaffold products
 * (`monthly`/`yearly`/`lifetime`) and the superseded underscore-form
 * subscriptions. Anything listing products for display or sale MUST scope to
 * this id — a project-wide `/products` call mixes dead Test Store SKUs in
 * with the 29 real ones, and they are indistinguishable by name alone.
 *
 * Not a secret; it is visible in the dashboard URL.
 */
export const REVENUECAT_PLAY_APP_ID = "app04675a40cc";

/**
 * Shared secret RevenueCat sends as the `Authorization` header on every
 * webhook.
 *
 * The webhook endpoint is PUBLIC — RevenueCat has to be able to reach it —
 * so this value is the only thing preventing a stranger from POSTing a
 * forged event and granting themselves Platinum. Treat it exactly like the
 * API keys: Secret Manager only, never `.env`.
 *
 *   firebase functions:secrets:set REVENUECAT_WEBHOOK_AUTH
 */
export const REVENUECAT_WEBHOOK_AUTH = defineSecret("REVENUECAT_WEBHOOK_AUTH");

/**
 * Where Vedika calls go. Defaults to the FREE sandbox
 * (`https://api.vedika.io/sandbox`) so this backend is deployable and
 * usable TODAY, before the client has a paid Vedika plan / real API key.
 *
 * Going live is a CONFIG-ONLY change, no code edit:
 *   1. Set `VEDIKA_BASE_URL=https://api.vedika.io` in `functions/.env`.
 *   2. Set a real key: `firebase functions:secrets:set VEDIKA_API_KEY`.
 *   3. Redeploy.
 *
 * `defineString` (not a plain `const`) is what makes this overridable per
 * environment via `.env` / `.env.<projectId>` without touching this file.
 */
export const VEDIKA_BASE_URL = defineString("VEDIKA_BASE_URL", {
  default: "https://api.vedika.io/sandbox",
});

/**
 * The value `VEDIKA_API_KEY` holds while there is no real paid key yet —
 * i.e. while running against the free sandbox above. Secret Manager will
 * not store an empty string as a secret value, so a real (but meaningless)
 * sentinel word is used instead of `""` to represent "no key configured".
 */
export const SANDBOX_KEY_SENTINEL = "SANDBOX";

/**
 * Auth header(s) to send with a Vedika request.
 *
 * The free sandbox is UNAUTHENTICATED and may reject a request that carries
 * a bogus auth header (rather than simply ignoring it) — so while the
 * secret still holds `SANDBOX_KEY_SENTINEL` we send NO auth header at all.
 * Once a real key is configured (any value other than the sentinel), it is
 * sent as `Authorization: Bearer <key>`.
 *
 * WHY Bearer, not `X-API-Key`: per vedika.io/openapi.json, the API key as
 * `Authorization: Bearer vk_live_...` is the PREFERRED, current auth method.
 * `X-API-Key: <key>` is explicitly called out as DEPRECATED there, with a
 * sunset date of **2026-10-20** — after that date it stops being accepted at
 * all. Sending it today would work, but ship code with a known expiry date
 * baked in for no reason. Bearer has none of that risk, so it's what this
 * backend has sent from the start.
 *
 * Call this INSIDE a function handler, never at module load time —
 * `VEDIKA_API_KEY.value()` is only resolvable at runtime.
 */
export function vedikaHeaders(): Record<string, string> {
  const key = VEDIKA_API_KEY.value();
  return key && key !== SANDBOX_KEY_SENTINEL ? { Authorization: `Bearer ${key}` } : {};
}

/**
 * Today's date as `YYYY-MM-DD` in Asia/Kolkata, independent of the
 * machine's own timezone (Cloud Functions always run in UTC).
 *
 * This is deliberately the SAME notion of "today" used by:
 *  - the 12:01 AM IST scheduled pre-warm (dailyPrewarm.ts), which is what
 *    decides which Firestore doc a given day's content lives under, and
 *  - the AI credit ledger (aiCredits.ts), which resets a user's daily
 *    quota at IST midnight, not at UTC midnight — the client base and
 *    billing cycle are India-first, so "daily" means the Indian calendar
 *    day, not the server's.
 * Using `Date#getUTCDate()` or similar here would silently shift both of
 * those by up to 5.5 hours around midnight IST. Do not "simplify" this by
 * dropping the explicit timeZone.
 */
export function todayKeyIST(): string {
  const parts = new Intl.DateTimeFormat("en-CA", {
    timeZone: "Asia/Kolkata",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).formatToParts(new Date());
  const y = parts.find((p) => p.type === "year")!.value;
  const m = parts.find((p) => p.type === "month")!.value;
  const d = parts.find((p) => p.type === "day")!.value;
  return `${y}-${m}-${d}`;
}
