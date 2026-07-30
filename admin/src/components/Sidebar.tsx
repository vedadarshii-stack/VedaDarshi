import { NavLink } from 'react-router-dom';
import { NAV_ITEMS } from '../app/navigation';
import { useAuth } from '../lib/authContext';
import { useAdminProfile } from '../lib/adminProfileContext';
import { hasPermission } from '../lib/permissions';
import { AccountMenu } from './AccountMenu';
import './Sidebar.css';

export function Sidebar() {
  const { user } = useAuth();
  const profileState = useAdminProfile();

  // Concept mode shows the whole sidebar (it is the static walkthrough);
  // a real session shows only what the role grants. Anything else fails closed.
  const granted =
    profileState.status === 'concept'
      ? ['*']
      : profileState.status === 'ready'
        ? profileState.profile.permissions
        : [];

  const visibleItems = NAV_ITEMS.filter((item) => hasPermission(granted, item.permission));

  const displayName =
    (profileState.status === 'ready' ? profileState.profile.displayName : null) ??
    user?.displayName ??
    user?.email ??
    'Admin';
  const initial = displayName.trim().charAt(0).toUpperCase() || 'A';

  const roleLabel =
    profileState.status === 'ready'
      ? profileState.profile.roleName
      : profileState.status === 'concept'
        ? 'Concept preview'
        : profileState.status === 'loading'
          ? 'Loading role…'
          : 'No console role';

  return (
    <aside className="sidebar">
      <div className="sidebar__brand">
        <span className="vd-om sidebar__om">ॐ</span>
        <span className="sidebar__brandText">
          <span className="sidebar__wordmark">Vedadarshi</span>
          <span className="sidebar__kicker">ADMIN</span>
        </span>
      </div>

      <nav className="sidebar__nav">
        <ul>
          {visibleItems.map((item) =>
            item.path ? (
              <li key={item.label}>
                <NavLink
                  to={item.path}
                  className={({ isActive }) =>
                    isActive ? 'sidebar__item sidebar__item--active' : 'sidebar__item'
                  }
                >
                  <span className="vd-glyph sidebar__icon">{item.icon}</span>
                  <span className="sidebar__label">{item.label}</span>
                </NavLink>
              </li>
            ) : (
              <li key={item.label}>
                <span
                  className="sidebar__item sidebar__item--inert"
                  title="Not part of the approved UI concept yet"
                >
                  <span className="vd-glyph sidebar__icon">{item.icon}</span>
                  <span className="sidebar__label">{item.label}</span>
                </span>
              </li>
            ),
          )}
        </ul>
      </nav>

      <AccountMenu
        displayName={displayName}
        roleLabel={roleLabel}
        email={user?.email ?? null}
        initial={initial}
        signedIn={Boolean(user)}
      />
    </aside>
  );
}
