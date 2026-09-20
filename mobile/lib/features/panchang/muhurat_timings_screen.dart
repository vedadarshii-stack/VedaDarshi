import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/astrology/astro_terms.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../l10n/app_localizations.dart';
import 'panchang_data.dart';
import 'cms_muhurat_repository.dart';
import 'panchang_location.dart';
import 'panchang_repository.dart';

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
            _Body(
              muhurta: muhurta,
              l10n: l10n,
              locale: locale,
              city: location.city.name,
              cmsMuhurat:
                  ref.watch(cmsMuhuratProvider).valueOrNull ?? const {},
            ),
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
    required this.cmsMuhurat,
  });

  /// Authored muhurat descriptions by kind, threaded down from the
  /// ConsumerWidget above rather than read here — this widget and its two
  /// children must see the SAME map, or a rebuild could render one tile from
  /// the console and its neighbour from the bundled copy.
  final Map<String, String> cmsMuhurat;

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
          _RahuCard(
            range: rahu,
            l10n: l10n,
            locale: locale,
            description: cmsMuhurat[MuhuratKindIds.rahuKaal],
          ),
          const SizedBox(height: 18),
        ],
        // Sections are omitted entirely when empty rather than shown as an
        // empty heading — Vedika occasionally returns only one half.
        if (day.isNotEmpty) ...[
          _SectionLabel(l10n.muhuratDay, locale: locale),
          const SizedBox(height: 8),
          for (final period in day)
            _PeriodTile(
              period: period,
              locale: locale,
              l10n: l10n,
              cmsMuhurat: cmsMuhurat,
            ),
          const SizedBox(height: 18),
        ],
        if (night.isNotEmpty) ...[
          _SectionLabel(l10n.muhuratNight, locale: locale),
          const SizedBox(height: 8),
          for (final period in night)
            _PeriodTile(
              period: period,
              locale: locale,
              l10n: l10n,
              cmsMuhurat: cmsMuhurat,
            ),
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
    this.description,
  });

  /// The console's authored explanation, or null.
  ///
  /// Optional on purpose: this card shipped as name + time only, and there is
  /// no bundled description to fall back on. So the line appears ONLY when
  /// the client has written one — nothing is invented to fill the space.
  final String? description;

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
                  // the two screens name it identically — which is now the
                  // l10n key, not `PanchangStaticData.muhurats[1].name`.
                  // That constant is hardcoded ENGLISH and was the last
                  // English string left on this screen (4 Sep 2026).
                  l10n.muhuratRahuKaal,
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
                if (description case final text?) ...[
                  const SizedBox(height: 4),
                  Text(
                    text,
                    style: AppFonts.body(
                      locale,
                      fontSize: 11.5,
                      color: AppColors.ashubhFg,
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

/// One choghadiya window.
///
/// The quality dot is driven by [ChoghadiyaPeriod.quality], which is
/// normalised from Vedika's own `vpiType` — never inferred from the window's
/// name. A window whose quality Vedika omitted gets a neutral grey dot and
/// no claim, rather than being guessed into a colour.
/// What a choghadiya period is suited for, in the app's language.
///
/// TRANSLATED 4 Sep 2026, after a second client screenshot. I had recorded
/// this as "Vedika prose, English-only" and moved on — **that was wrong.**
/// Reading the actual rendered screen showed the same seven strings
/// repeating: `Labh` carries the identical description at 01:51 PM and again
/// at 06:28 PM, as does `Kaal`. It is not free prose at all, it is a CLOSED
/// SET of seven — one fixed line per period type — and therefore perfectly
/// translatable.
///
/// The lesson worth keeping: "the API returns prose" is a claim to CHECK, not
/// to assume. Repetition across a rendered list is the tell.
///
/// These are the standard classical meanings of the seven choghadiya, so
/// translating them reports the same thing in another language — it does not
/// author new astrology, which is the line this codebase holds elsewhere.
///
/// Returns null for an unrecognised period so the caller falls back to
/// Vedika's own English rather than showing nothing.
/// The console's `choghadiya*` document-id suffix for [period], or null when
/// Vedika sent a name outside the classical seven.
///
/// Normalises the same way [_bestForText] does — Vedika is inconsistent about
/// spelling (`Kaal`/`Kala`, `Labh`/`Labha`), and a raw name would miss the
/// document every time.
String? _choghadiyaSuffix(ChoghadiyaPeriod period) {
  final name = period.name?.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
  return switch (name) {
    'kaal' || 'kala' => 'Kaal',
    'shubh' || 'shubha' => 'Shubh',
    'rog' || 'roga' => 'Rog',
    'udveg' || 'udvega' => 'Udveg',
    'char' || 'chara' => 'Char',
    'labh' || 'labha' => 'Labh',
    'amrit' || 'amrita' => 'Amrit',
    _ => null,
  };
}

/// What this period is suited for: the console's authored line if the client
/// wrote one, else the bundled translation, else Vedika's own English.
///
/// ⚠️ Order matters and is the whole safety argument for letting a CMS
/// override astrology copy — see `cms_muhurat_repository.dart`. A row that is
/// unpublished, empty, or absent never reaches this map, so the shipped
/// translation stays the floor.
String? _resolvedBestFor(
  ChoghadiyaPeriod period,
  AppLocalizations l10n,
  Map<String, String> cms,
) {
  final suffix = _choghadiyaSuffix(period);
  if (suffix != null) {
    final authored = cms[MuhuratKindIds.choghadiya(suffix)];
    if (authored != null) return authored;
  }
  return _bestForText(period, l10n);
}

String? _bestForText(ChoghadiyaPeriod period, AppLocalizations l10n) {
  final name = period.name?.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
  return switch (name) {
    'kaal' || 'kala' => l10n.choghadiyaBestForKaal,
    'shubh' || 'shubha' => l10n.choghadiyaBestForShubh,
    'rog' || 'roga' => l10n.choghadiyaBestForRog,
    'udveg' || 'udvega' => l10n.choghadiyaBestForUdveg,
    'char' || 'chara' => l10n.choghadiyaBestForChar,
    'labh' || 'labha' => l10n.choghadiyaBestForLabh,
    'amrit' || 'amrita' => l10n.choghadiyaBestForAmrit,
    _ => null,
  };
}

class _PeriodTile extends StatelessWidget {
  const _PeriodTile({
    required this.period,
    required this.locale,
    required this.l10n,
    required this.cmsMuhurat,
  });

  /// Authored descriptions by kind; empty when nothing is published.
  final Map<String, String> cmsMuhurat;

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
                        // The seven choghadiya names are a closed set, so
                        // they translate (4 Sep 2026 — the client saw
                        // "Kaal / Shubh / Rog…" in English on an otherwise
                        // Telugu screen). See `_bestForText` for why the
                        // description below translates too.
                        localizeAstroTerm(
                              period.name,
                              AstroTermKind.choghadiya,
                              locale,
                            ) ??
                            '—',
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
                    _resolvedBestFor(period, l10n, cmsMuhurat) ??
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
