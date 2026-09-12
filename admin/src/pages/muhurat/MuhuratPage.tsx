import { useCallback, useEffect, useState } from 'react';

import {
  LOCALE_CODES,
  LOCALE_LABELS,
  MUHURAT_KINDS,
  MUHURAT_LABELS,
  listMuhuratContent,
  saveMuhuratContent,
  type LocaleCode,
  type MuhuratContent,
  type MuhuratKind,
  type MuhuratStatus,
} from '../../lib/muhurat';
import { callableErrorMessage } from '../../lib/adminApi';
import { isPermissionDenied, firestoreErrorMessage } from '../../lib/firestoreErrors';
import { PageSkeleton } from '../../components/PageSkeleton';
import './MuhuratPage.css';

/** Muhurat Content CMS (sidebar item, previously inert). Unlike the other
 *  three new screens this is NOT an open collection — the app's astrology
 *  engine only ever asks for the 12 fixed `MUHURAT_KINDS`, so the screen
 *  always renders exactly 12 rows, with no way to add or remove one. A kind
 *  with no saved document yet still renders — as an empty, editable row,
 *  not as an error — because `listMuhuratContent` fills every kind in. */

type LoadState =
  | { status: 'loading' }
  | { status: 'ready' }
  | { status: 'denied' }
  | { status: 'error'; message: string };

export function MuhuratPage() {
  const [content, setContent] = useState<Record<MuhuratKind, MuhuratContent | null>>(
    {} as Record<MuhuratKind, MuhuratContent | null>,
  );
  const [state, setState] = useState<LoadState>({ status: 'loading' });
  const [error, setError] = useState<string | null>(null);
  const [editing, setEditing] = useState<MuhuratKind | null>(null);

  const load = useCallback(async () => {
    setState({ status: 'loading' });
    try {
      setContent(await listMuhuratContent());
      setState({ status: 'ready' });
    } catch (e) {
      setState(
        isPermissionDenied(e)
          ? { status: 'denied' }
          : { status: 'error', message: firestoreErrorMessage(e) },
      );
    }
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  if (state.status === 'loading') {
    return <PageSkeleton label="Loading muhurat content" />;
  }

  const publishedCount = MUHURAT_KINDS.filter(
    (kind) => content[kind]?.status === 'published',
  ).length;

  return (
    <>
      <header className="pageHead">
        <div className="pageHead__text">
          <h1 className="pageHead__title">Muhurat Content</h1>
          <p className="pageHead__subtitle">
            {state.status === 'ready'
              ? `${MUHURAT_KINDS.length} windows · ${publishedCount} published`
              : 'Descriptions shown under each muhurat window in the app.'}
          </p>
        </div>
      </header>

      {state.status === 'denied' && (
        <div className="card users__error" role="alert">
          <strong>Permission denied.</strong> Your role does not have read access to{' '}
          <code>muhuratContent</code> in Firestore.
        </div>
      )}

      {state.status === 'error' && (
        <div className="card users__error" role="alert">
          <strong>Something went wrong.</strong> {state.message}
          <button type="button" onClick={() => void load()}>
            Retry
          </button>
        </div>
      )}

      {error && (
        <div className="card users__error" role="alert">
          <strong>Something went wrong.</strong> {error}
          <button type="button" onClick={() => setError(null)}>
            Dismiss
          </button>
        </div>
      )}

      {state.status === 'ready' && (
        <div className="card muhurat__list">
          {MUHURAT_KINDS.map((kind, index) => {
            const entry = content[kind];
            return (
              <div key={kind}>
                {index > 0 && <div className="table__divider" />}
                <div className="muhurat__row">
                  <div className="muhurat__main">
                    <p className="muhurat__title">{MUHURAT_LABELS[kind]}</p>
                    <p className="muhurat__meta">
                      {entry?.description.en?.trim() || <em>No description yet</em>}
                    </p>
                  </div>
                  <span
                    className={`pill ${
                      entry?.status === 'published' ? 'pill--premium' : 'pill--free'
                    }`}
                  >
                    {entry?.status ?? 'draft'}
                  </span>
                  <div className="muhurat__actions">
                    <button type="button" onClick={() => setEditing(kind)}>
                      Edit
                    </button>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {editing && (
        <MuhuratEditor
          kind={editing}
          entry={content[editing]}
          onClose={() => setEditing(null)}
          onSaved={() => {
            setEditing(null);
            void load();
          }}
          onError={setError}
        />
      )}
    </>
  );
}

function MuhuratEditor({
  kind,
  entry,
  onClose,
  onSaved,
  onError,
}: {
  kind: MuhuratKind;
  entry: MuhuratContent | null;
  onClose: () => void;
  onSaved: () => void;
  onError: (message: string) => void;
}) {
  const [description, setDescription] = useState(() => ({ ...(entry?.description ?? {}) }));
  const [status, setStatus] = useState<MuhuratStatus>(entry?.status ?? 'draft');
  const [locale, setLocale] = useState<LocaleCode>('en');
  const [saving, setSaving] = useState(false);

  async function save() {
    if (saving) return;
    if (!description.en?.trim()) {
      onError('An English description is required — every other language falls back to it.');
      return;
    }
    setSaving(true);
    try {
      await saveMuhuratContent(kind, { description, status });
      onSaved();
    } catch (e) {
      onError(callableErrorMessage(e));
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="muhurat__overlay" role="dialog" aria-modal="true">
      <div className="card muhurat__editor">
        <div className="muhurat__editorHead">
          <h2 className="card__title">{MUHURAT_LABELS[kind]}</h2>
          <button type="button" onClick={onClose} aria-label="Close">
            ✕
          </button>
        </div>

        <label className="muhurat__field muhurat__statusField">
          <span>Status</span>
          <select value={status} onChange={(e) => setStatus(e.target.value as MuhuratStatus)}>
            <option value="draft">Draft</option>
            <option value="published">Published</option>
          </select>
        </label>

        <div className="muhurat__tabs">
          {LOCALE_CODES.map((code) => {
            const done = (description[code] ?? '').trim();
            return (
              <button
                key={code}
                type="button"
                className={
                  locale === code ? 'muhurat__tab muhurat__tab--active' : 'muhurat__tab'
                }
                onClick={() => setLocale(code)}
              >
                {LOCALE_LABELS[code]} {done ? '✓' : ''}
              </button>
            );
          })}
        </div>

        <label className="muhurat__field">
          <span>Description ({LOCALE_LABELS[locale]})</span>
          <textarea
            rows={5}
            value={description[locale] ?? ''}
            onChange={(e) => setDescription({ ...description, [locale]: e.target.value })}
          />
        </label>

        <div className="muhurat__editorFoot">
          <button type="button" onClick={onClose}>
            Cancel
          </button>
          <button
            type="button"
            className="muhurat__save"
            onClick={() => void save()}
            disabled={saving}
          >
            {saving ? 'Saving…' : 'Save'}
          </button>
        </div>
      </div>
    </div>
  );
}
