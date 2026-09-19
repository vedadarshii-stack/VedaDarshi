/**
 * Shared classifier for the four screens that read/write Firestore directly
 * (quotes & festivals, muhurat content, app config) — same reasoning
 * as `useCollection.ts`: a screen must not render an empty list when the read
 * was actually refused by security rules. Kept separate from `useCollection`
 * because these screens need bespoke queries (ordering, a fixed doc-id set,
 * a single document) rather than a generic "first N docs" read.
 */
export function isPermissionDenied(error: unknown): boolean {
  const code =
    typeof error === 'object' && error !== null && 'code' in error
      ? String((error as { code: unknown }).code)
      : '';
  return code === 'permission-denied';
}

export function firestoreErrorMessage(error: unknown): string {
  return error instanceof Error ? error.message : 'Unknown Firestore error';
}
