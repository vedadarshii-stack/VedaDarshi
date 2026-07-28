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

  static const LinearGradient navyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [navyTop, navyBottom],
  );
}
