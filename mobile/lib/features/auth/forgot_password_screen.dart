import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/auth/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../l10n/app_localizations.dart';
import 'auth_error_messages.dart';
import 'auth_widgets.dart';

/// Forgot-password screen, reached from [WelcomeLoginScreen]'s "Forgot
/// password?" link.
///
/// Collects an email address and requests a Firebase password-reset email.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onFieldChanged);
    _emailFocusNode.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onFieldChanged);
    _emailFocusNode.removeListener(_onFieldChanged);
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _onFieldChanged() => setState(() {});

  bool get _isEmailValid => _emailController.text.contains('@');

  Future<void> _sendResetLink() async {
    if (!_isEmailValid || _isSubmitting) return;
    final l10n = AppLocalizations.of(context)!;
    final authService = ref.read(authServiceProvider);
    setState(() => _isSubmitting = true);
    try {
      await authService.sendPasswordResetEmail(email: _emailController.text);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.resetLinkSent)));
      Navigator.of(context).pop();
    } on AuthException catch (e) {
      if (!mounted) return;
      // Never reveal whether an email is actually registered — an attacker
      // could otherwise use this screen to enumerate valid accounts by
      // checking which addresses produce an error vs. a success message.
      // So a "no such user" failure gets the exact same success
      // confirmation, and the exact same pop, as a real send.
      if (e.code == AuthErrorCode.userNotFound) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.resetLinkSent)));
        Navigator.of(context).pop();
        return;
      }
      final message = authErrorMessage(l10n, e.code);
      if (message != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
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
          l10n.forgotPasswordTitle,
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
              Text(
                l10n.forgotPasswordSubtitle,
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
                enabled: !_isSubmitting,
                hintText: l10n.emailHint,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _sendResetLink(),
              ),
              SizedBox(height: bodyGap),
              AuthPrimaryButton(
                locale: locale,
                label: l10n.sendResetLink,
                enabled: _isEmailValid && !_isSubmitting,
                loading: _isSubmitting,
                onTap: _sendResetLink,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
