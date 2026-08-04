import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import { VEDIKA_API_KEY, VEDIKA_BASE, todayKeyIST } from "./config";

/**
 * CREDIT PROTECTION — the rule this whole file exists to enforce:
 *
 *   AI credits are deducted ONLY after a successful 200 OK from Vedika.
 *   On timeout/failure, the user's balance is left EXACTLY as it was.
 *
 * That rule alone is not enough to be safe under concurrency: if "check
 * remaining credits" and "deduct one" are two separate steps, a double-
 * tapped Send button can fire two requests that both read "1 credit left"
 * before either has deducted anything, and both proceed. The fix is the
 * classic reserve → call → commit-or-release pattern, with the
 * check-and-reserve step done INSIDE a single Firestore transaction:
 *
 *   1. RESERVE (transaction): read today's usage doc, verify
 *      used + pending < limit, and if so increment `pending` by 1 — all
 *      inside one transaction, so a concurrent second reservation is
 *      forced to re-read the just-updated `pending` and correctly sees no
 *      room left, rather than racing against a stale read.
 *   2. CALL Vedika's AI endpoint (outside the transaction — network calls
 *      inside a Firestore transaction are an anti-pattern: transactions
 *      retry on contention, which would mean re-firing the network call).
 *   3a. On success: COMMIT — pending -1, used +1.
 *   3b. On failure/timeout: RELEASE — pending -1, used unchanged.
 *
 * THIS IS SCAFFOLDING. The transactional reserve/commit/release logic
 * below is real and safe to build on. The actual Vedika AI call is NOT —
 * see the TODO inside `callVedikaAi`. mobile/CLAUDE.md records that the
 * AI backend choice (OpenAI vs Vedika's chart-grounded endpoint) is still
 * an open decision, and that Vedika's `/api/*` tree is production-only
 * (404s on the sandbox everything else in this codebase has been built
 * and tested against). Per instructions, this file must NOT fabricate an
 * AI response to paper over that gap — an unwired call fails closed
 * (credit released, error returned), same as a genuine Vedika outage
 * would, rather than inventing astrology advice.
 */

interface AiUsageDoc {
  limit: number;
  used: number;
  pending: number;
  updatedAtMs: number;
}

/**
 * Free tier: 1 AI question/day (Access Control Matrix, mobile/CLAUDE.md).
 * Used as the fallback limit for every user until the TODO below is
 * resolved — deliberately CONSERVATIVE (undercounts paid users rather
 * than risking overcounting), because undercounting only produces a
 * wrongly-early "limit reached" message, while overcounting would let
 * free users burn a paid user's quota logic path.
 */
const DEFAULT_FREE_DAILY_AI_LIMIT = 1;

function usageDocRef(uid: string, dateKey: string) {
  return admin
    .firestore()
    .collection("users")
    .doc(uid)
    .collection("aiUsage")
    .doc(dateKey);
}

/**
 * Resolves how many AI questions this user gets today.
 *
 * TODO(entitlements): should come from the user's RevenueCat entitlement
 * — Bronze=2, Silver=4, Gold=7, Platinum=10 per the Access Control Matrix
 * in mobile/CLAUDE.md — most likely synced onto /users/{uid} by a
 * RevenueCat webhook (a trusted SERVER process), not read from RevenueCat
 * on every call. Whatever field ends up holding that tier, it MUST be
 * writable only by the Admin SDK / a verified webhook handler, never by
 * the client — mobile/CLAUDE.md is explicit that "[RevenueCat]
 * entitlement ... is NEVER mirrored into a Firestore field the client can
 * write". `aiDailyCreditLimitOverride` below is a placeholder for exactly
 * that future field; the Firestore rule for /users/{uid} already lets the
 * client write to its OWN document, so if this field is added for real,
 * the rules must be tightened to carve it out (e.g. via a
 * request.resource.data.diff() check) the same way this file's aiUsage
 * subcollection rule below carves that out.
 */
async function resolveDailyLimit(uid: string): Promise<number> {
  const snap = await admin.firestore().collection("users").doc(uid).get();
  const override = snap.data()?.aiDailyCreditLimitOverride;
  if (typeof override === "number" && override > 0) {
    return override;
  }
  return DEFAULT_FREE_DAILY_AI_LIMIT;
}

/**
 * Step 1: RESERVE. Throws `resource-exhausted` if there is no room left
 * today. Never touches `used` — only `pending`, so a call that never
 * reaches step 3 (commit/release) at all — e.g. the whole function crashes
 * — is visible as a stuck `pending` count rather than silently vanishing,
 * and can be swept by an operator/cron later if that is ever observed.
 */
async function reserveCredit(uid: string, dateKey: string): Promise<void> {
  const limit = await resolveDailyLimit(uid);
  const docRef = usageDocRef(uid, dateKey);

  await admin.firestore().runTransaction(async (tx) => {
    const snap = await tx.get(docRef);
    const data = snap.data() as Partial<AiUsageDoc> | undefined;
    const used = data?.used ?? 0;
    const pending = data?.pending ?? 0;

    // The read-check-write all happen inside this one transaction, so two
    // concurrent reservations can never both observe "room available" —
    // Firestore aborts and retries whichever one loses the race, and the
    // retry re-reads the other's already-incremented `pending`.
    if (used + pending >= limit) {
      throw new HttpsError(
        "resource-exhausted",
        `Daily AI credit limit (${limit}) reached.`
      );
    }

    tx.set(
      docRef,
      { limit, used, pending: pending + 1, updatedAtMs: Date.now() },
      { merge: true }
    );
  });
}

/** Step 3a: COMMIT. Only reached after a genuine 200 OK from Vedika. */
async function commitCredit(uid: string, dateKey: string): Promise<void> {
  const docRef = usageDocRef(uid, dateKey);
  await admin.firestore().runTransaction(async (tx) => {
    const snap = await tx.get(docRef);
    const data = (snap.data() ?? {}) as Partial<AiUsageDoc>;
    const pending = Math.max(0, (data.pending ?? 0) - 1);
    const used = (data.used ?? 0) + 1;
    tx.set(docRef, { pending, used, updatedAtMs: Date.now() }, { merge: true });
  });
}

/**
 * Step 3b: RELEASE. `used` is deliberately untouched — this is the whole
 * point of the pattern: a failed or timed-out call must leave the user's
 * balance exactly where it was before they tapped Send.
 */
async function releaseCredit(uid: string, dateKey: string): Promise<void> {
  const docRef = usageDocRef(uid, dateKey);
  await admin.firestore().runTransaction(async (tx) => {
    const snap = await tx.get(docRef);
    const data = (snap.data() ?? {}) as Partial<AiUsageDoc>;
    const pending = Math.max(0, (data.pending ?? 0) - 1);
    tx.set(docRef, { pending, updatedAtMs: Date.now() }, { merge: true });
  });
}

interface VedikaAiResult {
  ok: boolean;
  payload: unknown;
}

/**
 * Step 2: the actual Vedika call. THIS IS THE UNWIRED PART.
 *
 * The path/body below is a best-effort placeholder built from the
 * `/api/v1/astrology/query` name recorded in mobile/CLAUDE.md — it has
 * NOT been exercised against production (the sandbox 404s the entire
 * `/api/*` tree, so it cannot be verified from here). Before this can
 * carry real traffic:
 *   1. Confirm the AI backend decision (OpenAI vs Vedika chart-grounded).
 *   2. If Vedika: get the real request schema (birth chart params,
 *      message, language) and response envelope from a production call,
 *      and update this function to match.
 *   3. If OpenAI: replace this fetch entirely with an OpenAI call behind
 *      its own server-side key (same "never in the client" rule as
 *      VEDIKA_API_KEY), keeping the reserve/commit/release calls in
 *      `askAiAstrologer` below unchanged — they don't care which backend
 *      answered, only whether it succeeded.
 * Until then, this deliberately fails closed (returns ok:false) on
 * anything other than a genuine 200, which is the CORRECT behavior for
 * unfinished scaffolding — it must never fabricate a reply.
 */
async function callVedikaAi(message: string): Promise<VedikaAiResult> {
  try {
    const res = await fetch(`${VEDIKA_BASE}/api/v1/astrology/query`, {
      method: "POST",
      headers: {
        "X-API-Key": VEDIKA_API_KEY.value(),
        "Content-Type": "application/json",
        Accept: "application/json",
      },
      body: JSON.stringify({
        // TODO(ai-backend): real body — birth chart params + message +
        // language hint. See the function doc comment above.
        message,
      }),
    });
    const payload = await res.json().catch(() => null);
    const ok =
      res.ok &&
      typeof payload === "object" &&
      payload !== null &&
      (payload as { success?: boolean }).success !== false;
    return { ok, payload };
  } catch (e) {
    console.error("callVedikaAi: request threw", e);
    return { ok: false, payload: { code: "UPSTREAM_UNREACHABLE", error: String(e) } };
  }
}

/**
 * Callable entry point for an AI Astrologer question.
 *
 * Enforces the credit-protection rule end to end: reserve → call →
 * commit-or-release. `timeoutSeconds: 120` matches mobile/CLAUDE.md's
 * note that "AI latency can reach ~1–2 min for insights" — a shorter
 * function timeout would turn every slow-but-eventually-successful
 * Vedika response into a spurious release-and-fail.
 */
export const askAiAstrologer = onCall(
  {
    region: "asia-south1",
    secrets: [VEDIKA_API_KEY],
    timeoutSeconds: 120,
  },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "Sign in required.");
    }

    const message =
      typeof request.data?.message === "string" ? request.data.message : "";
    if (!message.trim()) {
      throw new HttpsError("invalid-argument", "message is required.");
    }

    const dateKey = todayKeyIST();

    // ---- 1. RESERVE ----------------------------------------------------
    // Throws resource-exhausted (and touches nothing else) if the daily
    // limit is already used up — no reservation is made in that case, so
    // there is nothing to release.
    await reserveCredit(uid, dateKey);

    // ---- 2. CALL, then 3. COMMIT-OR-RELEASE ----------------------------
    // Wrapped so that ANY failure between the reserve above and the
    // commit below — a bad Vedika response, a thrown error, even a bug in
    // this function itself — still runs the release path. The credit
    // must never be left silently deducted (as `pending`, which is
    // functionally the same as `used` from the "can I still ask?"
    // perspective) with no corresponding success.
    try {
      const result = await callVedikaAi(message);
      if (!result.ok) {
        throw new HttpsError(
          "unavailable",
          "The AI astrologer is not available right now."
        );
      }

      await commitCredit(uid, dateKey);
      return { success: true, data: result.payload };
    } catch (e) {
      await releaseCredit(uid, dateKey).catch((releaseErr) => {
        // If even the release fails, the user is left with a reserved
        // slot they didn't get to use and no automatic recovery — log it
        // LOUDLY rather than let it disappear into a normal error log,
        // since this is the one failure mode the whole design is meant
        // to prevent.
        console.error(
          "askAiAstrologer: CRITICAL — failed to release reserved credit",
          { uid, dateKey },
          releaseErr
        );
      });

      if (e instanceof HttpsError) {
        throw e;
      }
      console.error("askAiAstrologer: unexpected failure", e);
      throw new HttpsError(
        "unavailable",
        "The AI astrologer is not available right now. Your credit was not used."
      );
    }
  }
);
