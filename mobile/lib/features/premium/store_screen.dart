import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/app_motion.dart';
import '../../core/purchases/purchases_providers.dart';
import '../../core/purchases/purchases_service.dart';
import '../../core/purchases/report_catalogue.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../reports/daily_reading_repository.dart';
import '../reports/report_labels.dart';
import '../reports/reports_static_data.dart';
import 'purchase_error_messages.dart';
import 'subscription_paywall_screen.dart';

/// Every one-time purchase in one place.
///
/// BUILT 10 Sep 2026 on the client's request: *"instead top up i asked all one
/// time purchase should be one place"*.
///
/// ## The problem it fixes
///
/// The three consumable products were each reachable from somewhere
/// different, and nowhere showed them together:
///
///  - AI packs — Profile, and the Rishi AI quota message
///  - Individual reports — only inside each report, past the fade
///  - Daily Reading — a card at the top of the Reports tab
///
/// So a user could not answer "what can I buy?" without touching three
/// screens, and two of the three were only discoverable by hitting a limit
/// first. One tabbed screen makes the catalogue legible.
///
/// ## Subscriptions are deliberately NOT a tab
///
/// A subscription is a different commitment, has its own approved paywall
/// design, and needs upgrade/downgrade handling this screen does not do.
/// Folding it in would make one screen responsible for two payment models.
/// It is linked from the footer instead, which is also the honest place for
/// it: for a heavy reader the plan is the better deal, and the store should
/// say so.
class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key, this.initialTab = StoreTab.packs});

  final StoreTab initialTab;

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

enum StoreTab { packs, reports, dailyReading }

class _StoreScreenState extends ConsumerState<StoreScreen> {
  late StoreTab _tab = widget.initialTab;
  bool _isBusy = false;

  /// One purchase path for all three product kinds — they differ only in what
  /// package they pass. Keeping this in one place is what stops the three
  /// tabs drifting into three slightly different error behaviours.
  Future<void> _buy(Future<void> Function() purchase) async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await purchase();
      if (!mounted) return;
      // Never claims the item is unlocked: entitlement, credit and ownership
      // are all granted server-side by the RevenueCat webhook, and each has
      // its own live Firestore stream that updates this screen when it
      // lands. Asserting success here would be claiming what we have not
      // observed.
      messenger.showSnackBar(SnackBar(content: Text(l10n.aiPackPurchased)));
    } on PurchaseException catch (e) {
      if (!mounted) return;
      if (e.reason == PurchaseFailure.cancelled) return;
      messenger.showSnackBar(
        SnackBar(content: Text(purchaseFailureMessage(l10n, e.reason))),
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
              child: _Header(
                title: l10n.storeTitle,
                subtitle: l10n.storeSubtitle,
                locale: locale,
              ),
            ),
            const SizedBox(height: 14),
            _Tabs(
              current: _tab,
              locale: locale,
              l10n: l10n,
              onChanged: (tab) => setState(() => _tab = tab),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: switch (_tab) {
                StoreTab.packs => _PacksTab(
                  isBusy: _isBusy,
                  onBuy: _buy,
                  l10n: l10n,
                  locale: locale,
                ),
                StoreTab.reports => _ReportsTab(
                  isBusy: _isBusy,
                  onBuy: _buy,
                  l10n: l10n,
                  locale: locale,
                ),
                StoreTab.dailyReading => _DailyTab(
                  isBusy: _isBusy,
                  onBuy: _buy,
                  l10n: l10n,
                  locale: locale,
                ),
              },
            ),
            _SubscribeFooter(l10n: l10n, locale: locale),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tabs
// ---------------------------------------------------------------------------

class _PacksTab extends ConsumerWidget {
  const _PacksTab({
    required this.isBusy,
    required this.onBuy,
    required this.l10n,
    required this.locale,
  });

  final bool isBusy;
  final Future<void> Function(Future<void> Function()) onBuy;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogue = ref.watch(aiPackCatalogueProvider);
    final balance = ref.watch(aiPackBalanceProvider).valueOrNull ?? 0;

    return catalogue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => _Unavailable(l10n: l10n, locale: locale),
      data: (packs) {
        if (packs.isEmpty) return _Unavailable(l10n: l10n, locale: locale);
        final best = packs.bestValue;
        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
          children: [
            if (balance > 0)
              _BalanceBanner(
                text: l10n.aiPackBalance('$balance'),
                locale: locale,
              ),
            for (final pack in packs.packs)
              _StoreRow(
                title: l10n.aiPackQuestions('${pack.questions}'),
                subtitle: l10n.aiPackValidity('${pack.validityDays}'),
                price: pack.priceString,
                badge: identical(pack, best) ? l10n.aiPackBestValue : null,
                enabled: !isBusy,
                locale: locale,
                onTap: () => onBuy(
                  () => ref.read(purchasesServiceProvider).purchaseAiPack(pack),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ReportsTab extends ConsumerWidget {
  const _ReportsTab({
    required this.isBusy,
    required this.onBuy,
    required this.l10n,
    required this.locale,
  });

  final bool isBusy;
  final Future<void> Function(Future<void> Function()) onBuy;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offers = ref.watch(reportCatalogueProvider).valueOrNull ?? const {};
    final owned = ref.watch(ownedReportsProvider).valueOrNull ?? const <String>{};

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
      children: [
        for (final report in ReportsStaticData.reports)
          Builder(
            builder: (context) {
              final offer = offers[report.id];
              final isFree = report.access == ReportAccess.free;
              // Three ways a report is already yours. Showing a price on
              // something the reader can already open is how a store loses
              // trust.
              // ⚠️ `subscribed` is deliberately NOT part of this (12 Sep
              // 2026). It used to be, so every report showed "Included" to
              // any subscriber and could not be bought — see the same change
              // in `report_detail_screen.dart` for the client instruction
              // behind it. Reports are a separate one-time purchase for
              // everyone; a subscription is meant to discount them, not
              // include them.
              final alreadyHave = isFree || owned.contains(report.id);

              return _StoreRow(
                emoji: report.emoji,
                title: reportTitle(report.id, l10n),
                subtitle: reportDescription(report.id, l10n),
                // ⚠️ Four states, not two. A premium report with NO Play SKU
                // (Sade Sati — Play sells 14 reports and it is not one of
                // them) previously rendered dimmed with no price and no
                // word, which reads as a loading failure rather than as
                // "buy the plan for this one". Say it plainly instead.
                price: alreadyHave
                    ? (isFree ? l10n.storeIncluded : l10n.storeOwned)
                    : (offer?.priceString ?? l10n.storeSubscriptionOnly),
                enabled: !isBusy && !alreadyHave && offer != null,
                dimmed: alreadyHave,
                locale: locale,
                onTap: offer == null
                    ? null
                    : () => onBuy(
                        () => ref
                            .read(purchasesServiceProvider)
                            .purchaseConsumable(offer.package),
                      ),
              );
            },
          ),
      ],
    );
  }
}

class _DailyTab extends ConsumerWidget {
  const _DailyTab({
    required this.isBusy,
    required this.onBuy,
    required this.l10n,
    required this.locale,
  });

  final bool isBusy;
  final Future<void> Function(Future<void> Function()) onBuy;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final package = ref.watch(dailyReadingPackageProvider).valueOrNull;
    final unlocked = ref.watch(dailyReadingAccessProvider).valueOrNull ?? false;

    if (package == null && !unlocked) {
      return _Unavailable(l10n: l10n, locale: locale);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
      children: [
        _StoreRow(
          emoji: '🌅',
          title: l10n.dailyReadingTitle,
          subtitle: l10n.dailyReadingDesc,
          price: unlocked ? l10n.storeOwned : package?.storeProduct.priceString,
          enabled: !isBusy && !unlocked && package != null,
          dimmed: unlocked,
          locale: locale,
          onTap: package == null
              ? null
              : () => onBuy(
                  () => ref
                      .read(purchasesServiceProvider)
                      .purchaseConsumable(package),
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Pieces
// ---------------------------------------------------------------------------

class _Tabs extends StatelessWidget {
  const _Tabs({
    required this.current,
    required this.onChanged,
    required this.l10n,
    required this.locale,
  });

  final StoreTab current;
  final ValueChanged<StoreTab> onChanged;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final labels = {
      StoreTab.packs: l10n.storeTabPacks,
      StoreTab.reports: l10n.storeTabReports,
      StoreTab.dailyReading: l10n.storeTabDaily,
    };
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          for (final tab in StoreTab.values) ...[
            if (tab != StoreTab.values.first) const SizedBox(width: 8),
            Semantics(
              button: true,
              selected: current == tab,
              child: PressableScale(
                borderRadius: BorderRadius.circular(999),
                onTap: () => onChanged(tab),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: current == tab
                        ? AppColors.saffron
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: current == tab
                          ? AppColors.saffron
                          : AppColors.cardBorder,
                    ),
                  ),
                  child: Text(
                    labels[tab]!,
                    style: AppFonts.body(
                      locale,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: current == tab ? Colors.white : AppColors.muted,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StoreRow extends StatelessWidget {
  const _StoreRow({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.enabled,
    required this.locale,
    required this.onTap,
    this.emoji,
    this.badge,
    this.dimmed = false,
  });

  final String title;
  final String subtitle;

  /// Play's own localized price, or a state word ("Owned"). Null when the
  /// store has not answered — the row then shows nothing rather than a
  /// guessed figure.
  final String? price;
  final bool enabled;
  final bool dimmed;
  final Locale locale;
  final VoidCallback? onTap;
  final String? emoji;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dimmed ? 0.62 : (enabled ? 1 : 0.5),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Semantics(
          button: enabled,
          child: PressableScale(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              if (enabled && onTap != null) onTap!();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: badge != null
                    ? AppColors.mantraBg
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: badge != null
                      ? AppColors.gold
                      : AppColors.cardBorder,
                ),
              ),
              child: Row(
                children: [
                  if (emoji != null) ...[
                    Text(emoji!, style: AppFonts.body(locale, fontSize: 19)),
                    const SizedBox(width: 11),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                title,
                                style: AppFonts.body(
                                  locale,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                            if (badge != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  badge!,
                                  style: AppFonts.body(
                                    locale,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.tileGoldFg,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.body(
                            locale,
                            fontSize: 11.5,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (price != null)
                    Text(
                      price!,
                      style: AppFonts.body(
                        locale,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: dimmed ? AppColors.muted : AppColors.saffron,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BalanceBanner extends StatelessWidget {
  const _BalanceBanner({required this.text, required this.locale});

  final String text;
  final Locale locale;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    decoration: BoxDecoration(
      color: AppColors.geoChipBg,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      text,
      style: AppFonts.body(
        locale,
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: AppColors.tileGreenFg,
      ),
    ),
  );
}

class _Unavailable extends StatelessWidget {
  const _Unavailable({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Text(
        l10n.storeUnavailable,
        textAlign: TextAlign.center,
        style: AppFonts.body(locale, fontSize: 13, color: AppColors.muted),
      ),
    ),
  );
}

class _SubscribeFooter extends StatelessWidget {
  const _SubscribeFooter({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
    child: Semantics(
      button: true,
      child: PressableScale(
        borderRadius: BorderRadius.circular(999),
        onTap: () => Navigator.of(
          context,
        ).push(fadeThroughRoute(const SubscriptionPaywallScreen())),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Text(
            l10n.storeSubscribeHint,
            style: AppFonts.body(
              locale,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.saffron,
            ),
          ),
        ),
      ),
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.subtitle,
    required this.locale,
  });

  final String title;
  final String subtitle;
  final Locale locale;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Semantics(
        button: true,
        child: PressableScale(
          borderRadius: BorderRadius.circular(999),
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Icon(Icons.arrow_back, size: 18, color: AppColors.ink),
          ),
        ),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: AppFonts.heading(
                locale,
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            Text(
              subtitle,
              style: AppFonts.body(
                locale,
                fontSize: 11.5,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
