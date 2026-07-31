import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/widgets/app_radio_dot.dart';
import '../../l10n/app_localizations.dart';
import '../profile/birth_profile_repository.dart';
import 'kundli_chart_screen.dart';
import 'kundli_static_data.dart';

/// Which chart layout style is selected — see the "CHART STYLE" cards
/// (Figma node 17:26).
enum _ChartStyle { northIndian, southIndian }

/// Kundli — New Chart, per the approved Figma "B5 · Kundli — New Chart"
/// (node 17:2) concept.
///
/// Lets the user confirm which saved profile to generate a chart for and
/// pick a chart layout style, before generating the Kundli chart itself
/// ("B6 · Kundli Chart", Figma node 18:2 — not yet built). Unlike the
/// Home/Panchang tab roots, this screen has NO bottom nav in the design —
/// it's reached as a pushed destination with its own back button (see
/// `app_bottom_nav.dart`'s Kundli tab wiring and Home's Explore tile for the
/// two entry points).
///
/// Every value shown that isn't the real saved profile is STATIC PLACEHOLDER
/// DATA from [KundliStaticData]; see that file's doc comment for the full
/// rationale (in particular, why this screen shows only one profile card).
class KundliInputScreen extends ConsumerStatefulWidget {
  const KundliInputScreen({super.key});

  @override
  ConsumerState<KundliInputScreen> createState() => _KundliInputScreenState();
}

class _KundliInputScreenState extends ConsumerState<KundliInputScreen> {
  _ChartStyle _chartStyle = _ChartStyle.northIndian;

  void _selectChartStyle(_ChartStyle style) {
    if (style == _chartStyle) return;
    setState(() => _chartStyle = style);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final isCompact = MediaQuery.sizeOf(context).height < 840;

    // Prefer the real saved profile; fall back to static placeholder values
    // only for the should-be-impossible "no profile yet" case (see
    // KundliStaticData's doc comment) — this screen must never flash a
    // loading state or render zero profile cards, so `valueOrNull` covers
    // loading/error/null with the same fallback.
    final profile = ref.watch(birthProfileProvider).valueOrNull;
    final trimmedName = profile?.fullName.trim();
    final profileName = (trimmedName != null && trimmedName.isNotEmpty)
        ? trimmedName
        : KundliStaticData.fallbackProfileName;
    final profileSummary = profile != null
        ? profile.summaryLine
        : KundliStaticData.fallbackProfileSummary;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // The design (Figma node 17:35) has a flexible spacer pushing
            // the info note + CTA button to the bottom of the screen. A bare
            // Spacer() needs a bounded-height ancestor to resolve — a plain
            // ListView/SingleChildScrollView does NOT provide one, which bit
            // the Welcome/Login screen once already for the same reason
            // (see welcome_login_screen.dart's own SliverFillRemaining
            // comment). SliverFillRemaining(hasScrollBody: false) is what
            // gives the inner Column bounded height instead.
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, isCompact ? 32 : 56, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(l10n: l10n, locale: locale),
                    const SizedBox(height: 18),
                    _SectionLabel(text: l10n.selectProfile, locale: locale),
                    const SizedBox(height: 10),
                    _ProfileList(
                      l10n: l10n,
                      locale: locale,
                      profileName: profileName,
                      profileSummary: profileSummary,
                    ),
                    const SizedBox(height: 18),
                    _SectionLabel(text: l10n.chartStyle, locale: locale),
                    const SizedBox(height: 10),
                    _ChartStyleRow(
                      l10n: l10n,
                      locale: locale,
                      selected: _chartStyle,
                      onSelect: _selectChartStyle,
                    ),
                    const Spacer(),
                    _InfoNote(l10n: l10n, locale: locale),
                    const SizedBox(height: 12),
                    _GenerateKundliButton(
                      l10n: l10n,
                      locale: locale,
                      chartStyle: _chartStyle,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Back button + screen title (Figma node 17:3).
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
              child: const Icon(
                Icons.arrow_back,
                size: 18,
                color: AppColors.ink,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            l10n.generateKundliTitle,
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

/// Uppercased, letter-spaced section label ("SELECT PROFILE" / "CHART
/// STYLE").
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text, required this.locale});

  final String text;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppFonts.body(
        locale,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.muted,
        letterSpacing: 0.88,
      ),
    );
  }
}

/// PROFILE LIST (Figma node 17:8): the real saved profile's card, plus the
/// "Add family or friend" dashed placeholder button.
class _ProfileList extends StatelessWidget {
  const _ProfileList({
    required this.l10n,
    required this.locale,
    required this.profileName,
    required this.profileSummary,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final String profileName;
  final String profileSummary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProfileCard(name: profileName, summary: profileSummary, locale: locale),
        const SizedBox(height: 10),
        _AddFamilyFriendButton(l10n: l10n, locale: locale),
      ],
    );
  }
}

/// The one real profile card (Figma node 17:9's SELECTED variant — with only
/// one profile, it's always selected).
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    required this.summary,
    required this.locale,
  });

  final String name;
  final String summary;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.saffron, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.saffron.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.navyHeroGradient,
            ),
            child: Text(
              initial,
              style: AppFonts.heading(
                locale,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.gold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(
                    locale,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(
                    locale,
                    fontSize: 11,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const AppRadioDot(isSelected: true),
        ],
      ),
    );
  }
}

/// "Add family or friend" dashed placeholder button (Figma node 17:23).
class _AddFamilyFriendButton extends StatelessWidget {
  const _AddFamilyFriendButton({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: l10n.addFamilyFriend,
      child: PressableScale(
        borderRadius: BorderRadius.circular(16),
        // Multi-profile support (family/friends) is a follow-up feature not
        // implemented yet — this button is its honest placeholder entry
        // point. See kundli_static_data.dart's doc comment for the full
        // rationale (why this screen doesn't fabricate a second profile).
        onTap: () {},
        child: CustomPaint(
          painter: const _DashedBorderPainter(color: AppColors.otpBorderFilled),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add, size: 16, color: AppColors.saffron),
                const SizedBox(width: 6),
                Text(
                  l10n.addFamilyFriend,
                  style: AppFonts.body(
                    locale,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
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

/// Strokes a dashed rounded-rect outline — Flutter has no built-in dashed
/// border, so this hand-rolled painter fills the gap. Kept private to this
/// file since it's used only by [_AddFamilyFriendButton] above; the stroke
/// width/corner radius/dash pattern are fixed to that one card's look
/// rather than exposed as constructor parameters nothing calls with a
/// non-default value.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color});

  final Color color;

  static const double _strokeWidth = 1;
  static const double _radius = 16;
  static const double _dashWidth = 5;
  static const double _dashGap = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;

    const inset = _strokeWidth / 2;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        inset,
        inset,
        size.width - _strokeWidth,
        size.height - _strokeWidth,
      ),
      const Radius.circular(_radius),
    );
    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + _dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + _dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return color != oldDelegate.color;
  }
}

/// CHART STYLE cards (Figma node 17:26): North Indian (diamond) vs South
/// Indian (grid) layout.
class _ChartStyleRow extends StatelessWidget {
  const _ChartStyleRow({
    required this.l10n,
    required this.locale,
    required this.selected,
    required this.onSelect,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final _ChartStyle selected;
  final ValueChanged<_ChartStyle> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ChartStyleCard(
            // The Figma design uses a bare ◇ glyph for this card, which has
            // no guaranteed glyph in our bundled Playfair/Poppins/Noto fonts
            // (would render as tofu on device) — Icons.diamond_outlined is
            // the Material equivalent, per this project's icon convention
            // (see the top-level CLAUDE.md's ICON RULE).
            icon: Icons.diamond_outlined,
            title: l10n.chartNorthIndian,
            subtitle: l10n.chartNorthLayout,
            locale: locale,
            isSelected: selected == _ChartStyle.northIndian,
            onTap: () => onSelect(_ChartStyle.northIndian),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ChartStyleCard(
            // Same tofu risk as above — the design's bare ▦ glyph becomes
            // Icons.grid_on_rounded.
            icon: Icons.grid_on_rounded,
            title: l10n.chartSouthIndian,
            subtitle: l10n.chartSouthLayout,
            locale: locale,
            isSelected: selected == _ChartStyle.southIndian,
            onTap: () => onSelect(_ChartStyle.southIndian),
          ),
        ),
      ],
    );
  }
}

class _ChartStyleCard extends StatelessWidget {
  const _ChartStyleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.locale,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Locale locale;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final contentColor = isSelected
        ? AppColors.genderSelectedText
        : AppColors.ink;

    return Semantics(
      button: true,
      selected: isSelected,
      label: title,
      child: PressableScale(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.genderSelectedBg : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.saffron : AppColors.cardBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected ? AppColors.genderSelectedText : AppColors.navInactive,
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(
                    locale,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: contentColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(locale, fontSize: 10.5, color: AppColors.hint),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Info note (Figma node 17:36) explaining the calculation engine.
class _InfoNote extends StatelessWidget {
  const _InfoNote({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.tileBlueBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 14, color: AppColors.tileBlueFg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.kundliCalcNote,
              style: AppFonts.body(locale, fontSize: 11, color: AppColors.tileBlueFg),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-width "Generate Kundli 🪔" CTA (Figma node 17:38). Shares the
/// saffron-gradient pill recipe of the Welcome/Login screen's
/// `_GetOtpButton`.
class _GenerateKundliButton extends StatelessWidget {
  const _GenerateKundliButton({
    required this.l10n,
    required this.locale,
    required this.chartStyle,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final _ChartStyle chartStyle;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: l10n.generateKundli,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: AppColors.saffron.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: PressableScale(
          borderRadius: BorderRadius.circular(999),
          onTap: () {
            Navigator.of(context).push(
              fadeThroughRoute(
                KundliChartScreen(
                  initialStyle: chartStyle == _ChartStyle.northIndian
                      ? KundliChartStyle.northIndian
                      : KundliChartStyle.southIndian,
                ),
              ),
            );
          },
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 17),
            decoration: const BoxDecoration(gradient: AppColors.saffronGradient),
            child: Center(
              child: Text(
                '${l10n.generateKundli} 🪔',
                style: AppFonts.body(
                  locale,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
