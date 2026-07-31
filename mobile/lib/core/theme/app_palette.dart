import 'package:flutter/material.dart';

/// Light and dark counterparts of every [AppColors] member (`import
/// 'app_colors.dart'`) — this file owns the actual color VALUES, while
/// `app_colors.dart` owns the 639-call-site-stable NAMES that resolve to
/// whichever [AppPalette] is currently active (see
/// `AppColors.applyBrightness`).
///
/// [light] is the CURRENT palette, copied verbatim from the values that used
/// to live directly in `app_colors.dart` — nothing about light mode changes
/// here. [dark] is derived from it using these rules:
///
///  - **Brand accents stay identical** in both palettes: [saffron],
///    [saffronDark], [gold], [saffronGradient], [panchangGradient] (and its
///    [panchangOrange1]/[panchangOrange2]/[panchangOrange3] stops) and
///    [goldCtaGradient] — they're the app's identity and already read well
///    on a dark background. [googleBlue] is a third-party brand color (the
///    Google "G" wordmark) and is likewise fixed. A few already-light
///    accent tones that are only ever used ON TOP OF a fixed-color surface
///    ([creamText]/[creamTextSoft] on [panchangGradient], [quoteGold] on
///    [premiumDarkGradient], [onGold] on solid [gold], [goldBright] on
///    [paywallGradient]) are fixed too — their contrast partner doesn't
///    move, so there's nothing to re-derive (verified below).
///  - **Surfaces invert into the brand's own navy family** — never pure
///    black/grey. [cream] (the app-wide Scaffold background) becomes
///    `#0B0F19`; [chartPaper] (the one other "paper" surface) becomes the
///    slightly-lighter elevated-card tone `#161C2A`; borders
///    ([cardBorder]) become `#2A3346`.
///  - **Text inverts**: [ink] → `#F0F2F7` (near-white), [muted] → `#9BA3B8`,
///    [hint] → `#7A8296`.
///  - **Pale tinted tile backgrounds** (`tileXxxBg`, [mantraBg]/[warnBg]/
///    [ashubhBg]/[genderSelectedBg]/[terracottaBg]/[geoChipBg] and the warm
///    tinted borders [glanceBorder]/[mantraBorder]/[chipBorderWarm]/
///    [bridePinkBorder]/[aiCardBorder]/[notificationUnreadBorder]) keep
///    their hue but drop to ~12–18% lightness; their paired foregrounds
///    (`tileXxxFg`, [ashubhFg], [geoChipText], [mantraLabel]/[mantraBody]/
///    [mantraIcon], [genderSelectedText], [terracottaFg], [aiTitle]/
///    [aiBody]) brighten to ~68–82% lightness on the SAME hue so they clear
///    WCAG AA on their tinted dark background (see the contrast report
///    below — every pair lands well past 4.5:1, most 6:1+).
///  - **Navy gradients are already dark** ([navyGradient],
///    [navyHeroGradient], [navyGradientHorizontal], [navyGradientDiagonal],
///    [paywallGradient], [premiumDarkGradient], [aiAvatarGradient]) — kept,
///    but their [navyTop]/[navyBottom]/[navyHeroBottom] stops (and
///    [premiumDarkGradient]'s own two stops) are lifted a shade lighter in
///    dark mode so a navy hero still visibly separates from the near-black
///    `#0B0F19` page background instead of merging into it.
///    [horoscopeHeaderGradient] is deliberately EXCLUDED from that lift —
///    despite being grouped with the other "header" gradients, it's built
///    from [panchangOrange1]/[panchangOrange3] (the fixed brand orange),
///    not the navy family, so it stays identical for the same reason
///    [panchangGradient] does.
///
/// CONTRAST REPORT (WCAG relative-luminance ratio, computed with a
/// throwaway script against this exact palette, ≥4.5:1 required for body
/// text / ≥3:1 for large text — every pair below clears the bar with
/// margin, so nothing needed lightening beyond the values already baked in
/// here):
///  - ink-on-background 17.10 · muted-on-background 7.59 ·
///    hint-on-background 4.98 · ink-on-card 15.20
///  - tileBlueFg/Bg 6.03 · tileGoldFg/Bg 7.89 · tileGreenFg/Bg 8.41 ·
///    tilePurpleFg/Bg 6.40 · tileCyanFg/Bg 7.87 · tilePinkFg/Bg 6.31 ·
///    ashubhFg/Bg 6.05 · terracottaFg/Bg 6.92 · genderSelectedText/Bg 7.36
///  - geoChipText-on-geoChipBg 8.18 · mantraBody-on-mantraBg 8.23
///  - bubbleText-on-card 10.70 · quoteGold-on-premiumDark 8.06 (lighter
///    stop) / 12.54 (darker stop) · chartHouseNumber-on-chartPaper 9.63
abstract final class AppPalette {
  // ---------------------------------------------------------------------
  // LIGHT — verbatim copy of the pre-dark-mode values.
  // ---------------------------------------------------------------------

  static const Color _lightNavyTop = Color(0xFF22315E);
  static const Color _lightNavyBottom = Color(0xFF0C1329);
  static const Color _lightNavyHeroBottom = Color(0xFF101A3C);
  static const Color _lightPanchangOrange1 = Color(0xFFF0821E);
  static const Color _lightPanchangOrange2 = Color(0xFFD95F06);
  static const Color _lightPanchangOrange3 = Color(0xFFB84D02);
  static const Color _lightSaffronDark = Color(0xFFD95F06);
  static const Color _lightTilePurpleFg = Color(0xFF6B3FA0);

  static const AppColorSet light = AppColorSet(
    navyTop: _lightNavyTop,
    navyBottom: _lightNavyBottom,
    saffron: Color(0xFFE8720C),
    saffronDark: _lightSaffronDark,
    gold: Color(0xFFD4AF37),
    cream: Color(0xFFFDF8F1),
    ink: Color(0xFF1E2433),
    muted: Color(0xFF6E7385),
    cardBorder: Color(0xFFEFE7DB),
    navyHeroBottom: _lightNavyHeroBottom,
    mutedOnNavy: Color(0xFF8E97B5),
    hint: Color(0xFFA6AAB8),
    divider: Color(0xFFE5DCCB),
    googleBlue: Color(0xFF4285F4),
    otpBorderFilled: Color(0xFFD8CFC0),
    genderSelectedBg: Color(0xFFFDEBD9),
    genderSelectedText: Color(0xFFC25705),
    geoChipBg: Color(0xFFE9F6EF),
    geoChipText: Color(0xFF1E5B3F),
    panchangOrange1: _lightPanchangOrange1,
    panchangOrange2: _lightPanchangOrange2,
    panchangOrange3: _lightPanchangOrange3,
    creamText: Color(0xFFFFE3C4),
    creamTextSoft: Color(0xFFFFF3E3),
    glanceBorder: Color(0xFFEFD9B4),
    mantraBg: Color(0xFFF6EED3),
    mantraBorder: Color(0xFFEBDCB2),
    mantraLabel: Color(0xFFB07C1A),
    mantraBody: Color(0xFF6B5312),
    mantraIcon: Color(0xFF8C6D1F),
    tileBlueBg: Color(0xFFEAF0FB),
    tileBlueFg: Color(0xFF1F3C88),
    tileGoldBg: Color(0xFFF6EED3),
    tileGoldFg: Color(0xFF8C6D1F),
    tileGreenBg: Color(0xFFE9F6EF),
    tileGreenFg: Color(0xFF2E9E6B),
    tilePurpleBg: Color(0xFFF1EAFB),
    tilePurpleFg: _lightTilePurpleFg,
    tileCyanBg: Color(0xFFEAF6FB),
    tileCyanFg: Color(0xFF1A7A9E),
    tilePinkBg: Color(0xFFFBE9EE),
    tilePinkFg: Color(0xFFB0355C),
    bridePinkBorder: Color(0xFFF3D3DD),
    navInactive: Color(0xFF8A8FA0),
    navActiveText: Color(0xFFC2570A),
    quoteGold: Color(0xFFF3DE9E),
    quoteMuted: Color(0xFFC7B67B),
    ashubhBg: Color(0xFFFBEDED),
    ashubhFg: Color(0xFFD64545),
    warnBg: Color(0xFFFBF3E0),
    rowDivider: Color(0xFFF3EDE2),
    avoidText: Color(0xFF8A2F2F),
    chartPaper: Color(0xFFFFFDF8),
    chartLine: Color(0xFFC9A227),
    chartHouseNumber: Color(0xFFB8A15C),
    planetKetu: Color(0xFF4A5568),
    aiCardBorder: Color(0xFFDCCBF0),
    aiTitle: Color(0xFF4A2B73),
    aiBody: Color(0xFF4A3B60),
    matchSuccessText: Color(0xFF7BE0AE),
    headerSubtle: Color(0xFFC7CEE4),
    chipBorderWarm: Color(0xFFE8D9C0),
    bubbleText: Color(0xFF3A4155),
    onGold: Color(0xFF241C06),
    terracottaBg: Color(0xFFFBEFEA),
    terracottaFg: Color(0xFFB05A35),
    goldBright: Color(0xFFF2C94C),
    paywallFinePrint: Color(0xFF687190),
    remedyFg: Color(0xFF7A3E12),
    notificationUnreadBorder: Color(0xFFF3DCC3),
    navyGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [_lightNavyTop, _lightNavyBottom],
    ),
    navyHeroGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [_lightNavyTop, _lightNavyHeroBottom],
    ),
    saffronGradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFFF0821E), _lightSaffronDark],
    ),
    panchangGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        _lightPanchangOrange1,
        _lightPanchangOrange2,
        _lightPanchangOrange3,
      ],
      stops: [0.0, 0.43, 0.71],
    ),
    premiumDarkGradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFF3A2E11), Color(0xFF191405)],
    ),
    horoscopeHeaderGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [_lightPanchangOrange1, _lightPanchangOrange3],
      stops: [0.0, 0.714],
    ),
    aiAvatarGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [_lightTilePurpleFg, _lightNavyTop],
    ),
    navyGradientHorizontal: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [_lightNavyTop, _lightNavyBottom],
    ),
    paywallGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [_lightNavyTop, Color(0xFF141F42), _lightNavyBottom],
      stops: [0.0, 0.5, 1.0],
    ),
    goldCtaGradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFFE8C766), Color(0xFFC9A227)],
    ),
    navyGradientDiagonal: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [_lightNavyTop, _lightNavyBottom],
    ),
  );

  // ---------------------------------------------------------------------
  // DARK — derived per the rules documented above.
  // ---------------------------------------------------------------------

  // Navy family, lifted a shade lighter so hero gradients separate from the
  // near-black page background instead of merging into it.
  static const Color _darkNavyTop = Color(0xFF2E4076);
  static const Color _darkNavyBottom = Color(0xFF16214A);
  static const Color _darkNavyHeroBottom = Color(0xFF1B2A54);
  static const Color _darkPaywallMid = Color(0xFF1E2C52);

  // Brand oranges stay identical to light — see doc comment.
  static const Color _darkPanchangOrange1 = _lightPanchangOrange1;
  static const Color _darkPanchangOrange3 = _lightPanchangOrange3;

  // tilePurpleFg's dark value (brightened for text legibility) doubles as
  // one end of the decorative aiAvatarGradient, same reuse the light
  // palette uses.
  static const Color _darkTilePurpleFg = Color(0xFFAF90D5);

  static const AppColorSet dark = AppColorSet(
    navyTop: _darkNavyTop,
    navyBottom: _darkNavyBottom,
    saffron: Color(0xFFE8720C),
    saffronDark: _lightSaffronDark,
    gold: Color(0xFFD4AF37),
    cream: Color(0xFF0B0F19),
    ink: Color(0xFFF0F2F7),
    muted: Color(0xFF9BA3B8),
    cardBorder: Color(0xFF2A3346),
    navyHeroBottom: _darkNavyHeroBottom,
    mutedOnNavy: Color(0xFFC1C6D7),
    hint: Color(0xFF7A8296),
    divider: Color(0xFF242C40),
    googleBlue: Color(0xFF4285F4),
    otpBorderFilled: Color(0xFF3A445C),
    genderSelectedBg: Color(0xFF3B2611),
    genderSelectedText: Color(0xFFF4AA71),
    geoChipBg: Color(0xFF183525),
    geoChipText: Color(0xFF8ADBB6),
    panchangOrange1: _darkPanchangOrange1,
    panchangOrange2: _lightPanchangOrange2,
    panchangOrange3: _darkPanchangOrange3,
    creamText: Color(0xFFFFE3C4),
    creamTextSoft: Color(0xFFFFF3E3),
    glanceBorder: Color(0xFF614619),
    mantraBg: Color(0xFF3B3211),
    mantraBorder: Color(0xFF5E4D1D),
    mantraLabel: Color(0xFFEEC577),
    mantraBody: Color(0xFFECCD79),
    mantraIcon: Color(0xFFE6C97F),
    tileBlueBg: Color(0xFF11203B),
    tileBlueFg: Color(0xFF809CE5),
    tileGoldBg: Color(0xFF3B3211),
    tileGoldFg: Color(0xFFE6C97F),
    tileGreenBg: Color(0xFF183525),
    tileGreenFg: Color(0xFF86DFB6),
    tilePurpleBg: Color(0xFF23113B),
    tilePurpleFg: _darkTilePurpleFg,
    tileCyanBg: Color(0xFF112F3B),
    tileCyanFg: Color(0xFF79CDEC),
    tilePinkBg: Color(0xFF3B111D),
    tilePinkFg: Color(0xFFDE87A3),
    bridePinkBorder: Color(0xFF5D1E31),
    navInactive: Color(0xFFA5A9B6),
    navActiveText: Color(0xFFF7A164),
    quoteGold: Color(0xFFF3DE9E),
    quoteMuted: Color(0xFFD0C18B),
    ashubhBg: Color(0xFF3B1111),
    ashubhFg: Color(0xFFE67F7F),
    warnBg: Color(0xFF3B2F11),
    rowDivider: Color(0xFF202838),
    avoidText: Color(0xFFDC9393),
    chartPaper: Color(0xFF161C2A),
    chartLine: Color(0xFFE3C259),
    chartHouseNumber: Color(0xFFD2C293),
    planetKetu: Color(0xFFB4BCCB),
    aiCardBorder: Color(0xFF3B1F5C),
    aiTitle: Color(0xFFC9B4E4),
    aiBody: Color(0xFFC4B9D5),
    matchSuccessText: Color(0xFF98E7C0),
    headerSubtle: Color(0xFFC7CEE4),
    chipBorderWarm: Color(0xFF574424),
    bubbleText: Color(0xFFC8CDDA),
    onGold: Color(0xFF241C06),
    terracottaBg: Color(0xFF3B1E11),
    terracottaFg: Color(0xFFDEA187),
    goldBright: Color(0xFFF2C94C),
    paywallFinePrint: Color(0xFFB1B6C7),
    remedyFg: Color(0xFFEFAF80),
    notificationUnreadBorder: Color(0xFF623F18),
    navyGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [_darkNavyTop, _darkNavyBottom],
    ),
    navyHeroGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [_darkNavyTop, _darkNavyHeroBottom],
    ),
    saffronGradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFFF0821E), _lightSaffronDark],
    ),
    panchangGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        _darkPanchangOrange1,
        _lightPanchangOrange2,
        _darkPanchangOrange3,
      ],
      stops: [0.0, 0.43, 0.71],
    ),
    premiumDarkGradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFF4A3C1C), Color(0xFF241D0C)],
    ),
    horoscopeHeaderGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [_darkPanchangOrange1, _darkPanchangOrange3],
      stops: [0.0, 0.714],
    ),
    aiAvatarGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [_darkTilePurpleFg, _darkNavyTop],
    ),
    navyGradientHorizontal: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [_darkNavyTop, _darkNavyBottom],
    ),
    paywallGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [_darkNavyTop, _darkPaywallMid, _darkNavyBottom],
      stops: [0.0, 0.5, 1.0],
    ),
    goldCtaGradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFFE8C766), Color(0xFFC9A227)],
    ),
    navyGradientDiagonal: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [_darkNavyTop, _darkNavyBottom],
    ),
  );
}

/// One complete, immutable set of the 81 color/gradient values [AppColors]
/// exposes — [AppPalette.light] and [AppPalette.dark] are the only two
/// instances that should ever exist.
class AppColorSet {
  const AppColorSet({
    required this.navyTop,
    required this.navyBottom,
    required this.saffron,
    required this.saffronDark,
    required this.gold,
    required this.cream,
    required this.ink,
    required this.muted,
    required this.cardBorder,
    required this.navyHeroBottom,
    required this.mutedOnNavy,
    required this.hint,
    required this.divider,
    required this.googleBlue,
    required this.otpBorderFilled,
    required this.genderSelectedBg,
    required this.genderSelectedText,
    required this.geoChipBg,
    required this.geoChipText,
    required this.panchangOrange1,
    required this.panchangOrange2,
    required this.panchangOrange3,
    required this.creamText,
    required this.creamTextSoft,
    required this.glanceBorder,
    required this.mantraBg,
    required this.mantraBorder,
    required this.mantraLabel,
    required this.mantraBody,
    required this.mantraIcon,
    required this.tileBlueBg,
    required this.tileBlueFg,
    required this.tileGoldBg,
    required this.tileGoldFg,
    required this.tileGreenBg,
    required this.tileGreenFg,
    required this.tilePurpleBg,
    required this.tilePurpleFg,
    required this.tileCyanBg,
    required this.tileCyanFg,
    required this.tilePinkBg,
    required this.tilePinkFg,
    required this.bridePinkBorder,
    required this.navInactive,
    required this.navActiveText,
    required this.quoteGold,
    required this.quoteMuted,
    required this.ashubhBg,
    required this.ashubhFg,
    required this.warnBg,
    required this.rowDivider,
    required this.avoidText,
    required this.chartPaper,
    required this.chartLine,
    required this.chartHouseNumber,
    required this.planetKetu,
    required this.aiCardBorder,
    required this.aiTitle,
    required this.aiBody,
    required this.matchSuccessText,
    required this.headerSubtle,
    required this.chipBorderWarm,
    required this.bubbleText,
    required this.onGold,
    required this.terracottaBg,
    required this.terracottaFg,
    required this.goldBright,
    required this.paywallFinePrint,
    required this.remedyFg,
    required this.notificationUnreadBorder,
    required this.navyGradient,
    required this.navyHeroGradient,
    required this.saffronGradient,
    required this.panchangGradient,
    required this.premiumDarkGradient,
    required this.horoscopeHeaderGradient,
    required this.aiAvatarGradient,
    required this.navyGradientHorizontal,
    required this.paywallGradient,
    required this.goldCtaGradient,
    required this.navyGradientDiagonal,
  });

  final Color navyTop;
  final Color navyBottom;
  final Color saffron;
  final Color saffronDark;
  final Color gold;
  final Color cream;
  final Color ink;
  final Color muted;
  final Color cardBorder;
  final Color navyHeroBottom;
  final Color mutedOnNavy;
  final Color hint;
  final Color divider;
  final Color googleBlue;
  final Color otpBorderFilled;
  final Color genderSelectedBg;
  final Color genderSelectedText;
  final Color geoChipBg;
  final Color geoChipText;
  final Color panchangOrange1;
  final Color panchangOrange2;
  final Color panchangOrange3;
  final Color creamText;
  final Color creamTextSoft;
  final Color glanceBorder;
  final Color mantraBg;
  final Color mantraBorder;
  final Color mantraLabel;
  final Color mantraBody;
  final Color mantraIcon;
  final Color tileBlueBg;
  final Color tileBlueFg;
  final Color tileGoldBg;
  final Color tileGoldFg;
  final Color tileGreenBg;
  final Color tileGreenFg;
  final Color tilePurpleBg;
  final Color tilePurpleFg;
  final Color tileCyanBg;
  final Color tileCyanFg;
  final Color tilePinkBg;
  final Color tilePinkFg;
  final Color bridePinkBorder;
  final Color navInactive;
  final Color navActiveText;
  final Color quoteGold;
  final Color quoteMuted;
  final Color ashubhBg;
  final Color ashubhFg;
  final Color warnBg;
  final Color rowDivider;
  final Color avoidText;
  final Color chartPaper;
  final Color chartLine;
  final Color chartHouseNumber;
  final Color planetKetu;
  final Color aiCardBorder;
  final Color aiTitle;
  final Color aiBody;
  final Color matchSuccessText;
  final Color headerSubtle;
  final Color chipBorderWarm;
  final Color bubbleText;
  final Color onGold;
  final Color terracottaBg;
  final Color terracottaFg;
  final Color goldBright;
  final Color paywallFinePrint;
  final Color remedyFg;
  final Color notificationUnreadBorder;

  final LinearGradient navyGradient;
  final LinearGradient navyHeroGradient;
  final LinearGradient saffronGradient;
  final LinearGradient panchangGradient;
  final LinearGradient premiumDarkGradient;
  final LinearGradient horoscopeHeaderGradient;
  final LinearGradient aiAvatarGradient;
  final LinearGradient navyGradientHorizontal;
  final LinearGradient paywallGradient;
  final LinearGradient goldCtaGradient;
  final LinearGradient navyGradientDiagonal;
}
