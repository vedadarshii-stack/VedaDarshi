/** Lets the console be browsed without a Firebase account while it is still a
 *  design-review artefact (the login screen exposes this as an explicit link).
 *
 *  Deliberately sessionStorage, not localStorage: it dies with the tab and can
 *  never be mistaken for a real session. It gates nothing but the rendering of
 *  placeholder screens — every Firestore read still goes through security rules,
 *  so concept mode grants zero data access.
 *
 *  Delete this file, its link in LoginPage and its check in RequireAuth once
 *  real admin accounts exist. */
export const CONCEPT_MODE_KEY = 'vd_concept_mode';

export function isConceptMode() {
  return sessionStorage.getItem(CONCEPT_MODE_KEY) === '1';
}

export function enterConceptMode() {
  sessionStorage.setItem(CONCEPT_MODE_KEY, '1');
}

export function exitConceptMode() {
  sessionStorage.removeItem(CONCEPT_MODE_KEY);
}
