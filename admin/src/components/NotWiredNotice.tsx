import './NotWiredNotice.css';

/**
 * Says plainly that a CMS screen's content is stored but not yet rendered by
 * the mobile app.
 *
 * BUILT 12 Sep 2026, after the App Config screen shipped claiming "Global
 * settings read by the app on every launch" when nothing in `mobile/lib` read
 * them at all. Editorial screens landed ahead of their readers on purpose —
 * the same staged order Articles used — but a console that does not SAY so
 * teaches its operator something false, and they only find out when a change
 * they published fails to appear.
 *
 * The rule this encodes: **a CMS screen may ship before its reader, but it
 * must never imply the reader exists.** Delete this notice from a screen in
 * the same change that wires the app up to it — not before, and not after.
 */
export function NotWiredNotice({ what }: { what: string }) {
  return (
    <div className="notWired" role="status">
      <strong>Saved, but not live yet.</strong> {what} are stored in Firestore
      and are ready for the app to read, but the mobile app does not display
      them yet — so publishing here will not change anything a user sees.
    </div>
  );
}
