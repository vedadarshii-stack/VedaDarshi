import { defineSecret } from "firebase-functions/params";

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

export const VEDIKA_BASE = "https://api.vedika.io";

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
