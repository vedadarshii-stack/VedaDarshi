/**
 * Rewrites the upstream provider's name out of user-facing content.
 *
 * BUILT 10 Sep 2026 on the client's request: *"if in report vedika wording
 * comes please change that to our vedadarshi branding, update in the middle
 * ware of api so that content will parse replace name correctly"*.
 *
 * ## What actually needed fixing
 *
 * I probed five endpoints before writing this. The `/v2/*` astrology
 * endpoints mention the provider ONLY in metadata (`meta.engine`,
 * `meta.source`, `data.source`), never in prose — so reports were never
 * leaking the name to users.
 *
 * The real leak is the **AI**. `/api/v1/astrology/query` answers with:
 *
 *     "I am Vedika, your personal Vedic astrologer."
 *
 * That is shown verbatim in the Rishi AI chat, so the app introduces itself
 * to users under the vendor's name. That is what this fixes.
 *
 * ## Done in the proxy, deliberately
 *
 * Rebranding in the Flutter client would mean doing it in every parser, and
 * missing one is invisible until a user sees it. Here it happens once,
 * before the response is cached, so a cached answer carries the corrected
 * text too and every client — current and future — gets it.
 */

/** Matches the vendor name in any casing, as a whole word or in a hyphenated id. */
const VENDOR = /vedika/gi;

/**
 * Preserves the casing of what it replaced, so `Vedika` → `Vedadarshi`,
 * `vedika-intelligence` → `vedadarshi-intelligence`, `VEDIKA` → `VEDADARSHI`.
 * Getting this wrong produces "vedadarshi, your personal astrologer" mid
 * sentence, which reads worse than not rebranding at all.
 */
function replacementFor(match: string): string {
  if (match === match.toUpperCase()) return "VEDADARSHI";
  if (match[0] === match[0].toUpperCase()) return "Vedadarshi";
  return "vedadarshi";
}

function rewriteString(value: string): string {
  // ⚠️ URLs are left alone. `https://vedika.io/docs#…` rewritten to
  // `https://vedadarshi.io/…` is a link to a domain we do not own — a dead
  // link is worse than an honest vendor link, and these appear in error
  // payloads a support engineer may need to follow.
  if (value.includes("://")) return value;
  return value.replace(VENDOR, replacementFor);
}

/**
 * Recursively rewrites every string in a payload.
 *
 * ⚠️ **`meta` and `billing` are skipped on purpose.** They are diagnostics,
 * never rendered by the app (verified: nothing in `mobile/lib` reads
 * `meta.engine` or `meta.source`). Leaving them intact means a log or a
 * cached document still shows plainly which upstream produced it — rebranding
 * our own diagnostics would make a support question like "did this come from
 * the vendor or our cache?" unanswerable.
 */
export function rebrand<T>(payload: T): T {
  return walk(payload, "") as T;
}

function walk(node: unknown, key: string): unknown {
  if (typeof node === "string") return rewriteString(node);
  if (Array.isArray(node)) return node.map((item) => walk(item, key));
  if (node && typeof node === "object") {
    const out: Record<string, unknown> = {};
    for (const [k, v] of Object.entries(node as Record<string, unknown>)) {
      out[k] = k === "meta" || k === "billing" ? v : walk(v, k);
    }
    return out;
  }
  return node;
}
