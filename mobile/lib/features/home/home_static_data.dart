import 'package:flutter/foundation.dart' show immutable;

/// STATIC PLACEHOLDER CONTENT for the Home Dashboard screen — see
/// "B1 · Home Dashboard" (Figma node 10:3).
///
/// Every value in this file stands in for content that will eventually come
/// from two different live sources:
///  - the **Vedika API** (vedika.io) — panchang, horoscope, festival and
///    remedy content, cached once per day per language in Firestore (see the
///    "Astrology data" section of the project's top-level CLAUDE.md);
///  - the **Firestore CMS** — articles and daily quotes authored in the
///    admin panel.
///
/// Keeping every placeholder value in this one file (rather than scattered
/// across the widget tree in `home_dashboard_screen.dart`) means wiring up
/// those real data sources later is a matter of replacing the providers that
/// supply these values — it should never require touching the widgets
/// themselves.
///
/// **Vedika panchang IS wired now (1 Aug 2026)** — see
/// [HomeDashboardScreen]'s class doc in `home_dashboard_screen.dart` for
/// exactly which fields that made live. [panchang] and [glanceTiles] remain
/// here as the FALLBACK those live fields degrade to (loading, error, no
/// profile yet) and as the permanent value for the fields Vedika has no
/// equivalent for (sunrise/sunset; 5 of the 6 glance tiles) — they are not
/// dead code waiting to be deleted.
abstract final class HomeStaticData {
  static const String greeting = 'Shubh Prabhat 🌅';

  /// Fallback shown only if no [BirthProfile] is saved yet. In normal
  /// operation Home is unreachable without a saved profile (see
  /// `RootGate`), so this is a safety net, not something a real user should
  /// ever see.
  static const String fallbackUserName = 'Nagarjuna';

  static const HomePanchangData panchang = HomePanchangData(
    date: 'Saturday, 12 July 2026',
    tithi: 'Shukla Ashtami',
    nakshatra: 'Rohini',
    yoga: 'Siddhi',
    karana: 'Bava',
    sunrise: '05:52 AM',
    sunset: '07:04 PM',
  );

  static const List<GlanceTile> glanceTiles = [
    GlanceTile(GlanceTileId.luckyNumber, '3, 9'),
    GlanceTile(GlanceTileId.luckyColor, 'Gold'),
    GlanceTile(GlanceTileId.direction, 'East'),
    GlanceTile(GlanceTileId.todaysPlanet, 'Shukra'),
    GlanceTile(GlanceTileId.moonPhase, 'Waxing Gibbous'),
    GlanceTile(GlanceTileId.muhurat, '11:54 AM'),
  ];

  static const String remedy =
      'Offer water to the rising Sun and donate yellow items.';

  /// Devanagari mantra text. MUST always render with
  /// `AppFonts.body(const Locale('hi'), …)` regardless of the active app
  /// locale — Poppins/Playfair/the other Noto Sans faces contain no
  /// Devanagari glyphs (see the project's TYPOGRAPHY RULE).
  static const String mantra =
      'ॐ द्रां द्रीं द्रौं सः शुक्राय नमः — chant 11 times';

  static const String festival = 'Sawan Somvar — tomorrow';

  static const HoroscopeData horoscope = HoroscopeData(
    sign: 'Simha · Leo',
    rating: '4/5',
    body:
        'A favourable day for new beginnings. Jupiter blesses your career '
        'house…',
  );

  static const List<ArticleTeaser> articles = [
    ArticleTeaser(
      title: 'Understanding your Moon sign',
      readTime: '5 min read',
      // No article in ArticlesStaticData covers this exact topic yet (this
      // teaser and the Articles catalogue are independently-authored
      // placeholder copy) — linked to a thematically-close article so the
      // card still opens a real Article Detail page rather than a
      // fallback. Once both surfaces read from the same Firestore CMS
      // catalogue, this id will point at the article this teaser is
      // actually promoting.
      articleId: 'mantras-peaceful-sleep',
    ),
    ArticleTeaser(
      title: 'Sawan month: rituals & significance',
      readTime: '7 min read',
      // This one DOES match: same topic as ArticlesStaticData.featured.
      articleId: 'sawan-somvar-fasting',
    ),
  ];

  static const String aiTeaserQuestion =
      '"When is a good time to change my job…"';

  static const List<ReportTeaser> reports = [
    ReportTeaser(title: 'Career Report', meta: 'Viewed 2 days ago · PDF ⬇'),
    ReportTeaser(title: 'Marriage Report', meta: 'New · AI Summary ✨'),
  ];

  static const DailyQuote quote = DailyQuote(
    text:
        'The stars incline, they do not compel. Your karma writes the '
        'final word.',
    attribution: '— Daily Wisdom · Share ↗',
  );
}

/// Today's panchang summary shown in the Home hero card.
///
/// Named `HomePanchangData` (not `PanchangData`) specifically to avoid
/// colliding with the live Vedika response model of the same short name in
/// `panchang_data.dart` — both are imported into `home_dashboard_screen.dart`
/// side by side, one as the fallback shape, one as the live one.
@immutable
class HomePanchangData {
  const HomePanchangData({
    required this.date,
    required this.tithi,
    required this.nakshatra,
    required this.yoga,
    required this.karana,
    required this.sunrise,
    required this.sunset,
  });

  final String date;
  final String tithi;
  final String nakshatra;
  final String yoga;
  final String karana;
  final String sunrise;
  final String sunset;
}

/// Identifies which l10n label, emoji and tile color a [GlanceTile] should
/// render with — the widget layer owns that presentation mapping since
/// labels are UI chrome (l10n), not placeholder data.
enum GlanceTileId {
  luckyNumber,
  luckyColor,
  direction,
  todaysPlanet,
  moonPhase,
  muhurat,
}

/// One tile in the "Today at a glance" grid.
@immutable
class GlanceTile {
  const GlanceTile(this.id, this.value);

  final GlanceTileId id;
  final String value;
}

/// Today's horoscope teaser shown in the Home dashboard.
@immutable
class HoroscopeData {
  const HoroscopeData({
    required this.sign,
    required this.rating,
    required this.body,
  });

  final String sign;
  final String rating;
  final String body;
}

/// One article teaser card in the "Wisdom for you" section.
@immutable
class ArticleTeaser {
  const ArticleTeaser({
    required this.title,
    required this.readTime,
    required this.articleId,
  });

  final String title;
  final String readTime;

  /// Id of the matching [Article] in `ArticlesStaticData.all`, used to open
  /// the real Article Detail screen when this card is tapped.
  final String articleId;
}

/// One report teaser card in the "Recent reports" section.
@immutable
class ReportTeaser {
  const ReportTeaser({required this.title, required this.meta});

  final String title;
  final String meta;
}

/// The bottom-of-screen daily quote.
@immutable
class DailyQuote {
  const DailyQuote({required this.text, required this.attribution});

  final String text;
  final String attribution;
}
