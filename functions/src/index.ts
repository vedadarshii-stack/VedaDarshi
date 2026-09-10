import { onRequest } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import { VEDIKA_API_KEY, VEDIKA_BASE_URL, vedikaHeaders } from "./config";
import { rebrand } from "./rebrand";
import {
  acquireFetchLock,
  awaitFreshEntry,
  cacheKey,
  cacheTtlSeconds,
  dayScope,
  releaseFetchLock,
} from "./vedikaCache";

admin.initializeApp();
const db = admin.firestore();

// Re-exported so `firebase deploy --only functions` (single codebase, see
// firebase.json) picks up every function from one entry point.
export { dailyPrewarm } from "./dailyPrewarm";
export { askAiAstrologer } from "./aiCredits";
export { deleteAccount } from "./deleteAccount";
export { revenueCatWebhook } from "./revenueCatWebhook";
export {
  adminVedikaUsage,
  adminListUsers,
  adminSendNotification,
  adminDashboardStats,
} from "./adminApi";

/**
 * The paid Vedika API key is imported from ./config (see that file for
 * why it must be a single shared `defineSecret` binding) rather than
 * declared here. This is the entire reason this proxy exists: Vedika
 * bills per call ($0.012–0.048), so a key shipped inside the APK — which
 * is plain text to anyone who unzips it — would let a stranger spend the
 * client's balance.
 */

// `cacheKey`/`cacheTtlSeconds` now live in ./vedikaCache — shared with
// dailyPrewarm.ts so a pre-warmed entry and a real request always compute
// the SAME key. See that file's doc comment for the incident this fixes.

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

    const ttl = cacheTtlSeconds(path, bodyText);
    // The calendar day is part of the key for day-varying routes, so a new
    // day cannot be served yesterday's answer. See `dayScope`.
    const key = cacheKey(
      req.method,
      path,
      query,
      bodyText,
      dayScope(path, bodyText, ttl)
    );
    const docRef = db.collection("vedikaCache").doc(key);

    try {
      const cached = await docRef.get();
      if (cached.exists) {
        const d = cached.data()!;
        const ageSeconds = (Date.now() - d.fetchedAtMs) / 1000;
        if (ageSeconds < ttl) {
          res.set("X-Vedika-Cache", "HIT");
          res.set("X-Cache", "HIT");
          res.status(200).json(d.payload);
          return;
        }
      }
    } catch (e) {
      // A cache read failure must never fail the request — fall through and
      // hit Vedika directly.
      console.warn("vedikaCache read failed", e);
    }

    // ---- SINGLE FLIGHT ---------------------------------------------------
    // Misses are correlated: if the prewarm failed, every user opening the
    // app at 7am misses the SAME key at once. Without this, that is one
    // billed Vedika call per user for a single answer. See
    // `acquireFetchLock`.
    const holdsLock = await acquireFetchLock(db, key);
    if (!holdsLock) {
      const shared = await awaitFreshEntry(db, key, ttl);
      if (shared !== null) {
        // Someone else paid for this while we waited.
        res.set("X-Vedika-Cache", "HIT-SHARED");
        res.set("X-Cache", "HIT");
        res.status(200).json(shared);
        return;
      }
      // The winner crashed or is slow. Fall through and fetch it ourselves —
      // an extra call is always better than a hung request.
    }

    let upstream: Response;
    try {
      upstream = await fetch(
        `${VEDIKA_BASE_URL.value()}${path}${query ? `?${query}` : ""}`,
        {
          method: req.method,
          headers: {
            ...vedikaHeaders(),
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
      if (holdsLock) await releaseFetchLock(db, key);
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
      // Rebranded BEFORE the cache write below, so a cached answer carries
      // the corrected text too — otherwise a year-long cached report would
      // keep serving the vendor's name long after this shipped.
      payload = rebrand(JSON.parse(text));
    } catch {
      if (holdsLock) await releaseFetchLock(db, key);
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
      // AWAITED, unlike before: the lock is released immediately after, and
      // releasing before the entry is visible would let every waiter fall
      // through and re-fetch — exactly the stampede this is meant to stop.
      try {
        await docRef.set({
          payload,
          fetchedAtMs: Date.now(),
          path,
          // Drives the Firestore TTL policy on `vedikaCache` — see
          // firestore.indexes.json. Without a field to key it on, this
          // collection grows forever: 1-year natal entries are never
          // otherwise deleted. Stamped a day PAST the logical TTL so a
          // still-valid entry is never swept out from under a reader.
          expiresAt: new Date(Date.now() + (ttl + 86400) * 1000),
        });
      } catch (e) {
        console.warn("vedikaCache write failed", e);
      }
    }
    if (holdsLock) await releaseFetchLock(db, key);

    res.set("X-Vedika-Cache", "MISS");
    res.set("X-Cache", "MISS");
    res.status(upstream.status).json(payload);
  }
);
