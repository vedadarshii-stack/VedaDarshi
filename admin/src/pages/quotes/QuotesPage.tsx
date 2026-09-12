import { useCallback, useEffect, useMemo, useState } from 'react';

import {
  LOCALE_CODES,
  LOCALE_LABELS,
  createQuote,
  listQuotes,
  removeQuote,
  setQuotePublished,
  updateQuote,
  type LocaleCode,
  type Quote,
} from '../../lib/quotes';
import {
  createFestival,
  listFestivals,
  removeFestival,
  setFestivalPublished,
  updateFestival,
  type Festival,
} from '../../lib/festivals';
import { callableErrorMessage } from '../../lib/adminApi';
import { isPermissionDenied, firestoreErrorMessage } from '../../lib/firestoreErrors';
import { PageSkeleton } from '../../components/PageSkeleton';
import './QuotesPage.css';

/** Quotes & Festivals CMS (sidebar item, previously inert). Two independent
 *  Firestore collections behind one tab switcher, per the spec — each keeps
 *  its own load/error state so a denial on one never hides the other. */

type Tab = 'quotes' | 'festivals';
type Filter = 'all' | 'draft' | 'published';

type LoadState =
  | { status: 'loading' }
  | { status: 'ready' }
  | { status: 'denied' }
  | { status: 'error'; message: string };

const EMPTY_QUOTE_DRAFT = {
  text: {} as Partial<Record<LocaleCode, string>>,
  author: '',
};

const EMPTY_FESTIVAL_DRAFT = {
  name: {} as Partial<Record<LocaleCode, string>>,
  description: {} as Partial<Record<LocaleCode, string>>,
  date: '',
};

export function QuotesPage() {
  const [tab, setTab] = useState<Tab>('quotes');

  return (
    <>
      <header className="pageHead">
        <div className="pageHead__text">
          <h1 className="pageHead__title">Quotes &amp; Festivals</h1>
          <p className="pageHead__subtitle">
            Daily quotes and the festival calendar shown across the app.
          </p>
        </div>
      </header>

      <div className="quotes__tabs">
        {(['quotes', 'festivals'] as Tab[]).map((t) => (
          <button
            key={t}
            type="button"
            className={tab === t ? 'quotes__tab quotes__tab--active' : 'quotes__tab'}
            onClick={() => setTab(t)}
          >
            {t === 'quotes' ? 'Quotes' : 'Festivals'}
          </button>
        ))}
      </div>

      {tab === 'quotes' ? <QuotesTab /> : <FestivalsTab />}
    </>
  );
}

function QuotesTab() {
  const [quotes, setQuotes] = useState<Quote[]>([]);
  const [state, setState] = useState<LoadState>({ status: 'loading' });
  const [error, setError] = useState<string | null>(null);
  const [filter, setFilter] = useState<Filter>('all');
  const [editing, setEditing] = useState<Quote | 'new' | null>(null);

  const load = useCallback(async () => {
    setState({ status: 'loading' });
    try {
      setQuotes(await listQuotes());
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

  const visible = useMemo(
    () => (filter === 'all' ? quotes : quotes.filter((q) => q.status === filter)),
    [quotes, filter],
  );

  const counts = useMemo(
    () => ({
      all: quotes.length,
      published: quotes.filter((q) => q.status === 'published').length,
      draft: quotes.filter((q) => q.status === 'draft').length,
    }),
    [quotes],
  );

  async function act(fn: () => Promise<unknown>) {
    try {
      await fn();
      await load();
    } catch (e) {
      setError(callableErrorMessage(e));
    }
  }

  if (state.status === 'loading') {
    return <PageSkeleton label="Loading quotes" />;
  }

  if (state.status === 'denied') {
    return (
      <div className="card users__error" role="alert">
        <strong>Permission denied.</strong> Your role does not have read access to{' '}
        <code>quotes</code> in Firestore.
      </div>
    );
  }

  if (state.status === 'error') {
    return (
      <div className="card users__error" role="alert">
        <strong>Something went wrong.</strong> {state.message}
        <button type="button" onClick={() => void load()}>
          Retry
        </button>
      </div>
    );
  }

  return (
    <>
      <div className="quotes__toolbar">
        <div className="quotes__filters">
          {(['all', 'published', 'draft'] as Filter[]).map((f) => (
            <button
              key={f}
              type="button"
              className={filter === f ? 'quotes__filter quotes__filter--active' : 'quotes__filter'}
              onClick={() => setFilter(f)}
            >
              {f === 'all' ? 'All' : f === 'published' ? 'Published' : 'Drafts'}
              <span className="users__filterCount">{counts[f]}</span>
            </button>
          ))}
        </div>
        <button type="button" className="quotes__new" onClick={() => setEditing('new')}>
          ＋ New Quote
        </button>
      </div>

      {error && (
        <div className="card users__error" role="alert">
          <strong>Something went wrong.</strong> {error}
          <button type="button" onClick={() => setError(null)}>
            Dismiss
          </button>
        </div>
      )}

      <div className="card quotes__list">
        {visible.length === 0 && (
          <div className="quotes__empty">
            {quotes.length === 0
              ? 'No quotes yet. Create the first one — it appears as the app’s daily quote once published.'
              : 'Nothing in this tab.'}
          </div>
        )}

        {visible.map((quote, index) => {
          const locales = LOCALE_CODES.filter((code) => (quote.text[code] ?? '').trim());
          return (
            <div key={quote.id}>
              {index > 0 && <div className="table__divider" />}
              <div className="quotes__row">
                <div className="quotes__main">
                  <p className="quotes__title">
                    “{quote.text.en?.trim() || <em>Untitled</em>}”
                  </p>
                  <p className="quotes__meta">{quote.author || 'no author'}</p>
                  <div className="quotes__locales">
                    {LOCALE_CODES.map((code) => (
                      <span
                        key={code}
                        className={
                          locales.includes(code)
                            ? 'quotes__locale quotes__locale--ready'
                            : 'quotes__locale'
                        }
                      >
                        {code.toUpperCase()} {locales.includes(code) ? '✓' : '—'}
                      </span>
                    ))}
                  </div>
                </div>

                <span
                  className={`pill ${quote.status === 'published' ? 'pill--premium' : 'pill--free'}`}
                >
                  {quote.status}
                </span>

                <div className="quotes__actions">
                  <button type="button" onClick={() => setEditing(quote)}>
                    Edit
                  </button>
                  <button
                    type="button"
                    onClick={() =>
                      void act(() => setQuotePublished(quote, quote.status !== 'published'))
                    }
                    disabled={quote.status !== 'published' && !quote.text.en?.trim()}
                    title={
                      !quote.text.en?.trim()
                        ? 'Needs English text before publishing'
                        : undefined
                    }
                  >
                    {quote.status === 'published' ? 'Unpublish' : 'Publish'}
                  </button>
                  <button
                    type="button"
                    className="quotes__delete"
                    onClick={() => {
                      if (window.confirm('Delete this quote? This cannot be undone.')) {
                        void act(() => removeQuote(quote.id));
                      }
                    }}
                  >
                    Delete
                  </button>
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {editing && (
        <QuoteEditor
          quote={editing === 'new' ? null : editing}
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

function QuoteEditor({
  quote,
  onClose,
  onSaved,
  onError,
}: {
  quote: Quote | null;
  onClose: () => void;
  onSaved: () => void;
  onError: (message: string) => void;
}) {
  const [draft, setDraft] = useState(() =>
    quote ? { text: { ...quote.text }, author: quote.author } : { ...EMPTY_QUOTE_DRAFT },
  );
  const [locale, setLocale] = useState<LocaleCode>('en');
  const [saving, setSaving] = useState(false);

  async function save() {
    if (saving) return;
    if (!draft.text.en?.trim()) {
      onError('English text is required — every other language falls back to it.');
      return;
    }
    setSaving(true);
    try {
      if (quote) {
        await updateQuote(quote.id, draft);
      } else {
        await createQuote(draft);
      }
      onSaved();
    } catch (e) {
      onError(callableErrorMessage(e));
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="quotes__overlay" role="dialog" aria-modal="true">
      <div className="card quotes__editor">
        <div className="quotes__editorHead">
          <h2 className="card__title">{quote ? 'Edit quote' : 'New quote'}</h2>
          <button type="button" onClick={onClose} aria-label="Close">
            ✕
          </button>
        </div>

        <label className="quotes__field">
          <span>Author</span>
          <input
            value={draft.author}
            onChange={(e) => setDraft({ ...draft, author: e.target.value })}
            placeholder="Traditional"
          />
        </label>

        <div className="quotes__tabs quotes__localeTabs">
          {LOCALE_CODES.map((code) => {
            const done = (draft.text[code] ?? '').trim();
            return (
              <button
                key={code}
                type="button"
                className={
                  locale === code ? 'quotes__tab quotes__tab--active' : 'quotes__tab'
                }
                onClick={() => setLocale(code)}
              >
                {LOCALE_LABELS[code]} {done ? '✓' : ''}
              </button>
            );
          })}
        </div>

        <label className="quotes__field">
          <span>Text ({LOCALE_LABELS[locale]})</span>
          <textarea
            rows={4}
            value={draft.text[locale] ?? ''}
            onChange={(e) =>
              setDraft({ ...draft, text: { ...draft.text, [locale]: e.target.value } })
            }
          />
        </label>

        <div className="quotes__editorFoot">
          <span className="quotes__hint">
            Saved as a draft. Publish from the list when it is ready.
          </span>
          <button type="button" onClick={onClose}>
            Cancel
          </button>
          <button
            type="button"
            className="quotes__new"
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

function FestivalsTab() {
  const [festivals, setFestivals] = useState<Festival[]>([]);
  const [state, setState] = useState<LoadState>({ status: 'loading' });
  const [error, setError] = useState<string | null>(null);
  const [filter, setFilter] = useState<Filter>('all');
  const [editing, setEditing] = useState<Festival | 'new' | null>(null);

  const load = useCallback(async () => {
    setState({ status: 'loading' });
    try {
      setFestivals(await listFestivals());
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

  const visible = useMemo(
    () => (filter === 'all' ? festivals : festivals.filter((f) => f.status === filter)),
    [festivals, filter],
  );

  const counts = useMemo(
    () => ({
      all: festivals.length,
      published: festivals.filter((f) => f.status === 'published').length,
      draft: festivals.filter((f) => f.status === 'draft').length,
    }),
    [festivals],
  );

  async function act(fn: () => Promise<unknown>) {
    try {
      await fn();
      await load();
    } catch (e) {
      setError(callableErrorMessage(e));
    }
  }

  if (state.status === 'loading') {
    return <PageSkeleton label="Loading festivals" />;
  }

  if (state.status === 'denied') {
    return (
      <div className="card users__error" role="alert">
        <strong>Permission denied.</strong> Your role does not have read access to{' '}
        <code>festivals</code> in Firestore.
      </div>
    );
  }

  if (state.status === 'error') {
    return (
      <div className="card users__error" role="alert">
        <strong>Something went wrong.</strong> {state.message}
        <button type="button" onClick={() => void load()}>
          Retry
        </button>
      </div>
    );
  }

  return (
    <>
      <div className="quotes__toolbar">
        <div className="quotes__filters">
          {(['all', 'published', 'draft'] as Filter[]).map((f) => (
            <button
              key={f}
              type="button"
              className={filter === f ? 'quotes__filter quotes__filter--active' : 'quotes__filter'}
              onClick={() => setFilter(f)}
            >
              {f === 'all' ? 'All' : f === 'published' ? 'Published' : 'Drafts'}
              <span className="users__filterCount">{counts[f]}</span>
            </button>
          ))}
        </div>
        <button type="button" className="quotes__new" onClick={() => setEditing('new')}>
          ＋ New Festival
        </button>
      </div>

      {error && (
        <div className="card users__error" role="alert">
          <strong>Something went wrong.</strong> {error}
          <button type="button" onClick={() => setError(null)}>
            Dismiss
          </button>
        </div>
      )}

      <div className="card quotes__list">
        {visible.length === 0 && (
          <div className="quotes__empty">
            {festivals.length === 0
              ? 'No festivals yet. Create the first one — it appears on the app’s festival calendar once published.'
              : 'Nothing in this tab.'}
          </div>
        )}

        {visible.map((festival, index) => {
          const locales = LOCALE_CODES.filter((code) => (festival.name[code] ?? '').trim());
          return (
            <div key={festival.id}>
              {index > 0 && <div className="table__divider" />}
              <div className="quotes__row">
                <div className="quotes__main">
                  <p className="quotes__title">
                    {festival.name.en?.trim() || <em>Untitled</em>}
                  </p>
                  <p className="quotes__meta">{festival.date || 'no date set'}</p>
                  <div className="quotes__locales">
                    {LOCALE_CODES.map((code) => (
                      <span
                        key={code}
                        className={
                          locales.includes(code)
                            ? 'quotes__locale quotes__locale--ready'
                            : 'quotes__locale'
                        }
                      >
                        {code.toUpperCase()} {locales.includes(code) ? '✓' : '—'}
                      </span>
                    ))}
                  </div>
                </div>

                <span
                  className={`pill ${festival.status === 'published' ? 'pill--premium' : 'pill--free'}`}
                >
                  {festival.status}
                </span>

                <div className="quotes__actions">
                  <button type="button" onClick={() => setEditing(festival)}>
                    Edit
                  </button>
                  <button
                    type="button"
                    onClick={() =>
                      void act(() =>
                        setFestivalPublished(festival, festival.status !== 'published'),
                      )
                    }
                    disabled={
                      festival.status !== 'published' &&
                      (!festival.name.en?.trim() || !festival.date)
                    }
                    title={
                      !festival.name.en?.trim() || !festival.date
                        ? 'Needs an English name and a date before publishing'
                        : undefined
                    }
                  >
                    {festival.status === 'published' ? 'Unpublish' : 'Publish'}
                  </button>
                  <button
                    type="button"
                    className="quotes__delete"
                    onClick={() => {
                      if (window.confirm('Delete this festival? This cannot be undone.')) {
                        void act(() => removeFestival(festival.id));
                      }
                    }}
                  >
                    Delete
                  </button>
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {editing && (
        <FestivalEditor
          festival={editing === 'new' ? null : editing}
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

function FestivalEditor({
  festival,
  onClose,
  onSaved,
  onError,
}: {
  festival: Festival | null;
  onClose: () => void;
  onSaved: () => void;
  onError: (message: string) => void;
}) {
  const [draft, setDraft] = useState(() =>
    festival
      ? { name: { ...festival.name }, description: { ...festival.description }, date: festival.date }
      : { ...EMPTY_FESTIVAL_DRAFT },
  );
  const [locale, setLocale] = useState<LocaleCode>('en');
  const [saving, setSaving] = useState(false);

  async function save() {
    if (saving) return;
    if (!draft.name.en?.trim()) {
      onError('An English name is required — every other language falls back to it.');
      return;
    }
    if (!draft.date) {
      onError('A date is required.');
      return;
    }
    setSaving(true);
    try {
      if (festival) {
        await updateFestival(festival.id, draft);
      } else {
        await createFestival(draft);
      }
      onSaved();
    } catch (e) {
      onError(callableErrorMessage(e));
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="quotes__overlay" role="dialog" aria-modal="true">
      <div className="card quotes__editor">
        <div className="quotes__editorHead">
          <h2 className="card__title">{festival ? 'Edit festival' : 'New festival'}</h2>
          <button type="button" onClick={onClose} aria-label="Close">
            ✕
          </button>
        </div>

        <label className="quotes__field">
          <span>Date</span>
          <input
            type="date"
            value={draft.date}
            onChange={(e) => setDraft({ ...draft, date: e.target.value })}
          />
        </label>

        <div className="quotes__tabs quotes__localeTabs">
          {LOCALE_CODES.map((code) => {
            const done = (draft.name[code] ?? '').trim();
            return (
              <button
                key={code}
                type="button"
                className={
                  locale === code ? 'quotes__tab quotes__tab--active' : 'quotes__tab'
                }
                onClick={() => setLocale(code)}
              >
                {LOCALE_LABELS[code]} {done ? '✓' : ''}
              </button>
            );
          })}
        </div>

        <label className="quotes__field">
          <span>Name ({LOCALE_LABELS[locale]})</span>
          <input
            value={draft.name[locale] ?? ''}
            onChange={(e) =>
              setDraft({ ...draft, name: { ...draft.name, [locale]: e.target.value } })
            }
          />
        </label>

        <label className="quotes__field">
          <span>Description ({LOCALE_LABELS[locale]})</span>
          <textarea
            rows={4}
            value={draft.description[locale] ?? ''}
            onChange={(e) =>
              setDraft({
                ...draft,
                description: { ...draft.description, [locale]: e.target.value },
              })
            }
          />
        </label>

        <div className="quotes__editorFoot">
          <span className="quotes__hint">
            Saved as a draft. Publish from the list when it is ready.
          </span>
          <button type="button" onClick={onClose}>
            Cancel
          </button>
          <button
            type="button"
            className="quotes__new"
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
