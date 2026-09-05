import { todayKeyIST } from "./config";

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
export function cacheTtlSeconds(path: string, body = ""): number {
  // A request that names an explicit CALENDAR DATE is immutable: the panchang
  // and the muhurat windows for 10 Sep 2026 are the same facts whenever you
  // ask, before or after the fact. So once fetched, it never needs fetching
  // again.
  //
  // ADDED 4 Sep 2026. This is the client's "rolling 7-day window" request,
  // solved from the other end: rather than PRE-fetching a week for every city
  // (which is days x cities calls of mostly-unread data), we cache whatever
  // date a user actually opens, for a month. The first person to step to a
  // date pays once; everyone after that is free, and the date-stepper on the
  // Panchang screen stops re-billing entirely.
  //
  // 30 days rather than a year only because a stale far-future entry is worth
  // less than the storage it occupies; the data itself never changes.
  const datedDay =
    /\d{4}-\d{2}-\d{2}/.test(path) || /\d{4}-\d{2}-\d{2}/.test(body);
  const isDayFacts =
    path.includes("/panchang") ||
    path.includes("muhurta") ||
    path.includes("muhurat") ||
    path.includes("inauspicious-period") ||
    path.includes("/daily/");
  if (datedDay && isDayFacts) return 60 * 60 * 24 * 30;

  if (path.endsWith("/panchang/today")) return 60 * 60 * 6;
  // Muhurat windows are day+location facts, exactly like panchang. Added
  // 4 Sep 2026: `/v2/astrology/brahma-muhurta` became the muhurat source on
  // 2 Sep but no tier ever matched it, so it fell to the 1-hour default and
  // re-billed every hour for data that is fixed for the whole day.
  if (
    path.includes("/panchang") ||
    path.includes("/daily/") ||
    path.includes("muhurta") ||
    path.includes("muhurat") ||
    path.includes("inauspicious-period")
  ) {
    return 60 * 60 * 24;
  }
  if (path.includes("/horoscope")) return 60 * 60 * 24;
  if (path.includes("/kundli") || path.includes("/planet-positions")) {
    return 60 * 60 * 24 * 365;
  }

  // Doshas: FIXED AT BIRTH. A chart either carries Mangal/Kaal Sarp/Pitru
  // dosha or it does not — that is decided by the natal positions and never
  // changes, so this is as immutable as the kundli itself.
  if (path.includes("/all-doshas") || path.includes("-dosha")) {
    return 60 * 60 * 24 * 365;
  }

  // Vimshottari dasha: FULLY IMMUTABLE as of 4 Sep 2026, so cached like the
  // kundli it derives from.
  //
  // It was 30 days until the client made the point that a dasha timeline is
  // fixed at birth and only the "which period is running now" marker depends
  // on today. They were right, and the app now DERIVES that marker locally
  // from each period's start/end dates instead of reading Vedika's
  // `is_current` flag (see `kundli_dasha_data.dart::_spansNow`). With the one
  // date-dependent field gone, nothing in the payload can go stale — it is a
  // pure function of the birth moment, exactly like the chart.
  //
  // This also makes the marker MORE correct, not just cheaper: it is
  // recomputed on every read rather than frozen at fetch time, so it stays
  // right across a dasha boundary instead of drifting until the cache
  // expires. (Same reasoning already applied to `guidance.time_remaining`,
  // which was observed 441 days stale.)
  if (path.includes("vimshottari") || path.includes("/dasha")) {
    return 60 * 60 * 24 * 365;
  }
  if (path.includes("guna-milan") || path.includes("matching")) {
    return 60 * 60 * 24 * 365;
  }

  // Premium reports, added 2 Sep 2026 when the Reports screen started
  // actually fetching them. These are the MOST EXPENSIVE calls in the whole
  // app — `/v2/reports/complete` bills $0.07, roughly 5x a normal call,
  // measured against the live balance — and they fell to the 1-hour default
  // below, so re-opening a report card the next day re-billed it. Splitting
  // them by what the answer actually depends on:
  //
  //  - NATAL-ONLY reports are pure functions of the birth details, exactly
  //    like a kundli, so they are cached for a year. `complete`,
  //    `birth-chart-report`, `career-report` and `marriage-report` describe
  //    houses, lords and yogas; the gemstone remedy follows natal planet
  //    strength; numerology follows the birth date. None of these change
  //    tomorrow.
  //  - TRANSIT-DEPENDENT reports fall through to the 24-hour tier further
  //    down. Sade Sati is defined BY Saturn's current transit, wealth-timing
  //    keys off the active dasha and transit summary, and health-report's
  //    healing periods reference Jupiter's transit. Caching those for a year
  //    would serve a stale verdict long after it stopped being true, which
  //    is a correctness bug, not a saving.
  if (
    path.includes("/reports/complete") ||
    path.includes("/reports/birth-chart-report") ||
    path.includes("/reports/career-report") ||
    path.includes("/reports/marriage-report") ||
    path.includes("/remedies/gemstone") ||
    path.includes("/numerology/")
  ) {
    return 60 * 60 * 24 * 365;
  }
  if (
    path.includes("/reports/health-report") ||
    path.includes("/sade-sati") ||
    path.includes("/finance/")
  ) {
    return 60 * 60 * 24;
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
/**
 * Matches an ISO calendar date anywhere in a path or body, e.g.
 * `/v2/astrology/panchang/2026-09-05` or `{"datetime":"1990-05-15T10:30:00"}`.
 */
const ISO_DATE = /\d{4}-\d{2}-\d{2}/;

/**
 * The calendar day a cache entry belongs to, or `""` when the request does
 * not need one.
 *
 * ADDED 4 Sep 2026, fixing a real staleness risk. `cacheKey` hashes only
 * method + path + query + body, so `/v2/astrology/horoscope/leo` produced the
 * SAME key on Monday and Tuesday — nothing but a rolling 24h timer separated
 * them. It worked only because `dailyPrewarm` happened to overwrite the entry
 * at 00:01 IST, the same moment the timer expired. A late or failed prewarm
 * meant users were served YESTERDAY's horoscope — which is exactly the
 * "daily they are showing the same" bug the client reported.
 *
 * With the day in the key, a new day is a DIFFERENT key: an automatic miss
 * and a fresh fetch. Correctness no longer depends on a cron being punctual.
 *
 * Two guards decide when a day scope applies, and both matter:
 *
 *  1. **Only when the request does not already pin a date.** A request for
 *     `/panchang/2026-09-05`, or a POST carrying `"datetime":"1990-05-15…"`,
 *     is already self-scoping. Stamping today's date on top would mint a new
 *     key every day for the same requested date — turning a permanent cache
 *     hit into a daily billed miss. That would make the bill WORSE, which is
 *     the opposite of the point.
 *
 *  2. **Only when the TTL is a day or less.** That is the signal we already
 *     use to say "this varies by day". Anything we chose to cache for 30
 *     days or a year (kundli, doshas, dasha, natal reports) is immutable by
 *     definition, and day-scoping it would re-bill it every 24 hours.
 *
 * IST because the whole product is India-first and `dailyPrewarm` already
 * runs on `Asia/Kolkata` — the two must agree on when "tomorrow" starts or
 * the prewarm would write a key nobody reads.
 */
export function dayScope(path: string, body: string, ttlSeconds: number): string {
  if (ttlSeconds > 60 * 60 * 24) return "";
  if (ISO_DATE.test(path) || ISO_DATE.test(body)) return "";
  return todayKeyIST();
}

export function cacheKey(
  method: string,
  path: string,
  query: string,
  body: string,
  scope = ""
): string {
  const raw = `${method} ${path}?${normalizeQuery(query)} ${body}${scope ? ` @${scope}` : ""}`;
  // FNV-1a: good enough to key a cache, and dependency-free.
  let h = 0x811c9dc5;
  for (let i = 0; i < raw.length; i++) {
    h ^= raw.charCodeAt(i);
    h = Math.imul(h, 0x01000193) >>> 0;
  }
  return `${h.toString(16)}_${raw.length}`;
}

/**
 * How long a single-flight lock is honoured before other callers may steal
 * it. Must comfortably exceed a normal Vedika round trip (a full kundli is
 * not fast) but stay well under the proxy's own 60s timeout, so a crashed
 * holder cannot wedge a key for the life of the function instance.
 */
const LOCK_TTL_MS = 25_000;

/** How long a waiter will poll for the winner's result before giving up. */
const LOCK_WAIT_MS = 12_000;
const LOCK_POLL_MS = 400;

/**
 * Tries to become the single caller allowed to fetch `key` from Vedika.
 *
 * BUILT 4 Sep 2026 at the client's request: *"preventing duplicate API calls
 * when multiple users request the same missing data simultaneously"*.
 *
 * ## The problem it solves
 *
 * Cache misses are correlated, not random. If `dailyPrewarm` fails, then at
 * 7am every user opening the app misses the SAME horoscope key at the same
 * moment — 200 users meant up to 200 identical billed calls for one answer.
 * The cache only helps AFTER the first response lands; until then there is
 * nothing to hit.
 *
 * ## Why a Firestore transaction
 *
 * Cloud Functions scale horizontally, so an in-process mutex would only
 * deduplicate within one instance. The lock has to live where every instance
 * can see it, and it has to be won atomically — two instances reading "no
 * lock" and both writing one would defeat the whole point. A transaction
 * gives us compare-and-set across instances.
 *
 * ## Failure behaviour: always favour the user
 *
 * Every failure path returns `true` (proceed to fetch). A lock is a COST
 * optimisation; it must never be the reason a user sees an error. If
 * Firestore is unavailable we spend a little extra money and serve the
 * request, rather than saving money and failing.
 */
export async function acquireFetchLock(
  db: FirebaseFirestore.Firestore,
  key: string
): Promise<boolean> {
  const ref = db.collection("vedikaLocks").doc(key);
  try {
    return await db.runTransaction(async (tx) => {
      const snap = await tx.get(ref);
      const heldUntil = snap.exists
        ? (snap.data()?.heldUntilMs as number | undefined)
        : undefined;
      // A lock past its expiry is stolen, not respected — otherwise a
      // function instance that died mid-fetch would block this key until
      // someone noticed.
      if (typeof heldUntil === "number" && heldUntil > Date.now()) return false;
      tx.set(ref, {
        heldUntilMs: Date.now() + LOCK_TTL_MS,
        // A released lock is deleted immediately, but a CRASHED holder
        // leaves its document behind — the expiry check above lets others
        // steal it, yet nothing ever removes it. This field lets the
        // Firestore TTL policy sweep those orphans. One hour, generously
        // past LOCK_TTL_MS, so a live lock is never deleted mid-use.
        expiresAt: new Date(Date.now() + 60 * 60 * 1000),
      });
      return true;
    });
  } catch (e) {
    console.warn("vedikaLocks: acquire failed, proceeding unlocked", e);
    return true;
  }
}

/** Releases a lock. Best-effort — an expiry already bounds the damage. */
export async function releaseFetchLock(
  db: FirebaseFirestore.Firestore,
  key: string
): Promise<void> {
  try {
    await db.collection("vedikaLocks").doc(key).delete();
  } catch (e) {
    console.warn("vedikaLocks: release failed (expiry will clear it)", e);
  }
}

/**
 * Waits for whoever holds the lock to publish a fresh cache entry.
 *
 * Returns the payload if it appears within [LOCK_WAIT_MS], else `null` — and
 * `null` means "go fetch it yourself". A waiter must NEVER block
 * indefinitely: if the winner crashed, everyone waiting on it would hang and
 * the user would see a timeout instead of their horoscope. Bounded waiting
 * degrades to the old behaviour (an extra billed call) rather than to a
 * broken screen.
 */
export async function awaitFreshEntry(
  db: FirebaseFirestore.Firestore,
  key: string,
  ttlSeconds: number
): Promise<unknown | null> {
  const deadline = Date.now() + LOCK_WAIT_MS;
  const ref = db.collection("vedikaCache").doc(key);
  while (Date.now() < deadline) {
    await new Promise((r) => setTimeout(r, LOCK_POLL_MS));
    try {
      const snap = await ref.get();
      if (!snap.exists) continue;
      const d = snap.data()!;
      const ageSeconds = (Date.now() - d.fetchedAtMs) / 1000;
      if (ageSeconds < ttlSeconds) return d.payload;
    } catch {
      // Ignore and keep polling until the deadline; a transient read failure
      // is not a reason to give up early.
    }
  }
  return null;
}
