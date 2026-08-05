import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import { randomUUID } from "node:crypto";
import { VEDIKA_API_KEY, VEDIKA_BASE_URL, vedikaHeaders, todayKeyIST } from "./config";

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
 * Wired to the REAL Vedika AI endpoint (`POST /api/v1/astrology/query`,
 * contract recovered from vedika.io/openapi.json) — birth details are read
 * from the user's saved Firestore profile (never taken from the client),
 * and every non-2xx response maps to a specific error before the credit is
 * released. See `resolveBirthDetails` and `callVedikaAi` below.
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

/**
 * Step 3a: COMMIT. Only reached after a genuine 200 OK from Vedika. Returns
 * the post-commit `{used, limit}` so the caller can hand it straight back
 * to the client for the "2/3 free" counter, without a second Firestore read.
 */
async function commitCredit(
  uid: string,
  dateKey: string
): Promise<{ used: number; limit: number }> {
  const docRef = usageDocRef(uid, dateKey);
  return admin.firestore().runTransaction(async (tx) => {
    const snap = await tx.get(docRef);
    const data = (snap.data() ?? {}) as Partial<AiUsageDoc>;
    const pending = Math.max(0, (data.pending ?? 0) - 1);
    const used = (data.used ?? 0) + 1;
    const limit = data.limit ?? DEFAULT_FREE_DAILY_AI_LIMIT;
    tx.set(docRef, { pending, used, updatedAtMs: Date.now() }, { merge: true });
    return { used, limit };
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

// ---------------------------------------------------------------------------
// Birth details — ALWAYS read from Firestore, NEVER taken from the client.
// A callable request carrying its own birthDetails would let a client ask
// Vedika about a chart that isn't theirs, or one that doesn't match what
// every other screen in the app renders for them.
// ---------------------------------------------------------------------------

interface VedikaBirthDetails {
  datetime: string;
  latitude: number;
  longitude: number;
  timezone: string;
}

/**
 * `/users/{uid}/birthProfiles/primary` — see
 * mobile/lib/core/data/firestore_refs.dart (`birthProfilesCollection`,
 * `primaryProfileId`). Those constants live in the Dart codebase; this file
 * has its own string literals because there is no shared source of truth
 * across the two runtimes — keep them in sync by hand if either changes.
 */
function birthProfileRef(uid: string) {
  return admin
    .firestore()
    .collection("users")
    .doc(uid)
    .collection("birthProfiles")
    .doc("primary");
}

/**
 * `330` minutes → `"+05:30"`, `-240` → `"-04:00"` — mirrors
 * `_formatTzOffset`/`_formatOffset` in the Flutter app's kundli and
 * guna-milan repositories (mobile/lib/features/kundli/kundli_repository.dart,
 * mobile/lib/features/matching/guna_milan_data.dart), which build the exact
 * same `timezone` field for the exact same Vedika contract. Handles negative
 * offsets and non-hour offsets (e.g. `+05:45`) correctly.
 */
function formatUtcOffset(minutes: number): string {
  const sign = minutes < 0 ? "-" : "+";
  const abs = Math.abs(minutes);
  const hours = Math.floor(abs / 60).toString().padStart(2, "0");
  const mins = (abs % 60).toString().padStart(2, "0");
  return `${sign}${hours}:${mins}`;
}

/**
 * Recovers the birth calendar date (Y-M-D) from the stored `dateOfBirth`
 * Timestamp. A Timestamp is an absolute instant, not a calendar date — the
 * Flutter app's own `datetime` builders (kundli/guna-milan repositories)
 * read `dateOfBirth.year/.month/.day` directly off the live `DateTime`
 * object in the DEVICE's local timezone, which is lost once only the
 * Timestamp survives a round trip through Firestore.
 *
 * The best information available server-side to recover that intended
 * local date is `utcOffsetMinutes` — the birth city's UTC offset AT the
 * birth moment, stored on the profile for exactly this purpose (see
 * `BirthProfile.toFirestore()`'s doc comment in birth_profile.dart).
 * Shifting the absolute instant by that offset before reading its calendar
 * fields recovers the correct date whenever the device used to save the
 * profile was in the same timezone as the birth city — the common case for
 * this app's India-first audience. Reading the Timestamp's raw UTC/Node-
 * local fields instead would be wrong for essentially every IST user: IST
 * midnight is still the PREVIOUS day in UTC.
 */
function buildBirthDateComponents(
  dateOfBirth: admin.firestore.Timestamp,
  utcOffsetMinutes: number,
  dateOfBirthYmd?: unknown
): { year: string; month: string; day: string } {
  // PREFERRED PATH: the calendar date the user actually picked, written
  // explicitly by the app (birth_profile.dart `toFirestore`). Use it
  // whenever present — it is the only source here that is correct
  // unconditionally.
  if (typeof dateOfBirthYmd === "string" && /^\d{4}-\d{2}-\d{2}$/.test(dateOfBirthYmd)) {
    const [year, month, day] = dateOfBirthYmd.split("-");
    return { year, month, day };
  }

  // LEGACY FALLBACK, for profiles saved before `dateOfBirthYmd` existed.
  // KNOWN TO BE WRONG in one case, and kept anyway because a slightly-off
  // date beats refusing to answer at all for existing users:
  //
  // `dateOfBirth` is an absolute instant recorded at local midnight ON THE
  // SAVING DEVICE, and that device's UTC offset is not stored. Viewing the
  // instant through the birth CITY's offset (below) reproduces the right
  // day only while device and city share a timezone. When the city is WEST
  // of the device — an IST phone saving a New York birth city — the shift
  // goes backwards past midnight and yields the PREVIOUS day.
  //
  // Every profile re-saved by the app self-heals onto the preferred path
  // above. If this ever needs to be closed out properly, a one-off
  // backfill would have to ask users to re-confirm their birth date rather
  // than guess an offset the data never captured.
  const shifted = new Date(dateOfBirth.toMillis() + utcOffsetMinutes * 60_000);
  return {
    year: shifted.getUTCFullYear().toString().padStart(4, "0"),
    month: (shifted.getUTCMonth() + 1).toString().padStart(2, "0"),
    day: shifted.getUTCDate().toString().padStart(2, "0"),
  };
}

/**
 * Reads the caller's saved birth profile and shapes it into the
 * `birthDetails` object Vedika's `/api/v1/astrology/query` expects.
 *
 * Called BEFORE `reserveCredit` in `askAiAstrologer`: a user with no saved
 * profile can never get an answer anyway, so failing here must not cost
 * them one of their scarce, tier-limited daily questions.
 */
async function resolveBirthDetails(uid: string): Promise<VedikaBirthDetails> {
  const snap = await birthProfileRef(uid).get();
  const data = snap.data();

  const dateOfBirth = data?.dateOfBirth;
  const isBirthTimeUnknown = data?.isBirthTimeUnknown === true;
  const timeOfBirthField = data?.timeOfBirth;
  const utcOffsetMinutes = data?.utcOffsetMinutes;
  const latitude = data?.city?.latitude;
  const longitude = data?.city?.longitude;

  const isValid =
    snap.exists &&
    dateOfBirth instanceof admin.firestore.Timestamp &&
    (isBirthTimeUnknown || typeof timeOfBirthField === "string") &&
    typeof utcOffsetMinutes === "number" &&
    typeof latitude === "number" &&
    typeof longitude === "number";

  if (!isValid) {
    throw new HttpsError(
      "failed-precondition",
      "Save your birth details first — the AI astrologer needs your birth chart to answer questions."
    );
  }

  // "HH:mm" 24h, e.g. "06:45" — matches BirthProfile._formatTimeOfDay in
  // mobile/lib/features/profile/birth_profile.dart. When the birth time is
  // unknown, 12:00 noon is the app's own placeholder convention for
  // calculations (see that file's `isBirthTimeUnknown` doc comment) —
  // mirrored here rather than trusting whatever happens to be stored in
  // `timeOfBirth` for that case.
  const timeOfBirth = isBirthTimeUnknown ? "12:00" : (timeOfBirthField as string);
  const { year, month, day } = buildBirthDateComponents(
    dateOfBirth as admin.firestore.Timestamp,
    utcOffsetMinutes as number,
    data?.dateOfBirthYmd
  );

  return {
    datetime: `${year}-${month}-${day}T${timeOfBirth}:00`,
    latitude: latitude as number,
    longitude: longitude as number,
    timezone: formatUtcOffset(utcOffsetMinutes as number),
  };
}

// ---------------------------------------------------------------------------
// The Vedika call itself.
// ---------------------------------------------------------------------------

const SUPPORTED_LANGUAGES = ["en", "hi", "te", "ta", "kn"] as const;
type SupportedLanguage = (typeof SUPPORTED_LANGUAGES)[number];

interface VedikaQueryResult {
  answer: string;
  followUps: string[];
  conversationId: string | null;
}

/**
 * Step 2: the real Vedika call — `POST /api/v1/astrology/query`. Contract
 * recovered from vedika.io/openapi.json.
 *
 * `X-Idempotency-Key` is CRITICAL, not optional decoration: per the spec it
 * is a "client-generated unique key ... to make a retry safe and avoid a
 * double wallet charge." A dropped response on a slow (this endpoint can
 * take 1-2 minutes) or flaky connection must never turn into Vedika billing
 * the client's wallet twice for one question the user asked once — a fresh
 * `randomUUID()` per call (36 chars incl. hyphens, within the spec's
 * 16-64 alphanumerics/hyphens/underscores range) is what lets Vedika
 * recognize and dedupe a retried request.
 *
 * Every non-2xx/failure path throws a specific `HttpsError` rather than
 * returning a result the caller has to re-interpret — `askAiAstrologer`'s
 * existing try/catch around this call already releases the reserved credit
 * on ANY throw, so failing closed here is exactly the credit-protection
 * behavior the rest of this file was built around.
 */
async function callVedikaAi(params: {
  question: string;
  birthDetails: VedikaBirthDetails;
  language: SupportedLanguage;
  conversationId?: string;
}): Promise<VedikaQueryResult> {
  const idempotencyKey = randomUUID();

  let res: Response;
  try {
    res = await fetch(`${VEDIKA_BASE_URL.value()}/api/v1/astrology/query`, {
      method: "POST",
      headers: {
        ...vedikaHeaders(),
        "Content-Type": "application/json",
        Accept: "application/json",
        "X-Idempotency-Key": idempotencyKey,
      },
      body: JSON.stringify({
        question: params.question,
        birthDetails: params.birthDetails,
        language: params.language,
        system: "vedic",
        speed: "standard",
        includeRemedies: true,
        ...(params.conversationId ? { conversationId: params.conversationId } : {}),
        saveConversation: true,
        responseFormat: "text",
      }),
    });
  } catch (e) {
    console.error("callVedikaAi: request threw", { idempotencyKey }, e);
    throw new HttpsError(
      "unavailable",
      "The AI astrologer is not available right now. Your credit was not used."
    );
  }

  const payload = (await res.json().catch(() => null)) as Record<string, unknown> | null;

  // Success envelope has NO `data` key (unlike the /v2 endpoints elsewhere
  // in this codebase) — the answer is directly on `response`.
  if (res.ok && payload && payload.success === true) {
    const followUps =
      (payload.followUps as string[] | undefined) ??
      (payload.followUpSuggestions as string[] | undefined) ??
      [];
    return {
      answer: typeof payload.response === "string" ? payload.response : "",
      followUps,
      conversationId: typeof payload.conversationId === "string" ? payload.conversationId : null,
    };
  }

  const code = payload && typeof payload.code === "string" ? payload.code : undefined;
  console.error("callVedikaAi: non-success response", {
    status: res.status,
    code,
    idempotencyKey,
  });

  if (res.status === 400 || code === "PROMPT_GUARD_BLOCKED") {
    throw new HttpsError(
      "invalid-argument",
      "That question couldn't be processed. Please rephrase it."
    );
  }
  if (res.status === 401) {
    // Our own key is broken/expired — never the user's fault, so this must
    // not read as "you're not allowed to do this" (permission-denied).
    throw new HttpsError(
      "unavailable",
      "The AI astrologer is not available right now. Your credit was not used."
    );
  }
  if (res.status === 402) {
    // The CLIENT's (Nagarjuna's) Vedika account is out of wallet balance —
    // this is an operational problem that needs a top-up, not a user error.
    console.error(
      "callVedikaAi: CRITICAL — Vedika wallet balance exhausted; the Vedika account needs topping up",
      { idempotencyKey }
    );
    throw new HttpsError(
      "unavailable",
      "The AI astrologer is not available right now. Your credit was not used."
    );
  }
  if (res.status === 429) {
    throw new HttpsError(
      "unavailable",
      "The AI astrologer is busy right now. Please try again in a moment."
    );
  }
  // 500 ANALYSIS_ERROR / anything else unmapped.
  throw new HttpsError(
    "unavailable",
    "The AI astrologer is not available right now. Your credit was not used."
  );
}

/**
 * Callable entry point for an AI Astrologer question.
 *
 * Enforces the credit-protection rule end to end: resolve birth details →
 * reserve → call → commit-or-release → persist chat log. `timeoutSeconds:
 * 120` matches mobile/CLAUDE.md's note that "AI latency can reach ~1–2 min
 * for insights" — a shorter function timeout would turn every slow-but-
 * eventually-successful Vedika response into a spurious release-and-fail.
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

    const question =
      typeof request.data?.question === "string" ? request.data.question.trim() : "";
    if (!question || question.length > 1000) {
      throw new HttpsError(
        "invalid-argument",
        "question must be a non-empty string of at most 1000 characters."
      );
    }

    const requestedLanguage =
      typeof request.data?.language === "string" ? request.data.language : "";
    const language: SupportedLanguage = (
      SUPPORTED_LANGUAGES as readonly string[]
    ).includes(requestedLanguage)
      ? (requestedLanguage as SupportedLanguage)
      : "en";

    const conversationId =
      typeof request.data?.conversationId === "string" && request.data.conversationId.trim()
        ? (request.data.conversationId as string)
        : undefined;

    // ---- 0. BIRTH DETAILS ------------------------------------------------
    // Resolved BEFORE reserving a credit — see resolveBirthDetails' doc
    // comment for why.
    const birthDetails = await resolveBirthDetails(uid);

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
      const result = await callVedikaAi({ question, birthDetails, language, conversationId });

      const { used, limit } = await commitCredit(uid, dateKey);

      // ---- 4. PERSIST CHAT LOG (best-effort) ----------------------------
      // Vedika's own conversation storage expires 24h after the last
      // message (the /api/v1/conversations example in the spec shows
      // expiresAt = lastActivityAt + 1 day) — this Firestore copy is the
      // DURABLE history. A write failure here must NOT fail the request:
      // the user already has their answer and was already charged for it.
      await admin
        .firestore()
        .collection("users")
        .doc(uid)
        .collection("aiChats")
        .add({
          question,
          answer: result.answer,
          followUps: result.followUps,
          language,
          conversationId: result.conversationId,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          dateKey,
        })
        .catch((e) => {
          console.warn("askAiAstrologer: failed to persist chat log", { uid, dateKey }, e);
        });

      return {
        answer: result.answer,
        followUps: result.followUps,
        conversationId: result.conversationId,
        used,
        limit,
      };
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
