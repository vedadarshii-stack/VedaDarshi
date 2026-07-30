import { DASHBOARD_STATS, GROWTH_CHART, TODAYS_CONTENT } from '../../data/mock';
import './DashboardPage.css';

/** Figma E2 · Dashboard (node 31:2). */
export function DashboardPage() {
  return (
    <>
      <header className="pageHead">
        <div className="pageHead__text">
          <h1 className="pageHead__title">Dashboard</h1>
          <p className="pageHead__subtitle">Saturday, 12 July 2026 · Shukla Ashtami</p>
        </div>
        <label className="dash__search">
          <span className="vd-glyph">🔍</span>
          <input type="search" placeholder="Search users, articles…" />
        </label>
        <button type="button" className="dash__bell vd-glyph" aria-label="Notifications">
          🔔
        </button>
      </header>

      <section className="dash__stats">
        {DASHBOARD_STATS.map((stat) => (
          <article key={stat.label} className="statCard">
            <div className="statCard__top">
              <p className="statCard__label">{stat.label}</p>
              <span className={`statCard__icon vd-glyph tone tone--${stat.tone}`}>{stat.icon}</span>
            </div>
            <p className="statCard__value">{stat.value}</p>
            <p className="statCard__delta">{stat.delta}</p>
          </article>
        ))}
      </section>

      <section className="dash__lower">
        <article className="card chartCard">
          <div className="chartCard__head">
            <h2 className="card__title">User growth &amp; revenue</h2>
            <span className="chartCard__range">Last 6 months ▾</span>
          </div>

          <div className="chartCard__plot">
            {GROWTH_CHART.map((column) => (
              <div key={column.month} className="chartCard__column">
                <div className="chartCard__bars">
                  <span
                    className="chartCard__bar chartCard__bar--users"
                    style={{ height: `${column.users}px` }}
                    title={`${column.month} · new users`}
                  />
                  <span
                    className="chartCard__bar chartCard__bar--revenue"
                    style={{ height: `${column.revenue}px` }}
                    title={`${column.month} · revenue`}
                  />
                </div>
                <span className="chartCard__month">{column.month}</span>
              </div>
            ))}
          </div>

          <div className="chartCard__legend">
            <span className="chartCard__legendItem">
              <i className="chartCard__dot chartCard__dot--users" />
              New users
            </span>
            <span className="chartCard__legendItem">
              <i className="chartCard__dot chartCard__dot--revenue" />
              Revenue (₹10k)
            </span>
          </div>
        </article>

        <article className="card sideCard">
          <h2 className="card__title">Today&rsquo;s content</h2>
          <ul className="sideCard__list">
            {TODAYS_CONTENT.map((item) => (
              <li key={item.title} className="sideCard__row">
                <span className={`sideCard__icon sideCard__icon--${item.tone}`}>{item.icon}</span>
                <span className="sideCard__text">
                  <span className="sideCard__title">{item.title}</span>
                  <span className="sideCard__detail">{item.detail}</span>
                </span>
              </li>
            ))}
          </ul>
        </article>
      </section>
    </>
  );
}
