import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

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

export const deleteAccount = onCall(
  {
    region: "asia-south1",
    timeoutSeconds: 120,
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
      elapsedMs: Date.now() - startedAtMs,
    });

    return { success: true };
  }
);
