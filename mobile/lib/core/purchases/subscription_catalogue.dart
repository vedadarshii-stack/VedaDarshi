import 'package:intl/intl.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'subscription_tier.dart';

/// The two billing periods every tier is sold on.
///
/// These map to Play **base plans** (`monthly` / `annual`) under one Play
/// subscription product per tier, which is why a tier and a period together
/// identify exactly one purchasable thing.
enum BillingPeriod {
  monthly(['monthly', 'month', 'p1m']),
  annual(['annual', 'yearly', 'year', 'p1y']);

  const BillingPeriod(this.tokens);

  /// Lowercase substrings that identify this period inside a RevenueCat
  /// package identifier or a Play store-product identifier.
  final List<String> tokens;
}

/// One purchasable tier+period, resolved from a live RevenueCat [Package].
///
/// Everything price-shaped on this class is read straight off the store
/// product. **No price is ever hardcoded, derived from a table, or read from
/// our own backend** — Google Play localises prices per country and Play
/// Console pricing can change without an app update, so any stored copy goes
/// stale or shows the wrong currency to anyone outside India.
class SubscriptionPlan {
  const SubscriptionPlan({
    required this.tier,
    required this.period,
    required this.package,
  });

  final SubscriptionTier tier;
  final BillingPeriod period;
  final Package package;

  StoreProduct get _product => package.storeProduct;

  /// Already localised and currency-symbolled by the store, e.g. "₹219".
  /// This is the string to render — never format [rawPrice] yourself.
  String get priceString => _product.priceString;

  /// Numeric price, for computing the per-month equivalent and the annual
  /// saving. Not for display.
  double get rawPrice => _product.price;

  String get currencyCode => _product.currencyCode;
}

/// The paywall's view of a RevenueCat `Offering`.
///
/// Built by [fromOffering], which is deliberately tolerant: it resolves each
/// package's tier and period by looking for known tokens in BOTH the package
/// identifier (`$rc_custom_bronze_annual`) and the Play store product
/// identifier (`vedadarshi_bronze:annual`). Matching on only one of the two
/// would couple the app to a naming choice that lives in a dashboard someone
/// else can edit; a package that matches neither is skipped rather than
/// crashing the paywall.
class SubscriptionCatalogue {
  const SubscriptionCatalogue(this.options);

  const SubscriptionCatalogue.empty() : options = const [];

  final List<SubscriptionPlan> options;

  bool get isEmpty => options.isEmpty;

  /// Periods that have at least one purchasable tier, cheapest-period first.
  /// Drives which toggle segments the paywall shows — if Play only has the
  /// monthly base plans set up, no Annual segment appears.
  List<BillingPeriod> get availablePeriods => [
    for (final period in BillingPeriod.values)
      if (options.any((option) => option.period == period)) period,
  ];

  SubscriptionPlan? optionFor(SubscriptionTier tier, BillingPeriod period) {
    for (final option in options) {
      if (option.tier == tier && option.period == period) return option;
    }
    return null;
  }

  /// Tiers purchasable on [period], cheapest tier first.
  List<SubscriptionPlan> optionsForPeriod(BillingPeriod period) => [
    for (final tier in SubscriptionTier.paid) ?optionFor(tier, period),
  ];

  /// The annual plan's price divided by 12, formatted in the store's own
  /// currency — the "₹183/month · billed yearly" line.
  ///
  /// Returns `null` for monthly options (where it would be noise) and when
  /// the price is non-positive.
  String? monthlyEquivalent(SubscriptionPlan option, String localeName) {
    if (option.period != BillingPeriod.annual) return null;
    if (option.rawPrice <= 0) return null;
    final format = NumberFormat.simpleCurrency(
      locale: localeName,
      name: option.currencyCode,
      decimalDigits: 0,
    );
    return format.format(option.rawPrice / 12);
  }

  /// How much cheaper a tier's annual plan is than paying monthly for a year,
  /// as a whole percentage.
  ///
  /// Returns `null` unless BOTH plans for that tier are actually present and
  /// the annual one really is cheaper — a "SAVE 0%" or negative badge would
  /// be worse than no badge. This is computed from live prices on purpose:
  /// a hardcoded "SAVE 44%" silently becomes a lie the first time Play
  /// pricing changes.
  int? annualSavingsPercent(SubscriptionTier tier) {
    final monthly = optionFor(tier, BillingPeriod.monthly);
    final annual = optionFor(tier, BillingPeriod.annual);
    if (monthly == null || annual == null) return null;
    final yearAtMonthlyRate = monthly.rawPrice * 12;
    if (yearAtMonthlyRate <= 0 || annual.rawPrice <= 0) return null;
    final saving = (1 - annual.rawPrice / yearAtMonthlyRate) * 100;
    if (saving < 1) return null;
    return saving.round();
  }

  static SubscriptionCatalogue fromOffering(Offering? offering) {
    if (offering == null) return const SubscriptionCatalogue.empty();

    final resolved = <SubscriptionPlan>[];
    for (final package in offering.availablePackages) {
      // Both identifiers are searched because either one alone is a naming
      // convention we do not fully own — see the class doc.
      final haystack =
          '${package.identifier} ${package.storeProduct.identifier}'
              .toLowerCase();

      final tier = SubscriptionTier.paid
          .where((tier) => haystack.contains(tier.name))
          .firstOrNull;
      if (tier == null) continue;

      final period = BillingPeriod.values
          .where((period) => period.tokens.any(haystack.contains))
          .firstOrNull;
      if (period == null) continue;

      // First match wins, so a duplicate package for the same tier+period
      // cannot produce two cards for the same purchase.
      if (resolved.any((o) => o.tier == tier && o.period == period)) continue;

      resolved.add(
        SubscriptionPlan(tier: tier, period: period, package: package),
      );
    }

    // Sorted so the paywall renders cheapest tier first regardless of the
    // package order someone happens to set in the RevenueCat dashboard.
    resolved.sort((a, b) => a.tier.rank.compareTo(b.tier.rank));
    return SubscriptionCatalogue(resolved);
  }
}
