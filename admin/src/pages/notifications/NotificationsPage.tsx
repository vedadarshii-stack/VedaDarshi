import { useState } from 'react';
import { NOTIFICATION_TRANSLATIONS } from '../../data/mock';
import './NotificationsPage.css';

/** Figma E5 · Notification Composer (node 35:2).
 *  The phone mock on the right is bound to the form so the preview is genuinely live. */
export function NotificationsPage() {
  const [title, setTitle] = useState('🛕 Sawan Somvar is tomorrow!');
  const [message, setMessage] = useState(
    'Observe the sacred Monday fast. Tap for rituals, muhurat timings and vrat rules.',
  );

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

        <form className="card notify__form" onSubmit={(event) => event.preventDefault()}>
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
              <select className="notify__input notify__input--select" defaultValue="all">
                <option value="all">All users (48,320)</option>
                <option value="premium">Premium subscribers (6,905)</option>
                <option value="free">Free users (41,415)</option>
              </select>
            </label>

            <label className="notify__field">
              <span className="notify__label">DEEP LINK</span>
              <select className="notify__input notify__input--select" defaultValue="sawan">
                <option value="sawan">Article: Sawan Somvar</option>
                <option value="panchang">Screen: Panchang</option>
                <option value="paywall">Screen: Subscription</option>
                <option value="none">None</option>
              </select>
            </label>
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

          <div className="notify__submitRow">
            <span className="notify__schedule">◷ Schedule: Today, 7:00 PM IST</span>
            <button type="submit" className="notify__send">
              Schedule ➤
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
