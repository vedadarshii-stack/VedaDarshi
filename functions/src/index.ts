import { onRequest } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import { VEDIKA_API_KEY, VEDIKA_BASE } from "./config";

admin.initializeApp();
const db = admin.firestore();

// Re-exported so `firebase deploy --only functions` (single codebase, see
// firebase.json) picks up every function from one entry point.
export { dailyPrewarm } from "./dailyPrewarm";
export { askAiAstrologer } from "./aiCredits";

/**
 * The paid Vedika API key is imported from ./config (see that file for
 * why it must be a single shared `defineSecret` binding) rather than
 * declared here. This is the entire reason this proxy exists: Vedika
 * bills per call ($0.012–0.048), so a key shipped inside the APK — which
 * is plain text to anyone who unzips it — would let a stranger spend the
 * client's balance.
 */

/**
 * How long a cached response stays fresh, by endpoint family.
 *
 * These are what keep the bill down. Panchang and horoscope are identical
 * for every user in a location/sign for a whole day, so without caching we
 * would pay per user per screen-open instead of once per day. A natal chart
 * (kundli) and a guna-milan match never change at all for the same inputs,
 * so they are cached effectively forever.
 */
function cacheTtlSeconds(path: string): number {
  if (path.includes("/panchang") || path.includes("/daily/")) return 60 * 60 * 6;
  if (path.includes("/horoscope")) return 60 * 60 * 6;
  if (path.includes("/kundli") || path.includes("/planet-positions")) {
    return 60 * 60 * 24 * 365;
  }
  if (path.includes("guna-milan") || path.includes("matching")) {
    return 60 * 60 * 24 * 365;
  }
  return 60 * 60; // conservative default
}

/** Firestore document ids may not contain "/" — hash the request instead. */
function cacheKey(method: string, path: string, query: string, body: string) {
  const raw = `${method} ${path}?${query} ${body}`;
  // FNV-1a: good enough to key a cache, and dependency-free.
  let h = 0x811c9dc5;
  for (let i = 0; i < raw.length; i++) {
    h ^= raw.charCodeAt(i);
    h = Math.imul(h, 0x01000193) >>> 0;
  }
  return `${h.toString(16)}_${raw.length}`;
}

/**
 * Transparent proxy for the Vedika Intelligence API.
 *
 * The Flutter app points `VEDIKA_BASE_URL` at this function and otherwise
 * changes nothing: paths, query strings, bodies and the response envelope
 * all pass straight through, so `/v2/astrology/panchang/today` here behaves
 * exactly as it does against `https://api.vedika.io/sandbox/...`. That is
 * what makes going live a one-line `.env` change on the client.
 *
 * What it adds on top: the API key, a Firestore response cache, and a
 * refusal to forward anything that is not a read-only astrology call.
 */
export const vedika = onRequest(
  {
    region: "asia-south1",
    secrets: [VEDIKA_API_KEY],
    cors: true,
    // Vedika computes ephemeris server-side; a full kundli is not fast.
    timeoutSeconds: 60,
    memory: "256MiB",
  },
  async (req, res) => {
    const path = req.path;

    // Only the astrology surface the app actually uses. Without this the
    // function would be an open, authenticated relay to every paid endpoint
    // on the account for anyone who found its URL.
    if (!path.startsWith("/v2/") && !path.startsWith("/api/")) {
      res.status(404).json({
        success: false,
        code: "NOT_PROXIED",
        error: "Only /v2/* and /api/* Vedika paths are proxied.",
      });
      return;
    }

    if (req.method !== "GET" && req.method !== "POST") {
      res.status(405).json({
        success: false,
        code: "METHOD_NOT_ALLOWED",
        error: "Only GET and POST are proxied.",
      });
      return;
    }

    const query = new URLSearchParams(
      req.query as Record<string, string>
    ).toString();
    const bodyText =
      req.method === "POST" ? JSON.stringify(req.body ?? {}) : "";

    const key = cacheKey(req.method, path, query, bodyText);
    const ttl = cacheTtlSeconds(path);
    const docRef = db.collection("vedikaCache").doc(key);

    try {
      const cached = await docRef.get();
      if (cached.exists) {
        const d = cached.data()!;
        const ageSeconds = (Date.now() - d.fetchedAtMs) / 1000;
        if (ageSeconds < ttl) {
          res.set("X-Vedika-Cache", "HIT");
          res.status(200).json(d.payload);
          return;
        }
      }
    } catch (e) {
      // A cache read failure must never fail the request — fall through and
      // hit Vedika directly.
      console.warn("vedikaCache read failed", e);
    }

    let upstream: Response;
    try {
      upstream = await fetch(
        `${VEDIKA_BASE}${path}${query ? `?${query}` : ""}`,
        {
          method: req.method,
          headers: {
            "X-API-Key": VEDIKA_API_KEY.value(),
            Accept: "application/json",
            ...(req.method === "POST"
              ? { "Content-Type": "application/json" }
              : {}),
          },
          ...(req.method === "POST" ? { body: bodyText } : {}),
        }
      );
    } catch (e) {
      console.error("vedika upstream unreachable", e);
      res.status(502).json({
        success: false,
        code: "UPSTREAM_UNREACHABLE",
        error: "Could not reach Vedika.",
      });
      return;
    }

    const text = await upstream.text();
    let payload: unknown;
    try {
      payload = JSON.parse(text);
    } catch {
      res.status(502).json({
        success: false,
        code: "MALFORMED_UPSTREAM",
        error: "Vedika returned a non-JSON body.",
      });
      return;
    }

    // Only cache successes. Caching a failure would pin an error in place
    // for the whole TTL — and an INSUFFICIENT_BALANCE cached for a year
    // would outlive the top-up that fixed it.
    const ok =
      upstream.ok &&
      typeof payload === "object" &&
      payload !== null &&
      (payload as { success?: boolean }).success !== false;

    if (ok) {
      docRef
        .set({ payload, fetchedAtMs: Date.now(), path })
        .catch((e) => console.warn("vedikaCache write failed", e));
    }

    res.set("X-Vedika-Cache", "MISS");
    res.status(upstream.status).json(payload);
  }
);
