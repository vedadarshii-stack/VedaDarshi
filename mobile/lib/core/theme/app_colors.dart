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

  /// Border color of the bride-side heart divider circle on the Gun Milan
  /// select screen — see "C1 · Gun Milan — Select" (Figma node 19:3).
  static const Color bridePinkBorder = Color(0xFFF3D3DD);

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

  // --- Horoscope Detail — see "B4 · Horoscope Detail" (Figma node 16:2) ---

  /// "Avoid time" value text on the Horoscope Detail screen.
  static const Color avoidText = Color(0xFF8A2F2F);

  /// Dark premium-card gradient (Home's Daily Quote card, Horoscope Detail's
  /// premium teaser) — extracted here so both screens share one definition
  /// instead of duplicating the same literal gradient.
  static const LinearGradient premiumDarkGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF3A2E11), Color(0xFF191405)],
  );

  /// Horoscope Detail header gradient — reuses [panchangOrange1]/
  /// [panchangOrange3] rather than introducing new orange literals.
  static const LinearGradient horoscopeHeaderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [panchangOrange1, panchangOrange3],
    stops: [0.0, 0.714],
  );

  // --- Kundli Chart — see "B6 · Kundli Chart" (Figma node 18:2) ---
  //
  // NOTE: most planet colors on the chart REUSE existing tokens rather than
  // duplicating them — [genderSelectedText] (Ascendant), [tileBlueFg]
  // (Sun/Mercury/Moon/Venus + the header's PDF pill), [tileGreenFg]
  // (Jupiter), [ashubhFg] (Mars), [tilePurpleFg] (Saturn), [muted] (Rahu),
  // and [mantraLabel] (Sun's swatch specifically in the KEY PLANETS legend
  // — see `PlanetCode.legendColor`'s doc comment for why that one differs
  // from the chart's own Sun color). Only the 4 below are genuinely new.

  /// Fill color of the North Indian chart's square background.
  static const Color chartPaper = Color(0xFFFFFDF8);

  /// Stroke color of the chart's square border, diagonals and diamond.
  static const Color chartLine = Color(0xFFC9A227);

  /// Color of the house-number labels (1–12) inside the chart.
  static const Color chartHouseNumber = Color(0xFFB8A15C);

  /// Ketu's planet-label/legend color — the only planet with no existing
  /// tinted-token match among the reused colors above.
  static const Color planetKetu = Color(0xFF4A5568);

  // --- Gun Milan Result — see "C2 · Gun Milan — Result" (Figma node 20:2) ---
  //
  // NOTE: several of the design's tinted pairs are already covered by
  // existing tokens rather than duplicated here — [tileGreenFg] (strong
  // gunas + the verdict pill), [warnBg]/[mantraLabel] (moderate gunas, incl.
  // the Nadi card, and the Nadi warning banner), [ashubhBg]/[ashubhFg] (weak
  // gunas), [tileBlueFg] (the CTA fill), [tilePurpleBg] (the AI summary
  // card), [tileGoldFg], [cardBorder], [cream], [ink], [hint] and
  // [mutedOnNavy]. Only the 5 below are genuinely new.

  /// Border color of the Rishi AI summary card.
  static const Color aiCardBorder = Color(0xFFDCCBF0);

  /// Title text color inside the Rishi AI summary card.
  static const Color aiTitle = Color(0xFF4A2B73);

  /// Body text color inside the Rishi AI summary card.
  static const Color aiBody = Color(0xFF4A3B60);

  /// Verdict-pill check icon/text color on the navy header (brighter than
  /// [tileGreenFg] so it reads clearly on the dark background).
  static const Color matchSuccessText = Color(0xFF7BE0AE);

  /// Muted couple-names line on the navy header.
  static const Color headerSubtle = Color(0xFFC7CEE4);

  // --- AI Astrologer — see "C3 · AI Astrologer" (Figma node 21:2) ---

  /// Warm border color of the suggestion chips on the AI Astrologer chat.
  static const Color chipBorderWarm = Color(0xFFE8D9C0);

  /// Assistant chat-bubble body text color.
  static const Color bubbleText = Color(0xFF3A4155);

  /// 135° purple→navy gradient behind the Rishi AI avatar — reused by both
  /// Home's "Continue with Rishi AI" card icon and the AI Astrologer header
  /// avatar, so it's defined once here rather than duplicated per screen.
  static const LinearGradient aiAvatarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [tilePurpleFg, navyTop],
  );

  // --- Premium Reports — see "C4 · Premium Reports" (Figma node 22:2) ---
  //
  // NOTE: most of this screen reuses existing tokens rather than duplicating
  // them — [gold], [quoteGold], [quoteMuted], [rowDivider], [tileBlueBg]/
  // [tileBlueFg], [tilePurpleBg]/[tilePurpleFg], [tilePinkBg]/[tilePinkFg],
  // [geoChipBg]/[tileGreenFg], [mantraBg]/[tileGoldFg], [tileCyanBg]/
  // [tileCyanFg], [genderSelectedText], [cardBorder], [cream], [ink],
  // [muted], [hint] and [saffron]. Only the 3 below are genuinely new.

  /// Text color for content rendered ON TOP OF a solid [gold] fill (e.g. the
  /// "Upgrade" pill label) — [gold] is too light for white text to read
  /// well against it.
  static const Color onGold = Color(0xFF241C06);

  /// Terracotta tinted background/foreground pair for the Numerology report
  /// tile — the one report tile color pairing not already covered by an
  /// existing tile* token.
  static const Color terracottaBg = Color(0xFFFBEFEA);
  static const Color terracottaFg = Color(0xFFB05A35);

  /// Left→right variant of [navyGradient] for the Go Premium banner — same
  /// navy stops, different axis, so it's a small addition rather than an
  /// inlined literal gradient.
  static const LinearGradient navyGradientHorizontal = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [navyTop, navyBottom],
  );

  // --- Subscription Paywall — see "C5 · Subscription Paywall" (Figma node 23:2) ---
  //
  // NOTE: most of this screen reuses existing tokens rather than duplicating
  // them — [gold], [quoteGold], [onGold], [mutedOnNavy], [headerSubtle],
  // [navyTop] and [navyBottom]. Only the 4 below are genuinely new.

  /// 3-stop navy gradient behind the whole paywall screen — distinct from
  /// [navyGradient] (2-stop) because the design calls for a mid-tone stop at
  /// 50% rather than a straight top→bottom blend.
  static const LinearGradient paywallGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [navyTop, Color(0xFF141F42), navyBottom],
    stops: [0.0, 0.5, 1.0],
  );

  /// Gold CTA gradient for the paywall's "Start Premium" button.
  static const LinearGradient goldCtaGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFE8C766), Color(0xFFC9A227)],
  );

  /// Brighter gold used for the selected plan card's 2px border — [gold] on
  /// its own reads too muted against the [paywallGradient] backdrop.
  static const Color goldBright = Color(0xFFF2C94C);

  /// Fine-print text color at the bottom of the paywall (billing terms).
  static const Color paywallFinePrint = Color(0xFF687190);

  // --- Articles — see "D1 · Articles" (Figma node 25:3) + "D2 · Article
  // Detail" (Figma node 26:2) ---
  //
  // NOTE: most of this screen reuses existing tokens rather than duplicating
  // them — [gold], [onGold], [cardBorder], [cream], [ink], [muted], [hint],
  // [saffron], [mutedOnNavy], [tileBlueBg]/[tileBlueFg], [tilePurpleBg]/
  // [tilePurpleFg], [tileGreenBg]/[tileGreenFg], [tileCyanBg]/[tileCyanFg],
  // [terracottaBg]/[terracottaFg], [genderSelectedBg]/[genderSelectedText],
  // [mantraBg], [mantraBody], [chartLine], [bubbleText] and
  // [otpBorderFilled]. Only the 2 below are genuinely new.

  /// Icon/foreground color for the Remedies category accent tile, paired
  /// with [genderSelectedBg] — close to but distinct from
  /// [genderSelectedText] (#C25705 vs this #7A3E12), so it isn't a reuse.
  static const Color remedyFg = Color(0xFF7A3E12);

  /// Diagonal (top-left → bottom-right) navy gradient for the Articles
  /// featured card and the Article Detail hero — same stops as
  /// [navyGradient] but on a diagonal axis, matching the approved Figma
  /// angle (~145°/150°), so it's a small addition rather than an inlined
  /// literal gradient.
  static const LinearGradient navyGradientDiagonal = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navyTop, navyBottom],
  );

  // --- Search & Notifications — see "D3 · Search" (Figma node 27:2) + "D4 ·
  // Notifications" (Figma node 28:2) ---
  //
  // NOTE: both screens reuse existing tokens rather than duplicating them —
  // [cardBorder], [cream], [ink], [muted], [hint], [saffron],
  // [otpBorderFilled] (Search's result-row chevron), [genderSelectedBg]/
  // [genderSelectedText], [mantraBg]/[mantraIcon], [tilePinkBg]/[tilePinkFg],
  // [tileBlueBg]/[tileBlueFg] and [ashubhBg]/[ashubhFg] (Notifications' tinted
  // icon tiles). Only the 1 below is genuinely new.

  /// Border color of an UNREAD notification card. Distinct from
  /// [mantraBorder] (#EBDCB2) and [glanceBorder] (#EFD9B4) — close but not an
  /// exact match to either, so it isn't a reuse.
  static const Color notificationUnreadBorder = Color(0xFFF3DCC3);
}
