import 'package:flutter/material.dart';

import '../../features/ai/ai_astrologer_screen.dart';
import '../../features/home/home_dashboard_screen.dart';
import '../../features/kundli/kundli_input_screen.dart';
import '../../features/panchang/panchang_screen.dart';
import '../../features/profile/profile_settings_screen.dart';
import '../../l10n/app_localizations.dart';
import '../motion/app_motion.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';

/// Which bottom-nav tab a screen represents, and therefore which tab
/// [AppBottomNav] should render as active.
enum AppTab { home, panchang, kundli, askAi, profile }

/// Shared bottom navigation bar — Home / Panchang / Kundli / Ask AI /
/// Profile — used by every screen that has a bottom nav.
///
/// This is deliberately ROUTE-BASED rather than an `IndexedStack` shell:
/// only 3 of the 5 tabs have a real screen behind them today (Home,
/// Panchang, Profile), so there is no shell content yet for Kundli/Ask AI to
/// keep alive. When all five tab screens exist, replace this with a shell
/// widget that keeps each tab's scroll position — route-based switching (as
/// done here) discards it on every tab change.
///
/// Icon set matches the approved Figma "B1 · Home Dashboard" concept
/// (node 14:72) exactly: Home is a MONOCHROME outline icon (tintable, shows
/// the active/inactive state colour), the other four are COLOUR EMOJI
/// (matches the design 1:1, and — per the project's ICON RULE — Android's
/// system emoji font renders these fine, unlike bare typographic symbols).
/// Only the Home icon takes a `color`; emoji cannot be tinted and aren't
/// meant to be here. Active tab = a peach pill behind the icon only, no
/// second outer tinted block; equal-size icon boxes keep all five labels on
/// the same baseline.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.currentTab});

  final AppTab currentTab;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 22),
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  label: l10n.navHome,
                  locale: locale,
                  isActive: currentTab == AppTab.home,
                  onTap: () => _handleTap(context, AppTab.home),
                  // The design's ⌂ character renders as a thin outline
                  // house in Figma, but has no glyph in our bundled
                  // Playfair/Poppins/Noto fonts (see the project's ICON
                  // RULE) and would risk tofu on device. Icons.home_outlined
                  // is the faithful, safe equivalent — same silhouette,
                  // guaranteed to render, and tintable for the active state.
                  iconBuilder: (isActive) => Icon(
                    Icons.home_outlined,
                    size: 21,
                    color: isActive
                        ? AppColors.navActiveText
                        : AppColors.navInactive,
                  ),
                ),
              ),
              Expanded(
                child: _NavItem(
                  label: l10n.navPanchang,
                  locale: locale,
                  isActive: currentTab == AppTab.panchang,
                  onTap: () => _handleTap(context, AppTab.panchang),
                  iconBuilder: (isActive) =>
                      Text('🗓', style: AppFonts.body(locale, fontSize: 20)),
                ),
              ),
              Expanded(
                child: _NavItem(
                  label: l10n.navKundli,
                  locale: locale,
                  isActive: currentTab == AppTab.kundli,
                  onTap: () => _handleTap(context, AppTab.kundli),
                  // Was 🪐 (a planet) — WRONG per the design, which specifies
                  // a diya (🪔) for Kundli.
                  iconBuilder: (isActive) =>
                      Text('🪔', style: AppFonts.body(locale, fontSize: 20)),
                ),
              ),
              Expanded(
                child: _NavItem(
                  label: l10n.navAskAi,
                  locale: locale,
                  isActive: currentTab == AppTab.askAi,
                  onTap: () => _handleTap(context, AppTab.askAi),
                  iconBuilder: (isActive) =>
                      Text('🔮', style: AppFonts.body(locale, fontSize: 20)),
                ),
              ),
              Expanded(
                child: _NavItem(
                  label: l10n.navProfile,
                  locale: locale,
                  isActive: currentTab == AppTab.profile,
                  onTap: () => _handleTap(context, AppTab.profile),
                  iconBuilder: (isActive) =>
                      Text('👤', style: AppFonts.body(locale, fontSize: 20)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, AppTab tapped) {
    // Tapping the current tab is a no-op — there is nowhere to navigate to.
    if (tapped == currentTab) return;

    switch (tapped) {
      case AppTab.home:
        Navigator.of(
          context,
        ).pushReplacement(_instantRoute(const HomeDashboardScreen()));
      case AppTab.panchang:
        Navigator.of(
          context,
        ).pushReplacement(_instantRoute(const PanchangScreen()));
      case AppTab.kundli:
        // The Figma design gives the Kundli screen a back button and NO
        // bottom nav (it isn't a tab root visually), so — unlike Home/
        // Panchang above — this is a `push` (not `pushReplacement`) using
        // the shared fade-through transition: the back button must return
        // to whatever tab/screen the user came from, not to a fixed root,
        // and the back stack SHOULD grow here. When this app later moves to
        // an IndexedStack-based shell (see this file's class doc comment),
        // the Kundli tab's root should become this screen WITH the bottom
        // nav visible, and this push-based wiring should be revisited.
        Navigator.of(
          context,
        ).push<void>(fadeThroughRoute(const KundliInputScreen()));
      case AppTab.askAi:
        // Same push convention as Kundli above — this screen has no bottom
        // nav of its own in the Figma design either.
        Navigator.of(
          context,
        ).push<void>(fadeThroughRoute(const AiAstrologerScreen()));
      case AppTab.profile:
        // Same tab-root convention as Home/Panchang above: instant switch,
        // no growing back stack.
        Navigator.of(
          context,
        ).pushReplacement(_instantRoute(const ProfileSettingsScreen()));
    }
  }

  /// A tab switch should feel instant, like flipping between sibling
  /// screens, not like a page being pushed — hence the zero-duration
  /// transition. `pushReplacement` (rather than `push`) is equally
  /// deliberate: it stops the back stack growing every time the user
  /// toggles between tabs.
  static PageRouteBuilder<T> _instantRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (context, animation, secondaryAnimation) => page,
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.label,
    required this.locale,
    required this.onTap,
    required this.iconBuilder,
    this.isActive = false,
  });

  final String label;
  final Locale locale;
  final VoidCallback onTap;
  final bool isActive;

  /// Builds the tab's icon (a Material [Icon] for Home, an emoji [Text]
  /// for the rest) given whether the tab is currently active.
  final Widget Function(bool isActive) iconBuilder;

  @override
  State<_NavItem> createState() => _NavItemState();
}

/// Motion spec item 4 (nav pill slide) — the icon micro-bounce half.
///
/// On tap the icon quickly scales up to ~1.15x then settles back to 1.0
/// with `Curves.easeOutBack`, over ~220ms. The saffron pill "sliding
/// between tabs" (the other half of spec item 4) is NOT implementable here:
/// each screen builds a fresh [AppBottomNav] instance (see the route-based
/// note on the class above), so there is no shared widget for a pill to
/// animate between — it lands with the IndexedStack shell refactor already
/// planned for this file.
class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final Animation<double> _bounceScale;

  static const Duration _bounceDuration = Duration(milliseconds: 220);

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: _bounceDuration,
    );
    _bounceScale = TweenSequence<double>([
      TweenSequenceItem(
        weight: 40,
        tween: Tween(
          begin: 1.0,
          end: 1.15,
        ).chain(CurveTween(curve: Curves.easeOut)),
      ),
      TweenSequenceItem(
        weight: 60,
        tween: Tween(
          begin: 1.15,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
      ),
    ]).animate(_bounceController);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _bounceController.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    // Every tab gets the SAME padded icon box, so all five icons and all
    // five labels sit on identical baselines — only the active tab draws a
    // peach pill behind its icon. Giving the active tab a differently-sized
    // box shifted its label out of line with the others on real-device
    // feedback.
    final iconBox = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      decoration: BoxDecoration(
        color: widget.isActive
            ? AppColors.genderSelectedBg
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: AnimatedBuilder(
        animation: _bounceScale,
        builder: (context, child) =>
            Transform.scale(scale: _bounceScale.value, child: child),
        child: widget.iconBuilder(widget.isActive),
      ),
    );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        iconBox,
        const SizedBox(height: 4),
        Text(
          widget.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppFonts.body(
            widget.locale,
            fontSize: 10.5,
            fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w400,
            color: widget.isActive
                ? AppColors.navActiveText
                : AppColors.navInactive,
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      selected: widget.isActive,
      label: widget.label,
      // No second tinted block behind the active tab: the design had both
      // an outer tint AND an inner pill, which read as a heavy floating
      // slab on a real device. The pill around the icon alone is enough to
      // show selection, and it keeps all five tabs the same visual height.
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: _handleTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: content,
        ),
      ),
    );
  }
}
