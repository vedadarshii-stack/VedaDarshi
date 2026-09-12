import { useCallback, useEffect, useState } from 'react';

import {
  LOCALE_CODES,
  LOCALE_LABELS,
  getAppConfig,
  saveAppConfig,
  type AppConfigDraft,
  type LocaleCode,
} from '../../lib/appConfig';
import { callableErrorMessage } from '../../lib/adminApi';
import { isPermissionDenied, firestoreErrorMessage } from '../../lib/firestoreErrors';
import { PageSkeleton } from '../../components/PageSkeleton';
import './ConfigPage.css';

/** App Config CMS (sidebar item, previously inert) — a FORM over a single
 *  document, `appConfig/global`, not a list like the other three new
 *  screens. There is nothing to filter, publish or delete; there is one
 *  Save button. */

type LoadState =
  | { status: 'loading' }
  | { status: 'ready' }
  | { status: 'denied' }
  | { status: 'error'; message: string };

export function ConfigPage() {
  const [state, setState] = useState<LoadState>({ status: 'loading' });
  const [draft, setDraft] = useState<AppConfigDraft | null>(null);
  const [locale, setLocale] = useState<LocaleCode>('en');
  const [newFlagKey, setNewFlagKey] = useState('');
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [savedAt, setSavedAt] = useState<number | null>(null);

  const load = useCallback(async () => {
    setState({ status: 'loading' });
    setError(null);
    try {
      const config = await getAppConfig();
      // Strip `updatedAt` into local component state so the form only ever
      // holds fields the user can edit — `saveAppConfig` re-stamps it.
      const { updatedAt: _updatedAt, ...rest } = config;
      setDraft(rest);
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

  async function save() {
    if (!draft || saving) return;
    if (!draft.supportEmail.trim()) {
      setError('A support email is required.');
      return;
    }
    setSaving(true);
    setError(null);
    try {
      await saveAppConfig(draft);
      setSavedAt(Date.now());
    } catch (e) {
      setError(callableErrorMessage(e));
    } finally {
      setSaving(false);
    }
  }

  function addFlag() {
    const key = newFlagKey.trim();
    if (!key || !draft) return;
    if (key in draft.featureFlags) {
      setError(`Feature flag “${key}” already exists.`);
      return;
    }
    setDraft({ ...draft, featureFlags: { ...draft.featureFlags, [key]: false } });
    setNewFlagKey('');
  }

  function removeFlag(key: string) {
    if (!draft) return;
    const next = { ...draft.featureFlags };
    delete next[key];
    setDraft({ ...draft, featureFlags: next });
  }

  function toggleFlag(key: string) {
    if (!draft) return;
    setDraft({
      ...draft,
      featureFlags: { ...draft.featureFlags, [key]: !draft.featureFlags[key] },
    });
  }

  if (state.status === 'loading') {
    return <PageSkeleton label="Loading app config" />;
  }

  return (
    <>
      <header className="pageHead">
        <div className="pageHead__text">
          <h1 className="pageHead__title">App Config</h1>
          <p className="pageHead__subtitle">
            Global settings read by the app on every launch.
          </p>
        </div>
        {state.status === 'ready' && (
          <button
            type="button"
            className="config__save"
            onClick={() => void save()}
            disabled={saving}
          >
            {saving ? 'Saving…' : 'Save changes'}
          </button>
        )}
      </header>

      {state.status === 'denied' && (
        <div className="card users__error" role="alert">
          <strong>Permission denied.</strong> Your role does not have read access to{' '}
          <code>appConfig</code> in Firestore.
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

      {savedAt && !error && (
        <div className="config__saved" role="status">
          ✓ Saved.
        </div>
      )}

      {state.status === 'ready' && draft && (
        <div className="config__form">
          <section className="card config__section">
            <h2 className="card__title">General</h2>
            <label className="config__field">
              <span>Support email</span>
              <input
                type="email"
                value={draft.supportEmail}
                onChange={(e) => setDraft({ ...draft, supportEmail: e.target.value })}
                placeholder="support@gosewealth.com"
              />
            </label>
            <label className="config__field">
              <span>Minimum supported app version</span>
              <input
                value={draft.minSupportedVersion}
                onChange={(e) =>
                  setDraft({ ...draft, minSupportedVersion: e.target.value })
                }
                placeholder="1.0.0"
              />
              <span className="config__hint">
                Users below this version see a forced-update prompt.
              </span>
            </label>
          </section>

          <section className="card config__section">
            <div className="config__sectionHead">
              <h2 className="card__title">Maintenance mode</h2>
              <label className="config__toggle">
                <input
                  type="checkbox"
                  checked={draft.maintenanceMode.enabled}
                  onChange={(e) =>
                    setDraft({
                      ...draft,
                      maintenanceMode: {
                        ...draft.maintenanceMode,
                        enabled: e.target.checked,
                      },
                    })
                  }
                />
                <span>{draft.maintenanceMode.enabled ? 'Enabled' : 'Disabled'}</span>
              </label>
            </div>

            <div className="config__tabs">
              {LOCALE_CODES.map((code) => {
                const done = (draft.maintenanceMode.message[code] ?? '').trim();
                return (
                  <button
                    key={code}
                    type="button"
                    className={
                      locale === code ? 'config__tab config__tab--active' : 'config__tab'
                    }
                    onClick={() => setLocale(code)}
                  >
                    {LOCALE_LABELS[code]} {done ? '✓' : ''}
                  </button>
                );
              })}
            </div>

            <label className="config__field">
              <span>Message shown to users ({LOCALE_LABELS[locale]})</span>
              <textarea
                rows={3}
                value={draft.maintenanceMode.message[locale] ?? ''}
                onChange={(e) =>
                  setDraft({
                    ...draft,
                    maintenanceMode: {
                      ...draft.maintenanceMode,
                      message: {
                        ...draft.maintenanceMode.message,
                        [locale]: e.target.value,
                      },
                    },
                  })
                }
                placeholder="We're performing scheduled maintenance. Please check back shortly."
              />
            </label>
          </section>

          <section className="card config__section">
            <h2 className="card__title">Feature flags</h2>
            {Object.keys(draft.featureFlags).length === 0 && (
              <p className="config__empty">No feature flags yet.</p>
            )}
            {Object.entries(draft.featureFlags).map(([key, value]) => (
              <div key={key} className="config__flagRow">
                <span className="config__flagKey">{key}</span>
                <label className="config__toggle">
                  <input
                    type="checkbox"
                    checked={value}
                    onChange={() => toggleFlag(key)}
                  />
                  <span>{value ? 'On' : 'Off'}</span>
                </label>
                <button
                  type="button"
                  className="config__flagRemove"
                  onClick={() => removeFlag(key)}
                  aria-label={`Remove ${key}`}
                >
                  ✕
                </button>
              </div>
            ))}
            <div className="config__flagAdd">
              <input
                value={newFlagKey}
                onChange={(e) => setNewFlagKey(e.target.value)}
                placeholder="new_flag_key"
                onKeyDown={(e) => {
                  if (e.key === 'Enter') {
                    e.preventDefault();
                    addFlag();
                  }
                }}
              />
              <button type="button" onClick={addFlag}>
                ＋ Add flag
              </button>
            </div>
          </section>
        </div>
      )}
    </>
  );
}
