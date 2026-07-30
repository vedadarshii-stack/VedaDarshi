import type { SourceState } from '../lib/useCollection';
import { FIREBASE_PROJECT_ID } from '../lib/firebase';
import './DataSourceNotice.css';

/** Tells the truth about where the rows on screen came from. Without this it is
 *  impossible to tell a working Firestore read from the placeholder data. */
export function DataSourceNotice({ state, path }: { state: SourceState; path: string }) {
  if (state.status === 'loading') {
    return <p className="dataNotice dataNotice--muted">Reading {path} from Firestore…</p>;
  }

  if (state.status === 'live') {
    return (
      <p className="dataNotice dataNotice--live">
        ● Live — {state.count} document{state.count === 1 ? '' : 's'} from{' '}
        <code>{path}</code> in {FIREBASE_PROJECT_ID}
      </p>
    );
  }

  if (state.status === 'empty') {
    return (
      <p className="dataNotice dataNotice--warn">
        ⚠ Connected to {FIREBASE_PROJECT_ID}, but <code>{path}</code> has no documents yet —
        showing sample data from the Figma concept.
      </p>
    );
  }

  if (state.status === 'denied') {
    return (
      <p className="dataNotice dataNotice--warn">
        ⚠ Connected to {FIREBASE_PROJECT_ID}, but Firestore rules refuse this read
        (<code>{path}</code>). Admin reads need Cloud Functions or an admin claim — showing
        sample data from the Figma concept.
      </p>
    );
  }

  return (
    <p className="dataNotice dataNotice--error">
      ✕ Firestore error on <code>{path}</code>: {state.message} — showing sample data.
    </p>
  );
}
