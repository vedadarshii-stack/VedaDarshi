import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/auth/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../home/home_placeholder_screen.dart';
import 'auth_error_messages.dart';
import 'otp_verify_screen.dart';

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

  bool _isSendingOtp = false;
  bool _isGoogleLoading = false;
  bool _isGuestLoading = false;

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

  bool get _isAnyLoading =>
      _isSendingOtp || _isGoogleLoading || _isGuestLoading;

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

  void _goToOtpVerify(String phoneE164, PhoneCodeSent sent) {
    Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) =>
            OtpVerifyScreen(
              phoneE164: phoneE164,
              verificationId: sent.verificationId,
              resendToken: sent.resendToken,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Future<void> _requestOtp() async {
    if (!_isPhoneValid || _isAnyLoading) return;
    final l10n = AppLocalizations.of(context)!;
    final authService = ref.read(authServiceProvider);
    setState(() => _isSendingOtp = true);
    final phoneE164 = '+91${_phoneController.text}';
    try {
      final sent = await authService.sendOtp(phoneE164: phoneE164);
      if (!mounted) return;
      if (sent.autoVerified) {
        // Android instant verification already signed the user in — skip
        // the OTP entry screen entirely.
        _goToHome();
      } else {
        _goToOtpVerify(phoneE164, sent);
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      final message = authErrorMessage(l10n, e.code);
      if (message != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _isSendingOtp = false);
    }
  }

  Future<void> _continueWithGoogle() async {
    if (_isAnyLoading) return;
    final l10n = AppLocalizations.of(context)!;
    final authService = ref.read(authServiceProvider);
    setState(() => _isGoogleLoading = true);
    try {
      await authService.signInWithGoogle();
      if (!mounted) return;
      _goToHome();
    } on AuthException catch (e) {
      if (!mounted) return;
      // A user-cancelled Google sign-in (they closed the account picker)
      // isn't a real failure, so authErrorMessage returns null and no
      // snackbar is shown.
      final message = authErrorMessage(l10n, e.code);
      if (message != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  Future<void> _continueAsGuest() async {
    if (_isAnyLoading) return;
    final authService = ref.read(authServiceProvider);
    setState(() => _isGuestLoading = true);
    try {
      await authService.signInAnonymously();
    } on AuthException {
      // Guest browsing is account-less by definition — even if anonymous
      // sign-in fails (e.g. no network), still let the user into the app
      // rather than blocking them behind an auth error.
    } finally {
      if (mounted) {
        setState(() => _isGuestLoading = false);
        _goToHome();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    // The hero and body spacing scale with screen height so the hero
    // doesn't eat too much of the screen on short/compact phones, while
    // taller screens keep the original Figma proportions (300px hero /
    // generous spacing).
    final screenHeight = MediaQuery.sizeOf(context).height;
    final heroHeight = (screenHeight * 0.32).clamp(200.0, 300.0);
    final isCompact = screenHeight < 840;
    final bodyTopPadding = isCompact ? 24.0 : 36.0;
    final bodyGap = isCompact ? 14.0 : 20.0;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Hero(l10n: l10n, locale: locale, heroHeight: heroHeight),
                // Expanded (not a bare Padding) so the body column gets a
                // bounded height — the terms notice is pushed to the bottom
                // by a Spacer, which needs finite constraints to resolve.
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: bodyTopPadding,
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
                        SizedBox(height: bodyGap),
                        Text(
                          l10n.welcomeSubtitle,
                          style: AppFonts.body(
                            locale,
                            fontSize: 13,
                            color: AppColors.muted,
                          ),
                        ),
                        SizedBox(height: bodyGap),
                        _PhoneField(
                          l10n: l10n,
                          locale: locale,
                          controller: _phoneController,
                          focusNode: _phoneFocusNode,
                          enabled: !_isAnyLoading,
                          onSubmitted: (_) => _requestOtp(),
                        ),
                        SizedBox(height: bodyGap),
                        _GetOtpButton(
                          l10n: l10n,
                          locale: locale,
                          enabled: _isPhoneValid && !_isAnyLoading,
                          loading: _isSendingOtp,
                          onTap: _requestOtp,
                        ),
                        SizedBox(height: bodyGap),
                        _DividerRow(l10n: l10n, locale: locale),
                        SizedBox(height: bodyGap),
                        _GoogleButton(
                          l10n: l10n,
                          locale: locale,
                          enabled: !_isAnyLoading,
                          loading: _isGoogleLoading,
                          onTap: _continueWithGoogle,
                        ),
                        SizedBox(height: bodyGap),
                        _GuestLink(
                          l10n: l10n,
                          locale: locale,
                          enabled: !_isAnyLoading,
                          loading: _isGuestLoading,
                          onTap: _continueAsGuest,
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
  const _Hero({required this.l10n, required this.locale, required this.heroHeight});

  final AppLocalizations l10n;
  final Locale locale;

  /// Height of the hero, scaled by the parent from screen height (clamped
  /// 200–300px) so it doesn't dominate short/compact screens.
  final double heroHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: heroHeight,
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
                fontSize: heroHeight >= 280 ? 44 : 36,
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
    required this.enabled,
    required this.onSubmitted,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
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
              enabled: enabled,
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
    required this.loading,
    required this.onTap,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final bool enabled;
  final bool loading;
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
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
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
    required this.enabled,
    required this.loading,
    required this.onTap,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: l10n.continueWithGoogle,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
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
              children: loading
                  ? const [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.saffron,
                          ),
                        ),
                      ),
                    ]
                  : [
                      // The Google "G" wordmark is intentionally not
                      // localised — it is a fixed brand mark, not
                      // user-facing prose.
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
                      // Flexible so the longer Indic translations wrap
                      // instead of overflowing the pill.
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
    required this.enabled,
    required this.loading,
    required this.onTap,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: l10n.exploreAsGuest,
      // Full width so the label sits centred on the screen, not left-aligned
      // by the body column's CrossAxisAlignment.start.
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
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
                if (loading)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.saffron,
                      ),
                    ),
                  )
                else
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
