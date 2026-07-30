import { useEffect, useState } from 'react';
import { collection, getDocs, limit, query } from 'firebase/firestore';
import { db } from './firebase';

/** How a Firestore read actually went. The screens surface this verbatim rather
 *  than silently pretending mock rows are live data. */
export type SourceState =
  | { status: 'loading' }
  /** Read succeeded and returned documents. */
  | { status: 'live'; count: number }
  /** Read succeeded but the collection has no documents yet. */
  | { status: 'empty' }
  /** Security rules rejected the read — see the note in useCollection below. */
  | { status: 'denied' }
  | { status: 'error'; message: string };

/** Reads up to `max` documents from a top-level collection.
 *
 *  IMPORTANT — as of 29 Jul 2026 this will report `denied` for every CMS
 *  collection. The deployed Firestore rules intentionally allow a client to
 *  touch only its own /users/{uid} tree, and explicitly refuse `list` on
 *  /users ("a client must never be able to enumerate users"). An admin console
 *  therefore cannot read this data straight from the browser. Two supported
 *  ways forward, both still to be decided with the client:
 *    1. Cloud Functions with the Admin SDK (bypasses rules) — matches how the
 *       Vedika/OpenAI proxying is already planned.
 *    2. An admin carve-out in the rules keyed off a custom claim (admin: true).
 *  Do NOT loosen the rules without that decision — this database holds birth
 *  details, which are personal data. */
export function useCollection<T>(path: string, max = 50) {
  const [rows, setRows] = useState<T[]>([]);
  const [state, setState] = useState<SourceState>({ status: 'loading' });

  useEffect(() => {
    let cancelled = false;

    getDocs(query(collection(db, path), limit(max)))
      .then((snapshot) => {
        if (cancelled) return;
        if (snapshot.empty) {
          setState({ status: 'empty' });
          return;
        }
        setRows(snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }) as T));
        setState({ status: 'live', count: snapshot.size });
      })
      .catch((error: unknown) => {
        if (cancelled) return;
        const code =
          typeof error === 'object' && error !== null && 'code' in error
            ? String((error as { code: unknown }).code)
            : '';
        if (code === 'permission-denied') {
          setState({ status: 'denied' });
          return;
        }
        setState({
          status: 'error',
          message: error instanceof Error ? error.message : 'Unknown Firestore error',
        });
      });

    return () => {
      cancelled = true;
    };
  }, [path, max]);

  return { rows, state };
}
