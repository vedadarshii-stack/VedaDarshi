import { useCallback, useEffect, useState } from 'react';

import { callableErrorMessage, fetchPlans, type PlansData } from '../../lib/adminApi';
import { PageSkeleton } from '../../components/PageSkeleton';
import './PlansPage.css';

/**
 * Figma E6 · Plans & Billing — now showing REAL Play pricing.
 *
 * ⚠️ **REWIRED 11 Sep 2026 because every price on this screen was invented.**
 * It rendered "₹299 / ₹1,999 / ₹4,999" from `mock.ts`. The real catalogue is
 * four tiers with monthly AND annual base plans, starting at ₹219 — so the one
 * page a client would open to check what they charge was wrong in every cell.
 *
 * ## Read-only, and that is the correct design
 *
 * The Figma concept has "Edit pricing" buttons. They cannot work the way that
 * implies, and building them would be a mistake rather than a feature:
 *
 *  - **Play owns the price.** Nothing this console writes to Firestore changes
 *    what a user is charged. RevenueCat does not store prices either — it
 *    reads them from the store.
 *  - **Raising a price for existing subscribers** requires Google's
 *    price-change flow with notification and, in many regions, explicit
 *    opt-in. It is not a text field.
 *  - **The service account deliberately lacks "Manage store presence"**, so it
 *    cannot reprice anything. A leaked key that can only read orders is a far
 *    smaller problem than one that can rewrite the catalogue.
 *
 * So: show the truth, and link to Play to change it.
 */

const PLAY_CONSOLE_SUBSCRIPTIONS =
  'https://play.google.com/console/u/0/developers/6794665206972998780/app/4974821764704847706/subscriptions';

function formatPrice(amount: number, currency: string | null): string {
  if (!currency) return String(amount);
  try {
    return new Intl.NumberFormat(undefined, {
      style: 'currency',
      currency,
      maximumFractionDigits: amount % 1 === 0 ? 0 : 2,
    }).format(amount);
  } catch {
    return `${currency} ${amount}`;
  }
}

/** "P1M" → "Monthly". Play returns ISO-8601 durations. */
function periodLabel(iso: string | null, id: string): string {
  switch (iso) {
    case 'P1M':
      return 'Monthly';
    case 'P1Y':
      return 'Annual';
    case 'P1W':
      return 'Weekly';
    default:
      return id;
  }
}

export function PlansPage() {
  const [data, setData] = useState<PlansData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      setData(await fetchPlans());
    } catch (e) {
      setError(callableErrorMessage(e));
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  if (loading && !data && !error) {
    return <PageSkeleton label="Loading plans" />;
  }

  return (
    <>
      <header className="pageHead">
        <div className="pageHead__text">
          <h1 className="pageHead__title">Plans &amp; Billing</h1>
          <p className="pageHead__subtitle">
            Live from Google Play · {data?.plans.length ?? 0} subscriptions ·{' '}
            {data?.oneTime.length ?? 0} one-time products
          </p>
        </div>
        <button type="button" className="users__export" onClick={() => void load()}>
          ↻ Refresh
        </button>
      </header>

      {error && (
        <div className="card users__error" role="alert">
          <strong>Couldn’t load pricing.</strong> {error}
          <button type="button" onClick={() => void load()}>
            Retry
          </button>
        </div>
      )}

      <div className="plans__notice card">
        <strong>Prices are set in Google Play, not here.</strong> Play is what
        charges the customer, so it is the only source of truth. Changing a
        price for existing subscribers also needs Google’s price-change flow
        with user notification — it is not a field this console can safely edit.
        <a href={PLAY_CONSOLE_SUBSCRIPTIONS} target="_blank" rel="noreferrer">
          Edit pricing in Play Console ↗
        </a>
      </div>

      {data?.plans.map((plan) => (
        <section key={plan.productId ?? plan.storeIdentifier} className="card plans__plan">
          <div className="plans__planHead">
            <div>
              <h2 className="card__title">{plan.displayName ?? plan.storeIdentifier}</h2>
              <p className="plans__sku">{plan.storeIdentifier}</p>
            </div>
            {plan.storeStatus && (
              <span
                className={`pill ${plan.storeStatus === 'ok' ? 'pill--premium' : 'pill--free'}`}
              >
                {plan.storeStatus}
              </span>
            )}
          </div>

          {plan.periods.length === 0 && (
            <p className="plans__empty">No base plans returned by Play.</p>
          )}

          {plan.periods.map((period) => (
            <div key={period.id} className="plans__period">
              <span className="plans__periodName">
                {periodLabel(period.billingPeriod, period.id)}
                <span
                  className={
                    period.state === 'ACTIVE'
                      ? 'plans__state plans__state--active'
                      : 'plans__state'
                  }
                >
                  {period.state ?? 'unknown'}
                </span>
              </span>
              <span className="plans__prices">
                {period.prices.length === 0
                  ? '—'
                  : period.prices.map((p) => (
                      <span key={p.region} className="plans__price">
                        {formatPrice(p.amount, p.currency)}
                        <em>{p.region}</em>
                      </span>
                    ))}
              </span>
            </div>
          ))}
        </section>
      ))}

      {data && data.plans.length > 0 && (
        <p className="plans__stamp">
          {/* Regions are worth calling out: every base plan is India-only, so a
              user elsewhere sees an empty paywall. */}
          Fetched {new Date(data.fetchedAtMs).toLocaleTimeString()}. Prices shown
          per region — a plan with only IN is unavailable everywhere else.
        </p>
      )}

      {data && data.oneTime.length > 0 && (
        <section className="card plans__oneTime">
          <h2 className="card__title">One-time products ({data.oneTime.length})</h2>
          <p className="plans__empty">
            {/* Play's API does not expose store state for non-subscription
                products, so listing identifiers is the honest maximum here —
                inventing prices is exactly what this rewrite removed. */}
            Play does not expose prices for one-time products through this API.
            Identifiers only; open Play Console to see or change their prices.
          </p>
          <div className="plans__skus">
            {data.oneTime.map((p) => (
              <span key={p.productId ?? p.storeIdentifier} className="plans__sku">
                {p.storeIdentifier}
              </span>
            ))}
          </div>
        </section>
      )}
    </>
  );
}
