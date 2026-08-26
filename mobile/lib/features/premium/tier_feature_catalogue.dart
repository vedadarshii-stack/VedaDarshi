import '../../core/purchases/subscription_tier.dart';
import '../../l10n/app_localizations.dart';

/// Per-tier feature copy for the Subscription Paywall, one line list per
/// [SubscriptionTier].
///
/// **Canonical source: the `access_control_matrix` Remote Config parameter**
/// (Firebase project `vedadarshi-20989`) together with the client's
/// `pricing for vedadarshi (2).pdf`. Both are documented in
/// `projects/CLAUDE.md` under "Access Control Matrix" — that table is the
/// thing to re-check when a number here looks wrong.
///
/// **Remote Config is NOT yet read by the app.** `firebase_remote_config`
/// isn't even a dependency of this project, and nothing fetches
/// `access_control_matrix` at runtime. This class is therefore a
/// hand-maintained MIRROR of that parameter, not a live read of it — until a
/// consumer is wired up, editing one without the other lets this paywall
/// silently drift from what the client actually configured server-side.
///
/// **No price, currency, or period belongs in this file, ever.** Every price
/// shown on the paywall comes from `StoreProduct.priceString` by way of
/// `SubscriptionCatalogue` — see that class's doc comment. This one only
/// ever holds counts, percentages, and booleans.
///
/// Tiers are cumulative (see [SubscriptionTier]'s doc comment), so each
/// tier's list is written to read as a superset of the one below it —
/// bigger numbers, more things included — never as if a higher tier lacks
/// something a lower one has.
class TierFeatureCatalogue {
  const TierFeatureCatalogue._();

  static const Map<SubscriptionTier, TierFeatureData> _data = {
    SubscriptionTier.bronze: TierFeatureData(
      aiQuestionsPerDay: 2,
      hasYearlyHoroscope: false,
      savedKundalis: 15,
      detailedCompatibilityPerMonth: 3,
      reportDiscountPercent: 5,
      hasPremiumArticles: false,
      completeLifeReportCreditsPerMonth: 0,
    ),
    SubscriptionTier.silver: TierFeatureData(
      aiQuestionsPerDay: 4,
      hasYearlyHoroscope: false,
      savedKundalis: null,
      detailedCompatibilityPerMonth: 5,
      reportDiscountPercent: 10,
      hasPremiumArticles: false,
      completeLifeReportCreditsPerMonth: 0,
    ),
    SubscriptionTier.gold: TierFeatureData(
      aiQuestionsPerDay: 7,
      hasYearlyHoroscope: true,
      savedKundalis: null,
      detailedCompatibilityPerMonth: 10,
      reportDiscountPercent: 15,
      hasPremiumArticles: true,
      completeLifeReportCreditsPerMonth: 0,
    ),
    SubscriptionTier.platinum: TierFeatureData(
      aiQuestionsPerDay: 10,
      hasYearlyHoroscope: true,
      savedKundalis: null,
      detailedCompatibilityPerMonth: 30,
      reportDiscountPercent: 20,
      hasPremiumArticles: true,
      completeLifeReportCreditsPerMonth: 1,
    ),
  };

  /// Localized, ready-to-render feature lines for [tier].
  ///
  /// Returns an empty list for [SubscriptionTier.free] — the free tier has
  /// no card on this paywall (it is what you get by not subscribing).
  ///
  /// **`AI questions` is deliberately always a count, never "unlimited"** —
  /// no tier is unlimited, and Platinum caps at
  /// [TierFeatureData.aiQuestionsPerDay] = 10/day. Do not add an "unlimited
  /// AI" line for any tier; that claim was removed from this paywall
  /// precisely because it was false and a mis-selling risk.
  static List<String> linesFor(SubscriptionTier tier, AppLocalizations l10n) {
    final data = _data[tier];
    if (data == null) return const [];

    return [
      l10n.tierFeatureAiQuestions(data.aiQuestionsPerDay),
      // YEARLY IS DELIVERED — corrected 26 Aug 2026. The earlier "yearly
      // cannot be delivered" conclusion here only checked
      // `GET /v2/astrology/horoscope/{sign}/yearly`, which does 404; it
      // never checked whether Vedika had a yearly reading under a
      // different path. It does: `POST /v2/astrology/prediction/yearly`
      // (body `{"rashi": <sign>}`), verified live and now wired via
      // `fetchYearly`/`yearlyHoroscopeProvider` in
      // `horoscope_repository.dart`. Restored to the ternary the pricing
      // matrix always called for.
      data.hasYearlyHoroscope
          ? l10n.tierFeatureHoroscopeWithYearly
          : l10n.tierFeatureHoroscopeStandard,
      data.savedKundalis == null
          ? l10n.tierFeatureKundalisUnlimited
          : l10n.tierFeatureKundalisLimited(data.savedKundalis!),
      l10n.tierFeatureCompatibility(data.detailedCompatibilityPerMonth),
      l10n.tierFeatureReportDiscount(data.reportDiscountPercent),
      if (data.hasPremiumArticles) l10n.tierFeaturePremiumArticles,
      if (data.completeLifeReportCreditsPerMonth > 0)
        l10n.tierFeatureLifeReportCredit(
          data.completeLifeReportCreditsPerMonth,
        ),
    ];
  }
}

/// Raw per-tier numbers backing [TierFeatureCatalogue.linesFor].
///
/// Deliberately just data — no formatting, no strings, no prices. Localizing
/// these into copy is [TierFeatureCatalogue.linesFor]'s job, not this
/// class's.
class TierFeatureData {
  const TierFeatureData({
    required this.aiQuestionsPerDay,
    required this.hasYearlyHoroscope,
    required this.savedKundalis,
    required this.detailedCompatibilityPerMonth,
    required this.reportDiscountPercent,
    required this.hasPremiumArticles,
    required this.completeLifeReportCreditsPerMonth,
  });

  /// Total AI Astrologer questions allowed per day, INCLUDING the free daily
  /// question — matching how the pricing PDF and the ledger both count it
  /// (see the "AI question counts" note in `projects/CLAUDE.md`). Never
  /// unlimited for any tier.
  final int aiQuestionsPerDay;

  /// Whether this tier unlocks the Yearly horoscope, on top of Weekly and
  /// Monthly (which every paid tier gets).
  final bool hasYearlyHoroscope;

  /// Cap on saved kundalis, or `null` for unlimited (Silver and above).
  final int? savedKundalis;

  /// Detailed compatibility (Gun Milan) reports allowed per month.
  final int detailedCompatibilityPerMonth;

  /// Discount percentage applied to premium report purchases. Premium
  /// reports are always a separate one-time purchase — this is a discount
  /// on them, not free access, and the copy must not imply otherwise.
  final int reportDiscountPercent;

  /// Whether this tier unlocks premium articles (Gold and above).
  final bool hasPremiumArticles;

  /// Complete Life Report credits granted per month. `0` for every tier
  /// except Platinum, which gets 1/month.
  final int completeLifeReportCreditsPerMonth;
}
