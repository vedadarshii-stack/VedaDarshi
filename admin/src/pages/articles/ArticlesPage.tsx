import { useCallback, useEffect, useMemo, useState } from 'react';

import {
  CATEGORIES,
  LOCALE_CODES,
  LOCALE_LABELS,
  createArticle,
  listArticles,
  removeArticle,
  setPublished,
  translatedLocales,
  updateArticle,
  type Article,
  type ArticleStatus,
  type CategoryId,
  type LocaleCode,
} from '../../lib/articles';
import { callableErrorMessage } from '../../lib/adminApi';
import { PageSkeleton } from '../../components/PageSkeleton';
import './ArticlesPage.css';

/**
 * Figma E4 · Articles CMS (node 34:2) — now a REAL CMS.
 *
 * ⚠️ **REWIRED 10 Sep 2026.** This screen read an empty `articles`
 * collection, failed, and silently fell back to six invented articles from
 * `mock.ts` — under a header claiming "142 total · 8 drafts · 3 scheduled".
 * Nothing on it was real and nothing could be created.
 *
 * It now lists, creates, edits, publishes and deletes real documents, with a
 * title and body per language as the localisation rules require.
 */

type Filter = 'all' | ArticleStatus;

const EMPTY_DRAFT = {
  title: {} as Partial<Record<LocaleCode, string>>,
  body: {} as Partial<Record<LocaleCode, string>>,
  categoryId: 'festivals' as CategoryId,
  author: '',
  readMinutes: 5,
  isFeatured: false,
};

export function ArticlesPage() {
  const [articles, setArticles] = useState<Article[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [filter, setFilter] = useState<Filter>('all');
  const [editing, setEditing] = useState<Article | 'new' | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      setArticles(await listArticles());
    } catch (e) {
      setError(callableErrorMessage(e));
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  const visible = useMemo(
    () => (filter === 'all' ? articles : articles.filter((a) => a.status === filter)),
    [articles, filter],
  );

  const counts = useMemo(
    () => ({
      all: articles.length,
      published: articles.filter((a) => a.status === 'published').length,
      draft: articles.filter((a) => a.status === 'draft').length,
    }),
    [articles],
  );

  async function act(fn: () => Promise<unknown>) {
    try {
      await fn();
      await load();
    } catch (e) {
      setError(callableErrorMessage(e));
    }
  }

  if (loading && articles.length === 0 && !error) {
    return <PageSkeleton label="Loading articles" />;
  }

  return (
    <>
      <header className="pageHead">
        <div className="pageHead__text">
          <h1 className="pageHead__title">Articles</h1>
          <p className="pageHead__subtitle">
            {/* Real counts. The old copy claimed "142 total · 8 drafts ·
                3 scheduled" against an empty collection. */}
            {counts.all} total · {counts.published} published · {counts.draft} draft
          </p>
        </div>
        <button
          type="button"
          className="articles__new"
          onClick={() => setEditing('new')}
        >
          ＋ New Article
        </button>
      </header>

      {error && (
        <div className="card users__error" role="alert">
          <strong>Something went wrong.</strong> {error}
          <button type="button" onClick={() => void load()}>
            Retry
          </button>
        </div>
      )}

      <div className="articles__tabs">
        {(['all', 'published', 'draft'] as Filter[]).map((tab) => (
          <button
            key={tab}
            type="button"
            className={
              filter === tab ? 'articles__tab articles__tab--active' : 'articles__tab'
            }
            onClick={() => setFilter(tab)}
          >
            {tab === 'all' ? 'All' : tab === 'published' ? 'Published' : 'Drafts'}
            <span className="users__filterCount">{counts[tab]}</span>
          </button>
        ))}
      </div>

      <div className="card articles__list">
        {visible.length === 0 && (
          <div className="articles__empty">
            {articles.length === 0
              ? 'No articles yet. Create the first one — it appears in the app once published.'
              : 'Nothing in this tab.'}
          </div>
        )}

        {visible.map((article, index) => {
          const locales = translatedLocales(article);
          return (
            <div key={article.id}>
              {index > 0 && <div className="table__divider" />}
              <div className="articles__row">
                <div className="articles__main">
                  <p className="articles__title">
                    {article.title.en?.trim() || <em>Untitled</em>}
                  </p>
                  <p className="articles__meta">
                    {article.categoryId} · {article.author || 'no author'} ·{' '}
                    {article.readMinutes} min
                  </p>
                  <div className="articles__locales">
                    {LOCALE_CODES.map((code) => (
                      <span
                        key={code}
                        className={
                          locales.includes(code)
                            ? 'articles__locale articles__locale--ready'
                            : 'articles__locale'
                        }
                        title={
                          locales.includes(code)
                            ? `${LOCALE_LABELS[code]} — ready`
                            : `${LOCALE_LABELS[code]} — needs title and body`
                        }
                      >
                        {code.toUpperCase()} {locales.includes(code) ? '✓' : '—'}
                      </span>
                    ))}
                  </div>
                </div>

                <span
                  className={`pill ${
                    article.status === 'published' ? 'pill--premium' : 'pill--free'
                  }`}
                >
                  {article.status}
                </span>

                <div className="articles__actions">
                  <button type="button" onClick={() => setEditing(article)}>
                    Edit
                  </button>
                  <button
                    type="button"
                    onClick={() =>
                      void act(() =>
                        setPublished(article, article.status !== 'published'),
                      )
                    }
                    // An article with no English title has nothing the app can
                    // fall back to, so publishing it would show a blank card.
                    disabled={
                      article.status !== 'published' && !article.title.en?.trim()
                    }
                    title={
                      !article.title.en?.trim()
                        ? 'Needs an English title before publishing'
                        : undefined
                    }
                  >
                    {article.status === 'published' ? 'Unpublish' : 'Publish'}
                  </button>
                  <button
                    type="button"
                    className="articles__delete"
                    onClick={() => {
                      // Deleting published content is irreversible and removes
                      // it from the app immediately — worth one confirmation.
                      if (
                        window.confirm(
                          `Delete “${article.title.en || 'Untitled'}”? This cannot be undone.`,
                        )
                      ) {
                        void act(() => removeArticle(article.id));
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
        <ArticleEditor
          article={editing === 'new' ? null : editing}
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

function ArticleEditor({
  article,
  onClose,
  onSaved,
  onError,
}: {
  article: Article | null;
  onClose: () => void;
  onSaved: () => void;
  onError: (message: string) => void;
}) {
  const [draft, setDraft] = useState(() =>
    article
      ? {
          title: { ...article.title },
          body: { ...article.body },
          categoryId: article.categoryId,
          author: article.author,
          readMinutes: article.readMinutes,
          isFeatured: article.isFeatured,
        }
      : { ...EMPTY_DRAFT },
  );
  const [locale, setLocale] = useState<LocaleCode>('en');
  const [saving, setSaving] = useState(false);

  async function save() {
    if (saving) return;
    if (!draft.title.en?.trim()) {
      onError('An English title is required — every other language falls back to it.');
      return;
    }
    setSaving(true);
    try {
      if (article) {
        await updateArticle(article.id, draft);
      } else {
        await createArticle(draft);
      }
      onSaved();
    } catch (e) {
      onError(callableErrorMessage(e));
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="articles__overlay" role="dialog" aria-modal="true">
      <div className="card articles__editor">
        <div className="articles__editorHead">
          <h2 className="card__title">{article ? 'Edit article' : 'New article'}</h2>
          <button type="button" onClick={onClose} aria-label="Close">
            ✕
          </button>
        </div>

        <div className="articles__editorRow">
          <label>
            <span>Category</span>
            <select
              value={draft.categoryId}
              onChange={(e) =>
                setDraft({ ...draft, categoryId: e.target.value as CategoryId })
              }
            >
              {CATEGORIES.map((c) => (
                <option key={c} value={c}>
                  {c}
                </option>
              ))}
            </select>
          </label>
          <label>
            <span>Author</span>
            <input
              value={draft.author}
              onChange={(e) => setDraft({ ...draft, author: e.target.value })}
              placeholder="Vedadarshi Editorial"
            />
          </label>
          <label>
            <span>Read time (min)</span>
            <input
              type="number"
              min={1}
              max={60}
              value={draft.readMinutes}
              onChange={(e) =>
                setDraft({ ...draft, readMinutes: Number(e.target.value) || 1 })
              }
            />
          </label>
          <label className="articles__checkbox">
            <input
              type="checkbox"
              checked={draft.isFeatured}
              onChange={(e) => setDraft({ ...draft, isFeatured: e.target.checked })}
            />
            <span>Featured</span>
          </label>
        </div>

        {/* One tab per language rather than 10 stacked fields — an editor
            works in one language at a time, and the ✓ shows what is done. */}
        <div className="articles__tabs articles__localeTabs">
          {LOCALE_CODES.map((code) => {
            const done =
              (draft.title[code] ?? '').trim() && (draft.body[code] ?? '').trim();
            return (
              <button
                key={code}
                type="button"
                className={
                  locale === code ? 'articles__tab articles__tab--active' : 'articles__tab'
                }
                onClick={() => setLocale(code)}
              >
                {LOCALE_LABELS[code]} {done ? '✓' : ''}
              </button>
            );
          })}
        </div>

        <label className="articles__field">
          <span>Title ({LOCALE_LABELS[locale]})</span>
          <input
            value={draft.title[locale] ?? ''}
            onChange={(e) =>
              setDraft({ ...draft, title: { ...draft.title, [locale]: e.target.value } })
            }
          />
        </label>

        <label className="articles__field">
          <span>Body ({LOCALE_LABELS[locale]}) — blank line between paragraphs</span>
          <textarea
            rows={10}
            value={draft.body[locale] ?? ''}
            onChange={(e) =>
              setDraft({ ...draft, body: { ...draft.body, [locale]: e.target.value } })
            }
          />
        </label>

        <div className="articles__editorFoot">
          <span className="articles__hint">
            Saved as a draft. Publish from the list when it is ready.
          </span>
          <button type="button" onClick={onClose}>
            Cancel
          </button>
          <button
            type="button"
            className="articles__new"
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
