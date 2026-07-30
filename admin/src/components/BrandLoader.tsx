import './BrandLoader.css';

/** Full-screen loading state for the pre-layout gates (session check, sign-out).
 *
 *  Uses the gold-glow-pulse from the approved motion spec (Figma node 80:2) so the
 *  console feels like the same product as the app. Honours prefers-reduced-motion —
 *  see BrandLoader.css. */
export function BrandLoader({ message }: { message: string }) {
  return (
    <div className="brandLoader" role="status" aria-live="polite">
      <div className="brandLoader__halo">
        <span className="brandLoader__ring" />
        <span className="brandLoader__ring brandLoader__ring--delayed" />
        <span className="brandLoader__mark vd-om">ॐ</span>
      </div>
      <p className="brandLoader__text">
        {message}
        <span className="brandLoader__dots" aria-hidden="true">
          <i />
          <i />
          <i />
        </span>
      </p>
    </div>
  );
}
