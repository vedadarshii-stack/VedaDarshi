import { USER_FILTERS, USERS } from '../../data/mock';
import type { UserRow } from '../../data/mock';
import { useCollection } from '../../lib/useCollection';
import { DataSourceNotice } from '../../components/DataSourceNotice';
import './UsersPage.css';

const PAGES = ['1', '2', '3', '…', '8054'];
const COLLECTION = 'users';

/** Figma E3 · Users (node 32:2). */
export function UsersPage() {
  const { rows, state } = useCollection<UserRow>(COLLECTION);
  const users = state.status === 'live' ? rows : USERS;

  return (
    <>
      <header className="pageHead">
        <div className="pageHead__text">
          <h1 className="pageHead__title">Users</h1>
          <p className="pageHead__subtitle">48,320 registered · 6,905 premium</p>
        </div>
        <button type="button" className="users__export">
          ⬇ Export CSV
        </button>
      </header>

      <DataSourceNotice state={state} path={COLLECTION} />

      <div className="users__filters">
        <label className="users__search">
          <span className="vd-glyph">🔍</span>
          <input type="search" placeholder="Search by name, phone or email…" />
        </label>
        {USER_FILTERS.map((filter) => (
          <button key={filter} type="button" className="users__filter">
            {filter} ▾
          </button>
        ))}
      </div>

      <div className="card users__table">
        <div className="table__head users__grid">
          <span className="table__heading">USER</span>
          <span className="table__heading">CONTACT</span>
          <span className="table__heading">JOINED</span>
          <span className="table__heading">PLAN</span>
          <span className="table__heading">LAST ACTIVE</span>
          <span className="table__heading">LANGUAGE</span>
          <span className="table__heading" />
        </div>
        <div className="table__divider" />

        {users.map((user, index) => (
          <div key={user.name}>
            {index > 0 && <div className="table__divider" />}
            <div className="table__row users__grid">
              <span className="users__identity">
                <span className={`users__avatar tone tone--${user.tone}`}>{user.initial}</span>
                <span className="users__name">{user.name}</span>
              </span>
              <span className="users__cell">{user.contact}</span>
              <span className="users__cell">{user.joined}</span>
              <span>
                <span className={`pill ${user.plan.premium ? 'pill--premium' : 'pill--free'}`}>
                  {user.plan.text}
                </span>
              </span>
              <span className="users__cell">{user.lastActive}</span>
              <span className="users__cell">{user.language}</span>
              <button type="button" className="table__more" aria-label={`Actions for ${user.name}`}>
                ⋯
              </button>
            </div>
          </div>
        ))}
      </div>

      <div className="users__pagination">
        <p className="users__count">Showing 1–6 of 48,320</p>
        <button type="button" className="users__page" aria-label="Previous page">
          ‹
        </button>
        {PAGES.map((page, index) => (
          <button
            key={page}
            type="button"
            className={index === 0 ? 'users__page users__page--active' : 'users__page'}
          >
            {page}
          </button>
        ))}
        <button type="button" className="users__page" aria-label="Next page">
          ›
        </button>
      </div>
    </>
  );
}
