import './PageSkeleton.css';

/** Shimmer placeholder shown inside the console shell while the role loads.
 *
 *  Deliberately mirrors the real page rhythm — header block, stat row, wide
 *  panel — so the layout does not jump when the screen resolves. Shimmer
 *  loading is point 3 of the approved motion spec (Figma node 80:2). */
export function PageSkeleton({ label }: { label: string }) {
  return (
    <div className="skeleton" role="status" aria-live="polite">
      <span className="skeleton__srOnly">{label}</span>

      <div className="skeleton__head">
        <div className="skeleton__headText">
          <span className="shimmer skeleton__title" />
          <span className="shimmer skeleton__subtitle" />
        </div>
        <span className="shimmer skeleton__action" />
      </div>

      <div className="skeleton__stats">
        {[0, 1, 2, 3].map((index) => (
          <div key={index} className="skeleton__card">
            <span className="shimmer skeleton__label" />
            <span className="shimmer skeleton__value" />
            <span className="shimmer skeleton__delta" />
          </div>
        ))}
      </div>

      <div className="skeleton__panel">
        <span className="shimmer skeleton__panelTitle" />
        {[0, 1, 2, 3, 4].map((index) => (
          <span key={index} className="shimmer skeleton__row" />
        ))}
      </div>
    </div>
  );
}
