import { useEffect, useRef, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../lib/authContext';
import { exitConceptMode } from '../lib/conceptMode';
import './AccountMenu.css';

/** Sidebar account row + sign-out popover.
 *
 *  The row used to BE the sign-out button, which meant one stray click ended your
 *  session with no warning. Now it opens a menu and sign-out is a deliberate,
 *  labelled choice. */
export function AccountMenu({
  displayName,
  roleLabel,
  email,
  initial,
  signedIn,
}: {
  displayName: string;
  roleLabel: string;
  email: string | null;
  initial: string;
  signedIn: boolean;
}) {
  const navigate = useNavigate();
  const { signOut } = useAuth();
  const [open, setOpen] = useState(false);
  const [signingOut, setSigningOut] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);

  // Close on outside click and on Escape — a popover pinned to the bottom of the
  // sidebar is easy to lose track of otherwise.
  useEffect(() => {
    if (!open) return;

    function onPointerDown(event: MouseEvent) {
      if (!containerRef.current?.contains(event.target as Node)) {
        setOpen(false);
      }
    }
    function onKeyDown(event: KeyboardEvent) {
      if (event.key === 'Escape') setOpen(false);
    }

    document.addEventListener('mousedown', onPointerDown);
    document.addEventListener('keydown', onKeyDown);
    return () => {
      document.removeEventListener('mousedown', onPointerDown);
      document.removeEventListener('keydown', onKeyDown);
    };
  }, [open]);

  async function handleSignOut() {
    setSigningOut(true);
    try {
      // Clear the concept flag too, or "sign out" would leave the console
      // browsable and look like it failed.
      exitConceptMode();
      await signOut();
      navigate('/login', { replace: true });
    } finally {
      setSigningOut(false);
      setOpen(false);
    }
  }

  return (
    <div className="accountMenu" ref={containerRef}>
      {open && (
        <div className="accountMenu__popover" role="menu">
          <div className="accountMenu__identity">
            <span className="accountMenu__identityName">{displayName}</span>
            <span className="accountMenu__identityMeta">{email ?? roleLabel}</span>
          </div>
          <div className="accountMenu__separator" />
          <button
            type="button"
            role="menuitem"
            className="accountMenu__signOut"
            disabled={signingOut}
            onClick={() => void handleSignOut()}
          >
            <span className="accountMenu__signOutIcon" aria-hidden="true">
              ↪
            </span>
            {signingOut ? 'Signing out…' : signedIn ? 'Sign out' : 'Back to sign-in'}
          </button>
        </div>
      )}

      <button
        type="button"
        className={open ? 'accountMenu__trigger accountMenu__trigger--open' : 'accountMenu__trigger'}
        aria-haspopup="menu"
        aria-expanded={open}
        onClick={() => setOpen((next) => !next)}
      >
        <span className="accountMenu__avatar">{initial}</span>
        <span className="accountMenu__text">
          <span className="accountMenu__name">{displayName}</span>
          <span className="accountMenu__role">{roleLabel}</span>
        </span>
        <span className="accountMenu__chevron" aria-hidden="true">
          ⌃
        </span>
      </button>
    </div>
  );
}
