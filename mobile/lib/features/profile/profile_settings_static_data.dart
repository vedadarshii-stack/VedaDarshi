/// STATIC PLACEHOLDER CONTENT for the Profile & Settings screen — see
/// "D5 · Profile & Settings" (Figma node 29:2).
///
/// These are exactly the VALUES the design hardcodes (activity counts, the
/// last payment line, the appearance/subscription summary lines) — none of
/// them come from a real data source yet:
///  - `reportsPurchased` / `downloadedPdfs` / `aiChatConversations` /
///    `lastPayment` need the "My Activity" data layer (purchased reports,
///    exported PDFs, AI chat history persistence — the last two are listed
///    SCOPE WATCH items in `projects/CLAUDE.md`) and a payments record.
///  - `subscriptionSummary` needs RevenueCat entitlements (same rule as the
///    Subscription Paywall's hardcoded prices — real plan/renewal data must
///    come from RevenueCat, never a client-side flag).
/// Deliberately NOT included here: the "Birth profiles" count (computed for
/// real from `birthProfileProvider` in the screen — fabricating a count
/// would misrepresent multi-profile support that doesn't exist yet, same
/// principle as `KundliStaticData`'s doc comment) and the Panchang location
/// (reuses `PanchangStaticData.location` rather than duplicating it).
abstract final class ProfileSettingsStaticData {
  static const String reportsPurchased = '4 purchased';
  static const String downloadedPdfs = '3 files';
  static const String aiChatConversations = '12 conversations';
  static const String lastPayment = 'Last: ₹1,999 · 12 Jun 2026';
  static const String subscriptionSummary = 'Yearly · renews 12 Jun 2027';
}
