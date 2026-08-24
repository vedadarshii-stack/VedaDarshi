import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/auth/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../profile/post_sign_in_route.dart';
import 'auth_error_messages.dart';
import 'auth_widgets.dart';

/// Email sign-up screen, reached from [WelcomeLoginScreen]'s "Create
/// account" link.
///
/// Collects email + password + confirm-password, validates them
/// client-side (before ever calling Firebase), creates the account, and
/// hands off to `navigateAfterSignIn` — the same shared post-sign-in
/// routing [WelcomeLoginScreen] uses.
class EmailSignUpScreen extends ConsumerStatefulWidget {
  const EmailSignUpScreen({super.key});

  @override
  ConsumerState<EmailSignUpScreen> createState() => _EmailSignUpScreenState();
}

class _EmailSignUpScreenState extends ConsumerState<EmailSignUpScreen> {
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordController = TextEditingController();
  final _confirmPasswordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onFieldChanged);
    _emailFocusNode.addListener(_onFieldChanged);
    _passwordController.addListener(_onFieldChanged);
    _passwordFocusNode.addListener(_onFieldChanged);
    _confirmPasswordController.addListener(_onFieldChanged);
    _confirmPasswordFocusNode.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onFieldChanged);
    _emailFocusNode.removeListener(_onFieldChanged);
    _passwordController.removeListener(_onFieldChanged);
    _passwordFocusNode.removeListener(_onFieldChanged);
    _confirmPasswordController.removeListener(_onFieldChanged);
    _confirmPasswordFocusNode.removeListener(_onFieldChanged);
    _emailController.dispose();
    _emailFocusNode.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordController.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _onFieldChanged() => setState(() {});

  bool get _isEmailValid => _emailController.text.contains('@');

  bool get _canSubmit =>
      _isEmailValid &&
      _passwordController.text.isNotEmpty &&
      _confirmPasswordController.text.isNotEmpty &&
      !_isSubmitting;

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _signUp() async {
    if (!_canSubmit) return;
    final l10n = AppLocalizations.of(context)!;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Client-side validation BEFORE ever calling Firebase.
    if (password.length < 6) {
      _showSnack(l10n.passwordTooShort);
      return;
    }
    if (password != confirmPassword) {
      _showSnack(l10n.passwordsDoNotMatch);
      return;
    }

    final authService = ref.read(authServiceProvider);
    setState(() => _isSubmitting = true);
    try {
      await authService.signUpWithEmail(
        email: _emailController.text,
        password: password,
      );
      if (!mounted) return;
      await navigateAfterSignIn(context, ref);
    } on AuthException catch (e) {
      if (!mounted) return;
      final message = authErrorMessage(l10n, e.code);
      if (message != null) _showSnack(message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    // RESPONSIVE RULE: size off screen height and wrap the body in a scroll
    // view, so the longer Indic-language strings can never overflow on a
    // compact device.
    final screenHeight = MediaQuery.sizeOf(context).height;
    final isCompact = screenHeight < 840;
    final bodyGap = isCompact ? 14.0 : 20.0;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: Text(
          l10n.signUpTitle,
          style: AppFonts.heading(
            locale,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, bodyGap, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthTextField(
                locale: locale,
                controller: _emailController,
                focusNode: _emailFocusNode,
                enabled: !_isSubmitting,
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
                enabled: !_isSubmitting,
                hintText: l10n.passwordHint,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => FocusScope.of(
                  context,
                ).requestFocus(_confirmPasswordFocusNode),
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
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
              AuthTextField(
                locale: locale,
                controller: _confirmPasswordController,
                focusNode: _confirmPasswordFocusNode,
                enabled: !_isSubmitting,
                hintText: l10n.confirmPasswordHint,
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _signUp(),
                suffixIcon: IconButton(
                  onPressed: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  ),
                  icon: Icon(
                    _obscureConfirmPassword
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
                label: l10n.createAccount,
                enabled: _canSubmit,
                loading: _isSubmitting,
                onTap: _signUp,
              ),
              SizedBox(height: bodyGap),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      l10n.haveAccountPrompt,
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
                    onTap: () => Navigator.of(context).pop(),
                    child: Text(
                      l10n.signInAction,
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
      ),
    );
  }
}
