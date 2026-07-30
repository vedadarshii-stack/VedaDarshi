import { NavLink, useNavigate } from 'react-router-dom';
import { NAV_ITEMS } from '../app/navigation';
import { useAuth } from '../lib/authContext';
import { useAdminProfile } from '../lib/adminProfileContext';
import { hasPermission } from '../lib/permissions';
import { exitConceptMode } from '../lib/conceptMode';
import './Sidebar.css';

export function Sidebar() {
  const navigate = useNavigate();
  const { user, signOut } = useAuth();
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

  async function handleSignOut() {
    exitConceptMode();
    await signOut();
    navigate('/login', { replace: true });
  }

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

      <button
        type="button"
        className="sidebar__account"
        onClick={() => void handleSignOut()}
        title={user ? `Sign out ${displayName}` : 'Back to sign-in'}
      >
        <span className="sidebar__avatar">{initial}</span>
        <span className="sidebar__accountText">
          <span className="sidebar__accountName">{displayName}</span>
          <span className="sidebar__accountRole">{roleLabel}</span>
        </span>
        <span className="sidebar__signOut" aria-label="Sign out">
          ↪
        </span>
      </button>
    </aside>
  );
}
