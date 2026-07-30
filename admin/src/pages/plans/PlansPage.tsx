import { FEATURE_GATES, PLANS } from '../../data/mock';
import './PlansPage.css';

/** Figma E6 · Plans & Billing (node 36:2). */
export function PlansPage() {
  return (
    <>
      <header className="pageHead">
        <div className="pageHead__text">
          <h1 className="pageHead__title">Plans &amp; Billing</h1>
          <p className="pageHead__subtitle">Managed via RevenueCat + Google Play Billing</p>
        </div>
        <span className="plans__sync">● RevenueCat synced · 2 min ago</span>
      </header>

      <section className="plans__grid">
        {PLANS.map((plan) => (
          <article
            key={plan.name}
            className={plan.featured ? 'planCard planCard--featured' : 'planCard'}
          >
            <div className="planCard__head">
              <h2 className="planCard__name">{plan.name}</h2>
              {plan.badge && <span className="planCard__badge">{plan.badge}</span>}
            </div>

            <div className="planCard__priceRow">
              <span className="planCard__price">{plan.price}</span>
              <span className="planCard__period">{plan.period}</span>
            </div>

            <p className="planCard__subscribers">{plan.subscribers}</p>

            <p className="planCard__id">ID&nbsp;&nbsp;{plan.productId}</p>

            <div className="planCard__actions">
              <button type="button" className="planCard__primary">
                Edit pricing
              </button>
              <button type="button" className="planCard__secondary">
                Offers
              </button>
            </div>
          </article>
        ))}
      </section>

      <div className="card plans__gating">
        <div className="table__head plans__gateGrid">
          <span className="table__heading">FEATURE GATING</span>
          <span className="table__heading">FREE</span>
          <span className="table__heading">PREMIUM</span>
        </div>
        <div className="table__divider" />

        {FEATURE_GATES.map((gate, index) => (
          <div key={gate.feature}>
            {index > 0 && <div className="table__divider" />}
            <div className="plans__gateRow plans__gateGrid">
              <span className="plans__feature">{gate.feature}</span>
              <span className="plans__free">{gate.free}</span>
              <span className="plans__premium">{gate.premium}</span>
            </div>
          </div>
        ))}
      </div>
    </>
  );
}
