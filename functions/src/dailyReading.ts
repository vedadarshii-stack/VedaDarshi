import * as admin from "firebase-admin";

/**
 * Personalized Daily Reading — a one-time purchase granting **24 hours** of
 * access to the chart-based daily reading.
 *
 * BUILT 9 Sep 2026 alongside the AI packs, and for the same reason: the Play
 * product `vedadarshi_daily_reading` and the RevenueCat `daily_reading`
 * offering had existed since 16 Aug with nothing in the app able to sell or
 * unlock it.
 *
 * ## Why this is time-boxed rather than a credit count
 *
 * A pack grants N questions and is spent one at a time. This grants a
 * WINDOW: the pricing spec's own note on the offering is "single consumable,
 * 24-hour validity enforced server-side". So the ledger stores an expiry and
 * the access check is "is any window still open", with no decrementing.
 *
 * ## Why it is not tier-gated
 *
 * The Access Control Matrix marks Personalized Daily Reading as **Paid for
 * every tier, Platinum included**. It is deliberately not something a
 * subscription unlocks — so this must never be folded into
 * `resolveDailyLimit` or the entitlement tier check.
 */
export const DAILY_READING_SKU = "vedadarshi_daily_reading";

/** How long one purchase stays open. */
export const DAILY_READING_WINDOW_MS = 24 * 60 * 60 * 1000;

export interface DailyReadingDoc {
  sku: string;
  purchasedAtMs: number;
  expiresAtMs: number;
  /** Mirrors `expiresAtMs`; drives the Firestore TTL sweep. */
  expiresAt: admin.firestore.Timestamp;
  transactionId: string;
}

/**
 * `/users/{uid}/dailyReadings/{transactionId}`.
 *
 * ⚠️ Document id is the store transaction id — the same idempotency story as
 * the AI packs. RevenueCat retries webhooks, and a second grant here would
 * silently extend a paid window for free.
 *
 * ⚠️ Client-unwritable in `firestore.rules`, carved out of the
 * `/users/{uid}/{subcollection}` wildcard. A client that could write here
 * would grant itself unlimited readings, each one a real billed Vedika call.
 */
function readingRef(uid: string, transactionId: string) {
  return admin
    .firestore()
    .collection("users")
    .doc(uid)
    .collection("dailyReadings")
    .doc(transactionId);
}

function readingsCollection(uid: string) {
  return admin
    .firestore()
    .collection("users")
    .doc(uid)
    .collection("dailyReadings");
}

/**
 * Grants one purchased reading window. Safe to call repeatedly for the same
 * transaction.
 *
 * Returns whether anything was actually granted, so a reconciliation pass can
 * log a no-op as a no-op.
 */
export async function grantDailyReading(params: {
  uid: string;
  transactionId: string;
  purchasedAtMs: number;
}): Promise<boolean> {
  const ref = readingRef(params.uid, params.transactionId);

  return admin.firestore().runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (snap.exists) return false; // already granted — a webhook retry

    // The window runs from the PURCHASE, not from now. A webhook delayed by a
    // retry or an outage must not quietly hand out a longer window than was
    // sold — and, just as importantly, must not shorten it either, which is
    // why the purchase time is used rather than clamped to now.
    const expiresAtMs = params.purchasedAtMs + DAILY_READING_WINDOW_MS;

    const doc: DailyReadingDoc = {
      sku: DAILY_READING_SKU,
      purchasedAtMs: params.purchasedAtMs,
      expiresAtMs,
      expiresAt: admin.firestore.Timestamp.fromMillis(expiresAtMs),
      transactionId: params.transactionId,
    };
    tx.set(ref, doc);
    return true;
  });
}

/**
 * Whether the user currently has an open reading window, and when it ends.
 *
 * Returns the LATEST expiry when several are open: buying twice in a day
 * should not shorten access to the earlier purchase's end.
 */
export async function dailyReadingAccess(
  uid: string,
  nowMs: number = Date.now()
): Promise<{ hasAccess: boolean; expiresAtMs: number | null }> {
  const snap = await readingsCollection(uid)
    .where("expiresAtMs", ">", nowMs)
    .orderBy("expiresAtMs", "desc")
    .limit(1)
    .get();

  if (snap.empty) return { hasAccess: false, expiresAtMs: null };
  const data = snap.docs[0].data() as DailyReadingDoc;
  return { hasAccess: true, expiresAtMs: data.expiresAtMs };
}
