/// Static placeholder data for the Search feature, per the approved Figma
/// "D3 · Search" (node 27:2) concept.
///
/// Standing in for a real per-user recent-search history (Firestore, keyed
/// by uid) plus a trending-terms aggregate computed server-side from search
/// volume across all users. Both are simple string lists today; wiring the
/// real sources later should only touch this file and the small piece of
/// [SearchScreen] state that seeds from it, never the rest of the widget
/// tree.
library;

abstract final class SearchStaticData {
  /// Seed values for the screen's local, mutable "recent searches" list —
  /// see "D3 · Search" (Figma node 27:2), the RECENT row.
  static const List<String> recentSeed = [
    'sade sati',
    'marriage muhurat',
    'gemstone for leo',
  ];

  /// Trending search terms — see "D3 · Search" (Figma node 27:2), the
  /// TRENDING row.
  static const List<String> trending = [
    'Sawan 2026',
    'Mangal dosha',
    'Ekadashi',
    'Gemstones',
  ];
}
