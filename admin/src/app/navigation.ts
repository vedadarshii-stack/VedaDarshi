import { PERMISSIONS } from '../lib/permissions';
import type { Permission } from '../lib/permissions';

/** Sidebar model, mirroring the Figma concept 1:1.
 *
 * `path` — the Figma prototype only wires five destinations (Dashboard, Users,
 * Articles, Notifications, Plans & Billing). The rest are drawn but have no
 * screen behind them, so they stay inert. Give an item a `path` as soon as its
 * screen exists and it becomes clickable with no other change.
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
  { label: 'Banners', icon: '🖼', permission: PERMISSIONS.bannersManage },
  {
    label: 'Notifications',
    icon: '🔔',
    permission: PERMISSIONS.notificationsSend,
    path: '/notifications',
  },
  { label: 'Plans & Billing', icon: '👑', permission: PERMISSIONS.plansManage, path: '/plans' },
  { label: 'Quotes & Festivals', icon: '🪔', permission: PERMISSIONS.quotesManage },
  { label: 'Muhurat Content', icon: '🗓', permission: PERMISSIONS.muhuratManage },
  { label: 'AI Usage', icon: '🔮', permission: PERMISSIONS.aiView },
  { label: 'App Config', icon: '⚙', permission: PERMISSIONS.configManage },
];
