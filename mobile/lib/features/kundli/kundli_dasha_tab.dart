import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/vedika/vedika_client.dart';
import '../../core/vedika/vedika_config.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../l10n/app_localizations.dart';
import 'kundli_dasha_data.dart';
import 'kundli_sandbox_banner.dart';
import 'kundli_shimmer_block.dart';

/// "Vimshottari Dasha" tab of the Kundli Chart screen (tab pill Figma node
/// 18:11) — previously permanently premium-gated, opening the paywall
/// instead of a real tab (its own code comment said "the Dasha view itself
/// still doesn't exist"). Now backed by the live
/// `POST /v2/astrology/vimshottari-dasha` response
/// (`kundli_dasha_data.dart`), fetched independently of the Chart tab's
/// `/kundli` call — own loading/error state, own cache, own failure mode
/// (see `KundliRepository`'s class doc). A failure here must never affect
/// the Chart tab.
///
/// Renders exactly the three things asked for: the currently-running
/// mahadasha, the dasha balance at birth, and the full maha-dasha period
/// timeline. Deliberately NOT rendered: Vedika's much larger
/// `interpretation`/`antar_interpretation` essays — see
/// [VimshottariDashaData]'s class doc for why.
class KundliDashaTab extends StatelessWidget {
  const KundliDashaTab({
    super.key,
    required this.l10n,
    required this.locale,
    required this.dashaAsync,
    required this.onRetry,
  });

  final AppLocalizations l10n;
  final Locale locale;

  /// `null` only in the practically-impossible "no birth profile" case —
  /// see `KundliChartScreen.build`'s `request` comment.
  final AsyncValue<VimshottariDashaData>? dashaAsync;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final async = dashaAsync;
    if (async == null) {
      return _DashaErrorState(
        l10n: l10n,
        message: l10n.kundliDashaLoadErrorMessage,
        onRetry: null,
      );
    }
    return async.when(
      loading: () => _DashaLoadingState(l10n: l10n),
      error: (error, stackTrace) => _DashaErrorState(
        l10n: l10n,
        message: error is VedikaException
            ? error.message
            : l10n.kundliDashaLoadErrorMessage,
        onRetry: onRetry,
      ),
      data: (data) => _DashaLoadedSection(l10n: l10n, locale: locale, data: data),
    );
  }
}

class _DashaLoadingState extends StatelessWidget {
  const _DashaLoadingState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: l10n.kundliDashaLoading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KundliShimmerBlock(height: 84, borderRadius: BorderRadius.circular(16)),
          const SizedBox(height: 12),
          KundliShimmerBlock(height: 70, borderRadius: BorderRadius.circular(16)),
          const SizedBox(height: 16),
          for (var i = 0; i < 3; i++) ...[
            if (i != 0) const SizedBox(height: 10),
            KundliShimmerBlock(height: 58, borderRadius: BorderRadius.circular(14)),
          ],
        ],
      ),
    );
  }
}

class _DashaErrorState extends StatelessWidget {
  const _DashaErrorState({
    required this.l10n,
    required this.message,
    required this.onRetry,
  });

  final AppLocalizations l10n;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.error_outline,
      iconBackgroundColor: AppColors.ashubhBg,
      iconForegroundColor: AppColors.ashubhFg,
      title: l10n.kundliDashaLoadErrorTitle,
      message: message,
      actionLabel: onRetry == null ? null : l10n.kundliRetry,
      onAction: onRetry,
    );
  }
}

class _DashaLoadedSection extends StatelessWidget {
  const _DashaLoadedSection({
    required this.l10n,
    required this.locale,
    required this.data,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final VimshottariDashaData data;

  @override
  Widget build(BuildContext context) {
    final current = data.currentDasha?.mahaDasha;
    final guidance = data.guidance;
    final balance = data.dashaBalance;
    final periods = data.mahaDashaPeriods;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // See KundliSandboxBanner's doc comment: `/vimshottari-dasha` is
        // sandboxed exactly like `/kundli` — same fixed fixture regardless
        // of the birth details sent — so this tab needs the same warning.
        if (VedikaConfig.isSandbox) ...[
          KundliSandboxBanner(l10n: l10n, locale: locale),
          const SizedBox(height: 12),
        ],
        if (current != null) ...[
          _CurrentMahadashaCard(
            l10n: l10n,
            locale: locale,
            current: current,
            guidance: guidance,
          ),
          const SizedBox(height: 12),
        ],
        if (balance != null) ...[
          _DashaBalanceCard(l10n: l10n, locale: locale, balance: balance),
          const SizedBox(height: 16),
        ],
        Text(
          l10n.kundliDashaTimelineTitle,
          style: AppFonts.body(
            locale,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: AppColors.hint,
            letterSpacing: 0.9,
          ),
        ),
        const SizedBox(height: 8),
        if (periods.isEmpty)
          AppEmptyState(
            icon: Icons.info_outline,
            iconBackgroundColor: AppColors.geoChipBg,
            iconForegroundColor: AppColors.geoChipText,
            title: l10n.kundliDashaTimelineTitle,
            message: l10n.kundliDashaTimelineEmpty,
          )
        else
          for (var i = 0; i < periods.length; i++) ...[
            if (i != 0) const SizedBox(height: 8),
            EntranceFadeSlide(
              index: i,
              child: _DashaPeriodRow(l10n: l10n, locale: locale, period: periods[i]),
            ),
          ],
      ],
    );
  }
}

/// "Currently running" card — [current] is [CurrentDasha.mahaDasha] (the
/// maha-dasha level; the API also returns the running antar/pratyantar
/// sub-levels, not rendered here — see [VimshottariDashaData]'s class doc
/// for the scoping rationale).
class _CurrentMahadashaCard extends StatelessWidget {
  const _CurrentMahadashaCard({
    required this.l10n,
    required this.locale,
    required this.current,
    required this.guidance,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final DashaLevel current;
  final DashaGuidance? guidance;

  @override
  Widget build(BuildContext context) {
    final planetLabel = _planetLabel(current.planet, current.vedicName, l10n);
    final range = _dateRange(current.startDate, current.endDate, l10n);
    final phase = guidance?.currentPhase;
    final timeRemaining = guidance?.timeRemaining;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.genderSelectedBg,
        border: Border.all(color: AppColors.saffron.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.kundliDashaCurrentTitle,
            style: AppFonts.body(
              locale,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppColors.genderSelectedText,
              letterSpacing: 0.9,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            planetLabel,
            style: AppFonts.heading(
              locale,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            range,
            style: AppFonts.body(locale, fontSize: 11, color: AppColors.muted),
          ),
          // `phase`/`timeRemaining` are Vedika's own ready-made English
          // sentences (see `DashaGuidance`'s doc comment) — rendered as-is
          // regardless of app locale, same documented gap as the Chart
          // tab's summary banner.
          if (phase != null) ...[
            const SizedBox(height: 10),
            Text(
              phase,
              style: AppFonts.body(locale, fontSize: 11.5, color: AppColors.ink),
            ),
          ],
          if (timeRemaining != null) ...[
            const SizedBox(height: 6),
            Text(
              timeRemaining,
              style: AppFonts.body(
                locale,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: AppColors.genderSelectedText,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DashaBalanceCard extends StatelessWidget {
  const _DashaBalanceCard({
    required this.l10n,
    required this.locale,
    required this.balance,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final DashaBalance balance;

  @override
  Widget build(BuildContext context) {
    final planetLabel = _planetLabel(balance.planet, balance.vedicName, l10n);
    final years = balance.years;
    final months = balance.months;
    final days = balance.days;
    final durationText = (years != null && months != null && days != null)
        ? l10n.kundliDashaBalanceValue(years, months, days)
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.kundliDashaBalanceTitle,
            style: AppFonts.body(
              locale,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppColors.hint,
              letterSpacing: 0.9,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            planetLabel,
            style: AppFonts.body(
              locale,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          if (durationText != null) ...[
            const SizedBox(height: 2),
            Text(
              durationText,
              style: AppFonts.body(locale, fontSize: 11, color: AppColors.muted),
            ),
          ],
        ],
      ),
    );
  }
}

class _DashaPeriodRow extends StatelessWidget {
  const _DashaPeriodRow({
    required this.l10n,
    required this.locale,
    required this.period,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final DashaPeriod period;

  @override
  Widget build(BuildContext context) {
    final planetLabel = _planetLabel(period.planet, period.vedicName, l10n);
    final range = _dateRange(period.startDate, period.endDate, l10n);
    final isCurrent = period.isCurrent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrent ? AppColors.genderSelectedBg : AppColors.surface,
        border: Border.all(
          color: isCurrent ? AppColors.saffron : AppColors.cardBorder,
          width: isCurrent ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  planetLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(
                    locale,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  range,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(locale, fontSize: 10.5, color: AppColors.muted),
                ),
              ],
            ),
          ),
          if (isCurrent) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.saffron,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                l10n.kundliDashaCurrentBadge,
                style: AppFonts.body(
                  locale,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// e.g. `"Moon (Chandra)"` — falls back to whichever of the two names is
/// present, or the localized "unavailable" dash if neither is.
String _planetLabel(String? planet, String? vedicName, AppLocalizations l10n) {
  if (planet != null && vedicName != null) return '$planet ($vedicName)';
  return planet ?? vedicName ?? l10n.kundliValueUnavailable;
}

/// e.g. `"2019-12-19 – 2029-12-19"`. Dates are rendered as Vedika sends
/// them (`yyyy-MM-dd`, locale-neutral and universally readable) rather than
/// reformatted with `DateFormat` per app locale — that would need
/// `initializeDateFormatting()` for the 4 Indic locales first, which this
/// feature does not set up. Same "raw API text" trade-off as the planet
/// names elsewhere on this tab.
String _dateRange(String? start, String? end, AppLocalizations l10n) {
  if (start == null && end == null) return l10n.kundliValueUnavailable;
  return '${start ?? l10n.kundliValueUnavailable} – ${end ?? l10n.kundliValueUnavailable}';
}
