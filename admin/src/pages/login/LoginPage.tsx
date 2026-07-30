import { useEffect, useState } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { useAuth } from '../../lib/authContext';
import { authErrorMessage } from '../../lib/authErrors';
import { enterConceptMode, exitConceptMode } from '../../lib/conceptMode';
import './LoginPage.css';

/** Official Google "G". Not a Figma asset — the concept predates the Google
 *  button — so it is inlined here rather than exported from the design file.
 *  Keep the four brand colours exact; Google's branding guidelines require it. */
function GoogleMark() {
  return (
    <svg className="login__googleMark" viewBox="0 0 18 18" aria-hidden="true" focusable="false">
      <path
        fill="#4285F4"
        d="M17.64 9.2c0-.64-.06-1.25-.16-1.84H9v3.48h4.84a4.14 4.14 0 0 1-1.8 2.72v2.26h2.92a8.78 8.78 0 0 0 2.68-6.62Z"
      />
      <path
        fill="#34A853"
        d="M9 18c2.43 0 4.47-.8 5.96-2.18l-2.92-2.26c-.81.54-1.84.86-3.04.86a5.33 5.33 0 0 1-5-3.69H1.02v2.34A8.99 8.99 0 0 0 9 18Z"
      />
      <path
        fill="#FBBC05"
        d="M4 10.73a5.4 5.4 0 0 1 0-3.46V4.96H1.02a9 9 0 0 0 0 8.08L4 10.73Z"
      />
      <path
        fill="#EA4335"
        d="M9 3.58c1.32 0 2.5.46 3.44 1.35l2.58-2.58C13.46.89 11.43 0 9 0A8.99 8.99 0 0 0 1.02 4.96L4 7.27A5.33 5.33 0 0 1 9 3.58Z"
      />
    </svg>
  );
}

/** Figma E1 · Admin Login (node 30:3), wired to Firebase Auth on
 *  project vedadarshi-20989. */
export function LoginPage() {
  const navigate = useNavigate();
  const location = useLocation();
  const { user, loading, signInWithGoogle, signInWithEmail } = useAuth();

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [remember, setRemember] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState<'email' | 'google' | null>(null);

  const destination = (location.state as { from?: string } | null)?.from ?? '/dashboard';

  // A returning admin with a live session should never sit on the login screen.
  useEffect(() => {
    if (!loading && user) {
      navigate(destination, { replace: true });
    }
  }, [loading, user, destination, navigate]);

  async function run(kind: 'email' | 'google', action: () => Promise<void>) {
    setError(null);
    setBusy(kind);
    try {
      exitConceptMode();
      await action();
      navigate(destination, { replace: true });
    } catch (caught) {
      setError(authErrorMessage(caught));
    } finally {
      setBusy(null);
    }
  }

  function viewConcept() {
    enterConceptMode();
    navigate('/dashboard');
  }

  return (
    <div className="login">
      <section className="login__brand">
        <div className="login__logo">
          <span className="login__logoMark vd-om">ॐ</span>
          <span className="login__logoText">
            <span className="login__wordmark">Vedadarshi</span>
            <span className="login__kicker">ADMIN CONSOLE</span>
          </span>
        </div>

        <div className="login__pitch">
          <h1 className="login__headline">
            Manage the cosmos,
            <br />
            from one place.
          </h1>
          <p className="login__blurb">
            Content, users, notifications, subscriptions and AI usage — everything for the
            Vedadarshi app.
          </p>
        </div>

        <p className="login__legal">© 2026 Vedadarshi · Secure admin access</p>
      </section>

      <section className="login__panel">
        <form
          className="login__form"
          onSubmit={(event) => {
            event.preventDefault();
            void run('email', () => signInWithEmail(email, password));
          }}
        >
          <h2 className="login__title">Welcome back</h2>
          <p className="login__subtitle">Sign in with your admin credentials</p>

          <label className="login__field">
            <span className="login__label">EMAIL</span>
            <span className="login__input">
              <input
                type="email"
                value={email}
                required
                placeholder="admin@vedadarshi.app"
                autoComplete="username"
                onChange={(event) => setEmail(event.target.value)}
              />
            </span>
          </label>

          <label className="login__field">
            <span className="login__label">PASSWORD</span>
            <span className="login__input">
              <input
                type={showPassword ? 'text' : 'password'}
                value={password}
                required
                placeholder="••••••••••"
                autoComplete="current-password"
                onChange={(event) => setPassword(event.target.value)}
              />
              <button
                type="button"
                className="login__reveal vd-glyph"
                aria-label={showPassword ? 'Hide password' : 'Show password'}
                onClick={() => setShowPassword((visible) => !visible)}
              >
                👁
              </button>
            </span>
          </label>

          <div className="login__row">
            <label className="login__remember">
              <input
                type="checkbox"
                checked={remember}
                onChange={(event) => setRemember(event.target.checked)}
              />
              <span className="login__checkbox" aria-hidden="true" />
              <span>Remember me</span>
            </label>
            <button type="button" className="login__forgot">
              Forgot password?
            </button>
          </div>

          {error && (
            <p className="login__error" role="alert">
              {error}
            </p>
          )}

          <button type="submit" className="login__submit" disabled={busy !== null}>
            {busy === 'email' ? 'Signing in…' : 'Sign in to Console'}
          </button>

          <div className="login__divider">
            <span>or</span>
          </div>

          {/* Google is currently the ONLY working provider on this Firebase
              project — Email/Password is switched off (see authErrors.ts). */}
          <button
            type="button"
            className="login__google"
            disabled={busy !== null}
            onClick={() => void run('google', signInWithGoogle)}
          >
            <GoogleMark />
            {busy === 'google' ? 'Opening Google…' : 'Continue with Google'}
          </button>

          <p className="login__note">
            <span className="vd-glyph">🔒</span> Protected by 2-step verification
          </p>

          <button type="button" className="login__concept" onClick={viewConcept}>
            Skip sign-in — view the static UI concept
          </button>
        </form>
      </section>
    </div>
  );
}
