import { useCallback, useEffect, useState } from 'react';

import {
  callableErrorMessage,
  fetchDashboardStats,
  type DashboardStats,
} from '../../lib/adminApi';
import { PageSkeleton } from '../../components/PageSkeleton';
import './DashboardPage.css';

/**
 * Figma E2 · Dashboard (node 31:2) — now showing REAL numbers.
 *
 * ⚠️ **REWIRED 9 Sep 2026 because every figure on this screen was invented.**
 * It rendered hardcoded strings from `mock.ts`: "48,320 Total Users",
 * "6,905 Active Subscriptions", "₹11.4L Revenue (July)", "12,441 AI Questions
 * Today", plus a six-month growth chart and a fixed date of "Saturday,
 * 12 July 2026". The real figures were 18 users, 0 subscriptions and zero
 * revenue.
 *
 * That is more dangerous than an empty screen: it was screenshot-ready and
 * read as a business report. Numbers now come from `adminDashboardStats`, and
 * anything the server could not determine renders as "—" rather than as a
 * confident zero.
 *
 * The growth chart is GONE rather than zeroed. We keep no historical
 * user/revenue series, so any chart drawn here would be shape without data —
 * exactly the problem being fixed. It comes back when there is something to
 * plot.
 */

function formatNumber(value: number | null | undefined): string {
  return value == null ? '—' : value.toLocaleString();
}

function formatUsd(value: string | null | undefined): string {
  return value == null ? '—' : `$${value}`;
}

export function DashboardPage() {
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      setStats(await fetchDashboardStats());
    } catch (e) {
      setError(callableErrorMessage(e));
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  const today = new Date().toLocaleDateString(undefined, {
    weekday: 'long',
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  });

  // A skeleton for the FIRST load only. On a refresh the existing numbers
  // stay on screen rather than collapsing to placeholders — replacing real
  // data with a shimmer is a downgrade, not a loading state.
  if (loading && !stats && !error) {
    return <PageSkeleton label="Loading dashboard" />;
  }

  const cards = [
    {
      label: 'Total users',
      value: formatNumber(stats?.totalUsers),
      note: 'registered accounts',
      icon: '👥',
      tone: 'saffron',
    },
    {
      label: 'Paid subscribers',
      value: formatNumber(stats?.paidSubscribers),
      // Sandbox entitlements are called out rather than folded in — a
      // licence tester's Platinum is not a customer.
      note:
        stats?.sandboxEntitlements
          ? `${stats.sandboxEntitlements} sandbox (test) entitlement${stats.sandboxEntitlements === 1 ? '' : 's'}`
          : 'active entitlements',
      icon: '👑',
      tone: 'gold',
    },
    {
      label: 'Vedika queries',
      value: formatNumber(stats?.vedikaQueries),
      note: `spend ${formatUsd(stats?.vedikaSpendUsd)}`,
      icon: '🔮',
      tone: 'purple',
    },
    {
      label: 'Revenue (28 days)',
      value: stats?.revenue28d != null ? `$${stats.revenue28d}` : '—',
      note: `${formatNumber(stats?.activeSubscriptions)} active subscriptions`,
      icon: '💰',
      tone: 'green',
    },
  ];

  return (
    <>
      <header className="pageHead">
        <div className="pageHead__text">
          <h1 className="pageHead__title">Dashboard</h1>
          <p className="pageHead__subtitle">{today}</p>
        </div>
        <button type="button" className="users__export" onClick={() => void load()}>
          ↻ Refresh
        </button>
      </header>

      {error && (
        <div className="card users__error" role="alert">
          <strong>Couldn’t load stats.</strong> {error}
          <button type="button" onClick={() => void load()}>
            Retry
          </button>
        </div>
      )}

      <section className="dash__stats">
        {cards.map((stat) => (
          <article key={stat.label} className="statCard">
            <div className="statCard__top">
              <p className="statCard__label">{stat.label}</p>
              <span className={`statCard__icon vd-glyph tone tone--${stat.tone}`}>
                {stat.icon}
              </span>
            </div>
            <p className="statCard__value">{stat.value}</p>
            <p className="statCard__delta">{stat.note}</p>
          </article>
        ))}
      </section>

      <section className="card dash__health">
        <h2 className="card__title">Vedika wallet</h2>
        <p className="dash__healthValue">{formatUsd(stats?.vedikaBalanceUsd)}</p>
        <p className="dash__healthNote">
          Prepaid. At zero, every astrology call in the app fails — panchang,
          horoscopes, kundli and AI.
        </p>
      </section>

      {stats && (
        <p className="dash__stamp">
          Live figures, fetched {new Date(stats.fetchedAtMs).toLocaleTimeString()}.
          Historical charts return once there is history to plot.
        </p>
      )}
    </>
  );
}
