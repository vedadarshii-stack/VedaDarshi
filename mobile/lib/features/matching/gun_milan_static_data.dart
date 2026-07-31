/// Static placeholder data for the Gun Milan select screen, per the approved
/// Figma "C1 · Gun Milan — Select" (node 19:3) concept.
///
/// Standing in for the Vedika API's 36-point Ashtakoota Gun Milan endpoint
/// (see `projects/CLAUDE.md`'s "Confirmed stack decisions" section) — nothing
/// here is a real calculation, only presentation-ready placeholder copy.
///
/// The GROOM card shows the signed-in user's own saved [BirthProfile]
/// (`birth_profile_repository.dart`), falling back to [fallbackGroomName] /
/// [fallbackGroomSummary] only for the should-be-impossible "no profile yet"
/// case, same convention as `kundli_static_data.dart`.
///
/// The BRIDE side is deliberately an EMPTY STATE, exactly as the Figma design
/// shows it — there is no second saved profile to select because
/// multi-profile support (family/friends) isn't built yet (see the Kundli
/// input screen's "Add family or friend" placeholder button for the same
/// honest gap). This file does NOT invent a bride profile.
abstract final class GunMilanStaticData {
  static const String fallbackGroomName = 'Nagarjuna';
  static const String fallbackGroomSummary =
      '14 Aug 1990 · 06:45 AM · Hyderabad';
}
