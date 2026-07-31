import { deleteDoc, doc, getDoc, serverTimestamp, setDoc } from 'firebase/firestore';
import type { User } from 'firebase/auth';
import { db } from './firebase';

/** Turns a pending `adminInvites/{email}` into a real `adminUsers/{uid}`.
 *
 *  Why this exists: an admin document is keyed by uid, but someone you want to
 *  invite has no uid until their first sign-in. A super admin leaves an invite
 *  against their email; this runs once, right after that first sign-in.
 *
 *  The security rules (projects/firestore.rules) do the actual enforcement —
 *  they pin the role to the invite and require a verified email, so nothing here
 *  can promote anyone. Returns true if an invite was claimed. */
export async function claimPendingInvite(user: User): Promise<boolean> {
  const email = user.email?.toLowerCase();
  if (!email || !user.emailVerified) return false;

  const inviteRef = doc(db, 'adminInvites', email);
  const invite = await getDoc(inviteRef);
  if (!invite.exists()) return false;

  const roleId = String(invite.data().roleId ?? '');
  if (!roleId) return false;

  await setDoc(doc(db, 'adminUsers', user.uid), {
    uid: user.uid,
    email,
    displayName: user.displayName ?? email,
    roleId,
    status: 'active',
    provider: user.providerData[0]?.providerId ?? 'unknown',
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
    createdBy: `invite:${String(invite.data().invitedBy ?? 'unknown')}`,
  });

  // Spent invites must not linger — otherwise a REVOKED admin could re-claim
  // access simply by signing in again. Failure here is not fatal (the admin doc
  // already exists), so it must not break the sign-in.
  await deleteDoc(inviteRef).catch(() => undefined);

  return true;
}
