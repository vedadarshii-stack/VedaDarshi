import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/widgets/premium_glimpse.dart';
import '../../l10n/app_localizations.dart';
import '../kundli/kundli_repository.dart';
import '../premium/subscription_paywall_screen.dart';
import '../profile/birth_profile_repository.dart';
import 'report_content.dart';
import 'report_labels.dart';
import 'report_repository.dart';
import 'reports_static_data.dart';

/// One premium report, opened from a card on the Premium Reports screen.
///
/// BUILT 2 Sep 2026 for the client's request: *"for reports after clicking
/// show sample glimpse report set like that so that it can engage users"*.
///
/// Before this, tapping a PREMIUM card pushed the paywall straight away and a
/// FREE card did nothing at all — so the whole Reports screen was seven rows
/// that led nowhere. Now every card opens this screen, which fetches the
/// user's OWN report from Vedika and shows it.
///
/// ## The premium/free split is the only branch
///
/// A free report ([ReportAccess.free] — Gemstone and Numerology) renders in
/// full. A premium one renders through [PremiumGlimpse]: the same real
/// content, cut off partway with an upgrade CTA underneath. The content
/// fetched is identical either way; only the presentation differs.
///
/// ⚠️ **This is a TEASER gate, not entitlement enforcement.** A subscriber
/// still sees the glimpse here, because nothing yet checks their entitlement
/// on this screen — and the report body itself must eventually be served
/// behind a server-side check, not merely hidden behind a gradient. Wire it
/// to `subscriptionStatusProvider` and move the full body server-side before
/// this counts as a paid feature.
class ReportDetailScreen extends ConsumerWidget {
  const ReportDetailScreen({super.key, required this.report});

  final AstrologyReport report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final profile = ref.watch(birthProfileProvider).value;
    final birth = profile == null
        ? null
        : KundliRequest.fromBirthProfile(profile);
    final contentAsync = birth == null
        ? null
        : ref.watch(
            reportContentProvider(
              ReportRequest(reportId: report.id, birth: birth),
            ),
          );

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
          children: [
            _Header(
              title: reportTitle(report.id, l10n),
              locale: locale,
            ),
            const SizedBox(height: 18),
            _IntroCard(report: report, l10n: l10n, locale: locale),
            const SizedBox(height: 18),
            if (contentAsync == null)
              // No saved birth profile → no chart → nothing honest to show.
              _Message(l10n.reportEmptyMessage, locale: locale)
            else
              contentAsync.when(
                loading: () => const _Loading(),
                error: (error, stackTrace) => _Message(
                  l10n.kundliLoadErrorMessage,
                  locale: locale,
                  onRetry: () => ref.invalidate(
                    reportContentProvider(
                      ReportRequest(reportId: report.id, birth: birth!),
                    ),
                  ),
                ),
                // Built HERE, not in the repository: the labels are
                // localized, so the same cached payload has to render in
                // whatever language is active right now.
                data: (payload) => _Body(
                  report: report,
                  content: buildReportContent(report.id, payload, l10n),
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

class _Body extends StatelessWidget {
  const _Body({
    required this.report,
    required this.content,
    required this.l10n,
    required this.locale,
  });

  final AstrologyReport report;
  final ReportContent content;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) {
      return _Message(l10n.reportEmptyMessage, locale: locale);
    }

    final sections = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final section in content.sections)
          if (section.lines.isNotEmpty)
            _Section(section: section, l10n: l10n, locale: locale),
      ],
    );

    if (report.access == ReportAccess.free) return sections;

    return PremiumGlimpse(
      locale: locale,
      previewHeight: 260,
      ctaLabel: l10n.reportGlimpseCta,
      subtitle: l10n.reportGlimpseSubtitle,
      onUpgrade: () => Navigator.of(
        context,
      ).push(fadeThroughRoute(const SubscriptionPaywallScreen())),
      child: sections,
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.section,
    required this.l10n,
    required this.locale,
  });

  final ReportSection section;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reportSectionTitle(section.kind, l10n),
            style: AppFonts.heading(
              locale,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 10),
          for (final line in section.lines) _Line(line: line, locale: locale),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.line, required this.locale});

  final ReportLine line;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final label = line.label;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null && label.isNotEmpty)
            Text(
              label,
              style: AppFonts.body(
                locale,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.saffron,
              ),
            ),
          if (line.text.isNotEmpty)
            Text(
              line.text,
              style: AppFonts.body(
                locale,
                fontSize: 13,
                color: AppColors.muted,
              ),
            ),
        ],
      ),
    );
  }
}

/// Title + description card, so the screen names the report before its
/// content loads rather than opening on a bare spinner.
class _IntroCard extends StatelessWidget {
  const _IntroCard({
    required this.report,
    required this.l10n,
    required this.locale,
  });

  final AstrologyReport report;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: report.tileBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(report.emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              reportDescription(report.id, l10n),
              style: AppFonts.body(
                locale,
                fontSize: 13,
                color: AppColors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.locale});

  final String title;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Row(
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
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < 4; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              height: i == 0 ? 20 : 54,
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text, {required this.locale, this.onRetry});

  final String text;
  final Locale locale;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppFonts.body(locale, fontSize: 13, color: AppColors.muted),
          ),
          if (onRetry case final retry?) ...[
            const SizedBox(height: 12),
            TextButton(onPressed: retry, child: Text(l10n.retry)),
          ],
        ],
      ),
    );
  }
}
