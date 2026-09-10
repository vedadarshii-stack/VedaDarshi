import { useCallback, useEffect, useState } from 'react';

import {
  callableErrorMessage,
  fetchVedikaUsage,
  type VedikaUsage,
} from '../../lib/adminApi';
import { PageSkeleton } from '../../components/PageSkeleton';
import './AiUsagePage.css';

/**
 * AI Usage — the client's Vedika spend.
 *
 * BUILT 9 Sep 2026. "AI Usage" had been an inert sidebar item since the
 * console was scaffolded: it had no route and no screen behind it.
 *
 * ## Why this reads through a Cloud Function and not the proxy
 *
 * `functions/src/index.ts` (the `vedika` proxy) has **no authentication** —
 * an unauthenticated GET of `/api/v1/usage/wallet-balance` through it returns
 * 200. Pointing this page at the proxy would have put the client's wallet
 * balance and full spend history behind a URL anyone could call. It calls
 * `adminVedikaUsage` instead, which checks `adminUsers/{uid}` server-side.
 *
 * ⚠️ The proxy's missing auth is still open and is tracked separately. This
 * screen does not fix it — it declines to make it worse.
 *
 * ## What the numbers mean
 *
 * The balance is a PREPAID wallet: when it reaches zero, every Vedika call
 * fails and the app's astrology data stops working. That is why this screen
 * leads with the balance rather than with total spend.
 */

function currencyFrom(usage: VedikaUsage): string {
  return usage.wallet?.currency ?? usage.summary?.data?.currency ?? 'USD';
}

export function AiUsagePage() {
  const [usage, setUsage] = useState<VedikaUsage | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      setUsage(await fetchVedikaUsage());
    } catch (e) {
      setError(callableErrorMessage(e));
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  const summary = usage?.summary?.data;
  const balanceUsd = usage?.wallet?.balanceUsd;
  // Below roughly two weeks of the current fixed burn, this needs attention.
  const lowBalance = balanceUsd != null && Number(balanceUsd) < 15;

  return (
    <>
      <header className="pageHead">
        <div className="pageHead__text">
          <h1 className="pageHead__title">AI Usage</h1>
          <p className="pageHead__subtitle">
            Vedika Intelligence — prepaid wallet and query spend
          </p>
        </div>
        <button type="button" className="users__export" onClick={() => void load()}>
          ↻ Refresh
        </button>
      </header>

      {error && (
        <div className="card users__error" role="alert">
          <strong>Couldn’t load usage.</strong> {error}
          <button type="button" onClick={() => void load()}>
            Retry
          </button>
        </div>
      )}

      {/* The project's own shimmer skeleton, not a bare "Loading…" line.
          It reserves the same shape the content will occupy, so the layout
          does not jump when the numbers land — and it honours
          prefers-reduced-motion, which a spinner would not. */}
      {loading && !usage && <PageSkeleton label="Loading Vedika usage" />}

      {usage && (
        <>
          <div className="aiUsage__stats">
            <div className={`card aiUsage__stat ${lowBalance ? 'aiUsage__stat--warn' : ''}`}>
              <span className="aiUsage__label">Wallet balance</span>
              <strong className="aiUsage__value">
                {balanceUsd != null ? `$${balanceUsd}` : '—'}
              </strong>
              <span className="aiUsage__hint">
                {lowBalance
                  ? 'Low — every astrology call fails at zero'
                  : 'Prepaid; astrology calls stop at zero'}
              </span>
            </div>

            <div className="card aiUsage__stat">
              <span className="aiUsage__label">Spend</span>
              <strong className="aiUsage__value">
                {summary?.totalCost != null
                  ? `$${summary.totalCost}`
                  : '—'}
              </strong>
              <span className="aiUsage__hint">
                {summary?.dateRange?.start
                  ? `since ${new Date(summary.dateRange.start).toLocaleDateString()}`
                  : 'reporting period'}
              </span>
            </div>

            <div className="card aiUsage__stat">
              <span className="aiUsage__label">Queries</span>
              <strong className="aiUsage__value">
                {summary?.totalQueries?.toLocaleString() ?? '—'}
              </strong>
              <span className="aiUsage__hint">
                {summary?.truncated
                  ? `capped at ${summary.scanLimit?.toLocaleString() ?? 'scan limit'}`
                  : 'billed calls'}
              </span>
            </div>

            <div className="card aiUsage__stat">
              <span className="aiUsage__label">Avg per query</span>
              <strong className="aiUsage__value">
                {summary?.averageCostPerQuery != null
                  ? `$${summary.averageCostPerQuery}`
                  : '—'}
              </strong>
              <span className="aiUsage__hint">{currencyFrom(usage)}</span>
            </div>
          </div>

          {summary?.truncated && (
            <p className="aiUsage__note">
              Vedika caps this report at {summary.scanLimit?.toLocaleString()} queries,
              so spend and counts are a floor, not a total.
            </p>
          )}

          {summary?.byService && Object.keys(summary.byService).length > 0 && (
            <div className="card aiUsage__table">
              <div className="table__head aiUsage__grid">
                <span className="table__heading">SERVICE</span>
                <span className="table__heading">QUERIES</span>
                <span className="table__heading">COST</span>
              </div>
              <div className="table__divider" />
              {Object.entries(summary.byService).map(([service, row], index) => (
                <div key={service}>
                  {index > 0 && <div className="table__divider" />}
                  <div className="table__row aiUsage__grid">
                    <span>{service}</span>
                    <span>{row.queries?.toLocaleString() ?? '—'}</span>
                    <span>{row.cost != null ? `$${row.cost}` : '—'}</span>
                  </div>
                </div>
              ))}
            </div>
          )}

          <p className="aiUsage__stamp">
            Fetched {new Date(usage.fetchedAtMs).toLocaleTimeString()} · live from Vedika,
            not cached
          </p>
        </>
      )}
    </>
  );
}
