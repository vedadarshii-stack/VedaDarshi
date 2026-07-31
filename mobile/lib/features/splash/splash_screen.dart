import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/widgets/app_logo.dart';
import '../../l10n/app_localizations.dart';
import '../language/language_select_screen.dart';

/// Splash / intro carousel matching the approved Figma "A1 · Splash",
/// "A1b · Intro — Your Stars" and "A1c · Intro — AI Astrologer" concepts.
///
/// The whole content fades/slides in over 800ms. It then presents a
/// 3-slide carousel (brand → horoscope/panchang/kundli → AI astrologer)
/// that auto-advances the first two slides before waiting on the user to
/// tap "Get Started" on the final slide. Any manual swipe permanently
/// cancels the remaining auto-advance timers.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final PageController _pageController;

  final List<Timer> _autoAdvanceTimers = [];
  bool _autoAdvanceCancelled = false;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    final curved = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _fadeAnimation = curved;
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(curved);
    _controller.forward();

    _pageController = PageController();

    _autoAdvanceTimers
      ..add(Timer(const Duration(milliseconds: 2500), () => _advanceTo(1)))
      ..add(Timer(const Duration(milliseconds: 5500), () => _advanceTo(2)));
  }

  void _advanceTo(int page) {
    if (!mounted || _autoAdvanceCancelled) return;
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _cancelAutoAdvance() {
    if (_autoAdvanceCancelled) return;
    _autoAdvanceCancelled = true;
    for (final timer in _autoAdvanceTimers) {
      timer.cancel();
    }
  }

  bool _handleScrollStart(ScrollStartNotification notification) {
    if (notification.dragDetails != null) {
      _cancelAutoAdvance();
    }
    return false;
  }

  /// Ends the intro carousel and hands off to language selection (the next
  /// step of the onboarding flow, per the approved Figma prototype wiring:
  /// Splash → intro slides → Get Started → Language Select).
  void _goToLanguageSelect() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement<void, void>(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LanguageSelectScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _cancelAutoAdvance();
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.navyGradient),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: NotificationListener<ScrollStartNotification>(
                      onNotification: _handleScrollStart,
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) =>
                            setState(() => _currentPage = index),
                        children: [
                          _BrandSlide(l10n: l10n, locale: locale),
                          _StarsSlide(l10n: l10n, locale: locale),
                          _AiSlide(
                            l10n: l10n,
                            locale: locale,
                            onGetStarted: _goToLanguageSelect,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 36),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _Dot(isActive: _currentPage == 0),
                        const SizedBox(width: 8),
                        _Dot(isActive: _currentPage == 1),
                        const SizedBox(width: 8),
                        _Dot(isActive: _currentPage == 2),
                      ],
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

/// A single carousel dot; the active dot grows into a rounded pill.
class _Dot extends StatelessWidget {
  const _Dot({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: isActive ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.gold : Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Slide 1 — brand: logo, wordmark and tagline (identical to the original
/// static splash content).
class _BrandSlide extends StatelessWidget {
  const _BrandSlide({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppLogo(size: 148),
          const SizedBox(height: 24),
          Text(
            l10n.appName,
            style: AppFonts.heading(
              locale,
              fontWeight: FontWeight.w700,
              fontSize: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.splashTagline,
            style: AppFonts.body(locale, fontSize: 15, color: AppColors.gold),
          ),
        ],
      ),
    );
  }
}

/// Slide 2 — daily horoscope, Panchang & Kundli teaser.
class _StarsSlide extends StatelessWidget {
  const _StarsSlide({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const _IntroRing(icon: Icons.auto_awesome),
          const SizedBox(height: 24),
          Text(
            l10n.introStarsTitle,
            textAlign: TextAlign.center,
            style: AppFonts.heading(
              locale,
              fontWeight: FontWeight.w700,
              fontSize: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              l10n.introStarsSubtitle,
              textAlign: TextAlign.center,
              style: AppFonts.body(
                locale,
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Slide 3 — AI Astrologer teaser + the "Get Started" CTA that exits the
/// carousel into the app.
class _AiSlide extends StatelessWidget {
  const _AiSlide({
    required this.l10n,
    required this.locale,
    required this.onGetStarted,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const _IntroRing(icon: Icons.forum_outlined),
          const SizedBox(height: 24),
          Text(
            l10n.introAiTitle,
            textAlign: TextAlign.center,
            style: AppFonts.heading(
              locale,
              fontWeight: FontWeight.w700,
              fontSize: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              l10n.introAiSubtitle,
              textAlign: TextAlign.center,
              style: AppFonts.body(
                locale,
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
          const SizedBox(height: 28),
          _GetStartedButton(
            label: l10n.getStarted,
            locale: locale,
            onTap: onGetStarted,
          ),
        ],
      ),
    );
  }
}

/// Shared circular icon badge used by the feature-teaser slides.
class _IntroRing extends StatelessWidget {
  const _IntroRing({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      height: 148,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: AppColors.gold, width: 1.5),
      ),
      child: Icon(icon, size: 56, color: AppColors.gold),
    );
  }
}

/// Saffron gradient pill CTA that ends the intro carousel.
class _GetStartedButton extends StatelessWidget {
  const _GetStartedButton({
    required this.label,
    required this.locale,
    required this.onTap,
  });

  final String label;
  final Locale locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(27),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 14),
          decoration: BoxDecoration(gradient: AppColors.saffronGradient),
          child: Text(
            label,
            style: AppFonts.body(
              locale,
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
