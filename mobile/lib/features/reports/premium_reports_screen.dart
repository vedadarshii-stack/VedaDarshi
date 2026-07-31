import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../premium/subscription_paywall_screen.dart';
import 'reports_static_data.dart';

/// Premium Reports, per the approved Figma "C4 · Premium Reports"
/// (node 22:2) concept.
///
/// Reached from Home's Explore "Reports" tile and the "Recent Reports"
/// section's "My reports" action. Like the Kundli/Match/AI screens, this has
/// NO bottom nav in the design — it's a pushed destination with its own
/// back button.
///
/// Every report shown below is STATIC PLACEHOLDER DATA from
/// [ReportsStaticData]; see that file's doc comment for what eventually
/// replaces it (the Vedika API catalogue + a server-side RevenueCat
/// entitlement check).
class PremiumReportsScreen extends ConsumerStatefulWidget {
  const PremiumReportsScreen({super.key});

  @override
  ConsumerState<PremiumReportsScreen> createState() =>
      _PremiumReportsScreenState();
}

class _PremiumReportsScreenState extends ConsumerState<PremiumReportsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final isCompact = MediaQuery.sizeOf(context).height < 840;
    final reports = ReportsStaticData.reports;
    final remaining = ReportsStaticData.totalReports - reports.length;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, isCompact ? 32 : 56, 20, 24),
          children: [
            _Header(l10n: l10n, locale: locale),
            const SizedBox(height: 14),
            _GoPremiumBanner(l10n: l10n, locale: locale),
            const SizedBox(height: 14),
            Column(
              children: [
                for (var i = 0; i < reports.length; i++) ...[
                  if (i != 0) const SizedBox(height: 8),
                  EntranceFadeSlide(
                    index: i,
                    child: _ReportCard(
                      report: reports[i],
                      l10n: l10n,
                      locale: locale,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),
            _Footer(l10n: l10n, locale: locale, remaining: remaining),
          ],
        ),
      ),
    );
  }
}

/// Back button + screen title (Figma node 22:3).
class _Header extends StatelessWidget {
  const _Header({required this.l10n, required this.locale});

  final AppLocalizations l10n;
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
                color: Colors.white,
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
            l10n.premiumReportsTitle,
            maxLines: 1,
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

/// Navy "Go Premium" upsell banner (Figma node 22:7) with a gold glow pulse
/// on the whole banner (motion spec item 5).
class _GoPremiumBanner extends StatelessWidget {
  const _GoPremiumBanner({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: PressableScale(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(
          context,
        ).push(fadeThroughRoute(const SubscriptionPaywallScreen())),
        child: GoldGlowPulse(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: AppColors.navyGradientHorizontal,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.7)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navyBottom.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Text('👑', style: AppFonts.body(locale, fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.goPremium,
                        style: AppFonts.body(
                          locale,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.quoteGold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.goPremiumSubtitle(
                          ReportsStaticData.totalReports.toString(),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.body(
                          locale,
                          fontSize: 11,
                          color: AppColors.quoteMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Semantics(
                  button: true,
                  child: PressableScale(
                    borderRadius: BorderRadius.circular(999),
                    // Same destination as the banner tap above.
                    onTap: () => Navigator.of(
                      context,
                    ).push(fadeThroughRoute(const SubscriptionPaywallScreen())),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        l10n.upgrade,
                        style: AppFonts.body(
                          locale,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onGold,
                        ),
                      ),
                    ),
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

/// Resolves the l10n title for an [AstrologyReport.id].
String _reportTitle(String id, AppLocalizations l10n) {
  switch (id) {
    case 'career':
      return l10n.reportCareer;
    case 'marriage':
      return l10n.reportMarriage;
    case 'wealth':
      return l10n.reportWealth;
    case 'health':
      return l10n.reportHealth;
    case 'sadeSati':
      return l10n.reportSadeSati;
    case 'gemstone':
      return l10n.reportGemstone;
    case 'numerology':
      return l10n.reportNumerology;
    default:
      return id;
  }
}

/// Resolves the l10n description for an [AstrologyReport.id].
String _reportDescription(String id, AppLocalizations l10n) {
  switch (id) {
    case 'career':
      return l10n.reportCareerDesc;
    case 'marriage':
      return l10n.reportMarriageDesc;
    case 'wealth':
      return l10n.reportWealthDesc;
    case 'health':
      return l10n.reportHealthDesc;
    case 'sadeSati':
      return l10n.reportSadeSatiDesc;
    case 'gemstone':
      return l10n.reportGemstoneDesc;
    case 'numerology':
      return l10n.reportNumerologyDesc;
    default:
      return '';
  }
}

/// One report row card (Figma node 22:14 + meta row 53:2).
class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.report,
    required this.l10n,
    required this.locale,
  });

  final AstrologyReport report;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final title = _reportTitle(report.id, l10n);

    return Semantics(
      button: true,
      label: title,
      child: PressableScale(
        borderRadius: BorderRadius.circular(16),
        // Premium reports open the paywall. Free reports are still a no-op:
        // the report viewer itself doesn't exist yet.
        onTap: report.access == ReportAccess.premium
            ? () => Navigator.of(
                context,
              ).push(fadeThroughRoute(const SubscriptionPaywallScreen()))
            : () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: report.tileBg,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  report.emoji,
                  style: AppFonts.body(locale, fontSize: 17),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.body(
                        locale,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      _reportDescription(report.id, l10n),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.body(
                        locale,
                        fontSize: 10.5,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _MetaChip(
                          icon: Icons.schedule,
                          label: l10n.readMinutes(
                            report.readMinutes.toString(),
                          ),
                          background: AppColors.rowDivider,
                          foreground: AppColors.muted,
                          locale: locale,
                        ),
                        _MetaChip(
                          icon: Icons.picture_as_pdf,
                          label: l10n.pdf,
                          background: AppColors.tileBlueBg,
                          foreground: AppColors.tileBlueFg,
                          locale: locale,
                        ),
                        _MetaChip(
                          icon: Icons.auto_awesome,
                          label: l10n.aiSummary,
                          background: AppColors.tilePurpleBg,
                          foreground: AppColors.tilePurpleFg,
                          locale: locale,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _AccessBadge(access: report.access, l10n: l10n, locale: locale),
            ],
          ),
        ),
      ),
    );
  }
}

/// One small meta chip (reading time / PDF / AI summary) in the report
/// card's meta row (Figma node 53:2).
class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.locale,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 8, color: foreground),
          const SizedBox(width: 3),
          Text(
            label,
            style: AppFonts.body(
              locale,
              fontSize: 8.5,
              fontWeight: FontWeight.w500,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

/// Trailing Premium/Free access badge on a report card.
class _AccessBadge extends StatelessWidget {
  const _AccessBadge({
    required this.access,
    required this.l10n,
    required this.locale,
  });

  final ReportAccess access;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final isPremium = access == ReportAccess.premium;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: isPremium
            ? AppColors.saffron.withValues(alpha: 0.14)
            : AppColors.geoChipBg,
        borderRadius: BorderRadius.circular(999),
        border: isPremium
            ? Border.all(color: AppColors.saffron.withValues(alpha: 0.35))
            : null,
      ),
      child: isPremium
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock, size: 9, color: AppColors.genderSelectedText),
                const SizedBox(width: 3),
                Text(
                  l10n.premium,
                  style: AppFonts.body(
                    locale,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.genderSelectedText,
                  ),
                ),
              ],
            )
          : Text(
              l10n.free,
              style: AppFonts.body(
                locale,
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: AppColors.tileGreenFg,
              ),
            ),
    );
  }
}

/// Centered "+N more reports" footer (Figma node 22:71).
class _Footer extends StatelessWidget {
  const _Footer({
    required this.l10n,
    required this.locale,
    required this.remaining,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final int remaining;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Text(
            l10n.moreReportsFooter(remaining.toString()),
            textAlign: TextAlign.center,
            style: AppFonts.body(locale, fontSize: 11.5, color: AppColors.hint),
          ),
        ),
        const SizedBox(width: 4),
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(Icons.download_rounded, size: 12, color: AppColors.hint),
        ),
      ],
    );
  }
}
