import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// The buyable AI question packs, resolved from RevenueCat's `ai_packs`
/// offering.
///
/// BUILT 9 Sep 2026. The six Play products and their RevenueCat packages had
/// existed since 16 Aug, but `PurchasesService.fetchCatalogue` read only
/// `offerings.current` — which is the `default` (subscription) offering — so
/// `ai_packs` was never fetched and the products were unreachable from the
/// app. Same is still true of `reports` and `daily_reading`; those are
/// separate unbuilt features.
@immutable
class AiPack {
  const AiPack({
    required this.package,
    required this.questions,
    required this.validityDays,
  });

  final Package package;

  /// How many AI questions this pack grants. Mirrors `AI_PACKS` in
  /// `functions/src/aiPacks.ts` — the SERVER is authoritative; this copy
  /// exists only so the card can say "10 questions" before purchase.
  final int questions;

  /// Days the credit stays spendable, counted from the purchase.
  final int validityDays;

  String get productId => package.storeProduct.identifier;

  /// Play's own localized price string. **Never format a price ourselves** —
  /// Play sets it per region and the client can change it without an app
  /// release.
  String get priceString => package.storeProduct.priceString;

  /// Price per question, for the "best value" comparison. Uses the numeric
  /// price, which RevenueCat gives in the store's own currency, so the
  /// comparison is always within one currency and never cross-rate.
  double get pricePerQuestion =>
      questions == 0 ? double.infinity : package.storeProduct.price / questions;
}

/// The pack list, ordered smallest first.
@immutable
class AiPackCatalogue {
  const AiPackCatalogue(this.packs);
  const AiPackCatalogue.empty() : packs = const [];

  final List<AiPack> packs;

  bool get isEmpty => packs.isEmpty;

  /// The pack with the lowest price-per-question — the honest "best value"
  /// badge, computed from LIVE prices rather than hardcoded to the biggest
  /// pack. If the client ever reprices, the badge follows automatically.
  AiPack? get bestValue {
    if (packs.isEmpty) return null;
    return packs.reduce(
      (a, b) => a.pricePerQuestion <= b.pricePerQuestion ? a : b,
    );
  }

  /// Quantity + validity per SKU.
  ///
  /// ⚠️ A local table, because **the store carries neither number**. Play
  /// knows the price and the title; how many questions a pack is worth and
  /// how long it lasts are our business rules, and the server enforces them
  /// (`functions/src/aiPacks.ts`). This copy is presentational only — a
  /// mismatch here would misdescribe the product, but could never grant
  /// credit, because the client never grants anything.
  ///
  /// Source: `claudedocs/play-console-iap-setup.md`, the sheet the Play
  /// products were created from.
  static const Map<String, ({int questions, int validityDays})> specs = {
    'vedadarshi_ai_pack_3': (questions: 3, validityDays: 7),
    'vedadarshi_ai_pack_5': (questions: 5, validityDays: 15),
    'vedadarshi_ai_pack_10': (questions: 10, validityDays: 30),
    'vedadarshi_ai_pack_30': (questions: 30, validityDays: 30),
    'vedadarshi_ai_pack_100': (questions: 100, validityDays: 60),
    'vedadarshi_ai_pack_300': (questions: 300, validityDays: 90),
  };

  /// Builds the catalogue from the `ai_packs` offering.
  ///
  /// A package whose product id is not in [specs] is DROPPED rather than
  /// shown with a guessed quantity: selling "some questions" for a real
  /// price is worse than not offering the pack until the table is updated.
  factory AiPackCatalogue.fromOffering(Offering? offering) {
    if (offering == null) return const AiPackCatalogue.empty();

    final packs = <AiPack>[];
    for (final package in offering.availablePackages) {
      final spec = specs[package.storeProduct.identifier];
      if (spec == null) continue;
      packs.add(
        AiPack(
          package: package,
          questions: spec.questions,
          validityDays: spec.validityDays,
        ),
      );
    }
    packs.sort((a, b) => a.questions.compareTo(b.questions));
    return AiPackCatalogue(packs);
  }
}
