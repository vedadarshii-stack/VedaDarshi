import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../l10n/app_localizations.dart';
import 'panchang_data.dart';
import 'panchang_location.dart';
import 'panchang_repository.dart';
import 'panchang_static_data.dart';

/// Full choghadiya timetable for today — day and night — plus Rahu Kaal.
///
/// BUILT 21 Aug 2026. The Panchang screen has had a "View all muhurat
/// timings ›" link since it was first built, styled exactly like a working
/// link and doing nothing. This is the screen behind it.
///
/// It needed no new network call: `/v2/daily/muhurta` already returns the
/// complete `choghadiya` day/night schedule, and `MuhurtaData` already
/// parsed it — the model's own doc comment said it was modelled "enough for
/// a future 'view all muhurat timings' screen — see that still-inert link".
/// Only Rahu Kaal was ever rendered from that response; the other ~16
/// windows were fetched, parsed, and thrown away on every load.
///
/// Uses the same `muhurtaDataProvider` and the same location as the Panchang
/// tab, so both screens describe one day in one place and cannot disagree.
class MuhuratTimingsScreen extends ConsumerWidget {
  const MuhuratTimingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final location = ref.watch(panchangLocationProvider);
    final muhurtaAsync = ref.watch(
      muhurtaDataProvider((
        lat: location.city.latitude,
        lon: location.city.longitude,
        tz: location.city.timezoneId,
      )),
    );

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: Text(
          l10n.viewAllMuhurat,
          style: AppFonts.heading(
            locale,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ),
      body: muhurtaAsync.when(
        loading: () => const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Text(
              l10n.panchangLoadErrorMessage,
              textAlign: TextAlign.center,
              style: AppFonts.body(
                locale,
                fontSize: 13,
                color: AppColors.muted,
              ),
            ),
          ),
        ),
        data: (muhurta) =>
            _Body(muhurta: muhurta, l10n: l10n, locale: locale, city: location.city.name),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.muhurta,
    required this.l10n,
    required this.locale,
    required this.city,
  });

  final MuhurtaData muhurta;
  final AppLocalizations l10n;
  final Locale locale;
  final String city;

  @override
  Widget build(BuildContext context) {
    final day = muhurta.choghadiya?.day ?? const <ChoghadiyaPeriod>[];
    final night = muhurta.choghadiya?.night ?? const <ChoghadiyaPeriod>[];
    final rahu = muhurta.rahuKaal?.formattedRange;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        Text(
          city,
          style: AppFonts.body(locale, fontSize: 12, color: AppColors.hint),
        ),
        const SizedBox(height: 14),
        if (rahu != null) ...[
          _RahuCard(range: rahu, l10n: l10n, locale: locale),
          const SizedBox(height: 18),
        ],
        // Sections are omitted entirely when empty rather than shown as an
        // empty heading — Vedika occasionally returns only one half.
        if (day.isNotEmpty) ...[
          _SectionLabel(l10n.muhuratDay, locale: locale),
          const SizedBox(height: 8),
          for (final period in day)
            _PeriodTile(period: period, locale: locale, l10n: l10n),
          const SizedBox(height: 18),
        ],
        if (night.isNotEmpty) ...[
          _SectionLabel(l10n.muhuratNight, locale: locale),
          const SizedBox(height: 8),
          for (final period in night)
            _PeriodTile(period: period, locale: locale, l10n: l10n),
        ],
        if (day.isEmpty && night.isEmpty && rahu == null)
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Text(
              l10n.muhuratUnavailable,
              textAlign: TextAlign.center,
              style: AppFonts.body(
                locale,
                fontSize: 13,
                color: AppColors.muted,
              ),
            ),
          ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {required this.locale});

  final String text;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppFonts.body(
        locale,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.hint,
      ).copyWith(letterSpacing: 0.8),
    );
  }
}

class _RahuCard extends StatelessWidget {
  const _RahuCard({
    required this.range,
    required this.l10n,
    required this.locale,
  });

  final String range;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.ashubhBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.ashubhFg.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.ashubhFg),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // Same label the Panchang tab's Rahu Kaal card uses, so
                  // the two screens name it identically.
                  PanchangStaticData.muhurats[1].name,
                  style: AppFonts.body(
                    locale,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  range,
                  style: AppFonts.body(
                    locale,
                    fontSize: 12.5,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One choghadiya window.
///
/// The quality dot is driven by [ChoghadiyaPeriod.quality], which is
/// normalised from Vedika's own `vpiType` — never inferred from the window's
/// name. A window whose quality Vedika omitted gets a neutral grey dot and
/// no claim, rather than being guessed into a colour.
class _PeriodTile extends StatelessWidget {
  const _PeriodTile({
    required this.period,
    required this.locale,
    required this.l10n,
  });

  final ChoghadiyaPeriod period;
  final Locale locale;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final range = period.formattedRange;
    final color = switch (period.quality) {
      ChoghadiyaQuality.good => AppColors.tileGreenFg,
      ChoghadiyaQuality.bad => AppColors.ashubhFg,
      ChoghadiyaQuality.neutral => AppColors.gold,
      ChoghadiyaQuality.unknown => AppColors.hint,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        period.name ?? '—',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.body(
                          locale,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    if (range != null)
                      Text(
                        range,
                        style: AppFonts.body(
                          locale,
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                  ],
                ),
                if (period.bestFor != null && period.bestFor!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    period.bestFor!,
                    style: AppFonts.body(
                      locale,
                      fontSize: 11.5,
                      color: AppColors.hint,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
