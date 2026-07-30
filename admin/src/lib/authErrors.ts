/** Firebase Auth error codes → console-appropriate copy.
 *
 *  `auth/operation-not-allowed` is the one to watch: as of 29 Jul 2026 the
 *  Email/Password provider is DISABLED on vedadarshi-20989 (verified via the
 *  Identity Toolkit REST API → PASSWORD_LOGIN_DISABLED), so every password
 *  sign-in returns it until someone enables the provider in the console. */
const MESSAGES: Record<string, string> = {
  'auth/invalid-email': 'That email address is not valid.',
  'auth/user-disabled': 'This account has been disabled.',
  'auth/user-not-found': 'No admin account exists for that email.',
  'auth/wrong-password': 'Incorrect email or password.',
  'auth/invalid-credential': 'Incorrect email or password.',
  'auth/too-many-requests': 'Too many attempts. Try again in a few minutes.',
  'auth/network-request-failed': 'Network error — check your connection.',
  'auth/popup-closed-by-user': 'Sign-in window was closed before finishing.',
  'auth/cancelled-popup-request': 'Sign-in was cancelled.',
  'auth/popup-blocked': 'Your browser blocked the sign-in popup. Allow popups and retry.',
  'auth/unauthorized-domain':
    'This domain is not in the Firebase authorised-domains list. Add it under Authentication → Settings.',
  'auth/operation-not-allowed':
    'Email/password sign-in is switched off for this Firebase project. Enable it in Authentication → Sign-in method, or use Google.',
};

/** Returns null for user-cancelled flows, so callers can stay silent. */
export function authErrorMessage(error: unknown): string | null {
  const code =
    typeof error === 'object' && error !== null && 'code' in error
      ? String((error as { code: unknown }).code)
      : '';

  if (code === 'auth/popup-closed-by-user' || code === 'auth/cancelled-popup-request') {
    return null;
  }

  return MESSAGES[code] ?? 'Could not sign in. Please try again.';
}
