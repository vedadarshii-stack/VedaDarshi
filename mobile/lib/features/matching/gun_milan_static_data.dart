import 'guna_milan_data.dart';

/// Static placeholder data for the Gun Milan select + result screens, per
/// the approved Figma "C1 · Gun Milan — Select" (node 19:3) / "C2 · Gun
/// Milan — Result" (node 20:2) concepts.
///
/// **The astrology VALUES on the Result screen are now REAL** — wired to
/// the Vedika API's Ashtakoota Gun Milan endpoint (`guna_milan_data.dart` +
/// `guna_milan_repository.dart`). What remains placeholder here is
/// everything downstream of the fact that only ONE real birth profile
/// exists in this app (see the BRIDE doc comment below) plus the
/// should-be-impossible "no profile yet" fallback.
///
/// The GROOM card shows the signed-in user's own saved [BirthProfile]
/// (`birth_profile_repository.dart`), falling back to [fallbackGroomName] /
/// [fallbackGroomSummary] / [fallbackGroomPartnerParams] only for the
/// should-be-impossible "no profile yet" case, same convention as
/// `kundli_static_data.dart`.
///
/// The BRIDE side is deliberately an EMPTY STATE on the Select screen,
/// exactly as the Figma design shows it — there is no second saved profile
/// to select because multi-profile support (family/friends) isn't built yet
/// (see the Kundli input screen's "Add family or friend" placeholder button
/// for the same honest gap). **This is the multi-profile gap that also
/// blocks the Result screen's API call**: Vedika's guna-milan endpoint
/// requires a full second birth chart (date/time/lat/long) to run at all,
/// and there is nowhere in this app to collect one yet, so
/// [placeholderBrideName] / [placeholderBridePartnerParams] stand in for a
/// bride profile that does not exist. This file still does NOT invent a
/// bride *identity* beyond the name already shown in the empty-state design
/// mock — it only supplies the numbers the API call cannot run without.
/// Replace both the instant this app can store a second profile.
abstract final class GunMilanStaticData {
  static const String fallbackGroomName = 'Nagarjuna';
  static const String fallbackGroomSummary =
      '14 Aug 1990 · 06:45 AM · Hyderabad';

  /// [fallbackGroomSummary] as API request params — Hyderabad, India
  /// (17.384°N 78.4564°E, from the bundled `cities.json`), fixed +05:30
  /// (`Asia/Kolkata` has no DST, so no historical-offset resolution is
  /// needed the way [GunaMilanPartnerParams.fromBirthProfile] does for a
  /// real profile).
  static const GunaMilanPartnerParams fallbackGroomPartnerParams =
      GunaMilanPartnerParams(
        datetime: '1990-08-14T06:45:00',
        latitude: 17.384,
        longitude: 78.4564,
        timezone: '+05:30',
      );

  /// Bride display name for the Result screen's "$groomName 💞 $brideName"
  /// header line — the same 'Ananya' placeholder the Select screen's empty
  /// bride card design implies, kept as ONE shared constant rather than
  /// re-declared per screen.
  static const String placeholderBrideName = 'Ananya';

  /// Placeholder bride birth params (Mumbai, India — 19.0728°N 72.8826°E,
  /// also fixed +05:30) — the ONLY thing that makes the Result screen's API
  /// call runnable today, per this file's doc comment on the multi-profile
  /// gap. Arbitrary: not meant to represent a real "Ananya", just a
  /// plausible second chart. **Do not let this silently reach production**
  /// — once multi-profile support exists, the Result screen must require a
  /// real selected bride profile instead of falling back to this constant.
  static const GunaMilanPartnerParams placeholderBridePartnerParams =
      GunaMilanPartnerParams(
        datetime: '1997-03-15T14:00:00',
        latitude: 19.0728,
        longitude: 72.8826,
        timezone: '+05:30',
      );
}
