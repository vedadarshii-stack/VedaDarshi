import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/astrology/astro_terms.dart';
import '../../core/motion/app_motion.dart';
import '../../core/purchases/purchases_providers.dart';
import '../../core/purchases/purchases_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../kundli/kundli_repository.dart';
import '../premium/purchase_error_messages.dart';
import '../profile/birth_profile_repository.dart';
import 'daily_reading_data.dart';
import 'daily_reading_repository.dart';

/// Personalized Daily Reading — a 24-hour one-time purchase.
///
/// BUILT 9 Sep 2026. The Play product and the RevenueCat `daily_reading`
/// offering had existed since 16 Aug with nothing able to sell or show them.
///
/// ## Locked vs unlocked
///
/// Access comes from [dailyReadingAccessProvider], which reads the
/// server-written `/users/{uid}/dailyReadings` ledger — the user cannot forge
/// it. Until it says yes, the screen shows what the reading IS and a buy
/// button, and **makes no Vedika call at all**: fetching a reading nobody has
/// paid for would spend the client's wallet on content that is never shown.
class DailyReadingScreen extends ConsumerStatefulWidget {
  const DailyReadingScreen({super.key});

  @override
  ConsumerState<DailyReadingScreen> createState() => _DailyReadingScreenState();
}

class _DailyReadingScreenState extends ConsumerState<DailyReadingScreen> {
  bool _isBusy = false;

  Future<void> _buy() async {
    if (_isBusy) return;
    final package = ref.read(dailyReadingPackageProvider).valueOrNull;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    if (package == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.dailyReadingUnavailable)),
      );
      return;
    }

    setState(() => _isBusy = true);
    try {
      await ref.read(purchasesServiceProvider).purchaseConsumable(package);
      if (!mounted) return;
      // No success claim beyond the store's own: the 24-hour window is
      // granted by the webhook, and `dailyReadingAccessProvider` is a live
      // Firestore stream that unlocks this screen when it lands.
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
    final hasAccess = ref.watch(dailyReadingAccessProvider).valueOrNull ?? false;
    final profile = ref.watch(birthProfileProvider).value;
    final birth = profile == null
        ? null
        : KundliRequest.fromBirthProfile(profile);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
          children: [
            _Header(title: l10n.dailyReadingTitle, locale: locale),
            const SizedBox(height: 18),
            if (!hasAccess)
              _LockedCard(
                l10n: l10n,
                locale: locale,
                isBusy: _isBusy,
                priceString: ref
                    .watch(dailyReadingPackageProvider)
                    .valueOrNull
                    ?.storeProduct
                    .priceString,
                onBuy: _buy,
              )
            else if (birth == null)
              _Message(l10n.reportEmptyMessage, locale: locale)
            else
              ref
                  .watch(dailyReadingProvider(birth))
                  .when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (_, _) =>
                        _Message(l10n.kundliLoadErrorMessage, locale: locale),
                    data: (reading) => reading.isEmpty
                        ? _Message(l10n.reportEmptyMessage, locale: locale)
                        : _ReadingBody(
                            reading: reading,
                            l10n: l10n,
                            locale: locale,
                          ),
                  ),
          ],
        ),
      ),
    );
  }
}

/// Shown before purchase. Describes the product honestly and does not
/// pretend to preview content that has not been fetched.
class _LockedCard extends StatelessWidget {
  const _LockedCard({
    required this.l10n,
    required this.locale,
    required this.isBusy,
    required this.priceString,
    required this.onBuy,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final bool isBusy;
  final String? priceString;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🌅', style: AppFonts.body(locale, fontSize: 30)),
          const SizedBox(height: 10),
          Text(
            l10n.dailyReadingDesc,
            style: AppFonts.heading(
              locale,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.dailyReadingLocked,
            style: AppFonts.body(locale, fontSize: 13, color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          Semantics(
            button: true,
            child: PressableScale(
              borderRadius: BorderRadius.circular(999),
              onTap: isBusy ? () {} : onBuy,
              child: Opacity(
                opacity: isBusy ? 0.6 : 1,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: AppColors.saffronGradient,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: isBusy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          // Play's own price when known; never formatted by us.
                          priceString == null
                              ? l10n.dailyReadingBuy
                              : '${l10n.dailyReadingBuy} · $priceString',
                          style: AppFonts.body(
                            locale,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadingBody extends StatelessWidget {
  const _ReadingBody({
    required this.reading,
    required this.l10n,
    required this.locale,
  });

  final DailyReading reading;
  final AppLocalizations l10n;
  final Locale locale;

  String _areaLabel(String area) => switch (area) {
    'career' => l10n.dailyReadingAreaCareer,
    'finance' => l10n.dailyReadingAreaFinance,
    'health' => l10n.dailyReadingAreaHealth,
    'relationship' => l10n.dailyReadingAreaRelationship,
    _ => area,
  };

  @override
  Widget build(BuildContext context) {
    final lucky = reading.lucky;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (reading.summary case final summary?) ...[
          _Card(
            child: Text(
              summary,
              style: AppFonts.body(
                locale,
                fontSize: 13.5,
                height: 1.5,
                color: AppColors.ink,
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
        for (final (i, area) in reading.areas.indexed) ...[
          EntranceFadeSlide(
            index: i,
            child: _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _areaLabel(area.area),
                          style: AppFonts.body(
                            locale,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.saffron,
                          ),
                        ),
                      ),
                      if (area.score case final score?)
                        Text(
                          '$score',
                          style: AppFonts.heading(
                            locale,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                    ],
                  ),
                  if (area.text case final text?) ...[
                    const SizedBox(height: 5),
                    Text(
                      text,
                      style: AppFonts.body(
                        locale,
                        fontSize: 13,
                        height: 1.5,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                  if (area.tip case final tip?) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        tip,
                        style: AppFonts.body(
                          locale,
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (!lucky.isEmpty) ...[
          const SizedBox(height: 4),
          _SectionTitle(l10n.dailyReadingLucky, locale: locale),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Colour and direction go through the local term table — Vedika
              // returns them in English, and they are a closed vocabulary.
              if (lucky.colour case final c?)
                _Chip(
                  localizeAstroTerm(c, AstroTermKind.colour, locale) ?? c,
                  locale: locale,
                ),
              if (lucky.direction case final d?)
                _Chip(
                  localizeAstroTerm(d, AstroTermKind.direction, locale) ?? d,
                  locale: locale,
                ),
              if (lucky.day case final d?)
                _Chip(
                  localizeAstroTerm(d, AstroTermKind.vara, locale) ?? d,
                  locale: locale,
                ),
              if (lucky.number case final n?) _Chip('$n', locale: locale),
              // Time is free prose ("Late Morning (9-12 PM)") — no table can
              // translate it, so it stays as Vedika sent it.
              if (lucky.time case final t?) _Chip(t, locale: locale),
            ],
          ),
        ],
        if (reading.remedies.isNotEmpty) ...[
          const SizedBox(height: 18),
          _SectionTitle(l10n.dailyReadingRemedies, locale: locale),
          const SizedBox(height: 8),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final remedy in reading.remedies)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '• $remedy',
                      style: AppFonts.body(
                        locale,
                        fontSize: 12.5,
                        height: 1.45,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surface,
      border: Border.all(color: AppColors.cardBorder),
      borderRadius: BorderRadius.circular(16),
    ),
    child: child,
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {required this.locale});
  final String text;
  final Locale locale;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppFonts.heading(
      locale,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
    ),
  );
}

class _Chip extends StatelessWidget {
  const _Chip(this.text, {required this.locale});
  final String text;
  final Locale locale;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.mantraBg,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      text,
      style: AppFonts.body(
        locale,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.tileGoldFg,
      ),
    ),
  );
}

class _Message extends StatelessWidget {
  const _Message(this.text, {required this.locale});
  final String text;
  final Locale locale;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 34),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: AppFonts.body(locale, fontSize: 13, color: AppColors.muted),
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.locale});
  final String title;
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
        child: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppFonts.heading(
            locale,
            fontSize: 21,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ),
    ],
  );
}
