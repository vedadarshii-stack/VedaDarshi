import { PERMISSIONS } from '../lib/permissions';
import type { Permission } from '../lib/permissions';

/** Sidebar model, mirroring the Figma concept 1:1.
 *
 * `path` — an item with no `path` is drawn but inert; give it one as soon as
 * its screen exists and it becomes clickable with no other change. Every
 * item now has one — Quotes & Festivals, Muhurat Content and App Config
 * (built 12 Sep 2026) were the last without a screen behind them.
 *
 * ⚠️ **Banners was REMOVED on 12 Sep 2026, not merely un-pathed.** A Banners
 * CMS was built the same day and deleted hours later: the mobile app has no
 * banner surface to drive. Every `*Banner` widget in `mobile/lib` is a sandbox
 * warning, a dosha verdict, a wallet-balance notice or the hardcoded Go
 * Premium card on Reports — none of them is a slot a CMS row could fill. The
 * screen was therefore managing content nothing could ever display.
 * `PERMISSIONS.bannersManage` is deliberately KEPT in the catalogue because
 * the seeded `adminRoles/*` documents in Firestore still list
 * `banners.manage`; removing the constant would make those role documents
 * reference a permission the code no longer knows about. Re-add the nav entry
 * if a real banner slot is ever designed.
 *
 * `permission` — what the signed-in role must hold for the item to appear.
 * These strings match the `permissions` arrays on adminRoles/{roleId} in
 * Firestore, so changing a role document changes the sidebar. */
export type NavItem = {
  label: string;
  icon: string;
  permission: Permission;
  path?: string;
};

export const NAV_ITEMS: NavItem[] = [
  { label: 'Dashboard', icon: '◫', permission: PERMISSIONS.dashboardView, path: '/dashboard' },
  { label: 'Users', icon: '👥', permission: PERMISSIONS.usersView, path: '/users' },
  { label: 'Articles', icon: '📖', permission: PERMISSIONS.articlesView, path: '/articles' },
  {
    label: 'Notifications',
    icon: '🔔',
    permission: PERMISSIONS.notificationsSend,
    path: '/notifications',
  },
  { label: 'Plans & Billing', icon: '👑', permission: PERMISSIONS.plansManage, path: '/plans' },
  {
    label: 'Quotes & Festivals',
    icon: '🪔',
    permission: PERMISSIONS.quotesManage,
    path: '/quotes',
  },
  {
    label: 'Muhurat Content',
    icon: '🗓',
    permission: PERMISSIONS.muhuratManage,
    path: '/muhurat',
  },
  { label: 'AI Usage', icon: '🔮', permission: PERMISSIONS.aiView, path: '/ai-usage' },
  { label: 'App Config', icon: '⚙', permission: PERMISSIONS.configManage, path: '/config' },
];
