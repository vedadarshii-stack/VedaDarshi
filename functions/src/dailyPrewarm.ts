import { onSchedule } from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";
import { VEDIKA_API_KEY, VEDIKA_BASE_URL, vedikaHeaders, todayKeyIST } from "./config";
import { cacheKey } from "./vedikaCache";

/**
 * THE BIG COST SAVER — AND, until 26 Aug 2026, A COMPLETE NO-OP.
 *
 * Panchang and daily/weekly/monthly horoscope are the SAME for every user
 * who shares a sign (horoscope) or a city (panchang) on a given day. Left
 * as-is, the live `vedika` proxy (index.ts) still saves repeat calls via
 * its own Firestore cache (`vedikaCache`) — but that cache is populated
 * lazily by whichever user happens to open the app first each day.
 *
 * This job pre-computes the day's content ONCE, proactively, at 12:01 AM
 * IST — before anyone in India is awake to open the app — and writes it
 * BOTH to `dailyHoroscopes`/`dailyPanchang` (informational, nothing in the
 * app reads these today — `grep -rn "dailyPanchang\|dailyHoroscopes"
 * mobile/lib` returns nothing) AND, as of 26 Aug 2026, directly into
 * `vedikaCache` under the EXACT key `index.ts`'s proxy would compute for
 * the same request — see `./vedikaCache`. That second write is the part
 * that actually saves money: it is what makes the first real user's
 * request of the day a Firestore HIT instead of a fresh, billed Vedika
 * call.
 *
 * **Until this fix, this job saved nothing.** It called Vedika directly
 * (bypassing `vedika`'s cache entirely, by design — see below) and wrote
 * only to the two collections nothing reads. Worse, the panchang half hit
 * `/v2/astrology/panchang/today`, a route the app stopped calling on
 * 21 Aug 2026 in favour of the bundle route `/v2/astrology/panchang` — so
 * those 10 calls/day were billed against a route the app cannot even
 * produce a matching cache key for any more. Fixed by calling the SAME
 * route+query shape `panchang_repository.dart` uses (see
 * `prewarmCityPanchang`) and by sourcing `PANCHANG_CITIES`' coordinates
 * from the app's own `cities.json` (see that constant's doc comment) —
 * hand-typed city-centre coordinates from a different source do not
 * round-trip to the same 4-decimal cache key the app's nearest-city
 * lookup will actually request.
 *
 * This file still talks to Vedika DIRECTLY rather than through the
 * `vedika` proxy's HTTP endpoint — it needs GET-only, unauthenticated-by-
 * user, fire-and-forget calls on a schedule, not a per-request HTTP relay
 * — but it now writes to the SAME Firestore collection and SAME key
 * derivation the proxy uses, so "direct" no longer means "invisible to
 * the cache".
 */

const ZODIAC_SIGNS = [
  "aries",
  "taurus",
  "gemini",
  "cancer",
  "leo",
  "virgo",
  "libra",
  "scorpio",
  "sagittarius",
  "capricorn",
  "aquarius",
  "pisces",
] as const;

/**
 * A small, DOCUMENTED list of major Indian cities to pre-warm panchang
 * for. Panchang is location-dependent (tithi/nakshatra timings shift with
 * latitude/longitude), so — unlike horoscopes — there is no single
 * "today's panchang" that is correct for every user. Pre-warming this
 * fixed list is therefore a PARTIAL win: users in one of these cities get
 * an instant Firestore read; everyone else still falls through to the
 * live `vedika` proxy and its own 6-hour cache (see index.ts), which
 * means their FIRST request of the (cache) window still costs a real
 * Vedika call. Do not present this as "panchang is solved for everyone" —
 * it is not, and cannot be, without either a much longer city list or a
 * geo-bucketing scheme this job does not attempt.
 *
 * Coordinates are city-centre lat/lon; India is one timezone
 * (Asia/Kolkata, UTC+05:30) everywhere in this list, so no per-city
 * timezone lookup is needed the way the Flutter app's `cities.json` needs
 * one for arbitrary world cities.
 */
interface PrewarmCity {
  slug: string;
  name: string;
  latitude: number;
  longitude: number;
}

/**
 * Coordinates are copied VERBATIM from `mobile/assets/data/cities.json`
 * (the GeoNames-derived dataset `AssetCityPlaceSearch().nearestCity()`
 * snaps a device fix onto) — NOT independently sourced city-centre values.
 *
 * This is load-bearing, not cosmetic: `cacheKey` rounds latitude/longitude
 * to 4 decimal places, so a pre-warmed entry is only ever found by a real
 * request if the two sides' coordinates agree to that precision. They
 * previously didn't — the original hand-typed values here differed from
 * `cities.json`'s entries by up to ~0.04° (Delhi: 28.6139,77.2090 here vs.
 * 28.6519,77.2315 in the dataset an actual Delhi user resolves to), so
 * even a perfect cache-key implementation would have warmed a key no user
 * could ever request. Re-derive with:
 *   `jq '.[] | select(.c=="IN" and (.n=="Delhi" or …)) | {n,la,lo}'
 *     mobile/assets/data/cities.json`
 * if this list ever changes.
 */
const PANCHANG_CITIES: PrewarmCity[] = [
  { slug: "delhi", name: "Delhi", latitude: 28.6519, longitude: 77.2315 },
  { slug: "mumbai", name: "Mumbai", latitude: 19.0728, longitude: 72.8826 },
  { slug: "bengaluru", name: "Bengaluru", latitude: 12.9719, longitude: 77.5937 },
  { slug: "chennai", name: "Chennai", latitude: 13.0878, longitude: 80.2785 },
  { slug: "kolkata", name: "Kolkata", latitude: 22.5626, longitude: 88.363 },
  { slug: "hyderabad", name: "Hyderabad", latitude: 17.384, longitude: 78.4564 },
  { slug: "pune", name: "Pune", latitude: 18.5196, longitude: 73.8554 },
  { slug: "ahmedabad", name: "Ahmedabad", latitude: 23.0258, longitude: 72.5873 },
  { slug: "jaipur", name: "Jaipur", latitude: 26.9196, longitude: 75.7878 },
  { slug: "lucknow", name: "Lucknow", latitude: 26.8393, longitude: 80.9231 },
];

/** India has one timezone; every city in PANCHANG_CITIES uses it. */
const INDIA_UTC_OFFSET = "+05:30";

interface VedikaFetchResult {
  ok: boolean;
  payload: unknown;
}

/**
 * Minimal, direct GET against Vedika (no caching layer here — this
 * function's whole job IS to populate the cache other code reads from).
 * Mirrors the success/failure classification in index.ts's proxy: a 200
 * with `success: false` in the envelope is still a FAILURE, and must
 * never be written as if it were good data — an INSUFFICIENT_BALANCE (or
 * any other error envelope) baked into the public pre-warmed collection
 * would be served to every user of that sign/city for the rest of the
 * day, which is strictly worse than the live proxy's per-request failure.
 */
async function fetchVedikaJson(
  path: string,
  query = ""
): Promise<VedikaFetchResult> {
  try {
    const res = await fetch(`${VEDIKA_BASE_URL.value()}${path}${query ? `?${query}` : ""}`, {
      method: "GET",
      headers: {
        ...vedikaHeaders(),
        Accept: "application/json",
      },
    });
    const text = await res.text();
    let payload: unknown;
    try {
      payload = JSON.parse(text);
    } catch {
      return { ok: false, payload: { code: "MALFORMED_UPSTREAM_JSON", raw: text } };
    }
    const ok =
      res.ok &&
      typeof payload === "object" &&
      payload !== null &&
      (payload as { success?: boolean }).success !== false;
    return { ok, payload };
  } catch (e) {
    return { ok: false, payload: { code: "UPSTREAM_UNREACHABLE", error: String(e) } };
  }
}

/**
 * Writes a successful Vedika response into `vedikaCache` under the EXACT
 * key `index.ts`'s proxy would compute for the same `(method, path, query,
 * body)` — see `./vedikaCache`. `fetchedAtMs`/`payload` match that file's
 * write shape byte-for-byte so a HIT read there cannot tell the difference
 * between a pre-warmed entry and one it wrote itself.
 *
 * This is the actual cost-saving step. Without it, everything above is
 * still just populating `dailyHoroscopes`/`dailyPanchang`, which nothing
 * in the app reads.
 */
async function warmVedikaCache(
  db: FirebaseFirestore.Firestore,
  method: string,
  path: string,
  query: string,
  body: string,
  payload: unknown
): Promise<void> {
  const key = cacheKey(method, path, query, body);
  try {
    await db
      .collection("vedikaCache")
      .doc(key)
      .set({ payload, fetchedAtMs: Date.now(), path });
  } catch (e) {
    // Same rule as everywhere else in this file: a cache-write failure
    // must never take down the rest of the run.
    console.error(`dailyPrewarm: vedikaCache write failed for key=${key} path=${path}`, e);
  }
}

/**
 * Pre-warms all three "same for everyone" horoscope periods for ONE sign.
 *
 * Each period (daily/weekly/monthly) is fetched and written INDEPENDENTLY
 * with its own explicit `<period>Status` flag, rather than folding a
 * failure silently into a document that otherwise looks complete. This is
 * what "never let a partial failure leave a half-written document that
 * reads as complete" means concretely here: a reader (the Flutter app)
 * must check `dailyStatus`/`weeklyStatus`/`monthlyStatus` before trusting
 * the corresponding field, never infer completeness from the document
 * merely existing.
 *
 * `merge: true` also makes this IDEMPOTENT under retries or a manual
 * re-run for the same day: re-fetching only touches the periods that were
 * actually re-fetched, and Vedika returns the same content for the same
 * day/sign, so writing it twice is a no-op in substance.
 *
 * There is deliberately NO yearly fetch — `/v2/astrology/horoscope/
 * {sign}/yearly` answers `success: true` wrapping an error payload on the
 * sandbox (see mobile/CLAUDE.md, "THREE REAL LIMITS OF THE SANDBOX") and
 * there is no working yearly endpoint to pre-warm.
 */
async function prewarmSignHoroscope(
  db: FirebaseFirestore.Firestore,
  dateKey: string,
  sign: string
): Promise<void> {
  const docRef = db.collection("dailyHoroscopes").doc(`${dateKey}_${sign}`);

  // Paths match `horoscope_repository.dart`'s `fetchDaily`/`fetchWeekly`/
  // `fetchMonthly` exactly (no query string, no body) — see that file —
  // so `warmVedikaCache` below writes the SAME key the app's own proxy
  // call will compute.
  const dailyPath = `/v2/astrology/horoscope/${sign}`;
  const weeklyPath = `/v2/astrology/horoscope/${sign}/weekly`;
  const monthlyPath = `/v2/astrology/horoscope/${sign}/monthly`;

  const [daily, weekly, monthly] = await Promise.all([
    fetchVedikaJson(dailyPath),
    fetchVedikaJson(weeklyPath),
    fetchVedikaJson(monthlyPath),
  ]);

  const update: Record<string, unknown> = {
    date: dateKey,
    sign,
    updatedAtMs: Date.now(),
  };

  if (daily.ok) {
    update.daily = daily.payload;
    update.dailyStatus = "ok";
    await warmVedikaCache(db, "GET", dailyPath, "", "", daily.payload);
  } else {
    update.dailyStatus = "failed";
    console.error(`dailyPrewarm: horoscope daily failed for sign=${sign}`, daily.payload);
  }

  if (weekly.ok) {
    update.weekly = weekly.payload;
    update.weeklyStatus = "ok";
    await warmVedikaCache(db, "GET", weeklyPath, "", "", weekly.payload);
  } else {
    update.weeklyStatus = "failed";
    console.error(`dailyPrewarm: horoscope weekly failed for sign=${sign}`, weekly.payload);
  }

  if (monthly.ok) {
    update.monthly = monthly.payload;
    update.monthlyStatus = "ok";
    await warmVedikaCache(db, "GET", monthlyPath, "", "", monthly.payload);
  } else {
    update.monthlyStatus = "failed";
    console.error(`dailyPrewarm: horoscope monthly failed for sign=${sign}`, monthly.payload);
  }

  try {
    await docRef.set(update, { merge: true });
  } catch (e) {
    // One sign's Firestore write failing must not throw out of this
    // function — the caller runs all 12 signs via Promise.allSettled
    // specifically so one bad apple never takes the other 11 down with it.
    console.error(`dailyPrewarm: Firestore write failed for sign=${sign}`, e);
  }
}

/**
 * Pre-warms today's panchang for ONE fixed city.
 *
 * FIXED 26 Aug 2026 — this used to call `/v2/astrology/panchang/today`
 * with only `latitude`/`longitude`/`timezone`. Two things were wrong with
 * that, both now corrected:
 *
 *  1. **Wrong route.** The app itself switched to the BUNDLE route
 *     `/v2/astrology/panchang` on 21 Aug 2026 (see
 *     `panchang_repository.dart`) for the sunrise/sunset/festival data it
 *     adds. A pre-warmed `/today` entry can never be found by a request
 *     for `/v2/astrology/panchang` — different path, different cache key,
 *     full price either way. This job now calls the exact same route.
 *  2. **Missing `datetime`.** Without it Vedika anchors to the SERVER's
 *     UTC "now", which is a DIFFERENT calendar day from IST between
 *     00:00–05:30 — exactly the failure `panchang_repository.dart`
 *     documents fixing on the app side. `datetime` is now local noon on
 *     `dateKey`, built the identical way `_localNoonIso` does.
 *
 * Query params (`datetime`, `latitude`, `longitude`, `timezone`,
 * `include`) match `panchang_repository.dart`'s `fetch()` byte-for-byte in
 * VALUE (param order no longer matters — `cacheKey` sorts them, see
 * `./vedikaCache`), which is what lets `warmVedikaCache` below place this
 * under the exact key a real user's request for the same city+day will
 * compute.
 */
async function prewarmCityPanchang(
  db: FirebaseFirestore.Firestore,
  dateKey: string,
  city: PrewarmCity
): Promise<void> {
  const docRef = db.collection("dailyPanchang").doc(`${dateKey}_${city.slug}`);

  const path = "/v2/astrology/panchang";
  const query = new URLSearchParams({
    datetime: `${dateKey}T12:00:00`,
    latitude: String(city.latitude),
    longitude: String(city.longitude),
    timezone: INDIA_UTC_OFFSET,
    include: "sunrise,festivals",
  }).toString();

  const result = await fetchVedikaJson(path, query);

  if (result.ok) {
    await warmVedikaCache(db, "GET", path, query, "", result.payload);
  }

  try {
    if (result.ok) {
      await docRef.set(
        {
          date: dateKey,
          city: city.slug,
          cityName: city.name,
          latitude: city.latitude,
          longitude: city.longitude,
          panchang: result.payload,
          status: "ok",
          updatedAtMs: Date.now(),
        },
        { merge: true }
      );
    } else {
      // Deliberately do NOT overwrite a previously-good `panchang` field
      // with nothing — `merge: true` + omitting the field leaves any
      // earlier successful payload in place (stale-but-real beats
      // missing), while `status: "failed"` still makes the failure
      // visible to anything monitoring this collection.
      console.error(`dailyPrewarm: panchang failed for city=${city.slug}`, result.payload);
      await docRef.set(
        { date: dateKey, city: city.slug, cityName: city.name, status: "failed", updatedAtMs: Date.now() },
        { merge: true }
      );
    }
  } catch (e) {
    console.error(`dailyPrewarm: Firestore write failed for panchang city=${city.slug}`, e);
  }
}

/**
 * Runs at 12:01 AM Asia/Kolkata, every day.
 *
 * `retryCount: 2` covers a transient Cloud Scheduler/infra hiccup
 * triggering the WHOLE function; per-sign/per-city resilience within a
 * single run is handled by `Promise.allSettled` below, not by the
 * platform retry. Re-running this on the same IST day (whether via
 * `retryCount` or a manual trigger) is safe: every write is
 * `doc(dateKey_key).set(..., {merge:true})`, so it converges to the same
 * result rather than duplicating or corrupting anything.
 */
export const dailyPrewarm = onSchedule(
  {
    schedule: "1 0 * * *",
    timeZone: "Asia/Kolkata",
    region: "asia-south1",
    secrets: [VEDIKA_API_KEY],
    timeoutSeconds: 300,
    memory: "256MiB",
    retryCount: 2,
  },
  async () => {
    const db = admin.firestore();
    const dateKey = todayKeyIST();

    // 12 signs × 3 periods = 36 Vedika calls, ONCE, for every user of the
    // app that day — see the cost comment at the top of this file.
    const horoscopeResults = await Promise.allSettled(
      ZODIAC_SIGNS.map((sign) => prewarmSignHoroscope(db, dateKey, sign))
    );

    // A fixed, partial set of cities — see PANCHANG_CITIES' doc comment
    // for why this can never be "everyone", unlike the horoscope job above.
    const panchangResults = await Promise.allSettled(
      PANCHANG_CITIES.map((city) => prewarmCityPanchang(db, dateKey, city))
    );

    const horoscopeFailures = horoscopeResults.filter((r) => r.status === "rejected").length;
    const panchangFailures = panchangResults.filter((r) => r.status === "rejected").length;
    if (horoscopeFailures > 0 || panchangFailures > 0) {
      // Promise.allSettled already means a rejection here is unexpected —
      // prewarmSignHoroscope/prewarmCityPanchang both catch their own
      // errors internally. Reaching this branch means something threw
      // outside those try/catches, which is worth a loud log even though
      // it does not fail the scheduled invocation as a whole.
      console.error(
        `dailyPrewarm: ${horoscopeFailures} sign(s) and ${panchangFailures} cit(ies) had unexpected top-level failures for ${dateKey}`
      );
    }

    console.log(
      `dailyPrewarm: completed for ${dateKey} — ${ZODIAC_SIGNS.length} signs, ${PANCHANG_CITIES.length} cities`
    );
  }
);
