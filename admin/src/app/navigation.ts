import { PERMISSIONS } from '../lib/permissions';
import type { Permission } from '../lib/permissions';

/** Sidebar model, mirroring the Figma concept 1:1.
 *
 * `path` — an item with no `path` is drawn but inert; give it one as soon as
 * its screen exists and it becomes clickable with no other change. Every
 * item now has one — Banners, Quotes & Festivals, Muhurat Content and App
 * Config (built 12 Sep 2026) were the last four without a screen behind them.
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
  { label: 'Banners', icon: '🖼', permission: PERMISSIONS.bannersManage, path: '/banners' },
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
