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

  /// Selected-pill background/text for the gender picker on the Birth
  /// Details screen — see "A5 · Birth Details Setup" (Figma node 8:2).
  static const Color genderSelectedBg = Color(0xFFFDEBD9);
  static const Color genderSelectedText = Color(0xFFC25705);

  /// Geo-detected chip background/text shown once a birth city is selected
  /// — see "A5 · Birth Details Setup" (Figma node 8:2).
  static const Color geoChipBg = Color(0xFFE9F6EF);
  static const Color geoChipText = Color(0xFF1E5B3F);

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

  // --- Home Dashboard — see "B1 · Home Dashboard" (Figma node 10:3) ---

  static const Color panchangOrange1 = Color(0xFFF0821E);
  static const Color panchangOrange2 = Color(0xFFD95F06);
  static const Color panchangOrange3 = Color(0xFFB84D02);

  /// Background gradient of the Panchang hero card on Home.
  static const LinearGradient panchangGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [panchangOrange1, panchangOrange2, panchangOrange3],
    stops: [0.0, 0.43, 0.71],
  );

  /// Cream text tones used on top of [panchangGradient].
  static const Color creamText = Color(0xFFFFE3C4);
  static const Color creamTextSoft = Color(0xFFFFF3E3);

  /// Border color of the "Today at a glance" tiles.
  static const Color glanceBorder = Color(0xFFEFD9B4);

  /// Remedy/mantra card colors.
  static const Color mantraBg = Color(0xFFF6EED3);
  static const Color mantraBorder = Color(0xFFEBDCB2);
  static const Color mantraLabel = Color(0xFFB07C1A);
  static const Color mantraBody = Color(0xFF6B5312);
  static const Color mantraIcon = Color(0xFF8C6D1F);

  /// Tinted background/foreground pairs shared by the glance tiles, explore
  /// tiles and recent-report tiles on Home.
  static const Color tileBlueBg = Color(0xFFEAF0FB);
  static const Color tileBlueFg = Color(0xFF1F3C88);
  static const Color tileGoldBg = Color(0xFFF6EED3);
  static const Color tileGoldFg = Color(0xFF8C6D1F);
  static const Color tileGreenBg = Color(0xFFE9F6EF);
  static const Color tileGreenFg = Color(0xFF2E9E6B);
  static const Color tilePurpleBg = Color(0xFFF1EAFB);
  static const Color tilePurpleFg = Color(0xFF6B3FA0);
  static const Color tileCyanBg = Color(0xFFEAF6FB);
  static const Color tileCyanFg = Color(0xFF1A7A9E);
  static const Color tilePinkBg = Color(0xFFFBE9EE);
  static const Color tilePinkFg = Color(0xFFB0355C);

  /// Bottom nav colors.
  static const Color navInactive = Color(0xFF8A8FA0);
  static const Color navActiveText = Color(0xFFC2570A);

  /// Daily Quote card text tones.
  static const Color quoteGold = Color(0xFFF3DE9E);
  static const Color quoteMuted = Color(0xFFC7B67B);

  // --- Panchang — see "B2 · Panchang" (Figma node 14:2) ---
  //
  // NOTE: the design's shubh (auspicious) green and amber tones are already
  // covered by existing tokens — [geoChipBg]/[tileGreenFg] (#E9F6EF/#2E9E6B)
  // and [mantraLabel] (#B07C1A) respectively — so they're reused directly on
  // the Muhurat cards rather than duplicated here.

  /// Ashubh (inauspicious) muhurat card background/foreground.
  static const Color ashubhBg = Color(0xFFFBEDED);
  static const Color ashubhFg = Color(0xFFD64545);

  /// Caution muhurat card background (foreground reuses [mantraLabel]).
  static const Color warnBg = Color(0xFFFBF3E0);

  /// Hairline divider between rows in the Panchang elements card.
  static const Color rowDivider = Color(0xFFF3EDE2);
}
