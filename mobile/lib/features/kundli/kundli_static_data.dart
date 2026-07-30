/// STATIC PLACEHOLDER CONTENT for the Kundli — New Chart screen — see
/// "B5 · Kundli — New Chart" (Figma node 17:2).
///
/// Unlike most other `*_static_data.dart` files in this app, this one is
/// NOT the primary data source for its screen — the Kundli input screen
/// renders the real saved [BirthProfile] (via `birthProfileProvider`)
/// whenever one is available, which is effectively always (`RootGate`
/// guarantees a saved profile exists before Home — and therefore this
/// screen — is reachable at all). [fallbackProfileName] and
/// [fallbackProfileSummary] exist purely as a defensive fallback for the
/// should-be-impossible case where the provider resolves to `null` (or is
/// still loading) — this screen must never render zero profile cards, so
/// something has to be shown while/if that happens.
///
/// ## Why this screen shows only ONE profile card, not two
///
/// The Figma design shows TWO profile cards — the user's own profile, plus
/// a second "Ananya (Sister)" card — previewing what a future family/friends
/// profile picker will look like. This implementation deliberately renders
/// only the one real saved profile: multi-profile support (adding a family
/// member or friend's birth details) is not implemented anywhere in this app
/// yet (see `BirthProfileRepository`'s doc comment — "Only a single ... the
/// account owner's own profile is supported here"). Fabricating a second,
/// hardcoded "Ananya" card would misrepresent working functionality that
/// doesn't actually exist. The "Add family or friend" dashed button on this
/// screen is the honest placeholder entry point for that future feature —
/// tapping it is a no-op today (see its `onTap` in `kundli_input_screen.dart`
/// for the same rationale).
abstract final class KundliStaticData {
  static const String fallbackProfileName = 'Nagarjuna';
  static const String fallbackProfileSummary =
      '14 Aug 1990 · 06:45 AM · Hyderabad';
}
