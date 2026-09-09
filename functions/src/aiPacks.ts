import * as admin from "firebase-admin";

/**
 * AI question packs — the one-time purchases that top a user up beyond their
 * daily allowance.
 *
 * BUILT 9 Sep 2026. The store side had been ready since 16 Aug (6 Play
 * products, 6 RevenueCat packages in the `ai_packs` offering, all attached)
 * but nothing in the app or the backend could sell or spend one, so the
 * products were unreachable. This file is the backend half.
 *
 * ## Where the numbers come from
 *
 * `claudedocs/play-console-iap-setup.md`, which is the sheet the Play
 * products were created from — so these quantities and validity windows
 * match what the store actually sells.
 *
 * ⚠️ They are a CODE CONSTANT, deliberately. `projects/CLAUDE.md` claimed
 * these lived in Remote Config under `aiPacks`; they do not — the live
 * template holds only `access_control_matrix` (checked 9 Sep 2026). Rather
 * than depend on a parameter that does not exist, the grant table is
 * versioned with the code that reads it. A wrong quantity here is a bug that
 * shows up in review; a missing Remote Config key is a silent zero-credit
 * grant after the user has paid.
 *
 * ## Prices are NOT here
 *
 * Same rule as everywhere else in this project: Play owns the price, the app
 * renders `StoreProduct.priceString`. This table only says how many
 * questions a purchased SKU is worth and for how long.
 */
export interface AiPackSpec {
  questions: number;
  validityDays: number;
}

export const AI_PACKS: Record<string, AiPackSpec> = {
  vedadarshi_ai_pack_3: { questions: 3, validityDays: 7 },
  vedadarshi_ai_pack_5: { questions: 5, validityDays: 15 },
  vedadarshi_ai_pack_10: { questions: 10, validityDays: 30 },
  vedadarshi_ai_pack_30: { questions: 30, validityDays: 30 },
  vedadarshi_ai_pack_100: { questions: 100, validityDays: 60 },
  vedadarshi_ai_pack_300: { questions: 300, validityDays: 90 },
};

/**
 * One purchased pack.
 *
 * `pending` mirrors the daily ledger's reserve → commit/release pattern, so
 * an AI call that dies mid-flight cannot silently eat a paid question.
 */
export interface AiPackDoc {
  sku: string;
  questions: number;
  remaining: number;
  pending: number;
  purchasedAtMs: number;
  expiresAtMs: number;
  /** Mirrors `expiresAtMs`; drives the Firestore TTL sweep. */
  expiresAt: admin.firestore.Timestamp;
  transactionId: string;
}

/**
 * `/users/{uid}/aiPacks/{transactionId}`.
 *
 * ⚠️ **The document id IS the store transaction id, and that is the whole
 * idempotency story.** RevenueCat retries webhooks and can deliver the same
 * event twice; without this, one purchase could be granted repeatedly and a
 * user would accumulate free questions by doing nothing. `create` on an
 * existing id is a no-op here, not a second grant.
 *
 * ⚠️ It also MUST stay client-unwritable. `firestore.rules` carves this
 * subcollection out of the generic `/users/{uid}/{subcollection}` wildcard
 * exactly like `aiUsage` and `aiChats` — a client that could write here
 * would grant itself unlimited AI questions, each one a real billed Vedika
 * call against the account owner's wallet.
 */
export function packRef(uid: string, transactionId: string) {
  return admin
    .firestore()
    .collection("users")
    .doc(uid)
    .collection("aiPacks")
    .doc(transactionId);
}

function packsCollection(uid: string) {
  return admin.firestore().collection("users").doc(uid).collection("aiPacks");
}

/**
 * Grants one purchased pack. Safe to call repeatedly for the same
 * transaction — see [packRef].
 *
 * Returns whether this call actually granted anything, so the caller can
 * log a reconciliation as a no-op rather than as a purchase.
 */
export async function grantPack(params: {
  uid: string;
  sku: string;
  transactionId: string;
  purchasedAtMs: number;
}): Promise<boolean> {
  const spec = AI_PACKS[params.sku];
  if (!spec) return false;

  const ref = packRef(params.uid, params.transactionId);

  return admin.firestore().runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (snap.exists) return false; // already granted — a webhook retry

    // Validity runs from the PURCHASE time, not from now. A webhook that
    // arrives late (retry, outage) must not silently extend the window the
    // user was sold.
    const expiresAtMs =
      params.purchasedAtMs + spec.validityDays * 24 * 60 * 60 * 1000;

    const doc: AiPackDoc = {
      sku: params.sku,
      questions: spec.questions,
      remaining: spec.questions,
      pending: 0,
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
 * Unexpired packs with something left, **earliest expiry first**.
 *
 * That order is the spec's (pricing PDF §9) and it is the user-favourable
 * one: spending the pack that dies soonest means fewer questions expire
 * unused. Spending the newest first would quietly waste what they paid for.
 */
export async function activePacks(
  uid: string,
  nowMs: number = Date.now()
): Promise<Array<{ id: string; data: AiPackDoc }>> {
  const snap = await packsCollection(uid)
    .where("expiresAtMs", ">", nowMs)
    .orderBy("expiresAtMs")
    .get();

  return snap.docs
    .map((d) => ({ id: d.id, data: d.data() as AiPackDoc }))
    .filter((p) => (p.data.remaining ?? 0) - (p.data.pending ?? 0) > 0);
}

/** Questions a user could actually spend right now, across all live packs. */
export async function packBalance(
  uid: string,
  nowMs: number = Date.now()
): Promise<number> {
  const packs = await activePacks(uid, nowMs);
  return packs.reduce(
    (sum, p) => sum + Math.max(0, (p.data.remaining ?? 0) - (p.data.pending ?? 0)),
    0
  );
}

/**
 * Reserves one question from the soonest-expiring live pack.
 *
 * Returns the pack id it reserved against, or `null` when the user has no
 * pack credit — the caller then reports the daily limit as exhausted.
 *
 * The read-check-write sits inside one transaction for the same reason the
 * daily ledger's does: two concurrent sends must not both see the last
 * remaining question.
 */
export async function reserveFromPack(
  uid: string,
  nowMs: number = Date.now()
): Promise<string | null> {
  const candidates = await activePacks(uid, nowMs);
  if (candidates.length === 0) return null;

  for (const candidate of candidates) {
    const ref = packRef(uid, candidate.id);
    const reserved = await admin.firestore().runTransaction(async (tx) => {
      const snap = await tx.get(ref);
      if (!snap.exists) return false;
      const data = snap.data() as AiPackDoc;
      // Re-checked INSIDE the transaction: `activePacks` read before it, so
      // by now another request may have taken the last question, or the
      // pack may have expired between the query and here.
      if (data.expiresAtMs <= nowMs) return false;
      if ((data.remaining ?? 0) - (data.pending ?? 0) <= 0) return false;
      tx.update(ref, { pending: (data.pending ?? 0) + 1 });
      return true;
    });
    if (reserved) return candidate.id;
  }
  return null;
}

/** Spends the reserved question: `pending` down, `remaining` down. */
export async function commitPack(uid: string, packId: string): Promise<void> {
  const ref = packRef(uid, packId);
  await admin.firestore().runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (!snap.exists) return;
    const data = snap.data() as AiPackDoc;
    tx.update(ref, {
      pending: Math.max(0, (data.pending ?? 0) - 1),
      remaining: Math.max(0, (data.remaining ?? 0) - 1),
    });
  });
}

/**
 * Hands the reserved question back. `remaining` is untouched — a failed
 * call must leave a PAID balance exactly where it was.
 */
export async function releasePack(uid: string, packId: string): Promise<void> {
  const ref = packRef(uid, packId);
  await admin.firestore().runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (!snap.exists) return;
    const data = snap.data() as AiPackDoc;
    tx.update(ref, { pending: Math.max(0, (data.pending ?? 0) - 1) });
  });
}
