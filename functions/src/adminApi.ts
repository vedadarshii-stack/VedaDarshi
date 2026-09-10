import { onCall, HttpsError, CallableRequest } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {
  VEDIKA_API_KEY,
  VEDIKA_BASE_URL,
  vedikaHeaders,
  REVENUECAT_SECRET_API_KEY,
  REVENUECAT_PROJECT_ID,
} from "./config";

/**
 * Callables for the admin console (`admin/`, React + Vite).
 *
 * BUILT 9 Sep 2026. The console had **no server-side capability at all** —
 * every screen fell back to `src/data/mock.ts`, and the Users screen showed a
 * permanent "denied" banner because `firestore.rules` forbids `list` on
 * `/users` (deliberately: a client must never enumerate people whose
 * documents contain birth details).
 *
 * The fix is not to loosen those rules. It is to do the work here, where the
 * Admin SDK bypasses rules and the caller can be checked properly.
 *
 * ## Every function in this file starts with `requireAdmin`
 *
 * There is exactly one authorisation path and it reads the SAME
 * `adminUsers/{uid}` document the console's own UI gating reads — so a
 * revoked admin loses server access on their next call, with no token
 * refresh, which is the reason that collection exists rather than a custom
 * claim.
 *
 * ⚠️ The console's route guards are UI only. They hide menu items; they do
 * not protect anything. THIS is the enforcement.
 */

/** Permission wildcard held by `super_admin`. */
const ALL_PERMISSIONS = "*";

interface AdminIdentity {
  uid: string;
  roleId: string;
  permissions: string[];
}

/**
 * Throws unless the caller is a signed-in, ACTIVE admin holding `permission`.
 *
 * Fails closed at every step: not signed in, no admin document, status other
 * than active, a role that no longer exists, or a role without the
 * permission. A membership pointing at a deleted role resolves to **zero**
 * permissions rather than inheriting anything.
 */
async function requireAdmin(
  request: CallableRequest,
  permission: string
): Promise<AdminIdentity> {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Sign in required.");
  }

  const db = admin.firestore();
  const memberSnap = await db.collection("adminUsers").doc(uid).get();
  if (!memberSnap.exists) {
    throw new HttpsError("permission-denied", "Not an admin.");
  }
  const member = memberSnap.data() as { roleId?: string; status?: string };
  if (member.status !== "active") {
    throw new HttpsError("permission-denied", "Admin access is not active.");
  }

  const roleId = member.roleId;
  if (!roleId) {
    throw new HttpsError("permission-denied", "No role assigned.");
  }
  const roleSnap = await db.collection("adminRoles").doc(roleId).get();
  if (!roleSnap.exists) {
    // The role was deleted out from under this membership. Zero permissions,
    // never "assume it was fine".
    throw new HttpsError("permission-denied", "Assigned role no longer exists.");
  }
  const permissions =
    ((roleSnap.data() as { permissions?: string[] }).permissions ?? []);

  const allowed =
    permissions.includes(ALL_PERMISSIONS) || permissions.includes(permission);
  if (!allowed) {
    throw new HttpsError(
      "permission-denied",
      `Missing permission: ${permission}`
    );
  }

  return { uid, roleId, permissions };
}

// ---------------------------------------------------------------------------
// Vedika spend
// ---------------------------------------------------------------------------

/**
 * The client's Vedika wallet balance and usage summary.
 *
 * ⚠️ **This exists because the console must NOT call the proxy directly.**
 * `functions/src/index.ts` (the `vedika` function) has no authentication —
 * verified 9 Sep 2026, an unauthenticated GET of
 * `/api/v1/usage/wallet-balance` through it returns 200. Pointing the admin
 * console at that would put the client's financial data behind a URL anyone
 * can call. Routing it through an admin-checked callable keeps the wallet
 * readable only by actual admins.
 *
 * (The proxy's missing auth is a separate, still-open problem — this does not
 * fix it, it just refuses to make it worse.)
 */
export const adminVedikaUsage = onCall(
  { region: "asia-south1", secrets: [VEDIKA_API_KEY], timeoutSeconds: 30 },
  async (request) => {
    // `ai.view`, not a new "billing.view": that permission already exists in
    // the console's catalogue AND in the seeded `support` role, and the
    // inert "AI Usage" nav item is gated on it. Inventing a permission no
    // role holds would have made this callable super-admin-only by accident.
    await requireAdmin(request, "ai.view");

    const base = VEDIKA_BASE_URL.value();
    const headers = { ...vedikaHeaders(), Accept: "application/json" };

    async function get(path: string): Promise<unknown | null> {
      try {
        const res = await fetch(`${base}${path}`, { headers });
        if (!res.ok) {
          console.warn("adminVedikaUsage: upstream", path, res.status);
          return null;
        }
        return await res.json();
      } catch (e) {
        console.warn("adminVedikaUsage: fetch failed", path, e);
        return null;
      }
    }

    // Fetched together, and a failure of one must not lose the others: a
    // dashboard showing the balance but not the breakdown is far more useful
    // than an error page.
    const [wallet, summary] = await Promise.all([
      get("/api/v1/usage/wallet-balance"),
      get("/api/v1/usage/summary"),
    ]);

    return {
      wallet,
      summary,
      fetchedAtMs: Date.now(),
    };
  }
);

// ---------------------------------------------------------------------------
// App users
// ---------------------------------------------------------------------------

/**
 * A page of app end-users for the console's Users screen.
 *
 * ⚠️ **Returns deliberately REDUCED documents.** `/users/{uid}` and its
 * `birthProfiles` subcollection hold date, time and place of birth — personal
 * data under the DPDP Act, and the reason the security rules refuse `list` in
 * the first place. An admin listing needs to identify and support an account;
 * it does not need the birth chart. So this returns identity and account
 * metadata only, and never touches `birthProfiles`.
 *
 * If a future support workflow genuinely needs birth details, that should be
 * a separate, separately-permissioned call — not a widening of this one.
 */
export const adminListUsers = onCall(
  { region: "asia-south1", timeoutSeconds: 30 },
  async (request) => {
    await requireAdmin(request, "users.view");

    const rawLimit = (request.data as { limit?: unknown } | undefined)?.limit;
    const limit = Math.min(
      Math.max(typeof rawLimit === "number" ? rawLimit : 50, 1),
      200
    );
    const startAfterUid = (request.data as { startAfter?: unknown } | undefined)
      ?.startAfter;

    const db = admin.firestore();
    let query = db
      .collection("users")
      .orderBy(admin.firestore.FieldPath.documentId())
      .limit(limit);
    if (typeof startAfterUid === "string" && startAfterUid.length > 0) {
      query = query.startAfter(startAfterUid);
    }

    const snap = await query.get();

    // Entitlements are a separate top-level collection, so the tier has to be
    // joined in. Read in one batch rather than per row.
    const uids = snap.docs.map((d) => d.id);
    const tierByUid = new Map<string, string>();
    if (uids.length > 0) {
      const entSnaps = await db.getAll(
        ...uids.map((uid) => db.collection("entitlements").doc(uid))
      );
      for (const ent of entSnaps) {
        if (!ent.exists) continue;
        const tier = (ent.data() as { tier?: string }).tier;
        if (tier) tierByUid.set(ent.id, tier);
      }
    }

    const users = snap.docs.map((doc) => {
      const d = doc.data() as Record<string, unknown>;
      return {
        uid: doc.id,
        displayName: (d.displayName as string) ?? null,
        email: (d.email as string) ?? null,
        photoUrl: (d.photoUrl as string) ?? null,
        providers: (d.providers as string[]) ?? [],
        locale: (d.locale as string) ?? null,
        createdAt:
          d.createdAt instanceof admin.firestore.Timestamp
            ? d.createdAt.toMillis()
            : null,
        updatedAt:
          d.updatedAt instanceof admin.firestore.Timestamp
            ? d.updatedAt.toMillis()
            : null,
        // Free is the correct answer for a missing entitlement document — the
        // webhook only writes when something changes, so absence is the
        // normal state for most people.
        tier: tierByUid.get(doc.id) ?? "free",
      };
    });

    return {
      users,
      // Null when this page was not full, i.e. there is nothing after it.
      nextCursor: snap.docs.length === limit ? snap.docs.at(-1)?.id : null,
    };
  }
);

// ---------------------------------------------------------------------------
// Push notifications
// ---------------------------------------------------------------------------

const SUPPORTED_LOCALES = ["en", "hi", "te", "ta", "kn"] as const;

/**
 * Sends a push notification from the console's Notification Composer.
 *
 * BUILT 9 Sep 2026. The composer's phone preview has been live since 29 Jul
 * and the Flutter client has been able to RECEIVE and display a push since
 * 31 Jul — but **nothing could send one**. That was the last missing half.
 *
 * ## Topics, not per-token fan-out
 *
 * Sending to a locale means `FCM topic 'locale_hi'`, not iterating every
 * token document. Fan-out costs one API call per device and has to be
 * re-implemented with batching and retry as the user base grows; a topic send
 * is one call regardless of audience size, and FCM handles delivery.
 *
 * ⚠️ **This requires the client to SUBSCRIBE to its locale topic**, which it
 * does not do yet — `PushNotificationService` registers tokens but calls
 * `subscribeToTopic` nowhere. Until that ships, a locale-targeted send
 * reaches nobody. `target: "all"` works today via the `all_users` topic only
 * once the client subscribes to that too. **Do not report locale targeting as
 * working until the client half lands.**
 *
 * A single-token test send (`token: "..."`) works right now with no client
 * change, which is what makes this testable.
 */
export const adminSendNotification = onCall(
  { region: "asia-south1", timeoutSeconds: 60 },
  async (request) => {
    const identity = await requireAdmin(request, "notifications.send");

    const data = (request.data ?? {}) as {
      title?: unknown;
      body?: unknown;
      target?: unknown;
      locale?: unknown;
      token?: unknown;
      route?: unknown;
    };

    const title = typeof data.title === "string" ? data.title.trim() : "";
    const body = typeof data.body === "string" ? data.body.trim() : "";
    if (!title || !body) {
      throw new HttpsError(
        "invalid-argument",
        "Both title and body are required."
      );
    }
    // FCM itself allows far more, but a notification that does not fit on a
    // lock screen is a notification nobody reads.
    if (title.length > 100 || body.length > 240) {
      throw new HttpsError(
        "invalid-argument",
        "Title must be <= 100 and body <= 240 characters."
      );
    }

    const target = typeof data.target === "string" ? data.target : "all";
    const route = typeof data.route === "string" ? data.route : undefined;

    // `data.route` is read by the client's notification-tap handler. It is
    // reserved for deep links and currently always opens NotificationsScreen.
    const message: admin.messaging.Message = {
      notification: { title, body },
      data: { ...(route ? { route } : {}) },
      android: {
        priority: "high",
        notification: {
          channelId: "vedadarshi_default",
          // Must match res/values/colors.xml `notification_accent`.
          color: "#E8720C",
        },
      },
    } as admin.messaging.Message;

    let destination: string;
    if (target === "token") {
      const token = typeof data.token === "string" ? data.token.trim() : "";
      if (!token) {
        throw new HttpsError("invalid-argument", "A token is required.");
      }
      (message as { token?: string }).token = token;
      destination = "token";
    } else if (target === "locale") {
      const locale = typeof data.locale === "string" ? data.locale : "";
      if (!SUPPORTED_LOCALES.includes(locale as (typeof SUPPORTED_LOCALES)[number])) {
        throw new HttpsError(
          "invalid-argument",
          `locale must be one of ${SUPPORTED_LOCALES.join(", ")}`
        );
      }
      (message as { topic?: string }).topic = `locale_${locale}`;
      destination = `locale_${locale}`;
    } else {
      (message as { topic?: string }).topic = "all_users";
      destination = "all_users";
    }

    let messageId: string;
    try {
      messageId = await admin.messaging().send(message);
    } catch (e) {
      console.error("adminSendNotification: send failed", { destination }, e);
      throw new HttpsError("internal", "Send failed.");
    }

    // An audit row, because a push cannot be recalled. Who sent what, to
    // whom, and when — written AFTER a successful send so the log never
    // claims something went out that did not.
    try {
      await admin
        .firestore()
        .collection("notificationSends")
        .add({
          title,
          body,
          target,
          destination,
          route: route ?? null,
          messageId,
          sentByUid: identity.uid,
          sentByRole: identity.roleId,
          sentAt: admin.firestore.FieldValue.serverTimestamp(),
        });
    } catch (e) {
      // The push is already delivered; failing the call now would invite a
      // duplicate send.
      console.warn("adminSendNotification: audit write failed", e);
    }

    return { messageId, destination };
  }
);

// ---------------------------------------------------------------------------
// Dashboard
// ---------------------------------------------------------------------------

/**
 * Real numbers for the console's Dashboard.
 *
 * ⚠️ **REPLACES FABRICATED FIGURES.** Until 9 Sep 2026 that screen rendered
 * hardcoded strings from `src/data/mock.ts`: "48,320 users", "6,905 active
 * subscriptions", "₹11.4L revenue (July)", "12,441 AI questions today", and a
 * six-month growth chart — none of it real. The true figures at the time were
 * 18 users, 0 subscriptions and £0/₹0 revenue.
 *
 * That is a worse failure than showing nothing: the screen was screenshot-
 * ready and would have been read as a business report. Every number below is
 * counted or fetched, and anything unavailable comes back `null` for the UI
 * to render as "—" rather than as a plausible-looking zero.
 */
export const adminDashboardStats = onCall(
  {
    region: "asia-south1",
    secrets: [VEDIKA_API_KEY, REVENUECAT_SECRET_API_KEY],
    timeoutSeconds: 60,
  },
  async (request) => {
    await requireAdmin(request, "dashboard.view");
    const db = admin.firestore();

    // `count()` aggregations, not full reads: the whole point is a number,
    // and paging every user document to length-check it would get slower as
    // the app succeeds.
    async function countOf(
      query: admin.firestore.Query | admin.firestore.CollectionReference
    ): Promise<number | null> {
      try {
        return (await query.count().get()).data().count;
      } catch (e) {
        console.warn("adminDashboardStats: count failed", e);
        return null;
      }
    }

    const [totalUsers, paidSubscribers, sandboxEntitlements] = await Promise.all([
      countOf(db.collection("users")),
      countOf(db.collection("entitlements").where("isActive", "==", true)),
      // Surfaced separately so a tester's entitlement can never be mistaken
      // for revenue — the same reason the webhook records `isSandbox`.
      countOf(db.collection("entitlements").where("isSandbox", "==", true)),
    ]);

    // ---- Vedika spend ----------------------------------------------------
    let vedikaBalanceUsd: string | null = null;
    let vedikaQueries: number | null = null;
    let vedikaSpendUsd: string | null = null;
    try {
      const headers = { ...vedikaHeaders(), Accept: "application/json" };
      const base = VEDIKA_BASE_URL.value();
      const [walletRes, summaryRes] = await Promise.all([
        fetch(`${base}/api/v1/usage/wallet-balance`, { headers }),
        fetch(`${base}/api/v1/usage/summary`, { headers }),
      ]);
      if (walletRes.ok) {
        const w = (await walletRes.json()) as { balanceUsd?: string };
        vedikaBalanceUsd = w.balanceUsd ?? null;
      }
      if (summaryRes.ok) {
        const sJson = (await summaryRes.json()) as {
          data?: { totalQueries?: number; totalCost?: string };
        };
        vedikaQueries = sJson.data?.totalQueries ?? null;
        vedikaSpendUsd = sJson.data?.totalCost ?? null;
      }
    } catch (e) {
      console.warn("adminDashboardStats: vedika failed", e);
    }

    // ---- Revenue, from RevenueCat ---------------------------------------
    // The store is the only honest source. Nothing here is derived from our
    // own entitlement documents, which record ACCESS, not money.
    let revenue: { activeSubscriptions: number | null; revenue28d: string | null } = {
      activeSubscriptions: null,
      revenue28d: null,
    };
    try {
      const res = await fetch(
        `https://api.revenuecat.com/v2/projects/${REVENUECAT_PROJECT_ID}/metrics/overview`,
        {
          headers: {
            Authorization: `Bearer ${REVENUECAT_SECRET_API_KEY.value()}`,
            Accept: "application/json",
          },
        }
      );
      if (res.ok) {
        const body = (await res.json()) as {
          metrics?: Array<{ id?: string; value?: number }>;
        };
        const byId = new Map(
          (body.metrics ?? []).map((m) => [m.id, m.value])
        );
        revenue = {
          activeSubscriptions: byId.get("active_subscriptions") ?? null,
          revenue28d:
            byId.get("revenue") != null ? String(byId.get("revenue")) : null,
        };
      } else {
        console.warn("adminDashboardStats: revenuecat", res.status);
      }
    } catch (e) {
      console.warn("adminDashboardStats: revenuecat failed", e);
    }

    return {
      totalUsers,
      paidSubscribers,
      sandboxEntitlements,
      vedikaBalanceUsd,
      vedikaQueries,
      vedikaSpendUsd,
      ...revenue,
      fetchedAtMs: Date.now(),
    };
  }
);
