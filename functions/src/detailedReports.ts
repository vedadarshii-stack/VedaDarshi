import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import { createHash } from "node:crypto";
import { VEDIKA_API_KEY, VEDIKA_BASE_URL, vedikaHeaders } from "./config";
import { resolveBirthDetails, type VedikaBirthDetails } from "./aiCredits";
import { ownedReports } from "./reportPurchases";

/**
 * Full-length premium reports, rendered by Vedika as multi-page PDFs.
 *
 * BUILT 20 Sep 2026 on the client's instruction: *"We are selling for 200+
 * rupees so we want full detailed report."* They were right to complain. The
 * Complete Life Report that ₹699 bought was measured at **520 words / ~1
 * page** — houses 215 words, yogas 285, strengthTable 14, dashaTimeline 4.
 *
 * `vedic-janam-kundli-standard` measures **89 pages / 20,346 words / 19
 * sections** for $1.49. That is the same information class, forty times the
 * depth, at a cost the ₹299 price point absorbs comfortably.
 *
 * ## The endpoint, and the two traps in it
 *
 * `POST /v2/reports/prebuilt/generate`, discovered by probing — it is in the
 * contract but under the production-only `/api/*` tree, and the `/v2` alias
 * behaves identically.
 *
 * ⚠️ **The idempotency key goes in the BODY, not a header.** The spec
 * documents an `Idempotency-Key` / `X-Idempotency-Key` header and refuses the
 * call with `IDEMPOTENCY_KEY_REQUIRED` without one — but our proxy builds a
 * fresh header set and forwards no client headers, so a header can never
 * arrive. The body field `idempotencyKey` is accepted and works. Verified: a
 * replay returned the identical artifact with `"charged": 0`.
 *
 * ⚠️ **This endpoint COSTS MONEY PER CALL** — a separate charge on top of
 * normal per-call billing, taken from the client's prepaid Vedika wallet.
 * Everything below exists to make sure one purchase produces at most one
 * charge, forever.
 */

/**
 * Our report id → the Vedika prebuilt SKU that backs it.
 *
 * ## Tier is a MARGIN decision, not a quality one
 *
 * Play takes 15%, so a ₹299 report nets ₹254 and the ₹699 Complete nets ₹594.
 * At roughly ₹88/$:
 *
 *   standard $1.49 → ₹131   → 48% margin on a ₹299 report   ✅
 *   deep     $3.99 → ₹351   → LOSS on ₹299, 41% on ₹699     ⚠️
 *   master   $7.99 → ₹703   → loss at every price we charge ❌
 *
 * So the twelve ₹299 reports take `standard` and only the ₹699 Complete Life
 * Report takes a `deep` bundle. **Do not "upgrade" one of the twelve to deep
 * without raising its price first** — it silently turns a 48% margin into a
 * loss, and nothing in the code would complain.
 *
 * `remedies` deliberately takes `lalkitab-remedies-standard` rather than the
 * obvious `remedy-comprehensive-deep`: the latter is $3.99, which is the loss
 * case above.
 */
const VEDIKA_REPORT_TYPES: Readonly<Record<string, string>> = {
  // ₹699 — the only one that can carry a deep bundle.
  complete: "bundle-vedic-western-birth-deep",

  // ₹299 each — standard tier.
  career: "vedic-career-standard",
  marriage: "vedic-marriage-love-standard",
  wealth: "vedic-wealth-finance-standard",
  health: "vedic-health-longevity-standard",
  sadeSati: "vedic-sade-sati-standard",
  gemstone: "vedic-gemstone-standard",
  numerology: "numerology-comprehensive-standard",
  remedies: "lalkitab-remedies-standard",
  rudraksha: "remedy-rudraksha-mukhi-standard",
  property: "vedic-property-vehicle-standard",
  childFamily: "vedic-progeny-children-standard",
  business: "vedic-business-entrepreneurship-standard",
};

interface DetailedReportDoc {
  reportId: string;
  reportType: string;
  tier: string;
  language: string;
  pageCount: number;
  sectionCount: number;
  reportTitle: string;
  downloadUrl: string;
  iframeUrl: string | null;
  idempotencyKey: string;
  generatedAtMs: number;
}

function reportDocRef(uid: string, reportId: string) {
  return admin
    .firestore()
    .collection("users")
    .doc(uid)
    .collection("detailedReports")
    .doc(reportId);
}

/**
 * A key that is STABLE for one person + one report + one chart.
 *
 * This is the thing standing between the client and a duplicated wallet
 * charge, so it is derived rather than random: `randomUUID()` would make
 * every retry a fresh paid generation. Because Vedika keys its own
 * deduplication off this value, a retry after a timeout — where the charge
 * may already have happened but we never saw the response — returns the
 * SAME artifact for `charged: 0`.
 *
 * The chart is part of the hash so that correcting a wrong birth time
 * legitimately produces a new report rather than serving the old chart's PDF
 * forever. That is a real second charge, and the right one.
 *
 * ⚠️ Never let the client supply this. A caller that varied it could bill the
 * wallet repeatedly for a report they already own.
 */
function idempotencyKeyFor(
  uid: string,
  reportType: string,
  birth: VedikaBirthDetails
): string {
  return createHash("sha256")
    .update(
      [
        uid,
        reportType,
        birth.datetime,
        birth.latitude,
        birth.longitude,
        birth.timezone,
      ].join("|")
    )
    .digest("hex")
    .slice(0, 48);
}

/** Vedika's five supported app languages; anything else falls back to English. */
const SUPPORTED_LANGUAGES = new Set(["en", "hi", "te", "ta", "kn"]);

export const generateDetailedReport = onCall(
  {
    region: "asia-south1",
    secrets: [VEDIKA_API_KEY],
    // Rendering 89 pages is not instant; the SDK's 60s default cut off
    // legitimate responses in testing.
    timeoutSeconds: 180,
  },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "Sign in required.");
    }

    const reportId = (request.data as { reportId?: unknown } | undefined)
      ?.reportId;
    if (typeof reportId !== "string" || !reportId) {
      throw new HttpsError("invalid-argument", "reportId is required.");
    }

    const reportType = VEDIKA_REPORT_TYPES[reportId];
    if (!reportType) {
      throw new HttpsError(
        "invalid-argument",
        `No detailed report is available for '${reportId}'.`
      );
    }

    // ---- 1. OWNERSHIP, server-side ------------------------------------
    //
    // The ledger is written only by `reportPurchases` from a verified store
    // transaction, and the rules make `reportPurchases` unwritable by the
    // client. A subscription deliberately does NOT grant this (client,
    // 12 Sep 2026: *"we can't give free for subscription users"*) — reports
    // are bought outright, and the tier only discounts them.
    const owned = await ownedReports(uid);
    if (!owned.includes(reportId)) {
      throw new HttpsError(
        "permission-denied",
        "This report has not been purchased."
      );
    }

    // ---- 2. ALREADY GENERATED? ----------------------------------------
    //
    // The single most important branch in this file. Re-opening a report the
    // user already paid for must NEVER re-bill the wallet, and users re-open
    // reports constantly. Returning the stored artifact is both free and
    // faster.
    //
    // If the artifact URL ever expires, the right recovery is to call this
    // again with `force` — Vedika's own idempotency then returns the same
    // artifact for `charged: 0`, so even the recovery path is free.
    const existing = (await reportDocRef(uid, reportId).get()).data() as
      | DetailedReportDoc
      | undefined;
    const force =
      (request.data as { force?: unknown } | undefined)?.force === true;
    if (existing?.downloadUrl && !force) {
      return { ...existing, cached: true };
    }

    // ---- 3. Birth details, from the SERVER's copy ----------------------
    //
    // Shared with the AI path rather than re-implemented: that helper reads
    // `dateOfBirthYmd` rather than re-deriving the calendar date from the
    // stored Timestamp, which is what stops a cross-timezone profile
    // generating the previous day's chart.
    const birth = await resolveBirthDetails(uid);

    const rawLanguage = (request.data as { language?: unknown } | undefined)
      ?.language;
    const language =
      typeof rawLanguage === "string" && SUPPORTED_LANGUAGES.has(rawLanguage)
        ? rawLanguage
        : "en";

    const idempotencyKey = idempotencyKeyFor(uid, reportType, birth);

    // Numerology reports are driven by NAME, not by a chart — the contract is
    // explicit that they take `name` and/or `dob`. Sent for every type
    // regardless: the chart reports ignore it, and omitting it would silently
    // weaken the one report that depends on it.
    let name: string | undefined;
    try {
      const profile = await admin
        .firestore()
        .collection("users")
        .doc(uid)
        .collection("birthProfiles")
        .doc("primary")
        .get();
      const full = profile.data()?.fullName;
      if (typeof full === "string" && full.trim()) name = full.trim();
    } catch {
      // A missing name only weakens numerology; it must never block a report
      // the user has already paid for.
    }

    // ---- 4. Generate ---------------------------------------------------
    let res: Response;
    try {
      res = await fetch(
        `${VEDIKA_BASE_URL.value()}/v2/reports/prebuilt/generate`,
        {
          method: "POST",
          headers: {
            ...vedikaHeaders(),
            Accept: "application/json",
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            reportType,
            lang: language,
            // BODY, not a header — see this file's header comment.
            idempotencyKey,
            ...(name ? { name } : {}),
            birthDetails: {
              datetime: birth.datetime,
              latitude: birth.latitude,
              longitude: birth.longitude,
              timezone: birth.timezone,
            },
          }),
        }
      );
    } catch (e) {
      console.error("generateDetailedReport: unreachable", { uid, reportId }, e);
      throw new HttpsError(
        "unavailable",
        "The report service is not reachable right now. Please try again."
      );
    }

    const payload = (await res.json().catch(() => null)) as Record<
      string,
      unknown
    > | null;

    if (!res.ok || !payload || payload.success !== true) {
      const code =
        payload && typeof payload.code === "string" ? payload.code : undefined;
      console.error("generateDetailedReport: upstream refused", {
        uid,
        reportId,
        reportType,
        status: res.status,
        code,
      });

      // A language Vedika has not finished translating is the ONE failure
      // worth retrying differently rather than surfacing: the catalogue
      // advertises 29 languages but every non-English one currently answers
      // REPORT_LANGUAGE_NOT_READY ("…until its full document passes
      // translation acceptance"), and critically it says "You were not
      // charged". Falling back to English gives the user the report they paid
      // for instead of an error.
      if (code === "REPORT_LANGUAGE_NOT_READY" && language !== "en") {
        return await generateEnglishFallback({
          uid,
          reportId,
          reportType,
          birth,
          idempotencyKey,
          name,
        });
      }

      if (code === "INSUFFICIENT_BALANCE") {
        throw new HttpsError(
          "resource-exhausted",
          "Report generation is temporarily unavailable. Please try again later."
        );
      }
      throw new HttpsError(
        "internal",
        "Could not generate the report. Please try again."
      );
    }

    return await storeAndReturn(uid, reportId, reportType, idempotencyKey, payload);
  }
);

/**
 * Retries in English after `REPORT_LANGUAGE_NOT_READY`.
 *
 * Reuses the SAME idempotency key on purpose. The refused call was explicitly
 * not charged, so this is the first real generation for this key — and if the
 * user later retries, they get this same artifact for free.
 */
async function generateEnglishFallback(params: {
  uid: string;
  reportId: string;
  reportType: string;
  birth: VedikaBirthDetails;
  idempotencyKey: string;
  name?: string;
}): Promise<Record<string, unknown>> {
  const { uid, reportId, reportType, birth, idempotencyKey, name } = params;
  const res = await fetch(
    `${VEDIKA_BASE_URL.value()}/v2/reports/prebuilt/generate`,
    {
      method: "POST",
      headers: {
        ...vedikaHeaders(),
        Accept: "application/json",
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        reportType,
        lang: "en",
        idempotencyKey,
        ...(name ? { name } : {}),
        birthDetails: {
          datetime: birth.datetime,
          latitude: birth.latitude,
          longitude: birth.longitude,
          timezone: birth.timezone,
        },
      }),
    }
  );
  const payload = (await res.json().catch(() => null)) as Record<
    string,
    unknown
  > | null;
  if (!res.ok || !payload || payload.success !== true) {
    throw new HttpsError(
      "internal",
      "Could not generate the report. Please try again."
    );
  }
  return await storeAndReturn(uid, reportId, reportType, idempotencyKey, payload);
}

/** Persists the artifact and returns it to the caller. */
async function storeAndReturn(
  uid: string,
  reportId: string,
  reportType: string,
  idempotencyKey: string,
  payload: Record<string, unknown>
): Promise<Record<string, unknown>> {
  const data = (payload.data ?? {}) as Record<string, unknown>;
  const downloadUrl = data.downloadUrl;
  if (typeof downloadUrl !== "string" || !downloadUrl) {
    // A success envelope with no artifact is not something to store — storing
    // it would permanently cache a broken report and the cache branch above
    // would never regenerate it.
    throw new HttpsError(
      "internal",
      "The report service returned no document. Please try again."
    );
  }

  const doc: DetailedReportDoc = {
    reportId,
    reportType,
    tier: typeof data.tier === "string" ? data.tier : "",
    language: typeof data.language === "string" ? data.language : "en",
    pageCount: typeof data.pageCount === "number" ? data.pageCount : 0,
    sectionCount:
      typeof data.sectionCount === "number" ? data.sectionCount : 0,
    reportTitle:
      typeof data.reportTitle === "string" ? data.reportTitle : reportId,
    downloadUrl,
    iframeUrl: typeof data.iframeUrl === "string" ? data.iframeUrl : null,
    idempotencyKey,
    generatedAtMs: Date.now(),
  };

  // Written with the Admin SDK, and `detailedReports` is unwritable by the
  // client in the rules — the same stance as `reportPurchases`. A client that
  // could write here could mint itself a report it never bought.
  await reportDocRef(uid, reportId).set(doc);

  const billing = payload.billing as Record<string, unknown> | undefined;
  console.log("generateDetailedReport: generated", {
    uid,
    reportId,
    reportType,
    pageCount: doc.pageCount,
    charged: billing?.charged,
  });

  return { ...doc, cached: false };
}
