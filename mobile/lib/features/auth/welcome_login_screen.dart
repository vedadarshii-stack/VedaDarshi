import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../home/home_placeholder_screen.dart';

/// Welcome/Login screen, matching the approved Figma "A3 · Welcome / Login"
/// (node 7:2) concept.
///
/// Offers phone-number sign-in (OTP), Google sign-in, or a guest pass-through
/// into the app. Reached from [LanguageSelectScreen]'s Continue button.
class WelcomeLoginScreen extends ConsumerStatefulWidget {
  const WelcomeLoginScreen({super.key});

  @override
  ConsumerState<WelcomeLoginScreen> createState() => _WelcomeLoginScreenState();
}

class _WelcomeLoginScreenState extends ConsumerState<WelcomeLoginScreen> {
  final _phoneController = TextEditingController();
  final _phoneFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
    _phoneFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _phoneFocusNode.removeListener(_onFocusChanged);
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _onPhoneChanged() => setState(() {});

  void _onFocusChanged() => setState(() {});

  bool get _isPhoneValid => _phoneController.text.length == 10;

  void _goToHome() {
    Navigator.of(context).pushReplacement<void, void>(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomePlaceholderScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  /// TODO-free interim handler: real Firebase phone-OTP verification is
  /// wired in M1 together with "A4 · OTP Verify" (Figma node 7:27). Until
  /// then this proceeds straight to Home, matching the same interim
  /// convention already used by [HomePlaceholderScreen]'s other entry
  /// points — no fake OTP flow, delay or mock auth state is introduced here.
  void _requestOtp() {
    if (!_isPhoneValid) return;
    _goToHome();
  }

  /// TODO-free interim handler: real Google sign-in is wired in M1 together
  /// with "A4 · OTP Verify" (Figma node 7:27). Until then this proceeds
  /// straight to Home, matching the same interim convention already used by
  /// [HomePlaceholderScreen]'s other entry points — no mock auth state is
  /// introduced here.
  void _continueWithGoogle() {
    _goToHome();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Hero(l10n: l10n, locale: locale),
                // Expanded (not a bare Padding) so the body column gets a
                // bounded height — the terms notice is pushed to the bottom
                // by a Spacer, which needs finite constraints to resolve.
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 36,
                      bottom: 32,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.welcomeGreeting,
                          style: AppFonts.heading(
                            locale,
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n.welcomeSubtitle,
                          style: AppFonts.body(
                            locale,
                            fontSize: 13,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _PhoneField(
                          l10n: l10n,
                          locale: locale,
                          controller: _phoneController,
                          focusNode: _phoneFocusNode,
                          onSubmitted: (_) => _requestOtp(),
                        ),
                        const SizedBox(height: 20),
                        _GetOtpButton(
                          l10n: l10n,
                          locale: locale,
                          enabled: _isPhoneValid,
                          onTap: _requestOtp,
                        ),
                        const SizedBox(height: 20),
                        _DividerRow(l10n: l10n, locale: locale),
                        const SizedBox(height: 20),
                        _GoogleButton(
                          l10n: l10n,
                          locale: locale,
                          onTap: _continueWithGoogle,
                        ),
                        const SizedBox(height: 20),
                        _GuestLink(
                          l10n: l10n,
                          locale: locale,
                          onTap: _goToHome,
                        ),
                        const Spacer(),
                        SafeArea(
                          top: false,
                          child: SizedBox(
                            width: double.infinity,
                            child: Text(
                              l10n.termsNotice,
                              textAlign: TextAlign.center,
                              style: AppFonts.body(
                                locale,
                                fontSize: 11,
                                color: AppColors.hint,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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

/// Section 1 — navy hero with the ॐ mark, wordmark and tagline. Deliberately
/// not wrapped in `SafeArea` so the navy gradient runs under the status bar.
class _Hero extends StatelessWidget {
  const _Hero({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.navyHeroGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Forced to the 'hi' locale because ॐ is Devanagari and has no
            // glyph in the Latin-only Poppins/Playfair faces.
            Text(
              'ॐ',
              style: AppFonts.body(
                const Locale('hi'),
                fontSize: 44,
                fontWeight: FontWeight.w600,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.appName,
              style: AppFonts.heading(
                locale,
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ).copyWith(letterSpacing: 0.6),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              // This tagline runs long in the Indic locales, so it is
              // allowed to wrap onto multiple lines rather than being
              // forced onto one.
              child: Text(
                l10n.welcomeHeroTagline,
                textAlign: TextAlign.center,
                style: AppFonts.body(
                  locale,
                  fontSize: 11,
                  color: AppColors.mutedOnNavy,
                  letterSpacing: 0.44,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section 2 — the phone number input, with a fixed "🇮🇳 +91" country-code
/// prefix and animated focus border.
class _PhoneField extends StatelessWidget {
  const _PhoneField({
    required this.l10n,
    required this.locale,
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final isFocused = focusNode.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFocused ? AppColors.saffron : AppColors.cardBorder,
          width: isFocused ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // The country code is deliberately NOT localised — it is a fixed
          // ISO dialing prefix, not user-facing prose.
          Text(
            '🇮🇳  +91',
            style: AppFonts.body(
              const Locale('en'),
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(width: 12),
          Container(width: 1, height: 22, color: AppColors.cardBorder),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textInputAction: TextInputAction.done,
              onSubmitted: onSubmitted,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                counterText: '',
                contentPadding: EdgeInsets.zero,
                hintText: l10n.phoneHint,
                hintStyle: AppFonts.body(
                  locale,
                  fontSize: 15,
                  color: AppColors.hint,
                ),
              ),
              // Digits are always Latin regardless of the active app locale.
              style: AppFonts.body(
                const Locale('en'),
                fontSize: 15,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section 3 — full-width "Get OTP" CTA, disabled until 10 digits are
/// entered. Shares the saffron-gradient pill recipe of the language select
/// screen's `_ContinueButton`.
class _GetOtpButton extends StatelessWidget {
  const _GetOtpButton({
    required this.l10n,
    required this.locale,
    required this.enabled,
    required this.onTap,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: l10n.getOtp,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.saffron.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled ? onTap : null,
            child: Ink(
              padding: const EdgeInsets.symmetric(vertical: 17),
              decoration: BoxDecoration(
                gradient: enabled ? AppColors.saffronGradient : null,
                color: enabled
                    ? null
                    : AppColors.saffron.withValues(alpha: 0.35),
              ),
              child: Center(
                child: Text(
                  l10n.getOtp,
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
      ),
    );
  }
}

/// Section 4 — "or continue with" hairline divider row.
class _DividerRow extends StatelessWidget {
  const _DividerRow({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: _HairlineDivider()),
        const SizedBox(width: 12),
        // Flexible so the longer Indic translations wrap instead of
        // overflowing the row.
        Flexible(
          child: Text(
            l10n.orContinueWith,
            textAlign: TextAlign.center,
            style: AppFonts.body(locale, fontSize: 12, color: AppColors.hint),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(child: _HairlineDivider()),
      ],
    );
  }
}

class _HairlineDivider extends StatelessWidget {
  const _HairlineDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: AppColors.divider);
  }
}

/// Section 5 — Google sign-in button.
class _GoogleButton extends StatelessWidget {
  const _GoogleButton({
    required this.l10n,
    required this.locale,
    required this.onTap,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: l10n.continueWithGoogle,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // The Google "G" wordmark is intentionally not localised —
                // it is a fixed brand mark, not user-facing prose.
                Text(
                  'G',
                  style: AppFonts.body(
                    const Locale('en'),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.googleBlue,
                  ),
                ),
                const SizedBox(width: 10),
                // Flexible so the longer Indic translations wrap instead of
                // overflowing the pill.
                Flexible(
                  child: Text(
                    l10n.continueWithGoogle,
                    textAlign: TextAlign.center,
                    style: AppFonts.body(
                      locale,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ink,
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

/// Section 6 — "Explore as Guest" link, bypassing sign-in.
class _GuestLink extends StatelessWidget {
  const _GuestLink({
    required this.l10n,
    required this.locale,
    required this.onTap,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: l10n.exploreAsGuest,
      // Full width so the label sits centred on the screen, not left-aligned
      // by the body column's CrossAxisAlignment.start.
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Flexible so the longer Indic translations wrap instead of
                // overflowing the row.
                Flexible(
                  child: Text(
                    l10n.exploreAsGuest,
                    textAlign: TextAlign.center,
                    style: AppFonts.body(
                      locale,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.saffron,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: AppColors.saffron,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
