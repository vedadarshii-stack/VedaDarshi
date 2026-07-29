import 'package:flutter/material.dart';

/// Brand color palette approved in the "🪔 Brand — Logo" Figma page.
///
/// Centralizing colors here keeps the navy/saffron/gold brand identity
/// consistent across the splash screen, launcher icon and future feature UI.
abstract final class AppColors {
  static const Color navyTop = Color(0xFF22315E);
  static const Color navyBottom = Color(0xFF0C1329);
  static const Color saffron = Color(0xFFE8720C);
  static const Color saffronDark = Color(0xFFD95F06);
  static const Color gold = Color(0xFFD4AF37);
  static const Color cream = Color(0xFFFDF8F1);
  static const Color ink = Color(0xFF1E2433);
  static const Color muted = Color(0xFF6E7385);

  /// Border color for unselected cards (e.g. the language-select cards).
  static const Color cardBorder = Color(0xFFEFE7DB);

  /// Bottom stop of the Welcome/Login hero gradient — slightly darker than
  /// [navyBottom] per the approved "A3 · Welcome / Login" design.
  static const Color navyHeroBottom = Color(0xFF101A3C);

  /// Secondary/muted text rendered on top of the navy hero.
  static const Color mutedOnNavy = Color(0xFF8E97B5);

  /// Placeholder/hint text and fine print (e.g. phone input hint, terms
  /// notice).
  static const Color hint = Color(0xFFA6AAB8);

  /// Hairline rule color (section dividers, the Google button border).
  static const Color divider = Color(0xFFE5DCCB);

  /// Google brand blue, used for the "G" wordmark on the Google sign-in
  /// button.
  static const Color googleBlue = Color(0xFF4285F4);

  /// Border color of an OTP box that already has a digit typed into it (but
  /// isn't currently focused) — see "A4 · OTP Verify" (Figma node 7:27).
  static const Color otpBorderFilled = Color(0xFFD8CFC0);

  static const LinearGradient navyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [navyTop, navyBottom],
  );

  /// Welcome/Login hero gradient — same top stop as [navyGradient] but a
  /// slightly darker bottom stop ([navyHeroBottom]) per the approved design.
  static const LinearGradient navyHeroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [navyTop, navyHeroBottom],
  );

  /// Primary saffron CTA gradient (splash "Get Started", language "Continue").
  static const LinearGradient saffronGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFF0821E), saffronDark],
  );
}
