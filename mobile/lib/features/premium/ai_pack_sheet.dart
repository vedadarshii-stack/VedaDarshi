import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/app_motion.dart';
import '../../core/purchases/ai_pack_catalogue.dart';
import '../../core/purchases/purchases_providers.dart';
import '../../core/purchases/purchases_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../l10n/app_localizations.dart';
import 'purchase_error_messages.dart';
import 'subscription_paywall_screen.dart';

/// Buy AI question packs.
///
/// BUILT 9 Sep 2026 — the six pack products existed in Play and RevenueCat
/// since 16 Aug with **no way to buy one**, because the app only ever read
/// the `default` offering.
///
/// ## Why a sheet, and why here
///
/// The moment worth selling into is the one where the user has just run out
/// of questions. Until now that moment pushed the full SUBSCRIPTION paywall,
/// which answers a question they did not ask: someone who wants one more
/// answer is not shopping for a monthly plan. The sheet puts the small
/// purchase first and keeps the subscription reachable underneath.
Future<void> showAiPackSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _AiPackSheet(),
  );
}

class _AiPackSheet extends ConsumerStatefulWidget {
  const _AiPackSheet();

  @override
  ConsumerState<_AiPackSheet> createState() => _AiPackSheetState();
}

class _AiPackSheetState extends ConsumerState<_AiPackSheet> {
  bool _isBusy = false;

  Future<void> _buy(AiPack pack) async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(purchasesServiceProvider).purchaseAiPack(pack);
      if (!mounted) return;
      // Deliberately does NOT claim the credit has landed. The questions are
      // granted by the RevenueCat webhook server-side, which takes a moment;
      // `aiPackBalanceProvider` is a Firestore stream and updates the counter
      // on its own when it does. Saying "10 questions added" here would be
      // asserting something we have not observed.
      messenger.showSnackBar(SnackBar(content: Text(l10n.aiPackPurchased)));
      Navigator.of(context).pop();
    } on PurchaseException catch (e) {
      if (!mounted) return;
      if (e.reason == PurchaseFailure.cancelled) return;
      messenger.showSnackBar(
        SnackBar(content: Text(purchaseFailureMessage(l10n, e.reason))),
      );
      // A deferred payment (UPI / net-banking / cash) is committed, not
      // failed — close, same as the paywall does.
      if (e.reason == PurchaseFailure.pending) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final packsAsync = ref.watch(aiPackCatalogueProvider);
    final balance = ref.watch(aiPackBalanceProvider).valueOrNull ?? 0;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Text(
              l10n.aiPacksTitle,
              style: AppFonts.heading(
                locale,
                fontSize: 19,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              // Once they hold credit, the balance is more useful than the
              // sales line.
              balance > 0
                  ? l10n.aiPackBalance('$balance')
                  : l10n.aiPacksSubtitle,
              style: AppFonts.body(locale, fontSize: 12.5, color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: packsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, _) => _Unavailable(l10n: l10n, locale: locale),
                data: (catalogue) {
                  if (catalogue.isEmpty) {
                    return _Unavailable(l10n: l10n, locale: locale);
                  }
                  final best = catalogue.bestValue;
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: catalogue.packs.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final pack = catalogue.packs[i];
                      return _PackRow(
                        pack: pack,
                        isBestValue: identical(pack, best),
                        enabled: !_isBusy,
                        l10n: l10n,
                        locale: locale,
                        onTap: () => _buy(pack),
                      );
                    },
                  );
                },
              ),
            ),
            // The subscription stays one tap away. A heavy user is better
            // served by a plan than by repeatedly buying packs, and hiding
            // that would be selling them the worse deal.
            const SizedBox(height: 12),
            Center(
              child: Semantics(
                button: true,
                child: PressableScale(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      fadeThroughRoute(const SubscriptionPaywallScreen()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Text(
                      l10n.goPremium,
                      style: AppFonts.body(
                        locale,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.saffron,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 26),
    child: Text(
      l10n.aiPacksUnavailable,
      textAlign: TextAlign.center,
      style: AppFonts.body(locale, fontSize: 13, color: AppColors.muted),
    ),
  );
}

class _PackRow extends StatelessWidget {
  const _PackRow({
    required this.pack,
    required this.isBestValue,
    required this.enabled,
    required this.l10n,
    required this.locale,
    required this.onTap,
  });

  final AiPack pack;
  final bool isBestValue;
  final bool enabled;
  final AppLocalizations l10n;
  final Locale locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Semantics(
        button: true,
        child: PressableScale(
          borderRadius: BorderRadius.circular(14),
          // PressableScale requires a non-null callback, so the
          // disabled state is enforced here rather than by passing
          // null — a second tap while a purchase is in flight must
          // not open a second Play sheet.
          onTap: () { if (enabled) onTap(); },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isBestValue ? AppColors.mantraBg : AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isBestValue ? AppColors.gold : AppColors.cardBorder,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              l10n.aiPackQuestions('${pack.questions}'),
                              style: AppFonts.body(
                                locale,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          if (isBestValue) ...[
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
                                l10n.aiPackBestValue,
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
                        l10n.aiPackValidity('${pack.validityDays}'),
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
                Text(
                  // Play's own localized price. NEVER formatted by us — the
                  // store owns the price and the currency.
                  pack.priceString,
                  style: AppFonts.body(
                    locale,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.saffron,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
