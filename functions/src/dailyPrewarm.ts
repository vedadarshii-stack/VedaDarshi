import { onSchedule } from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";
import { VEDIKA_API_KEY, VEDIKA_BASE, todayKeyIST } from "./config";

/**
 * THE BIG COST SAVER.
 *
 * Panchang and daily/weekly/monthly horoscope are the SAME for every user
 * who shares a sign (horoscope) or a city (panchang) on a given day. Left
 * as-is, the live `vedika` proxy (index.ts) still saves repeat calls via
 * its own Firestore cache — but that cache is populated lazily by
 * whichever user happens to open the app first each day, and its TTL
 * (6h for these families, see `cacheTtlSeconds` in index.ts) means it
 * re-fetches from Vedika several times a day even for a single sign/city.
 *
 * This job instead pre-computes the day's content ONCE, proactively, at
 * 12:01 AM IST — before anyone in India is awake to open the app — and
 * writes it to a collection every signed-in user can read directly from
 * Firestore. That turns "N users × M app-opens × Vedika calls" into a
 * fixed, small number of Vedika calls per day, independent of traffic.
 *
 * This file talks to Vedika DIRECTLY (not through the `vedika` proxy
 * function) because it needs GET-only, unauthenticated-by-user, fire-and-
 * forget calls on a schedule, not a per-request HTTP relay.
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

const PANCHANG_CITIES: PrewarmCity[] = [
  { slug: "delhi", name: "Delhi", latitude: 28.6139, longitude: 77.209 },
  { slug: "mumbai", name: "Mumbai", latitude: 19.076, longitude: 72.8777 },
  { slug: "bengaluru", name: "Bengaluru", latitude: 12.9716, longitude: 77.5946 },
  { slug: "chennai", name: "Chennai", latitude: 13.0827, longitude: 80.2707 },
  { slug: "kolkata", name: "Kolkata", latitude: 22.5726, longitude: 88.3639 },
  { slug: "hyderabad", name: "Hyderabad", latitude: 17.385, longitude: 78.4867 },
  { slug: "pune", name: "Pune", latitude: 18.5204, longitude: 73.8567 },
  { slug: "ahmedabad", name: "Ahmedabad", latitude: 23.0225, longitude: 72.5714 },
  { slug: "jaipur", name: "Jaipur", latitude: 26.9124, longitude: 75.7873 },
  { slug: "lucknow", name: "Lucknow", latitude: 26.8467, longitude: 80.9462 },
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
    const res = await fetch(`${VEDIKA_BASE}${path}${query ? `?${query}` : ""}`, {
      method: "GET",
      headers: {
        "X-API-Key": VEDIKA_API_KEY.value(),
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

  const [daily, weekly, monthly] = await Promise.all([
    fetchVedikaJson(`/v2/astrology/horoscope/${sign}`),
    fetchVedikaJson(`/v2/astrology/horoscope/${sign}/weekly`),
    fetchVedikaJson(`/v2/astrology/horoscope/${sign}/monthly`),
  ]);

  const update: Record<string, unknown> = {
    date: dateKey,
    sign,
    updatedAtMs: Date.now(),
  };

  if (daily.ok) {
    update.daily = daily.payload;
    update.dailyStatus = "ok";
  } else {
    update.dailyStatus = "failed";
    console.error(`dailyPrewarm: horoscope daily failed for sign=${sign}`, daily.payload);
  }

  if (weekly.ok) {
    update.weekly = weekly.payload;
    update.weeklyStatus = "ok";
  } else {
    update.weeklyStatus = "failed";
    console.error(`dailyPrewarm: horoscope weekly failed for sign=${sign}`, weekly.payload);
  }

  if (monthly.ok) {
    update.monthly = monthly.payload;
    update.monthlyStatus = "ok";
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
 * QUERY PARAM CAVEAT: the Vedika contract excerpt this codebase has been
 * built against (see mobile/CLAUDE.md) documents
 * `/v2/astrology/panchang/today` without spelling out its query
 * parameters, because every other caller so far has only ever needed
 * "today, wherever the requesting client's device is" via the live proxy.
 * For a server-side pre-warm we must name a city explicitly, so this
 * sends `latitude`/`longitude`/`timezone` — the same field names Vedika
 * uses in every POST body elsewhere in this API (kundli, guna-milan).
 * **This has not been independently re-verified against a fresh
 * openapi.json dump for the panchang endpoint specifically.** Before
 * trusting this in production: run it once, fetch two different cities'
 * documents from `dailyPanchang`, and confirm the tithi/nakshatra data
 * genuinely differs between e.g. Delhi and Chennai — if Vedika ignores
 * these params and returns one fixed answer, every city document will be
 * identical, which would mean this needs the correct param names instead.
 */
async function prewarmCityPanchang(
  db: FirebaseFirestore.Firestore,
  dateKey: string,
  city: PrewarmCity
): Promise<void> {
  const docRef = db.collection("dailyPanchang").doc(`${dateKey}_${city.slug}`);

  const query = new URLSearchParams({
    latitude: String(city.latitude),
    longitude: String(city.longitude),
    timezone: INDIA_UTC_OFFSET,
  }).toString();

  const result = await fetchVedikaJson("/v2/astrology/panchang/today", query);

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
