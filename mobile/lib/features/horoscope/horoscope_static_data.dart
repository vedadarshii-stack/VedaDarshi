/// STATIC PLACEHOLDER CONTENT for the "Horoscope — All Signs" screen — see
/// "B3 · Horoscope — All Signs" (Figma node 15:2).
///
/// Every value in this file stands in for what will eventually come from
/// the **Vedika API** (vedika.io), cached once per day per language in
/// Firestore (see the "Astrology data" section of the project's top-level
/// CLAUDE.md).
///
/// Keeping every placeholder value in this one file (rather than scattered
/// across the widget tree in `horoscope_signs_screen.dart`) means wiring up
/// that real data source later is a matter of replacing the provider that
/// supplies these values — it should never require touching the widgets
/// themselves.
/// DELETED 21 Aug 2026: `userSignId`.
///
/// It was `'simha'` — a constant, so the "Your sign" badge on the grid, the
/// Home horoscope teaser and the sign that teaser opened were **Leo for
/// every user of the app**, whatever their birth date. The doc comment here
/// said the real sign "must be DERIVED from the saved birth profile", which
/// is now what happens: see `userZodiacSignProvider` in
/// `user_sign_provider.dart`, which reads the Moon's rashi off the user's
/// own kundli.
///
/// The constant is removed rather than deprecated on purpose — leaving a
/// plausible-looking default in reach is how it ended up on three screens.
/// Anything needing the user's sign watches the provider and renders a
/// neutral state when it is null.
///
/// This class is now empty; the file is kept for the doc note above and as
/// the home for genuine horoscope placeholder content if any is added.
abstract final class HoroscopeStaticData {}
