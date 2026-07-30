import type { ReactNode } from 'react';
import { useAdminProfile } from '../lib/adminProfileContext';
import { hasPermission } from '../lib/permissions';
import type { Permission } from '../lib/permissions';
import { AccessNotice } from './AccessNotice';
import { PageSkeleton } from './PageSkeleton';

/** Per-screen permission gate.
 *
 *  Hiding an item in the sidebar is cosmetic — this is what stops someone
 *  typing /plans directly. It is still only a UI guard: the real enforcement is
 *  the Firestore rules in projects/firestore.rules. */
export function RequirePermission({
  need,
  children,
}: {
  need: Permission;
  children: ReactNode;
}) {
  const state = useAdminProfile();

  if (state.status === 'loading') {
    return <PageSkeleton label="Checking your permissions" />;
  }

  // The static walkthrough has no role, and reads no real data.
  if (state.status === 'concept') {
    return <>{children}</>;
  }

  if (state.status === 'error') {
    return (
      <AccessNotice
        title="Could not read your role"
        detail={state.message}
        hint="If this says the request was denied, the console role rules in projects/firestore.rules have not been deployed to this Firebase project yet."
      />
    );
  }

  if (state.status === 'not-admin') {
    return (
      <AccessNotice
        title="No console access"
        detail={`${state.email ?? 'This account'} is not listed as a Vedadarshi admin.`}
        hint="A super admin can grant access by adding a document to adminUsers keyed by your Firebase Auth uid."
      />
    );
  }

  if (!hasPermission(state.profile.permissions, need)) {
    return (
      <AccessNotice
        title="Not available for your role"
        detail={`The ${state.profile.roleName} role does not include “${need}”.`}
        hint="Ask a super admin to change your role, or add this permission to the role in adminRoles."
      />
    );
  }

  return <>{children}</>;
}
