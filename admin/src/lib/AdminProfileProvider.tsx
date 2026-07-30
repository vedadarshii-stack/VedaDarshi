import { useEffect, useState } from 'react';
import type { ReactNode } from 'react';
import { doc, getDoc } from 'firebase/firestore';
import { db } from './firebase';
import { useAuth } from './authContext';
import { isConceptMode } from './conceptMode';
import { AdminProfileContext } from './adminProfileContext';
import type { AdminProfileState } from './adminProfileContext';

/** Resolves the signed-in user's console role from Firestore:
 *    adminUsers/{uid}.roleId → adminRoles/{roleId}.permissions
 *
 *  Two reads, once per sign-in. Kept as documents rather than custom claims so
 *  a role change takes effect on the next page load instead of after a token
 *  refresh — see the BOOTSTRAP note in projects/firestore.rules. */
export function AdminProfileProvider({ children }: { children: ReactNode }) {
  const { user, loading } = useAuth();
  const [state, setState] = useState<AdminProfileState>({ status: 'loading' });

  useEffect(() => {
    if (loading) {
      setState({ status: 'loading' });
      return;
    }

    if (!user) {
      setState(isConceptMode() ? { status: 'concept' } : { status: 'not-admin', email: null });
      return;
    }

    let cancelled = false;
    setState({ status: 'loading' });

    (async () => {
      const membership = await getDoc(doc(db, 'adminUsers', user.uid));

      if (!membership.exists() || membership.data().status !== 'active') {
        if (!cancelled) setState({ status: 'not-admin', email: user.email });
        return;
      }

      const roleId = String(membership.data().roleId ?? '');
      const role = await getDoc(doc(db, 'adminRoles', roleId));
      const roleData = role.exists() ? role.data() : null;

      if (cancelled) return;
      setState({
        status: 'ready',
        profile: {
          uid: user.uid,
          email: user.email,
          displayName: user.displayName,
          roleId,
          // A membership pointing at a deleted role must not silently become
          // all-powerful, so the fallback grants nothing.
          roleName: String(roleData?.name ?? roleId ?? 'Unknown role'),
          permissions: Array.isArray(roleData?.permissions)
            ? (roleData.permissions as string[])
            : [],
          canManageAdmins: roleData?.canManageAdmins === true,
        },
      });
    })().catch((error: unknown) => {
      if (cancelled) return;
      setState({
        status: 'error',
        message: error instanceof Error ? error.message : 'Could not read your admin role',
      });
    });

    return () => {
      cancelled = true;
    };
  }, [user, loading]);

  return <AdminProfileContext.Provider value={state}>{children}</AdminProfileContext.Provider>;
}
