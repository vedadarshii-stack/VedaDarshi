import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Locale-aware font resolver.
///
/// Vedadarshi ships in 5 locales (en, hi, te, ta, kn), but the brand display
/// face (Playfair Display) and UI face (Poppins) are Latin-only typefaces —
/// they contain no Devanagari/Telugu/Tamil/Kannada glyphs. Calling
/// `GoogleFonts.playfairDisplay` / `GoogleFonts.poppins` directly for
/// regional text renders via an arbitrary system fallback font, or as tofu
/// boxes, and breaks the app's typography consistency.
///
/// Every widget MUST resolve its text style through [AppFonts] instead of
/// calling `GoogleFonts.*` directly, passing the current `Locale` (usually
/// `Localizations.localeOf(context)`) so the correct script-appropriate
/// face is chosen automatically. This is the rule for every current and
/// future screen.
///
/// Only the TTFs bundled in `assets/google_fonts/` are available offline
/// (see `pubspec.yaml` and `GoogleFonts.config.allowRuntimeFetching`):
/// Playfair Display (Bold only), Poppins (Regular/Medium/SemiBold), and
/// each Noto Sans Indic face (Regular/SemiBold only). Requested weights
/// that aren't bundled are clamped to the closest bundled weight so the
/// font never silently falls back to a network fetch.
abstract final class AppFonts {
  /// Brand display face for large titles (splash wordmark, section titles).
  ///
  /// `en` uses Playfair Display (Latin display serif). The four Indic
  /// locales use the matching Noto Sans Indic face instead, since Playfair
  /// has no Devanagari/Telugu/Tamil/Kannada glyphs.
  static TextStyle heading(
    Locale locale, {
    required double fontSize,
    Color? color,
    FontWeight fontWeight = FontWeight.w700,
    double? height,
  }) {
    switch (locale.languageCode) {
      case 'hi':
        return GoogleFonts.notoSansDevanagari(
          fontSize: fontSize,
          color: color,
          fontWeight: _clampWeight(fontWeight, _notoBundledWeights),
          height: height,
        );
      case 'te':
        return GoogleFonts.notoSansTelugu(
          fontSize: fontSize,
          color: color,
          fontWeight: _clampWeight(fontWeight, _notoBundledWeights),
          height: height,
        );
      case 'ta':
        return GoogleFonts.notoSansTamil(
          fontSize: fontSize,
          color: color,
          fontWeight: _clampWeight(fontWeight, _notoBundledWeights),
          height: height,
        );
      case 'kn':
        return GoogleFonts.notoSansKannada(
          fontSize: fontSize,
          color: color,
          fontWeight: _clampWeight(fontWeight, _notoBundledWeights),
          height: height,
        );
      default:
        return GoogleFonts.playfairDisplay(
          fontSize: fontSize,
          color: color,
          fontWeight: _clampWeight(fontWeight, _playfairBundledWeights),
          height: height,
        );
    }
  }

  /// UI body/label face (buttons, subtitles, taglines).
  ///
  /// `en` uses Poppins (Latin geometric sans). The four Indic locales use
  /// the matching Noto Sans Indic face instead, for the same glyph-coverage
  /// reason as [heading].
  static TextStyle body(
    Locale locale, {
    required double fontSize,
    Color? color,
    FontWeight fontWeight = FontWeight.w400,
    double? height,
    double? letterSpacing,
  }) {
    switch (locale.languageCode) {
      case 'hi':
        return GoogleFonts.notoSansDevanagari(
          fontSize: fontSize,
          color: color,
          fontWeight: _clampWeight(fontWeight, _notoBundledWeights),
          height: height,
          letterSpacing: letterSpacing,
        );
      case 'te':
        return GoogleFonts.notoSansTelugu(
          fontSize: fontSize,
          color: color,
          fontWeight: _clampWeight(fontWeight, _notoBundledWeights),
          height: height,
          letterSpacing: letterSpacing,
        );
      case 'ta':
        return GoogleFonts.notoSansTamil(
          fontSize: fontSize,
          color: color,
          fontWeight: _clampWeight(fontWeight, _notoBundledWeights),
          height: height,
          letterSpacing: letterSpacing,
        );
      case 'kn':
        return GoogleFonts.notoSansKannada(
          fontSize: fontSize,
          color: color,
          fontWeight: _clampWeight(fontWeight, _notoBundledWeights),
          height: height,
          letterSpacing: letterSpacing,
        );
      default:
        return GoogleFonts.poppins(
          fontSize: fontSize,
          color: color,
          fontWeight: _clampWeight(fontWeight, _poppinsBundledWeights),
          height: height,
          letterSpacing: letterSpacing,
        );
    }
  }

  static const List<FontWeight> _playfairBundledWeights = [FontWeight.w700];
  static const List<FontWeight> _poppinsBundledWeights = [
    FontWeight.w400,
    FontWeight.w500,
    FontWeight.w600,
  ];
  static const List<FontWeight> _notoBundledWeights = [
    FontWeight.w400,
    FontWeight.w600,
  ];

  /// Returns the entry in [bundled] closest to [requested], so a request
  /// for a weight whose TTF isn't bundled never triggers a network fetch.
  static FontWeight _clampWeight(
    FontWeight requested,
    List<FontWeight> bundled,
  ) {
    var closest = bundled.first;
    var minDiff = (requested.value - closest.value).abs();
    for (final candidate in bundled) {
      final diff = (requested.value - candidate.value).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = candidate;
      }
    }
    return closest;
  }
}
