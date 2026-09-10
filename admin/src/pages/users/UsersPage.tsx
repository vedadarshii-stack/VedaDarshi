import { useCallback, useEffect, useMemo, useState } from 'react';

import {
  callableErrorMessage,
  fetchUsers,
  type AdminUserRow,
} from '../../lib/adminApi';
import { PageSkeleton } from '../../components/PageSkeleton';
import './UsersPage.css';

/**
 * Figma E3 · Users (node 32:2) — now backed by REAL data.
 *
 * REWIRED 9 Sep 2026. This screen used to read `/users` straight from the
 * browser and show a permanent "denied" banner, because `firestore.rules`
 * refuses `list` on that collection — deliberately, since those documents
 * carry birth details. It then fell back to `mock.ts` and displayed six
 * invented people as if they were customers.
 *
 * It now calls `adminListUsers`, which runs with the Admin SDK behind a
 * server-side role check. The rules are unchanged; the enumeration happens
 * where the caller can actually be verified.
 *
 * ⚠️ The callable returns **reduced** documents on purpose — identity and
 * account metadata only, never `birthProfiles`. A support agent needs to find
 * an account, not read someone's birth chart.
 */

const PAGE_SIZE = 25;

/** Deterministic avatar tone, so a given user keeps the same colour. */
const TONES = ['saffron', 'blue', 'green', 'purple', 'cyan', 'pink'] as const;
function toneFor(uid: string): string {
  let hash = 0;
  for (let i = 0; i < uid.length; i += 1) hash = (hash * 31 + uid.charCodeAt(i)) | 0;
  return TONES[Math.abs(hash) % TONES.length];
}

function initialFor(user: AdminUserRow): string {
  const source = user.displayName || user.email || '?';
  return source.trim().charAt(0).toUpperCase() || '?';
}

function formatDate(ms: number | null): string {
  if (!ms) return '—';
  return new Date(ms).toLocaleDateString(undefined, {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  });
}

/**
 * Sign-in method, derived from the Firebase `providers` array.
 *
 * ⚠️ A GUEST is the ABSENCE of a provider, not a provider called "guest".
 * Anonymous auth mints a real uid with an empty `providers` list, so the
 * check has to be "no recognised provider", never a positive match — and a
 * user who later links a credential stops being a guest without their uid
 * changing.
 */
type SignInMethod = 'all' | 'google' | 'email' | 'guest';

function signInMethodOf(user: AdminUserRow): Exclude<SignInMethod, 'all'> {
  const providers = user.providers ?? [];
  if (providers.includes('google.com')) return 'google';
  if (providers.includes('password')) return 'email';
  return 'guest';
}

const METHOD_LABELS: Record<Exclude<SignInMethod, 'all'>, string> = {
  google: 'Google',
  email: 'Email',
  guest: 'Guest',
};

const METHOD_FILTERS: { id: SignInMethod; label: string }[] = [
  { id: 'all', label: 'All' },
  { id: 'google', label: 'Google' },
  { id: 'email', label: 'Email' },
  { id: 'guest', label: 'Guest' },
];

const LANGUAGE_NAMES: Record<string, string> = {
  en: 'English',
  hi: 'हिन्दी',
  te: 'తెలుగు',
  ta: 'தமிழ்',
  kn: 'ಕನ್ನಡ',
};

export function UsersPage() {
  const [users, setUsers] = useState<AdminUserRow[]>([]);
  const [cursor, setCursor] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [query, setQuery] = useState('');
  const [method, setMethod] = useState<SignInMethod>('all');

  const load = useCallback(async (startAfter: string | null) => {
    setLoading(true);
    setError(null);
    try {
      const page = await fetchUsers({ limit: PAGE_SIZE, startAfter });
      // Appending rather than replacing: "Load more" must not lose the rows
      // already on screen.
      setUsers((prev) => (startAfter ? [...prev, ...page.users] : page.users));
      setCursor(page.nextCursor);
    } catch (e) {
      setError(callableErrorMessage(e));
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void load(null);
  }, [load]);

  // Filtering is CLIENT-side over the loaded page, and the placeholder says
  // so. Server-side search would need a search index; pretending to search
  // everyone while only matching 25 rows would be worse than being explicit.
  const visible = useMemo(() => {
    const q = query.trim().toLowerCase();
    return users.filter((u) => {
      if (method !== 'all' && signInMethodOf(u) !== method) return false;
      if (!q) return true;
      return (
        (u.displayName ?? '').toLowerCase().includes(q) ||
        (u.email ?? '').toLowerCase().includes(q) ||
        u.uid.toLowerCase().includes(q)
      );
    });
  }, [users, query, method]);

  // Counts come from the LOADED rows, so the chips can show how many of each
  // are actually on screen rather than implying a database-wide total.
  const methodCounts = useMemo(() => {
    const counts = { google: 0, email: 0, guest: 0 };
    for (const u of users) counts[signInMethodOf(u)] += 1;
    return counts;
  }, [users]);

  const premiumCount = users.filter((u) => u.tier !== 'free').length;

  // First load only — "Load more" must not blank the rows already read.
  if (loading && users.length === 0 && !error) {
    return <PageSkeleton label="Loading users" />;
  }

  return (
    <>
      <header className="pageHead">
        <div className="pageHead__text">
          <h1 className="pageHead__title">Users</h1>
          <p className="pageHead__subtitle">
            {/* Counts describe what is LOADED, not the whole database — the
                previous copy claimed "48,320 registered · 6,905 premium",
                which was invented.

                The bare "+" that used to sit after the number meant "more
                pages exist" and explained nothing; it read as a typo. Say it
                in words instead. */}
            {users.length} user{users.length === 1 ? '' : 's'} loaded
            {cursor ? ' · more available' : ''} · {premiumCount} premium
          </p>
        </div>
      </header>

      {error && (
        <div className="card users__error" role="alert">
          <strong>Couldn’t load users.</strong> {error}
          <button type="button" onClick={() => void load(null)}>
            Retry
          </button>
        </div>
      )}

      <div className="users__filters">
        <label className="users__search">
          <span className="vd-glyph">🔍</span>
          <input
            type="search"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Filter loaded users by name, email or UID…"
          />
        </label>

        {METHOD_FILTERS.map((filter) => (
          <button
            key={filter.id}
            type="button"
            className={
              method === filter.id
                ? 'users__filter users__filter--active'
                : 'users__filter'
            }
            onClick={() => setMethod(filter.id)}
          >
            {filter.label}
            {filter.id !== 'all' && (
              <span className="users__filterCount">
                {methodCounts[filter.id as Exclude<SignInMethod, 'all'>]}
              </span>
            )}
          </button>
        ))}
      </div>

      <div className="card users__table">
        <div className="table__head users__grid">
          <span className="table__heading">USER</span>
          <span className="table__heading">EMAIL</span>
          <span className="table__heading">SIGN-IN</span>
          <span className="table__heading">JOINED</span>
          <span className="table__heading">PLAN</span>
          <span className="table__heading">LANGUAGE</span>
          <span className="table__heading" />
        </div>
        <div className="table__divider" />

        {visible.length === 0 && !loading && !error && (
          <div className="table__row">
            <span className="users__cell">
              {query ? 'No loaded user matches that.' : 'No users yet.'}
            </span>
          </div>
        )}

        {visible.map((user, index) => (
          <div key={user.uid}>
            {index > 0 && <div className="table__divider" />}
            <div className="table__row users__grid">
              <span className="users__identity">
                <span className={`users__avatar tone tone--${toneFor(user.uid)}`}>
                  {initialFor(user)}
                </span>
                <span className="users__name">
                  {user.displayName ?? <em>Unnamed</em>}
                </span>
              </span>
              <span className="users__cell">{user.email ?? '—'}</span>
              <span>
                <span className={`pill users__method users__method--${signInMethodOf(user)}`}>
                  {METHOD_LABELS[signInMethodOf(user)]}
                </span>
              </span>
              <span className="users__cell">{formatDate(user.createdAt)}</span>
              <span>
                <span
                  className={`pill ${user.tier !== 'free' ? 'pill--premium' : 'pill--free'}`}
                >
                  {user.tier}
                </span>
              </span>
              <span className="users__cell">
                {LANGUAGE_NAMES[user.locale ?? ''] ?? user.locale ?? '—'}
              </span>
              <span className="users__cell users__uid" title={user.uid}>
                {user.uid.slice(0, 6)}…
              </span>
            </div>
          </div>
        ))}
      </div>

      <div className="users__pagination">
        <p className="users__count">
          {loading ? 'Loading…' : `Showing ${visible.length} of ${users.length} loaded`}
        </p>
        {cursor && (
          <button
            type="button"
            className="users__page"
            disabled={loading}
            onClick={() => void load(cursor)}
          >
            Load more
          </button>
        )}
      </div>
    </>
  );
}
