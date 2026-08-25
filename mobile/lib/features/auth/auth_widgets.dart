import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';

/// Shared input styling for the auth screens (Welcome/Login, Create
/// Account, Reset Password) — the same container decoration, radius and
/// animated saffron focus border the old phone field used, generalized for
/// email/password inputs and shared across every screen that needs one
/// instead of being copy-pasted per screen.
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.locale,
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.suffixIcon,
  });

  final Locale locale;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  /// Optional trailing widget (e.g. the password visibility toggle).
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final isFocused = focusNode.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      // HEIGHT IS SET BY A minHeight, NOT BY VERTICAL PADDING — 24 Aug 2026.
      // With `vertical: 16` padding the password field rendered ~28dp taller
      // than the email field, because a suffix `IconButton` keeps Material
      // 3's 48dp minimum tap target even when handed `padding: zero` +
      // `constraints: BoxConstraints()` (those are honoured on the M2 path
      // only). So the row was 48 + 32 = 80dp, against ~52dp for a plain
      // field, and the two inputs visibly disagreed.
      //
      // A minHeight instead means every field — suffix or not — settles at
      // the same 56dp, since 48dp of icon still fits inside it. It stays a
      // MINIMUM rather than a fixed `height:` so the field can still grow
      // for large system font scales instead of clipping the text.
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFocused ? AppColors.saffron : AppColors.cardBorder,
          width: isFocused ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              enabled: enabled,
              obscureText: obscureText,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              onSubmitted: onSubmitted,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: hintText,
                hintStyle: AppFonts.body(
                  locale,
                  fontSize: 15,
                  color: AppColors.hint,
                ),
              ),
              style: AppFonts.body(locale, fontSize: 15, color: AppColors.ink),
            ),
          ),
          if (suffixIcon != null) ...[const SizedBox(width: 8), suffixIcon!],
        ],
      ),
    );
  }
}

/// Shared full-width saffron-gradient CTA pill for the auth screens, with a
/// loading-spinner state and a disabled state. Reuses the exact visual
/// recipe of the old "Get OTP" button.
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.locale,
    required this.label,
    required this.enabled,
    required this.loading,
    required this.onTap,
  });

  final Locale locale;
  final String label;
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
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
                        label,
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
