import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../auth/auth_providers.dart';
import 'purchases_providers.dart';

/// Individually purchasable reports, from RevenueCat's `reports` offering.
///
/// BUILT 10 Sep 2026. Fourteen `vedadarshi_report_*` products had existed in
/// Play since 16 Aug with no way to buy one — the app read only
/// `offerings.current` (subscriptions) and, from 9 Sep, `ai_packs`. This is
/// the third of the four offerings to be wired; nothing now reads
/// `daily_reading`'s sibling by accident.
@immutable
class PurchasableReport {
  const PurchasableReport({required this.reportId, required this.package});

  /// Matches `ReportsStaticData.reports[].id`.
  final String reportId;
  final Package package;

  String get priceString => package.storeProduct.priceString;
}

/// ⚠️ **Only reports the app can actually deliver appear here**, and this map
/// MUST stay identical to `REPORT_SKUS` in `functions/src/reportPurchases.ts`
/// — the server grants against its copy, so a SKU present here but absent
/// there would take money and grant nothing.
///
/// Three Play products are deliberately excluded, verified against Vedika's
/// 694-path contract on 9 Sep 2026:
///
///  - `vedadarshi_report_education` — no education endpoint exists at all.
///  - `vedadarshi_report_foreign_travel` — only sun-sign data, so every Aries
///    would receive identical text while every other report is chart-based.
///  - `vedadarshi_report_finance` — the same `wealth-timing` endpoint already
///    sold as Wealth Report.
///
/// **They should be archived in Play.** Until they are, Play will still sell
/// them; the server grants nothing, which is the safe failure but still a
/// refund waiting to happen.
const Map<String, String> reportSkus = {
  'vedadarshi_report_complete_life': 'complete',
  'vedadarshi_report_career': 'career',
  'vedadarshi_report_marriage': 'marriage',
  'vedadarshi_report_wealth': 'wealth',
  'vedadarshi_report_health': 'health',
  'vedadarshi_report_gemstone': 'gemstone',
  'vedadarshi_report_remedies': 'remedies',
  'vedadarshi_report_rudraksha': 'rudraksha',
  'vedadarshi_report_property': 'property',
  'vedadarshi_report_child_family': 'childFamily',
  'vedadarshi_report_business': 'business',
};

/// The buyable reports, keyed by app report id.
final reportCatalogueProvider =
    FutureProvider<Map<String, PurchasableReport>>((ref) async {
      ref.watch(subscriptionStatusProvider);
      final service = ref.watch(purchasesServiceProvider);
      final packages = await service.fetchReportPackages();

      final byId = <String, PurchasableReport>{};
      for (final package in packages) {
        final reportId = reportSkus[package.storeProduct.identifier];
        // A package whose SKU is not in the map is DROPPED, not guessed at —
        // that is how the three undeliverable products stay unbuyable in the
        // app even while they exist in Play.
        if (reportId == null) continue;
        byId[reportId] = PurchasableReport(
          reportId: reportId,
          package: package,
        );
      }
      return byId;
    });

/// Report ids this user owns outright.
///
/// ⚠️ Read from **Firestore**, written only by the RevenueCat webhook
/// (`/users/{uid}/reportPurchases`, `allow write: if false`). The store
/// confirms the purchase; ownership is our own ledger, so asking RevenueCat
/// would be asking the wrong system — and asking the CLIENT would be asking
/// the one party with a reason to lie.
///
/// Ownership is permanent, so unlike packs and daily readings there is no
/// expiry to filter on.
final ownedReportsProvider = StreamProvider<Set<String>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value(const <String>{});

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('reportPurchases')
      .snapshots()
      .map(
        (snap) => snap.docs
            .map((d) => d.data()['reportId'] as String?)
            .whereType<String>()
            .toSet(),
      )
      .handleError((_) => const <String>{});
});
