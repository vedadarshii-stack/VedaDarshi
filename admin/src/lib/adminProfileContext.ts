import { createContext, useContext } from 'react';
import type { Permission } from './permissions';
import { hasPermission } from './permissions';

/** Who the signed-in operator is, as far as the console is concerned. */
export type AdminProfile = {
  uid: string;
  email: string | null;
  displayName: string | null;
  roleId: string;
  /** Human label from adminRoles/{roleId}.name, e.g. "Super Admin". */
  roleName: string;
  permissions: readonly string[];
  canManageAdmins: boolean;
};

export type AdminProfileState =
  | { status: 'loading' }
  /** Signed in and listed in /adminUsers with status 'active'. */
  | { status: 'ready'; profile: AdminProfile }
  /** Signed in, but no active /adminUsers row — not console staff. */
  | { status: 'not-admin'; email: string | null }
  /** The role lookup itself failed (rules not deployed yet, offline, …). */
  | { status: 'error'; message: string };

export const AdminProfileContext = createContext<AdminProfileState | null>(null);

export function useAdminProfile(): AdminProfileState {
  const context = useContext(AdminProfileContext);
  if (!context) {
    throw new Error('useAdminProfile must be used inside <AdminProfileProvider>');
  }
  return context;
}

/** Permission check that resolves the current profile for you.
 *
 *  Every state other than `ready` grants nothing — fail closed. There is no
 *  longer a state that grants everything: the `concept` bypass was removed
 *  9 Sep 2026. */
export function useCan(permission: Permission): boolean {
  const state = useAdminProfile();
  if (state.status !== 'ready') return false;
  return hasPermission(state.profile.permissions, permission);
}
