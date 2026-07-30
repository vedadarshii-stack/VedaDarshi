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
abstract final class HoroscopeStaticData {
  /// Which [ZodiacSign.id] gets the "Your sign" badge on the grid.
  ///
  /// The real sign must be DERIVED from the saved birth profile's moon/sun
  /// sign, which needs the Vedika API — hardcoded to Simha per the design
  /// until then.
  static const String userSignId = 'simha';
}
