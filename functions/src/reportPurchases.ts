import * as admin from "firebase-admin";

/**
 * Individually purchased reports.
 *
 * BUILT 10 Sep 2026. Fourteen `vedadarshi_report_*` products have existed in
 * Play since 16 Aug and in the RevenueCat `reports` offering since 31 Jul,
 * with **no way to buy one and no record of owning one**. This is the ledger
 * half.
 *
 * ## Permanent, unlike the other two consumables
 *
 * An AI pack is a credit count and a Daily Reading is a 24-hour window; a
 * report is bought once and owned forever. So there is no `remaining`, no
 * `expiresAtMs`, and deliberately **no Firestore TTL field** — a swept
 * document here would silently revoke something the user paid for.
 *
 * ## Which SKUs are honoured
 *
 * Only reports the app can actually deliver. Three Play products are
 * deliberately ABSENT from this map, because the data behind them does not
 * exist (probed against Vedika's 694-path contract on 9 Sep 2026):
 *
 *  - `vedadarshi_report_education` — no education endpoint at all; the only
 *    matches are vastu room-layout advice.
 *  - `vedadarshi_report_foreign_travel` — only `/v2/lifestyle/zodiac-travel/
 *    {sign}`, which is sun-sign based. Every Aries would get identical text
 *    while every other report is computed from the user's own chart.
 *  - `vedadarshi_report_finance` — resolves to the same `wealth-timing`
 *    endpoint already sold as `vedadarshi_report_wealth`; one reading, two
 *    SKUs.
 *
 * ⚠️ **Those three should be ARCHIVED in Play Console.** Until they are, a
 * user can still buy them — Play does not know this map exists — and they
 * will be granted nothing here. That is the safer failure (no false content)
 * but it is still a refund waiting to happen, which is why archiving them is
 * the real fix rather than a code change.
 */
/** Full-price Play SKU -> app report id. */
const BASE_REPORT_SKUS: Record<string, string> = {
  vedadarshi_report_complete_life: "complete",
  vedadarshi_report_career: "career",
  vedadarshi_report_marriage: "marriage",
  vedadarshi_report_wealth: "wealth",
  vedadarshi_report_health: "health",
  vedadarshi_report_gemstone: "gemstone",
  vedadarshi_report_remedies: "remedies",
  vedadarshi_report_rudraksha: "rudraksha",
  vedadarshi_report_property: "property",
  vedadarshi_report_child_family: "childFamily",
  vedadarshi_report_business: "business",
};

/**
 * The per-tier discount suffixes, in Access Control Matrix order.
 *
 * Bronze 5% · Silver 10% · Gold 15% · Platinum 20%.
 */
export const REPORT_DISCOUNT_TIERS = [
  "bronze",
  "silver",
  "gold",
  "platinum",
] as const;

/**
 * Every Play SKU that grants a report, full-price and discounted alike.
 *
 * BUILT 21 Oct 2026, client (11 Sep): *"for subscription only discounts
 * applicable for respective plans"*. Until now the paywall advertised
 * "5% off premium reports" on every tier and **no discount existed
 * anywhere** — a subscriber paid the same Rs299 as everyone else.
 *
 * ## Why a discounted SKU rather than a computed price
 *
 * Google Play owns the price. A product has ONE price and there is no API
 * to charge a given buyer less, so "10% off for Silver" can only exist as a
 * different product. That is the whole reason this sat open for six weeks:
 * it is a store-catalogue problem wearing a code problem's clothes.
 *
 * ## Why derived rather than 44 hand-written lines
 *
 * `{base}_{tier}` resolves to the SAME report id as its base SKU, so the
 * mapping cannot drift: adding a report to [BASE_REPORT_SKUS] creates its
 * four discounted variants automatically, and there is no way to typo one
 * of them into pointing at the wrong reading.
 *
 * ⚠️ `grantReport` needs no change at all — it looks a SKU up in here and
 * grants whatever report id it finds, so a discounted purchase grants
 * exactly what the full-price one does. The discount is purely a price
 * difference at the store; ownership is identical.
 */
export const REPORT_SKUS: Record<string, string> = {
  ...BASE_REPORT_SKUS,
  ...Object.fromEntries(
    Object.entries(BASE_REPORT_SKUS).flatMap(([sku, reportId]) =>
      REPORT_DISCOUNT_TIERS.map((tier) => [`${sku}_${tier}`, reportId])
    )
  ),
};

/** The full-price SKUs only — what a free user is offered. */
export const BASE_REPORT_SKU_IDS = Object.keys(BASE_REPORT_SKUS);

export interface ReportPurchaseDoc {
  sku: string;
  reportId: string;
  purchasedAtMs: number;
  transactionId: string;
}

/**
 * `/users/{uid}/reportPurchases/{transactionId}`.
 *
 * ⚠️ Keyed on the store transaction id for idempotency (RevenueCat retries),
 * and **not** on the report id — someone who buys the same report twice, e.g.
 * after a refund, gets two rows rather than a silently-overwritten one, and
 * ownership is still the presence of any row for that report.
 *
 * ⚠️ Client-unwritable in `firestore.rules`, carved out of the
 * `/users/{uid}/{subcollection}` wildcard. A client that could write here
 * would hand itself every paid report.
 */
function purchaseRef(uid: string, transactionId: string) {
  return admin
    .firestore()
    .collection("users")
    .doc(uid)
    .collection("reportPurchases")
    .doc(transactionId);
}

/**
 * Grants one purchased report. Safe to call repeatedly for the same
 * transaction; returns whether anything was actually written.
 */
export async function grantReport(params: {
  uid: string;
  sku: string;
  transactionId: string;
  purchasedAtMs: number;
}): Promise<boolean> {
  const reportId = REPORT_SKUS[params.sku];
  if (!reportId) return false;

  const ref = purchaseRef(params.uid, params.transactionId);
  return admin.firestore().runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (snap.exists) return false; // a webhook retry

    const doc: ReportPurchaseDoc = {
      sku: params.sku,
      reportId,
      purchasedAtMs: params.purchasedAtMs,
      transactionId: params.transactionId,
    };
    tx.set(ref, doc);
    return true;
  });
}

/** Report ids this user owns outright. */
export async function ownedReports(uid: string): Promise<string[]> {
  const snap = await admin
    .firestore()
    .collection("users")
    .doc(uid)
    .collection("reportPurchases")
    .get();
  return Array.from(
    new Set(snap.docs.map((d) => (d.data() as ReportPurchaseDoc).reportId))
  );
}
