import 'package:flutter/foundation.dart' show immutable;

/// One zodiac (rashi) sign — its Unicode glyph plus its Sanskrit and
/// English names.
///
/// The Sanskrit/English name pairs live here as DATA rather than in the
/// ARBs because the Vedika API returns sign names already localised per
/// language — when real data is wired up, these become the fallback/label
/// source (e.g. for offline use, or while a language response is loading),
/// not strings that go through Flutter's translation layer.
@immutable
class ZodiacSign {
  const ZodiacSign({
    required this.id,
    required this.glyph,
    required this.sanskritName,
    required this.englishName,
  });

  /// Stable identifier (e.g. `'mesha'`) — used to key placeholder data such
  /// as [HoroscopeStaticData.userSignId] and, later, API lookups.
  final String id;

  /// Unicode zodiac glyph (e.g. `'♈'`).
  final String glyph;

  final String sanskritName;
  final String englishName;
}

/// All 12 zodiac signs, in the fixed order used by "B3 · Horoscope — All
/// Signs" (Figma node 15:2).
const List<ZodiacSign> kZodiacSigns = [
  ZodiacSign(
    id: 'mesha',
    glyph: '♈',
    sanskritName: 'Mesha',
    englishName: 'Aries',
  ),
  ZodiacSign(
    id: 'vrishabha',
    glyph: '♉',
    sanskritName: 'Vrishabha',
    englishName: 'Taurus',
  ),
  ZodiacSign(
    id: 'mithuna',
    glyph: '♊',
    sanskritName: 'Mithuna',
    englishName: 'Gemini',
  ),
  ZodiacSign(
    id: 'karka',
    glyph: '♋',
    sanskritName: 'Karka',
    englishName: 'Cancer',
  ),
  ZodiacSign(
    id: 'simha',
    glyph: '♌',
    sanskritName: 'Simha',
    englishName: 'Leo',
  ),
  ZodiacSign(
    id: 'kanya',
    glyph: '♍',
    sanskritName: 'Kanya',
    englishName: 'Virgo',
  ),
  ZodiacSign(
    id: 'tula',
    glyph: '♎',
    sanskritName: 'Tula',
    englishName: 'Libra',
  ),
  ZodiacSign(
    id: 'vrischika',
    glyph: '♏',
    sanskritName: 'Vrischika',
    englishName: 'Scorpio',
  ),
  ZodiacSign(
    id: 'dhanu',
    glyph: '♐',
    sanskritName: 'Dhanu',
    englishName: 'Sagittarius',
  ),
  ZodiacSign(
    id: 'makara',
    glyph: '♑',
    sanskritName: 'Makara',
    englishName: 'Capricorn',
  ),
  ZodiacSign(
    id: 'kumbha',
    glyph: '♒',
    sanskritName: 'Kumbha',
    englishName: 'Aquarius',
  ),
  ZodiacSign(
    id: 'meena',
    glyph: '♓',
    sanskritName: 'Meena',
    englishName: 'Pisces',
  ),
];
