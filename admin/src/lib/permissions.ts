/** Permission vocabulary for the console.
 *
 *  These strings are the contract between the `permissions` array on
 *  `adminRoles/{roleId}` in Firestore and the UI. Adding a capability means
 *  adding it here AND to the relevant role documents — the two must not drift.
 *
 *  Seeded roles (Firestore, 30 Jul 2026):
 *    super_admin    → ['*']
 *    content_editor → dashboard.view, articles.*, banners/quotes/muhurat, notifications.send
 *    support        → dashboard.view, users.view, articles.view, ai.view
 */
export const PERMISSIONS = {
  dashboardView: 'dashboard.view',
  usersView: 'users.view',
  usersEdit: 'users.edit',
  articlesView: 'articles.view',
  articlesEdit: 'articles.edit',
  articlesPublish: 'articles.publish',
  bannersManage: 'banners.manage',
  notificationsSend: 'notifications.send',
  plansManage: 'plans.manage',
  quotesManage: 'quotes.manage',
  muhuratManage: 'muhurat.manage',
  aiView: 'ai.view',
  configManage: 'config.manage',
  adminsManage: 'admins.manage',
} as const;

export type Permission = (typeof PERMISSIONS)[keyof typeof PERMISSIONS];

/** Wildcard held by super_admin. Checked explicitly so a role never has to
 *  enumerate every permission — new features are granted to super admins
 *  automatically, which is the behaviour you want for the owner account. */
export const WILDCARD = '*';

export function hasPermission(granted: readonly string[], needed: Permission): boolean {
  return granted.includes(WILDCARD) || granted.includes(needed);
}
