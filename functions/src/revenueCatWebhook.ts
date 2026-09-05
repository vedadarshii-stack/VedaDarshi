import { onRequest } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {
  REVENUECAT_PROJECT_ID,
  REVENUECAT_SECRET_API_KEY,
  REVENUECAT_WEBHOOK_AUTH,
} from "./config";

/**
 * Receives RevenueCat webhooks and mirrors the user's entitlement into
 * Firestore, where the BACKEND can trust it.
 *
 * BUILT 5 Sep 2026. Until now nothing on the server knew whether a user had
 * paid: `aiCredits.ts` had a `TODO(entitlements)` and fell back to a manual
 * `aiDailyCreditLimitOverride` field. The app read entitlement live from the
 * RevenueCat SDK, which is fine for showing or hiding UI, but a client can
 * lie — so no server-side quota or gate could depend on it.
 *
 * ## Why it re-fetches instead of trusting the event body
 *
 * The webhook payload names the event ("RENEWAL", "CANCELLATION", …) and the
 * entitlements at that moment. Acting on that alone is fragile: webhooks can
 * arrive OUT OF ORDER or more than once, so a late-delivered CANCELLATION
 * could overwrite a newer RENEWAL and silently strip a paying user's access.
 *
 * Instead every event is treated as nothing more than "this user changed —
 * go look". We then read the AUTHORITATIVE subscriber record from
 * RevenueCat's own API and write that. The result is idempotent and
 * order-independent: replaying yesterday's events produces today's correct
 * answer, because the answer never comes from the event.
 *
 * ## Trust boundary
 *
 * The endpoint is public — RevenueCat has to reach it — so the shared
 * `Authorization` secret is the ONLY thing standing between a stranger and
 * the ability to grant themselves Platinum. It is compared in constant time
 * and the function refuses anything that does not match.
 */
export const revenueCatWebhook = onRequest(
  {
    region: "asia-south1",
    secrets: [REVENUECAT_WEBHOOK_AUTH, REVENUECAT_SECRET_API_KEY],
    timeoutSeconds: 60,
    memory: "256MiB",
  },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).json({ error: "POST only" });
      return;
    }

    const expected = REVENUECAT_WEBHOOK_AUTH.value();
    const provided = req.get("Authorization") ?? "";
    if (!expected || !constantTimeEquals(provided, expected)) {
      // Deliberately terse: an attacker probing this endpoint learns only
      // that it exists, never whether they were close.
      console.warn("revenueCatWebhook: rejected unauthenticated request");
      res.status(401).json({ error: "unauthorized" });
      return;
    }

    const appUserId = req.body?.event?.app_user_id;
    const eventType = req.body?.event?.type ?? "UNKNOWN";
    // "SANDBOX" for a licence-tester / test purchase, "PRODUCTION" for a real
    // one. Both webhooks point at THIS endpoint with the same secret, so this
    // field is the only thing distinguishing them — see `environment` on the
    // stored document for why we record it rather than filter on it.
    const environment = String(
      req.body?.event?.environment ?? "UNKNOWN"
    ).toUpperCase();
    if (typeof appUserId !== "string" || appUserId.length === 0) {
      // 200, not 4xx: RevenueCat retries non-2xx, and retrying a malformed
      // payload forever helps nobody. Log it and move on.
      console.error("revenueCatWebhook: event without app_user_id", req.body);
      res.status(200).json({ ok: true, skipped: "no app_user_id" });
      return;
    }

    // The app aliases the RevenueCat app-user id onto the Firebase uid
    // (`subscriptionStatusProvider` calls `logIn(uid)`), so they are the same
    // string. An ANONYMOUS RevenueCat id ($RCAnonymousID:…) belongs to a user
    // who has not signed in; there is no Firebase document to write, and
    // inventing one would create orphans.
    if (appUserId.startsWith("$RCAnonymousID:")) {
      console.log("revenueCatWebhook: anonymous subscriber, nothing to sync", {
        eventType,
      });
      res.status(200).json({ ok: true, skipped: "anonymous" });
      return;
    }

    try {
      const entitlement = await fetchEntitlement(appUserId);
      await admin
        .firestore()
        .collection("entitlements")
        .doc(appUserId)
        .set(
          {
            ...entitlement,
            uid: appUserId,
            lastEventType: eventType,
            // SANDBOX purchases DO grant entitlement, deliberately.
            //
            // Licence-tester purchases are the only way to exercise the
            // paywall before the payments profile clears, and blocking them
            // would make the whole flow untestable. But a sandbox grant is
            // NOT a real customer, so it is recorded rather than hidden:
            // anyone auditing who is paying can filter on this field, and a
            // tester's Platinum cannot be mistaken for revenue.
            //
            // ⚠️ If sandbox entitlements ever need to be refused in
            // production, do it HERE — not in the app, which cannot be
            // trusted to check.
            environment,
            isSandbox: environment === "SANDBOX",
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true }
        );
      console.log("revenueCatWebhook: synced", {
        uid: appUserId,
        eventType,
        environment,
        tier: entitlement.tier,
      });
      res.status(200).json({ ok: true });
    } catch (e) {
      // 500 so RevenueCat RETRIES. A transient failure here would otherwise
      // leave a paying user without the access they just bought.
      console.error("revenueCatWebhook: sync failed", { appUserId }, e);
      res.status(500).json({ error: "sync failed" });
    }
  }
);

/** Tier ranks, mirroring `subscription_tier.dart`. */
const TIER_BY_ENTITLEMENT: Record<string, number> = {
  vedadarshi_bronze: 1,
  vedadarshi_silver: 2,
  vedadarshi_gold: 3,
  vedadarshi_platinum: 4,
};
const TIER_NAMES = ["free", "bronze", "silver", "gold", "platinum"] as const;

/**
 * Daily AI question allowance per tier, from the Access Control Matrix.
 *
 * ⚠️ These numbers are TOTALS INCLUDING the free daily question — the
 * pricing PDF's §6 says "2 AI Questions per day (including free daily
 * question)". Do not add the free one on top.
 */
const AI_LIMIT_BY_TIER: Record<string, number> = {
  free: 1,
  bronze: 2,
  silver: 4,
  gold: 7,
  platinum: 10,
};

interface Entitlement {
  tier: string;
  tierRank: number;
  isActive: boolean;
  aiDailyLimit: number;
  activeEntitlements: string[];
  expiresAtMs: number | null;
}

/**
 * Reads the subscriber's CURRENT state from RevenueCat.
 *
 * Tiers are CUMULATIVE — a Platinum subscriber holds all four entitlements —
 * so the tier is the HIGHEST rank present, never the first one found.
 */
async function fetchEntitlement(appUserId: string): Promise<Entitlement> {
  const key = REVENUECAT_SECRET_API_KEY.value();
  const url =
    `https://api.revenuecat.com/v2/projects/${REVENUECAT_PROJECT_ID}` +
    `/customers/${encodeURIComponent(appUserId)}/subscriptions`;

  const response = await fetch(url, {
    headers: { Authorization: `Bearer ${key}`, Accept: "application/json" },
  });

  // 404 = no such customer at RevenueCat, which is a real and correct answer
  // for someone who never opened the paywall: they are on the free tier.
  if (response.status === 404) return freeEntitlement();
  if (!response.ok) {
    throw new Error(`RevenueCat ${response.status}: ${await response.text()}`);
  }

  const body = (await response.json()) as {
    items?: Array<{
      status?: string;
      entitlements?: { items?: Array<{ lookup_key?: string }> };
      current_period_ends_at?: number;
    }>;
  };

  const active: string[] = [];
  let expiresAtMs: number | null = null;
  for (const sub of body.items ?? []) {
    // Only subscriptions actually granting access right now. A cancelled
    // subscription still inside its paid period counts — the user paid for
    // that time and must keep it until it lapses.
    const live = sub.status === "active" || sub.status === "in_grace_period";
    if (!live) continue;
    for (const ent of sub.entitlements?.items ?? []) {
      if (ent.lookup_key) active.push(ent.lookup_key);
    }
    if (typeof sub.current_period_ends_at === "number") {
      expiresAtMs = Math.max(expiresAtMs ?? 0, sub.current_period_ends_at);
    }
  }

  const rank = active.reduce(
    (highest, id) => Math.max(highest, TIER_BY_ENTITLEMENT[id] ?? 0),
    0
  );
  const tier = TIER_NAMES[rank];
  return {
    tier,
    tierRank: rank,
    isActive: rank > 0,
    aiDailyLimit: AI_LIMIT_BY_TIER[tier] ?? AI_LIMIT_BY_TIER.free,
    activeEntitlements: Array.from(new Set(active)),
    expiresAtMs,
  };
}

function freeEntitlement(): Entitlement {
  return {
    tier: "free",
    tierRank: 0,
    isActive: false,
    aiDailyLimit: AI_LIMIT_BY_TIER.free,
    activeEntitlements: [],
    expiresAtMs: null,
  };
}

/**
 * Length-independent comparison, so timing cannot reveal how much of the
 * secret a guess got right.
 */
function constantTimeEquals(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return diff === 0;
}
