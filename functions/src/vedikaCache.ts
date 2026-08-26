/**
 * Shared cache-key + TTL logic for the Firestore `vedikaCache` collection.
 *
 * Used by BOTH the live proxy (`vedika` in index.ts) and the scheduled
 * pre-warm job (`dailyPrewarm.ts). Sharing this single implementation is
 * what guarantees a pre-warmed entry is actually found by the request that
 * would otherwise have to pay for it — before this file existed, the two
 * callers computed the key independently, which is exactly how they drifted
 * apart (see the incident below).
 *
 * ## THE INCIDENT THIS FIXES (found 26 Aug 2026)
 *
 * The client's Vedika billing dashboard showed repeated, separately-billed
 * `GET /v2/astrology/panchang/today` calls minutes apart, despite that
 * route carrying a 6-hour cache TTL. Real `vedikaCache` documents proved
 * why: four DISTINCT cache keys were created for what should have been one
 * cached day+location bucket, 90 seconds apart (18 Aug 2026, 13:25:22 →
 * 13:26:51 IST) — `8509ead4_81`, `4936400f_81`, `ce983b60_92`,
 * `3d9c4b15_97`. The trailing number is the raw request string's LENGTH,
 * and it differs across the four (81/81/92/97 characters) — direct proof
 * the query string genuinely varied call to call, not just hash noise.
 * That is the signature of an unrounded, per-call-varying value (raw GPS
 * precision and/or a live timestamp) landing straight in the cache key.
 *
 * Separately, `dailyPrewarm.ts` was found to warm keys nobody reads at
 * all: it called `/v2/astrology/panchang/today` directly against Vedika
 * (bypassing this cache entirely) and wrote the result only to
 * `dailyPanchang`, a collection `grep -rn "dailyPanchang" mobile/lib`
 * confirms the app never reads. Meanwhile the app itself had already moved
 * to the bundle route `/v2/astrology/panchang` (21 Aug 2026) — so the
 * pre-warm job was both hitting a route the app no longer calls AND
 * writing to a collection nothing reads. 10 cities/day at $0.02 each,
 * 100% wasted. `dailyPrewarm.ts` now calls the same route with the same
 * query shape the app uses and writes into `vedikaCache` too.
 *
 * Fixed here by normalizing the key (below) so semantically-identical
 * requests always collide, and by giving panchang/daily/horoscope a
 * 24-hour TTL instead of 6 — see `cacheTtlSeconds` for why that is still
 * astrologically exact, not a looser cache.
 */

/**
 * Canonicalizes a query string so two requests that are semantically "the
 * same day, the same place" always hash to the same cache key:
 *
 *  - `latitude`/`longitude` are rounded to 4 decimal places (~11 m —
 *    city-block precision, never enough to change a tithi/nakshatra/
 *    muhurat reading, which is why this does not weaken correctness).
 *    This is what protects against raw, jittering GPS precision reaching
 *    the cache key — the root cause of the incident above.
 *  - Params are re-serialized in SORTED key order, so two callers (or two
 *    app versions) that build the same params in a different order still
 *    collide instead of minting a second cache entry.
 *
 * Anything genuinely day/location-varying (the `datetime` bucket, the
 * `latitude`/`longitude` values themselves) stays IN the key — this only
 * removes noise, never a real dimension of the answer.
 */
export function normalizeQuery(query: string): string {
  const params = new URLSearchParams(query);
  for (const key of ["latitude", "longitude"]) {
    const raw = params.get(key);
    if (raw !== null) {
      const n = Number(raw);
      if (Number.isFinite(n)) params.set(key, n.toFixed(4));
    }
  }
  params.sort();
  return params.toString();
}

/**
 * How long a cached response stays fresh, by endpoint family.
 *
 * These are what keep the bill down. Panchang and horoscope are identical
 * for every user in a location/sign for a whole day, so without caching we
 * would pay per user per screen-open instead of once per day. A natal chart
 * (kundli) and a guna-milan match never change at all for the same inputs,
 * so they are cached effectively forever.
 *
 * Panchang/daily/horoscope are 24 HOURS, not the original 6 — raised
 * 26 Aug 2026. This is NOT "caching looser than astrologically correct":
 * the specific calendar day is already baked into the KEY (the `datetime`
 * query param, or the `{yyyy-MM-dd}` path segment), so the cached answer
 * for a given key never becomes wrong within that day — a rolling 6-hour
 * window was simply forcing up to 4 needless re-fetches of the identical
 * answer per city/sign per day, independent of any bug. A new calendar day
 * mints a new key on its own (a new `datetime`), so this cannot serve
 * yesterday's tithi as today's.
 *
 * EXCEPT `/panchang/today` — deliberately EXCLUDED from that 24h bump and
 * kept at the original 6h. That route (deprecated in the app 21 Aug 2026,
 * but still proxied for any older installed build still calling it — see
 * the incident in this file's top comment) carries NO date anywhere in
 * its key: no `{date}` path segment, and none of its callers ever sent a
 * `datetime` query param. Its cache key is therefore NOT day-scoped the
 * way every other route here is, so a 24h TTL on it really could serve
 * yesterday's tithi as today's for up to 18 extra hours. 6h bounds that
 * risk to what the route already tolerated before this change, without
 * assuming the deprecated route ever becomes day-safe.
 */
export function cacheTtlSeconds(path: string): number {
  if (path.endsWith("/panchang/today")) return 60 * 60 * 6;
  if (path.includes("/panchang") || path.includes("/daily/")) return 60 * 60 * 24;
  if (path.includes("/horoscope")) return 60 * 60 * 24;
  if (path.includes("/kundli") || path.includes("/planet-positions")) {
    return 60 * 60 * 24 * 365;
  }
  if (path.includes("guna-milan") || path.includes("matching")) {
    return 60 * 60 * 24 * 365;
  }
  return 60 * 60; // conservative default
}

/**
 * Firestore document ids may not contain "/" — hash the request instead.
 *
 * `query` is normalized (see [normalizeQuery]) BEFORE hashing, so this is
 * the one function every caller must go through — never hash a raw query
 * string directly, or the normalization is defeated for that caller alone.
 */
export function cacheKey(method: string, path: string, query: string, body: string): string {
  const raw = `${method} ${path}?${normalizeQuery(query)} ${body}`;
  // FNV-1a: good enough to key a cache, and dependency-free.
  let h = 0x811c9dc5;
  for (let i = 0; i < raw.length; i++) {
    h ^= raw.charCodeAt(i);
    h = Math.imul(h, 0x01000193) >>> 0;
  }
  return `${h.toString(16)}_${raw.length}`;
}
