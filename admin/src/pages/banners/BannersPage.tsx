import { useCallback, useEffect, useMemo, useState } from 'react';

import {
  CTA_TARGETS,
  LOCALE_CODES,
  LOCALE_LABELS,
  createBanner,
  listBanners,
  removeBanner,
  setBannerPublished,
  updateBanner,
  type Banner,
  type BannerCtaTarget,
  type BannerStatus,
  type LocaleCode,
} from '../../lib/banners';
import { callableErrorMessage } from '../../lib/adminApi';
import { isPermissionDenied, firestoreErrorMessage } from '../../lib/firestoreErrors';
import { PageSkeleton } from '../../components/PageSkeleton';
import './BannersPage.css';

/** Home-screen banner carousel CMS (sidebar "Banners", previously inert —
 *  see `App.tsx`/`navigation.ts`). Mirrors the Articles CMS structure. */

type Filter = 'all' | BannerStatus;

const EMPTY_DRAFT = {
  title: {} as Partial<Record<LocaleCode, string>>,
  subtitle: {} as Partial<Record<LocaleCode, string>>,
  emoji: '🔔',
  ctaLabel: {} as Partial<Record<LocaleCode, string>>,
  ctaTarget: 'none' as BannerCtaTarget,
  sortOrder: 0,
  startsAt: null as string | null,
  endsAt: null as string | null,
};

export function BannersPage() {
  const [banners, setBanners] = useState<Banner[]>([]);
  const [loading, setLoading] = useState(true);
  const [denied, setDenied] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [filter, setFilter] = useState<Filter>('all');
  const [editing, setEditing] = useState<Banner | 'new' | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setDenied(false);
    setError(null);
    try {
      setBanners(await listBanners());
    } catch (e) {
      if (isPermissionDenied(e)) {
        setDenied(true);
      } else {
        setError(firestoreErrorMessage(e));
      }
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  const visible = useMemo(
    () => (filter === 'all' ? banners : banners.filter((b) => b.status === filter)),
    [banners, filter],
  );

  const counts = useMemo(
    () => ({
      all: banners.length,
      published: banners.filter((b) => b.status === 'published').length,
      draft: banners.filter((b) => b.status === 'draft').length,
    }),
    [banners],
  );

  async function act(fn: () => Promise<unknown>) {
    try {
      await fn();
      await load();
    } catch (e) {
      setError(callableErrorMessage(e));
    }
  }

  if (loading && banners.length === 0 && !error && !denied) {
    return <PageSkeleton label="Loading banners" />;
  }

  return (
    <>
      <header className="pageHead">
        <div className="pageHead__text">
          <h1 className="pageHead__title">Banners</h1>
          <p className="pageHead__subtitle">
            {counts.all} total · {counts.published} published · {counts.draft} draft
          </p>
        </div>
        <button type="button" className="banners__new" onClick={() => setEditing('new')}>
          ＋ New Banner
        </button>
      </header>

      {denied && (
        <div className="card users__error" role="alert">
          <strong>Permission denied.</strong> Your role does not have read access to{' '}
          <code>banners</code> in Firestore.
        </div>
      )}

      {error && (
        <div className="card users__error" role="alert">
          <strong>Something went wrong.</strong> {error}
          <button type="button" onClick={() => void load()}>
            Retry
          </button>
        </div>
      )}

      {!denied && (
        <>
          <div className="banners__tabs">
            {(['all', 'published', 'draft'] as Filter[]).map((tab) => (
              <button
                key={tab}
                type="button"
                className={
                  filter === tab ? 'banners__tab banners__tab--active' : 'banners__tab'
                }
                onClick={() => setFilter(tab)}
              >
                {tab === 'all' ? 'All' : tab === 'published' ? 'Published' : 'Drafts'}
                <span className="users__filterCount">{counts[tab]}</span>
              </button>
            ))}
          </div>

          <div className="card banners__list">
            {visible.length === 0 && (
              <div className="banners__empty">
                {banners.length === 0
                  ? 'No banners yet. Create the first one — it appears in the app home carousel once published.'
                  : 'Nothing in this tab.'}
              </div>
            )}

            {visible.map((banner, index) => {
              const locales = LOCALE_CODES.filter((code) => (banner.title[code] ?? '').trim());
              return (
                <div key={banner.id}>
                  {index > 0 && <div className="table__divider" />}
                  <div className="banners__row">
                    <span className="banners__emoji" aria-hidden="true">
                      {banner.emoji || '🔔'}
                    </span>
                    <div className="banners__main">
                      <p className="banners__title">
                        {banner.title.en?.trim() || <em>Untitled</em>}
                      </p>
                      <p className="banners__meta">
                        target: {banner.ctaTarget} · order {banner.sortOrder}
                        {(banner.startsAt || banner.endsAt) && (
                          <>
                            {' '}
                            · {banner.startsAt ?? '…'} → {banner.endsAt ?? '…'}
                          </>
                        )}
                      </p>
                      <div className="banners__locales">
                        {LOCALE_CODES.map((code) => (
                          <span
                            key={code}
                            className={
                              locales.includes(code)
                                ? 'banners__locale banners__locale--ready'
                                : 'banners__locale'
                            }
                            title={
                              locales.includes(code)
                                ? `${LOCALE_LABELS[code]} — ready`
                                : `${LOCALE_LABELS[code]} — needs a title`
                            }
                          >
                            {code.toUpperCase()} {locales.includes(code) ? '✓' : '—'}
                          </span>
                        ))}
                      </div>
                    </div>

                    <span
                      className={`pill ${
                        banner.status === 'published' ? 'pill--premium' : 'pill--free'
                      }`}
                    >
                      {banner.status}
                    </span>

                    <div className="banners__actions">
                      <button type="button" onClick={() => setEditing(banner)}>
                        Edit
                      </button>
                      <button
                        type="button"
                        onClick={() =>
                          void act(() => setBannerPublished(banner, banner.status !== 'published'))
                        }
                        // No English title means nothing for the app to fall
                        // back to — publishing would show a blank card.
                        disabled={
                          banner.status !== 'published' && !banner.title.en?.trim()
                        }
                        title={
                          !banner.title.en?.trim()
                            ? 'Needs an English title before publishing'
                            : undefined
                        }
                      >
                        {banner.status === 'published' ? 'Unpublish' : 'Publish'}
                      </button>
                      <button
                        type="button"
                        className="banners__delete"
                        onClick={() => {
                          if (
                            window.confirm(
                              `Delete “${banner.title.en || 'Untitled'}”? This cannot be undone.`,
                            )
                          ) {
                            void act(() => removeBanner(banner.id));
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
        </>
      )}

      {editing && (
        <BannerEditor
          banner={editing === 'new' ? null : editing}
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

function BannerEditor({
  banner,
  onClose,
  onSaved,
  onError,
}: {
  banner: Banner | null;
  onClose: () => void;
  onSaved: () => void;
  onError: (message: string) => void;
}) {
  const [draft, setDraft] = useState(() =>
    banner
      ? {
          title: { ...banner.title },
          subtitle: { ...banner.subtitle },
          emoji: banner.emoji,
          ctaLabel: { ...banner.ctaLabel },
          ctaTarget: banner.ctaTarget,
          sortOrder: banner.sortOrder,
          startsAt: banner.startsAt,
          endsAt: banner.endsAt,
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
      if (banner) {
        await updateBanner(banner.id, draft);
      } else {
        await createBanner(draft);
      }
      onSaved();
    } catch (e) {
      onError(callableErrorMessage(e));
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="banners__overlay" role="dialog" aria-modal="true">
      <div className="card banners__editor">
        <div className="banners__editorHead">
          <h2 className="card__title">{banner ? 'Edit banner' : 'New banner'}</h2>
          <button type="button" onClick={onClose} aria-label="Close">
            ✕
          </button>
        </div>

        <div className="banners__editorRow">
          <label>
            <span>Emoji</span>
            <input
              value={draft.emoji}
              maxLength={4}
              onChange={(e) => setDraft({ ...draft, emoji: e.target.value })}
              placeholder="🔔"
            />
          </label>
          <label>
            <span>CTA target</span>
            <select
              value={draft.ctaTarget}
              onChange={(e) =>
                setDraft({ ...draft, ctaTarget: e.target.value as BannerCtaTarget })
              }
            >
              {CTA_TARGETS.map((t) => (
                <option key={t} value={t}>
                  {t}
                </option>
              ))}
            </select>
          </label>
          <label>
            <span>Sort order</span>
            <input
              type="number"
              value={draft.sortOrder}
              onChange={(e) =>
                setDraft({ ...draft, sortOrder: Number(e.target.value) || 0 })
              }
            />
          </label>
          <label>
            <span>Starts on (optional)</span>
            <input
              type="date"
              value={draft.startsAt ?? ''}
              onChange={(e) => setDraft({ ...draft, startsAt: e.target.value || null })}
            />
          </label>
          <label>
            <span>Ends on (optional)</span>
            <input
              type="date"
              value={draft.endsAt ?? ''}
              onChange={(e) => setDraft({ ...draft, endsAt: e.target.value || null })}
            />
          </label>
        </div>

        {/* One tab per language — the same recipe as the Articles editor. */}
        <div className="banners__tabs banners__localeTabs">
          {LOCALE_CODES.map((code) => {
            const done = (draft.title[code] ?? '').trim();
            return (
              <button
                key={code}
                type="button"
                className={
                  locale === code ? 'banners__tab banners__tab--active' : 'banners__tab'
                }
                onClick={() => setLocale(code)}
              >
                {LOCALE_LABELS[code]} {done ? '✓' : ''}
              </button>
            );
          })}
        </div>

        <label className="banners__field">
          <span>Title ({LOCALE_LABELS[locale]})</span>
          <input
            value={draft.title[locale] ?? ''}
            onChange={(e) =>
              setDraft({ ...draft, title: { ...draft.title, [locale]: e.target.value } })
            }
          />
        </label>

        <label className="banners__field">
          <span>Subtitle ({LOCALE_LABELS[locale]})</span>
          <input
            value={draft.subtitle[locale] ?? ''}
            onChange={(e) =>
              setDraft({ ...draft, subtitle: { ...draft.subtitle, [locale]: e.target.value } })
            }
          />
        </label>

        <label className="banners__field">
          <span>CTA label ({LOCALE_LABELS[locale]})</span>
          <input
            value={draft.ctaLabel[locale] ?? ''}
            onChange={(e) =>
              setDraft({ ...draft, ctaLabel: { ...draft.ctaLabel, [locale]: e.target.value } })
            }
          />
        </label>

        <div className="banners__editorFoot">
          <span className="banners__hint">
            Saved as a draft. Publish from the list when it is ready.
          </span>
          <button type="button" onClick={onClose}>
            Cancel
          </button>
          <button
            type="button"
            className="banners__new"
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
