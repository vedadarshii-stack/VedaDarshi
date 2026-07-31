import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Brand color palette approved in the "🪔 Brand — Logo" Figma page.
///
/// Centralizing colors here keeps the navy/saffron/gold brand identity
/// consistent across the splash screen, launcher icon and future feature UI.
///
/// **Dark mode note:** every member below is a GETTER, not a `static const`,
/// delegating to whichever [AppColorSet] ([AppPalette.light] or
/// [AppPalette.dark]) [_active] currently points at. [applyBrightness] flips
/// that pointer and is called from [MainApp]'s `build` — once per frame,
/// BEFORE the widget tree builds — so it's always set to match the
/// `ThemeData` (light/dark/system-resolved) that's about to render. That's
/// what lets all ~639 existing `AppColors.*` call sites across the app keep
/// compiling and rendering correctly UNCHANGED, instead of every widget
/// needing a `BuildContext`/`Theme.of(context)` threaded through to pick a
/// palette.
///
/// **Trade-off, stated honestly:** [_active] is process-global mutable
/// state, not scoped state. Any widget that CACHES a color read from
/// [AppColors] across a theme change (e.g. stores it in a field at `initState`
/// instead of reading it inside `build()`) would keep the stale value until
/// it happens to rebuild. Nothing in this codebase does that today — every
/// call site reads `AppColors.xxx` directly inside `build()`/`paint()` — but
/// it's the one thing to watch for if that ever changes.
abstract final class AppColors {
  static AppColorSet _active = AppPalette.light;

  /// Points [AppColors] at the palette matching [brightness]. Call this
  /// before the widget tree builds for the frame that uses it — see
  /// [MainApp]'s `build` in `main.dart`, which resolves the effective
  /// brightness (explicit light/dark, or the platform brightness for
  /// `ThemeMode.system`) and calls this first thing every build.
  static void applyBrightness(Brightness brightness) {
    _active = brightness == Brightness.dark
        ? AppPalette.dark
        : AppPalette.light;
  }

  static Color get navyTop => _active.navyTop;
  static Color get navyBottom => _active.navyBottom;
  static Color get saffron => _active.saffron;
  static Color get saffronDark => _active.saffronDark;
  static Color get gold => _active.gold;
  static Color get cream => _active.cream;
  static Color get ink => _active.ink;
  static Color get muted => _active.muted;

  /// Background of every raised element that sits ON TOP of the [cream] page
  /// background: cards, tiles, chips, input fields, sheets, the bottom nav
  /// bar and the circular top-bar icon buttons.
  ///
  /// This used to be a hardcoded `Colors.white` at ~55 call sites, which is
  /// exactly why the first dark-mode pass looked broken — the page went dark
  /// and the text inverted to near-white, but every card stayed pure white,
  /// leaving near-white text on a white card. It MUST be a palette token so
  /// it flips with everything else.
  static Color get surface => _active.surface;

  /// A slightly *raised* variant of [surface], used where one row/card has
  /// to read as emphasized against its neighbours (currently just the
  /// highlighted city suggestion in the Place-of-Birth autocomplete).
  ///
  /// Note the direction flips with the theme, on purpose: in light mode
  /// emphasis reads as "slightly darker/warmer than white", in dark mode as
  /// "slightly lighter than the card". Hardcoding [cream] for the highlight
  /// (as the autocomplete originally did) inverts wrongly in dark mode,
  /// where [cream] is the near-black PAGE background.
  static Color get surfaceAlt => _active.surfaceAlt;

  /// Base color for drop shadows. Light mode casts the brand ink; dark mode
  /// casts true black — using [ink] here (as three call sites originally
  /// did) paints a near-WHITE glow around every card once [ink] inverts.
  static Color get shadow => _active.shadow;

  /// Border color for unselected cards (e.g. the language-select cards).
  static Color get cardBorder => _active.cardBorder;

  /// Bottom stop of the Welcome/Login hero gradient — slightly darker than
  /// [navyBottom] per the approved "A3 · Welcome / Login" design.
  static Color get navyHeroBottom => _active.navyHeroBottom;

  /// Secondary/muted text rendered on top of the navy hero.
  static Color get mutedOnNavy => _active.mutedOnNavy;

  /// Placeholder/hint text and fine print (e.g. phone input hint, terms
  /// notice).
  static Color get hint => _active.hint;

  /// Hairline rule color (section dividers, the Google button border).
  static Color get divider => _active.divider;

  /// Google brand blue, used for the "G" wordmark on the Google sign-in
  /// button.
  static Color get googleBlue => _active.googleBlue;

  /// Border color of an OTP box that already has a digit typed into it (but
  /// isn't currently focused) — see "A4 · OTP Verify" (Figma node 7:27).
  static Color get otpBorderFilled => _active.otpBorderFilled;

  /// Selected-pill background/text for the gender picker on the Birth
  /// Details screen — see "A5 · Birth Details Setup" (Figma node 8:2).
  static Color get genderSelectedBg => _active.genderSelectedBg;
  static Color get genderSelectedText => _active.genderSelectedText;

  /// Geo-detected chip background/text shown once a birth city is selected
  /// — see "A5 · Birth Details Setup" (Figma node 8:2).
  static Color get geoChipBg => _active.geoChipBg;
  static Color get geoChipText => _active.geoChipText;

  static LinearGradient get navyGradient => _active.navyGradient;

  /// Welcome/Login hero gradient — same top stop as [navyGradient] but a
  /// slightly darker bottom stop ([navyHeroBottom]) per the approved design.
  static LinearGradient get navyHeroGradient => _active.navyHeroGradient;

  /// Primary saffron CTA gradient (splash "Get Started", language "Continue").
  static LinearGradient get saffronGradient => _active.saffronGradient;

  // --- Home Dashboard — see "B1 · Home Dashboard" (Figma node 10:3) ---

  static Color get panchangOrange1 => _active.panchangOrange1;
  static Color get panchangOrange2 => _active.panchangOrange2;
  static Color get panchangOrange3 => _active.panchangOrange3;

  /// Background gradient of the Panchang hero card on Home.
  static LinearGradient get panchangGradient => _active.panchangGradient;

  /// Cream text tones used on top of [panchangGradient].
  static Color get creamText => _active.creamText;
  static Color get creamTextSoft => _active.creamTextSoft;

  /// Border color of the "Today at a glance" tiles.
  static Color get glanceBorder => _active.glanceBorder;

  /// Remedy/mantra card colors.
  static Color get mantraBg => _active.mantraBg;
  static Color get mantraBorder => _active.mantraBorder;
  static Color get mantraLabel => _active.mantraLabel;
  static Color get mantraBody => _active.mantraBody;
  static Color get mantraIcon => _active.mantraIcon;

  /// Tinted background/foreground pairs shared by the glance tiles, explore
  /// tiles and recent-report tiles on Home.
  static Color get tileBlueBg => _active.tileBlueBg;
  static Color get tileBlueFg => _active.tileBlueFg;
  static Color get tileGoldBg => _active.tileGoldBg;
  static Color get tileGoldFg => _active.tileGoldFg;
  static Color get tileGreenBg => _active.tileGreenBg;
  static Color get tileGreenFg => _active.tileGreenFg;
  static Color get tilePurpleBg => _active.tilePurpleBg;
  static Color get tilePurpleFg => _active.tilePurpleFg;
  static Color get tileCyanBg => _active.tileCyanBg;
  static Color get tileCyanFg => _active.tileCyanFg;
  static Color get tilePinkBg => _active.tilePinkBg;
  static Color get tilePinkFg => _active.tilePinkFg;

  /// Border color of the bride-side heart divider circle on the Gun Milan
  /// select screen — see "C1 · Gun Milan — Select" (Figma node 19:3).
  static Color get bridePinkBorder => _active.bridePinkBorder;

  /// Bottom nav colors.
  static Color get navInactive => _active.navInactive;
  static Color get navActiveText => _active.navActiveText;

  /// Daily Quote card text tones.
  static Color get quoteGold => _active.quoteGold;
  static Color get quoteMuted => _active.quoteMuted;

  // --- Panchang — see "B2 · Panchang" (Figma node 14:2) ---
  //
  // NOTE: the design's shubh (auspicious) green and amber tones are already
  // covered by existing tokens — [geoChipBg]/[tileGreenFg] and
  // [mantraLabel] respectively — so they're reused directly on the Muhurat
  // cards rather than duplicated here.

  /// Ashubh (inauspicious) muhurat card background/foreground.
  static Color get ashubhBg => _active.ashubhBg;
  static Color get ashubhFg => _active.ashubhFg;

  /// Caution muhurat card background (foreground reuses [mantraLabel]).
  static Color get warnBg => _active.warnBg;

  /// Hairline divider between rows in the Panchang elements card.
  static Color get rowDivider => _active.rowDivider;

  // --- Horoscope Detail — see "B4 · Horoscope Detail" (Figma node 16:2) ---

  /// "Avoid time" value text on the Horoscope Detail screen.
  static Color get avoidText => _active.avoidText;

  /// Dark premium-card gradient (Home's Daily Quote card, Horoscope Detail's
  /// premium teaser) — extracted here so both screens share one definition
  /// instead of duplicating the same literal gradient.
  static LinearGradient get premiumDarkGradient => _active.premiumDarkGradient;

  /// Horoscope Detail header gradient — reuses [panchangOrange1]/
  /// [panchangOrange3] rather than introducing new orange literals.
  static LinearGradient get horoscopeHeaderGradient =>
      _active.horoscopeHeaderGradient;

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
  static Color get chartPaper => _active.chartPaper;

  /// Stroke color of the chart's square border, diagonals and diamond.
  static Color get chartLine => _active.chartLine;

  /// Color of the house-number labels (1–12) inside the chart.
  static Color get chartHouseNumber => _active.chartHouseNumber;

  /// Ketu's planet-label/legend color — the only planet with no existing
  /// tinted-token match among the reused colors above.
  static Color get planetKetu => _active.planetKetu;

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
  static Color get aiCardBorder => _active.aiCardBorder;

  /// Title text color inside the Rishi AI summary card.
  static Color get aiTitle => _active.aiTitle;

  /// Body text color inside the Rishi AI summary card.
  static Color get aiBody => _active.aiBody;

  /// Verdict-pill check icon/text color on the navy header (brighter than
  /// [tileGreenFg] so it reads clearly on the dark background).
  static Color get matchSuccessText => _active.matchSuccessText;

  /// Muted couple-names line on the navy header.
  static Color get headerSubtle => _active.headerSubtle;

  // --- AI Astrologer — see "C3 · AI Astrologer" (Figma node 21:2) ---

  /// Warm border color of the suggestion chips on the AI Astrologer chat.
  static Color get chipBorderWarm => _active.chipBorderWarm;

  /// Assistant chat-bubble body text color.
  static Color get bubbleText => _active.bubbleText;

  /// 135° purple→navy gradient behind the Rishi AI avatar — reused by both
  /// Home's "Continue with Rishi AI" card icon and the AI Astrologer header
  /// avatar, so it's defined once here rather than duplicated per screen.
  static LinearGradient get aiAvatarGradient => _active.aiAvatarGradient;

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
  static Color get onGold => _active.onGold;

  /// Terracotta tinted background/foreground pair for the Numerology report
  /// tile — the one report tile color pairing not already covered by an
  /// existing tile* token.
  static Color get terracottaBg => _active.terracottaBg;
  static Color get terracottaFg => _active.terracottaFg;

  /// Left→right variant of [navyGradient] for the Go Premium banner — same
  /// navy stops, different axis, so it's a small addition rather than an
  /// inlined literal gradient.
  static LinearGradient get navyGradientHorizontal =>
      _active.navyGradientHorizontal;

  // --- Subscription Paywall — see "C5 · Subscription Paywall" (Figma node 23:2) ---
  //
  // NOTE: most of this screen reuses existing tokens rather than duplicating
  // them — [gold], [quoteGold], [onGold], [mutedOnNavy], [headerSubtle],
  // [navyTop] and [navyBottom]. Only the 4 below are genuinely new.

  /// 3-stop navy gradient behind the whole paywall screen — distinct from
  /// [navyGradient] (2-stop) because the design calls for a mid-tone stop at
  /// 50% rather than a straight top→bottom blend.
  static LinearGradient get paywallGradient => _active.paywallGradient;

  /// Gold CTA gradient for the paywall's "Start Premium" button.
  static LinearGradient get goldCtaGradient => _active.goldCtaGradient;

  /// Brighter gold used for the selected plan card's 2px border — [gold] on
  /// its own reads too muted against the [paywallGradient] backdrop.
  static Color get goldBright => _active.goldBright;

  /// Fine-print text color at the bottom of the paywall (billing terms).
  static Color get paywallFinePrint => _active.paywallFinePrint;

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
  static Color get remedyFg => _active.remedyFg;

  /// Diagonal (top-left → bottom-right) navy gradient for the Articles
  /// featured card and the Article Detail hero — same stops as
  /// [navyGradient] but on a diagonal axis, matching the approved Figma
  /// angle (~145°/150°), so it's a small addition rather than an inlined
  /// literal gradient.
  static LinearGradient get navyGradientDiagonal =>
      _active.navyGradientDiagonal;

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
  static Color get notificationUnreadBorder => _active.notificationUnreadBorder;
}
