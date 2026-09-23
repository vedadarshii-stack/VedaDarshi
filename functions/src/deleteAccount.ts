import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {
  REVENUECAT_PROJECT_ID,
  REVENUECAT_SECRET_API_KEY,
} from "./config";
import { deleteRenderedReports } from "./reportRenderer";

/**
 * Permanently deletes the signed-in user's account and all their data.
 *
 * WHY THIS HAS TO BE A CLOUD FUNCTION, NOT A CLIENT DELETE: the deployed
 * Firestore rules (`projects/firestore.rules`, `/users/{userId}`) have
 * `allow delete: if false` on the account document specifically so this
 * can't happen client-side — a client delete of `/users/{uid}` alone would
 * leave every subcollection (`birthProfiles`, `fcmTokens`, `aiChats`, and
 * anything added later) orphaned, since Firestore does not cascade deletes.
 * Only the Admin SDK (this function) can walk and remove the whole subtree.
 *
 * ORDER MATTERS — Firestore is deleted BEFORE the Auth user, never after:
 *   1. If Auth were deleted first and the Firestore delete then failed
 *      partway, the user's token would already be revoked, leaving them
 *      with no authenticated way to retry `deleteAccount` — their data
 *      would be stuck half-deleted forever.
 *   2. Deleting Firestore first means a mid-way Firestore failure surfaces
 *      as a normal thrown error while the caller is STILL signed in, so
 *      the client can simply call `deleteAccount` again.
 *   3. Only once the Firestore subtree is confirmed gone do we take the
 *      irreversible step of deleting the Auth user.
 *
 * SUBCOLLECTIONS ARE ENUMERATED, NOT HARDCODED: `mobile/lib/core/data/
 * firestore_refs.dart` currently defines `birthProfiles`, `fcmTokens` and
 * `aiChats`, but hardcoding that list here would silently orphan any
 * subcollection added later (e.g. a future `reports` or `payments`
 * collection) the day someone adds it to the Dart side and forgets this
 * file exists. `listCollections()` discovers whatever is actually there at
 * delete time, and `firestore.recursiveDelete()` (Admin SDK, backed by a
 * BulkWriter — batches and retries internally) removes each of them plus
 * the account document itself in one call, so nothing needs to be named
 * twice.
 *
 * IDEMPOTENT: safe to call more than once, or to retry after a transient
 * failure.
 *   - A missing/already-deleted `/users/{uid}` document (or one whose
 *     subcollections are already gone) is not an error — `recursiveDelete`
 *     on a reference with nothing left under it is a no-op.
 *   - An already-deleted Auth user (`auth/user-not-found`) is treated as
 *     success rather than surfaced as a failure.
 */

const FIRESTORE_DELETE_TIMEOUT_MESSAGE =
  "Could not delete your account data. Nothing was removed — please try again.";

/**
 * Top-level collection recording RevenueCat customers we failed to delete.
 *
 * Deliberately NOT under `/users/{uid}` — that whole subtree is about to be
 * erased, so a record written there would delete itself moments later. This
 * is the sweep list: each doc is a customer whose Firebase account is gone
 * but whose purchase records may still exist at RevenueCat.
 *
 * Nothing consumes it yet. It exists so the gap is VISIBLE and fixable
 * rather than silent — an operator can list it and retry by hand, and a
 * sweeper job can be written later. An empty collection means nothing has
 * failed.
 */
const ORPHANED_RC_COLLECTION = "orphanedRevenueCatCustomers";

/**
 * Same idea as [ORPHANED_RC_COLLECTION], for rendered report PDFs we failed
 * to remove from Cloud Storage. Also top-level, for the same reason: a
 * record under `/users/{uid}` would be erased seconds later by the very
 * delete it is recording.
 *
 * This one matters MORE than the RevenueCat list, because these are our own
 * files in our own bucket — a leftover here is personal astrological data
 * we promised to delete, not a third party's billing record.
 */
const ORPHANED_REPORTS_COLLECTION = "orphanedReportArtifacts";

/**
 * Deletes the customer's RevenueCat records.
 *
 * ADDED 2 Sep 2026, closing a real gap: the app aliases the RevenueCat
 * app-user id onto the Firebase uid (`subscriptionStatusProvider` calls
 * `logIn(uid)`), so before this, deleting an account left purchase history
 * and subscriber attributes behind, keyed to a uid that no longer resolved.
 * For a feature whose entire purpose is honouring a Play data-deletion
 * promise, that was a hole.
 *
 * **Tries V2 first, falls back to V1.** RevenueCat's dashboard can mint
 * either a scoped V2 key or a legacy all-access V1 key and they are not
 * interchangeable across API versions, so rather than pinning this to
 * whichever kind happened to be created, it attempts the modern endpoint and
 * retries on the legacy one when the key is rejected as unauthorized. That
 * makes the function work with either key without anyone having to remember
 * which was issued.
 *
 * 🚨 **THIS HAS NEVER ACTUALLY SUCCEEDED IN PRODUCTION — discovered
 * 23 Sep 2026.** Every deletion since 2 Sep has logged a 403 and written an
 * orphan record. The 2 Sep note calling this gap "closed" was wrong: the
 * code shipped, but the credential behind it cannot perform the operation.
 *
 * Probed directly against the live API with the configured secret:
 *
 * | Call | Result |
 * |---|---|
 * | `GET /v2/projects` | 200 — the key is valid |
 * | `GET /v2/…/customers/{id}` | 404 — read permission is present |
 * | `DELETE /v2/…/customers/{id}` | **403 — "The API key needs at least the `customer_information:customers:read_write` permission defined"** |
 * | `DELETE /v1/subscribers/{id}` | 403 code 7723 — "secret API key incompatible with RevenueCat API V1" |
 *
 * So `REVENUECAT_SECRET_API_KEY` is a V2 key holding customers:**read**
 * only. Two consequences worth being precise about:
 *
 *  1. **The fix is a dashboard permission change, not a code change** —
 *     grant `customer_information:customers:read_write` to the existing key
 *     (or issue a new one with it and re-set the secret). Nothing here
 *     needs editing once that is done.
 *  2. **The V1 fallback is dead code for THIS key**, because V1 rejects V2
 *     keys by construction rather than for lack of permission. It is kept
 *     anyway: it costs one failed request on an already-failing path, and
 *     it still earns its place if a legacy key is ever configured.
 *
 * Everything in `orphanedReportArtifacts`' sibling collection
 * [ORPHANED_RC_COLLECTION] is a uid that needs re-deleting by hand once the
 * permission is granted.
 *
 * Returns true on success (INCLUDING 404 — a customer who never opened the
 * paywall simply does not exist at RevenueCat, which is not a failure).
 */
async function deleteRevenueCatCustomer(uid: string): Promise<boolean> {
  const key = REVENUECAT_SECRET_API_KEY.value();
  if (!key) {
    console.warn("deleteAccount: no RevenueCat key configured", { uid });
    return false;
  }

  const attempts = [
    `https://api.revenuecat.com/v2/projects/${REVENUECAT_PROJECT_ID}/customers/${encodeURIComponent(uid)}`,
    `https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(uid)}`,
  ];

  let lastStatus = 0;
  let lastBody = "";
  for (const url of attempts) {
    try {
      const response = await fetch(url, {
        method: "DELETE",
        headers: {
          Authorization: `Bearer ${key}`,
          "Content-Type": "application/json",
        },
      });
      // 404 = no such customer. Idempotent success, not an error.
      if (response.ok || response.status === 404) return true;
      lastStatus = response.status;
      // RevenueCat says exactly which permission is missing, and without
      // that line a 403 is indistinguishable from a wrong key, a wrong
      // project id or a revoked key. Capped because it is third-party text
      // going into our logs.
      lastBody = (await response.text().catch(() => "")).slice(0, 300);
      // Only an auth rejection is worth retrying on the other API version;
      // anything else (429, 5xx) would fail the same way twice.
      if (response.status !== 401 && response.status !== 403) break;
    } catch (e) {
      console.error("deleteAccount: RevenueCat request threw", { uid }, e);
      return false;
    }
  }
  console.error("deleteAccount: RevenueCat delete failed", {
    uid,
    lastStatus,
    lastBody,
  });
  return false;
}

export const deleteAccount = onCall(
  {
    region: "asia-south1",
    timeoutSeconds: 120,
    secrets: [REVENUECAT_SECRET_API_KEY],
  },
  async (request) => {
    // uid comes ONLY from the verified auth token — never from
    // request.data. Taking it from the request body would let any signed-in
    // caller delete an arbitrary account by uid.
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "Sign in required.");
    }

    const startedAtMs = Date.now();
    const db = admin.firestore();
    const userDocRef = db.collection("users").doc(uid);

    // ---- 0. REVENUECAT: before anything irreversible --------------------
    //
    // Ordered FIRST on purpose. At this point nothing has been destroyed, so
    // a failure here is recoverable and the user is still signed in.
    //
    // But a RevenueCat outage must NOT block someone from deleting their
    // account — the right to delete cannot depend on a third party being up.
    // So a failure is recorded for sweeping and the deletion continues,
    // rather than either aborting or being silently swallowed.
    const revenueCatDeleted = await deleteRevenueCatCustomer(uid);
    if (!revenueCatDeleted) {
      try {
        await db.collection(ORPHANED_RC_COLLECTION).doc(uid).set({
          uid,
          failedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      } catch (e) {
        // Even the bookkeeping is best-effort — it must never be the reason
        // an account deletion fails.
        console.error("deleteAccount: could not record RC orphan", { uid }, e);
      }
    }

    // ---- 0b. STORAGE: rendered report PDFs ------------------------------
    //
    // Before Firestore, for the same reason RevenueCat is: nothing the user
    // cannot retry has happened yet, and this step is idempotent, so a
    // later failure that sends them back through `deleteAccount` re-runs it
    // harmlessly.
    //
    // ⚠️ This CANNOT be folded into the `listCollections()` enumeration
    // below. That discovers Firestore subcollections; these files live in
    // Cloud Storage, which it cannot see. Verified the hard way on
    // 23 Sep 2026 — see `deleteRenderedReports`.
    //
    // Non-fatal, like RevenueCat: refusing to delete the account would not
    // remove these files, it would just leave more data behind.
    const reportsDeleted = await deleteRenderedReports(uid);
    if (!reportsDeleted) {
      try {
        await db.collection(ORPHANED_REPORTS_COLLECTION).doc(uid).set({
          uid,
          storagePrefix: `detailedReports/${uid}/`,
          failedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      } catch (e) {
        console.error(
          "deleteAccount: could not record report orphan",
          { uid },
          e
        );
      }
    }

    // ---- 1. FIRESTORE: enumerate + recursively delete -------------------
    let subcollectionNames: string[] = [];
    try {
      const subcollections = await userDocRef.listCollections();
      subcollectionNames = subcollections.map((c) => c.id);

      // Deletes every subcollection under /users/{uid} AND the user
      // document itself in one call. Works even if the document has no
      // fields (or does not "exist" in the has-data sense) but still has
      // subcollections under it — a real Firestore possibility this
      // function must not miss.
      await db.recursiveDelete(userDocRef);
    } catch (e) {
      // A genuine Firestore failure here must NOT proceed to delete the
      // Auth user (see the ordering comment above) — the caller is still
      // authenticated and can retry.
      console.error("deleteAccount: Firestore delete failed", { uid }, e);
      throw new HttpsError("internal", FIRESTORE_DELETE_TIMEOUT_MESSAGE);
    }

    console.log("deleteAccount: Firestore subtree deleted", {
      uid,
      subcollections: subcollectionNames,
      elapsedMs: Date.now() - startedAtMs,
    });

    // ---- 2. AUTH: delete last, once Firestore is confirmed gone ---------
    try {
      await admin.auth().deleteUser(uid);
    } catch (e) {
      const code = (e as { code?: string } | null)?.code;
      if (code === "auth/user-not-found") {
        // Already gone (e.g. a retried call after the first attempt's
        // Firestore step succeeded but the response was lost) — this is
        // success, not a failure.
        console.log("deleteAccount: Auth user already deleted", { uid });
      } else {
        // Firestore data is already gone at this point and cannot be
        // un-deleted; surface the error so the caller knows the Auth
        // account itself still needs attention (e.g. a manual retry or
        // support follow-up), rather than reporting a false success.
        console.error("deleteAccount: Auth delete failed", { uid }, e);
        throw new HttpsError(
          "internal",
          "Your data was deleted, but removing your sign-in account failed. Please try again or contact support."
        );
      }
    }

    console.log("deleteAccount: completed", {
      uid,
      revenueCatDeleted,
      reportsDeleted,
      elapsedMs: Date.now() - startedAtMs,
    });

    // `success` reports the ACCOUNT deletion, which did happen. RevenueCat
    // and the stored report PDFs are reported separately rather than folded
    // in — the client shows the same confirmation either way (the account
    // really is gone), but the caller and the logs can tell the difference.
    return { success: true, revenueCatDeleted, reportsDeleted };
  }
);
