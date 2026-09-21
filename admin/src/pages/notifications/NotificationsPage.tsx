import { useState } from 'react';

import {
  callableErrorMessage,
  sendNotification,
  type NotificationTarget,
} from '../../lib/adminApi';
import './NotificationsPage.css';

/** Figma E5 · Notification Composer (node 35:2).
 *  The phone mock on the right is bound to the form so the preview is genuinely live. */
/** The five shipped app languages, with the font each needs to render. */
const LOCALES = [
  { code: 'en', label: 'English', font: 'var(--vd-font-ui)' },
  { code: 'hi', label: 'हिन्दी', font: 'var(--vd-font-deva)' },
  { code: 'te', label: 'తెలుగు', font: 'var(--vd-font-telu)' },
  { code: 'ta', label: 'தமிழ்', font: 'var(--vd-font-tamil)' },
  { code: 'kn', label: 'ಕನ್ನಡ', font: 'var(--vd-font-kannada)' },
] as const;

type LocaleCode = (typeof LOCALES)[number]['code'];

type Draft = { title: string; body: string };

const EMPTY_DRAFTS: Record<LocaleCode, Draft> = {
  en: { title: '', body: '' },
  hi: { title: '', body: '' },
  te: { title: '', body: '' },
  ta: { title: '', body: '' },
  kn: { title: '', body: '' },
};

/** A language counts as written only when BOTH fields are filled. */
function isReady(d: Draft | undefined): boolean {
  return !!d && d.title.trim().length > 0 && d.body.trim().length > 0;
}

export function NotificationsPage() {
  // ⚠️ AUDIENCE IS NOW REAL, and the options changed to match what FCM can
  // actually do. The previous list offered "Premium subscribers (6,905)" and
  // "Free users (41,415)" — both invented counts, and neither is targetable:
  // FCM sends to TOPICS, and a subscription tier is not a topic. Offering a
  // target the server cannot honour is worse than offering fewer.
  const [target, setTarget] = useState<NotificationTarget>('all');
  const [locale, setLocale] = useState('hi');
  const [token, setToken] = useState('');
  const [sending, setSending] = useState(false);
  const [result, setResult] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  // ⚠️ REWRITTEN 21 Sep 2026. The TRANSLATIONS row used to be a hardcoded
  // array in `data/mock.ts` that rendered a fixed "English ✓ हिन्दी ✓ తెలుగు ✓
  // தமிழ் — ಕನ್ನಡ —". It reflected nothing: not the message being composed,
  // not the ARB files, not anything server-side, and it showed those same two
  // ✗ marks forever. The composer only ever held ONE title and body, so the
  // chips could not have meant anything.
  //
  // They are now the real editor: one draft per language, a chip ticks when
  // that language actually has both fields, and clicking a chip switches
  // which language you are writing. The row went from decoration to the
  // primary control.
  const [drafts, setDrafts] = useState<Record<LocaleCode, Draft>>({
    ...EMPTY_DRAFTS,
    en: {
      title: '🛕 Sawan Somvar is tomorrow!',
      body: 'Observe the sacred Monday fast. Tap for rituals, muhurat timings and vrat rules.',
    },
  });
  const [editing, setEditing] = useState<LocaleCode>('en');

  const draft = drafts[editing];
  const title = draft.title;
  const message = draft.body;

  function setDraft(patch: Partial<Draft>) {
    setDrafts((prev) => ({ ...prev, [editing]: { ...prev[editing], ...patch } }));
  }

  /** Languages with a complete draft — what actually gets sent. */
  const written = LOCALES.filter((l) => isReady(drafts[l.code]));

  /** English is the fallback for any language left unwritten. */
  const fallback = isReady(drafts.en) ? drafts.en : undefined;

  async function handleSend(event: React.FormEvent) {
    event.preventDefault();
    if (sending) return;
    setSending(true);
    setResult(null);
    setError(null);
    try {
      if (target === 'all' && written.length > 1) {
        // MULTILINGUAL BROADCAST. Send once per language topic, each with its
        // own text, instead of one English push to `all_users`.
        //
        // ⚠️ It is one or the other, never both. The app subscribes a device
        // to `all_users` AND to its own `locale_xx`, so doing both would
        // deliver the same push twice to everyone. Because every user sits on
        // exactly one locale topic, fanning out reaches the same audience —
        // each person once, in their own language.
        //
        // Languages with no draft fall back to the English text, so nobody is
        // silently skipped just because a translation is missing.
        const sends = LOCALES.map((l) => {
          const d = isReady(drafts[l.code]) ? drafts[l.code] : fallback;
          if (!d) return null;
          return sendNotification({
            title: d.title,
            body: d.body,
            target: 'locale',
            locale: l.code,
          });
        }).filter(Boolean) as Promise<{ messageId: string; destination: string }>[];

        // `allSettled`, not `all`: one language failing must not hide the
        // fact that the other four went out. A push cannot be recalled, so
        // the operator needs to know exactly what landed before retrying.
        const results = await Promise.allSettled(sends);
        const ok = results.filter((r) => r.status === 'fulfilled').length;
        const failed = results.length - ok;
        setResult(
          failed === 0
            ? `Sent in ${ok} languages`
            : `Sent in ${ok} languages · ${failed} failed — do not resend the ones that worked`,
        );
      } else {
        const d = target === 'all' && fallback ? fallback : draft;
        const res = await sendNotification({
          title: d.title,
          body: d.body,
          target,
          ...(target === 'locale' ? { locale } : {}),
          ...(target === 'token' ? { token } : {}),
        });
        // Reports the DESTINATION, not "sent to 48,320 users" — FCM accepts a
        // topic send without telling anyone how many devices it reached, and
        // inventing a number is how the old placeholder copy went wrong.
        setResult(`Sent to ${res.destination} · id ${res.messageId.slice(-12)}`);
      }
    } catch (e) {
      setError(callableErrorMessage(e));
    } finally {
      setSending(false);
    }
  }

  return (
    <div className="notify">
      <section className="notify__composer">
        <header className="pageHead">
          <div className="pageHead__text">
            <h1 className="pageHead__title">Send Notification</h1>
            <p className="pageHead__subtitle">
              Compose a push notification via Firebase Cloud Messaging
            </p>
          </div>
        </header>

        <form onSubmit={handleSend} className="card notify__form">
          <label className="notify__field">
            <span className="notify__label">TITLE</span>
            <input
              className="notify__input"
              value={title}
              onChange={(event) => setDraft({ title: event.target.value })}
            />
          </label>

          <label className="notify__field">
            <span className="notify__label">MESSAGE</span>
            <textarea
              className="notify__input notify__input--area"
              rows={3}
              value={message}
              onChange={(event) => setDraft({ body: event.target.value })}
            />
          </label>

          <div className="notify__pair">
            <label className="notify__field">
              <span className="notify__label">AUDIENCE</span>
              <select
                className="notify__input notify__input--select"
                value={target}
                onChange={(e) => setTarget(e.target.value as NotificationTarget)}
              >
                <option value="all">All users</option>
                <option value="locale">By language</option>
                <option value="token">One device (test)</option>
              </select>
            </label>

            {target === 'locale' ? (
              <label className="notify__field">
                <span className="notify__label">LANGUAGE</span>
                <select
                  className="notify__input notify__input--select"
                  value={locale}
                  onChange={(e) => setLocale(e.target.value)}
                >
                  <option value="en">English</option>
                  <option value="hi">हिन्दी</option>
                  <option value="te">తెలుగు</option>
                  <option value="ta">தமிழ்</option>
                  <option value="kn">ಕನ್ನಡ</option>
                </select>
              </label>
            ) : target === 'token' ? (
              <label className="notify__field">
                <span className="notify__label">FCM TOKEN</span>
                <input
                  className="notify__input"
                  value={token}
                  onChange={(e) => setToken(e.target.value)}
                  placeholder="Paste a device token to test"
                />
              </label>
            ) : (
              <div className="notify__field" />
            )}
          </div>

          <div className="notify__field">
            <span className="notify__label">
              TRANSLATIONS — click a language to write it
            </span>
            <div className="notify__locales">
              {LOCALES.map((l) => {
                const ready = isReady(drafts[l.code]);
                const active = editing === l.code;
                return (
                  <button
                    key={l.code}
                    type="button"
                    onClick={() => setEditing(l.code)}
                    aria-pressed={active}
                    className={[
                      'notify__locale',
                      ready ? 'notify__locale--ready' : '',
                      active ? 'notify__locale--active' : '',
                    ]
                      .filter(Boolean)
                      .join(' ')}
                    style={{ fontFamily: l.font }}
                  >
                    {l.label} {ready ? '✓' : '—'}
                  </button>
                );
              })}
            </div>
            <span className="notify__hint">
              {target === 'all' && written.length > 1
                ? `Will send ${written.length} separate pushes, one per language — everyone gets theirs once.`
                : target === 'all'
                  ? 'Only English is written, so this goes to everyone in English. Write another language to send per-language.'
                  : `Sending the ${LOCALES.find((l) => l.code === (target === 'locale' ? locale : editing))?.label} version.`}
            </span>
          </div>

          {/* Scheduling was a label with nothing behind it — there is no
              scheduler, so the button says what it does: send now. */}
          <div className="notify__submitRow">
            <span className="notify__schedule">
              {error ? (
                <strong className="notify__error">{error}</strong>
              ) : result ? (
                <span className="notify__ok">{result}</span>
              ) : (
                'Sends immediately — a push cannot be recalled'
              )}
            </span>
            <button type="submit" className="notify__send" disabled={sending}>
              {sending ? 'Sending…' : 'Send now ➤'}
            </button>
          </div>
        </form>
      </section>

      <aside className="notify__previewPane">
        <p className="notify__previewLabel">LIVE PREVIEW</p>
        <div className="phone">
          <p className="phone__time">7:00</p>
          <p className="phone__date">Saturday, 12 July</p>
          <div className="phone__push">
            <span className="phone__appIcon vd-om">ॐ</span>
            <span className="phone__body">
              <span className="phone__meta">
                <span className="phone__app">Vedadarshi</span>
                <span className="phone__ago">now</span>
              </span>
              <span className="phone__title">{title}</span>
              <span className="phone__message">{message}</span>
            </span>
          </div>
        </div>
      </aside>
    </div>
  );
}
