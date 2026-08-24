import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/auth/auth_service.dart';
import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../profile/post_sign_in_route.dart';
import 'auth_error_messages.dart';
import 'auth_widgets.dart';
import 'email_sign_up_screen.dart';
import 'forgot_password_screen.dart';

/// Welcome/Login screen, matching the approved Figma "A3 · Welcome / Login"
/// (node 7:2) concept.
///
/// Offers email/password sign-in, Google sign-in, or a guest pass-through
/// into the app. Reached from [LanguageSelectScreen]'s Continue button.
class WelcomeLoginScreen extends ConsumerStatefulWidget {
  const WelcomeLoginScreen({super.key});

  @override
  ConsumerState<WelcomeLoginScreen> createState() => _WelcomeLoginScreenState();
}

class _WelcomeLoginScreenState extends ConsumerState<WelcomeLoginScreen> {
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _isSigningIn = false;
  bool _isGoogleLoading = false;
  bool _isGuestLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onFieldChanged);
    _emailFocusNode.addListener(_onFieldChanged);
    _passwordController.addListener(_onFieldChanged);
    _passwordFocusNode.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onFieldChanged);
    _emailFocusNode.removeListener(_onFieldChanged);
    _passwordController.removeListener(_onFieldChanged);
    _passwordFocusNode.removeListener(_onFieldChanged);
    _emailController.dispose();
    _emailFocusNode.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  bool get _isAnyLoading =>
      _isSigningIn || _isGoogleLoading || _isGuestLoading;

  void _onFieldChanged() => setState(() {});

  bool get _isEmailValid => _emailController.text.contains('@');

  bool get _isPasswordValid => _passwordController.text.length >= 6;

  Future<void> _signIn() async {
    if (!_isEmailValid || !_isPasswordValid || _isAnyLoading) return;
    final l10n = AppLocalizations.of(context)!;
    final authService = ref.read(authServiceProvider);
    setState(() => _isSigningIn = true);
    try {
      await authService.signInWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      await navigateAfterSignIn(context, ref);
    } on AuthException catch (e) {
      if (!mounted) return;
      final message = authErrorMessage(l10n, e.code);
      if (message != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
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
      await navigateAfterSignIn(context, ref);
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
        await navigateAfterSignIn(context, ref);
      }
    }
  }

  void _goToForgotPassword() {
    Navigator.of(context).push<void>(fadeThroughRoute(const ForgotPasswordScreen()));
  }

  void _goToSignUp() {
    Navigator.of(context).push<void>(fadeThroughRoute(const EmailSignUpScreen()));
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
                        AuthTextField(
                          locale: locale,
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          enabled: !_isAnyLoading,
                          hintText: l10n.emailHint,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) =>
                              FocusScope.of(context).requestFocus(_passwordFocusNode),
                        ),
                        SizedBox(height: bodyGap),
                        AuthTextField(
                          locale: locale,
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          enabled: !_isAnyLoading,
                          hintText: l10n.passwordHint,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _signIn(),
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            color: AppColors.hint,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            visualDensity: VisualDensity.compact,
                            splashRadius: 20,
                          ),
                        ),
                        SizedBox(height: bodyGap),
                        AuthPrimaryButton(
                          locale: locale,
                          label: l10n.signInAction,
                          enabled:
                              _isEmailValid && _isPasswordValid && !_isAnyLoading,
                          loading: _isSigningIn,
                          onTap: _signIn,
                        ),
                        SizedBox(height: bodyGap * 0.6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: _isAnyLoading ? null : _goToForgotPassword,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                l10n.forgotPassword,
                                style: AppFonts.body(
                                  locale,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.saffron,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: bodyGap * 0.6),
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
                          child: Column(
                            children: [
                              SizedBox(
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
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      l10n.noAccountPrompt,
                                      textAlign: TextAlign.center,
                                      style: AppFonts.body(
                                        locale,
                                        fontSize: 13,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: _isAnyLoading ? null : _goToSignUp,
                                    child: Text(
                                      l10n.createAccount,
                                      style: AppFonts.body(
                                        locale,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.saffron,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
  const _Hero({
    required this.l10n,
    required this.locale,
    required this.heroHeight,
  });

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
      decoration: BoxDecoration(
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
        color: AppColors.surface,
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
                  ? [
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
                  SizedBox(
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
                  Icon(Icons.arrow_forward, size: 16, color: AppColors.saffron),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
