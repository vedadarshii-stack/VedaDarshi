import { useState } from 'react';

import {
  callableErrorMessage,
  sendNotification,
  type NotificationTarget,
} from '../../lib/adminApi';
import { NOTIFICATION_TRANSLATIONS } from '../../data/mock';
import './NotificationsPage.css';

/** Figma E5 · Notification Composer (node 35:2).
 *  The phone mock on the right is bound to the form so the preview is genuinely live. */
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

  const [title, setTitle] = useState('🛕 Sawan Somvar is tomorrow!');
  const [message, setMessage] = useState(
    'Observe the sacred Monday fast. Tap for rituals, muhurat timings and vrat rules.',
  );

  async function handleSend(event: React.FormEvent) {
    event.preventDefault();
    if (sending) return;
    setSending(true);
    setResult(null);
    setError(null);
    try {
      const res = await sendNotification({
        title,
        body: message,
        target,
        ...(target === 'locale' ? { locale } : {}),
        ...(target === 'token' ? { token } : {}),
      });
      // Reports the DESTINATION, not "sent to 48,320 users" — FCM accepts a
      // topic send without telling anyone how many devices it reached, and
      // inventing a number is how the old placeholder copy went wrong.
      setResult(`Sent to ${res.destination} · id ${res.messageId.slice(-12)}`);
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
              onChange={(event) => setTitle(event.target.value)}
            />
          </label>

          <label className="notify__field">
            <span className="notify__label">MESSAGE</span>
            <textarea
              className="notify__input notify__input--area"
              rows={3}
              value={message}
              onChange={(event) => setMessage(event.target.value)}
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
            <span className="notify__label">TRANSLATIONS</span>
            <div className="notify__locales">
              {NOTIFICATION_TRANSLATIONS.map((locale) => (
                <span
                  key={locale.label}
                  className={
                    locale.ready ? 'notify__locale notify__locale--ready' : 'notify__locale'
                  }
                  style={{ fontFamily: locale.font }}
                >
                  {locale.label} {locale.ready ? '✓' : '—'}
                </span>
              ))}
            </div>
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
