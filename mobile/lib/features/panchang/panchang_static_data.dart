import 'package:flutter/foundation.dart' show immutable;

/// STATIC PLACEHOLDER CONTENT for the Panchang screen — see
/// "B2 · Panchang" (Figma node 14:2).
///
/// Every value in this file stands in for what will eventually come from
/// the **Vedika API** (vedika.io) panchang endpoint, cached once per day per
/// language in Firestore (see the "Astrology data" section of the project's
/// top-level CLAUDE.md).
///
/// Keeping every placeholder value in this one file (rather than scattered
/// across the widget tree in `panchang_screen.dart`) means wiring up that
/// real data source later is a matter of replacing the provider that
/// supplies these values — it should never require touching the widgets
/// themselves.
abstract final class PanchangStaticData {
  static const String location = 'Hyderabad';
  static const String date = 'Saturday, 12 July 2026';
  static const String masaPaksha = 'Shravana Masa · Shukla Paksha';

  static const String sunrise = '05:52 AM';
  static const String sunset = '07:04 PM';
  static const String moonrise = '11:20 AM';
  static const String moonset = '11:52 PM';

  static const List<PanchangElement> elements = [
    PanchangElement(
      PanchangElementId.tithi,
      'Shukla Ashtami',
      'till 04:32 PM',
    ),
    PanchangElement(PanchangElementId.nakshatra, 'Rohini', 'till 09:12 PM'),
    PanchangElement(PanchangElementId.yoga, 'Siddhi', 'till 02:18 PM'),
    PanchangElement(PanchangElementId.karana, 'Bava', 'till 04:32 PM'),
    PanchangElement(PanchangElementId.vaar, 'Shanivaar', null),
  ];

  static const List<Muhurat> muhurats = [
    Muhurat('Abhijit Muhurat', '11:54 AM – 12:47 PM', MuhuratKind.shubh),
    Muhurat('Rahu Kaal', '09:06 – 10:42 AM', MuhuratKind.ashubh),
    Muhurat('Yamaganda', '01:54 – 03:30 PM', MuhuratKind.ashubh),
    Muhurat('Gulika Kaal', '05:06 – 06:42 AM', MuhuratKind.caution),
  ];

  static const String festival = 'Kamika Ekadashi (fasting till moonrise)';

  static const String advice =
      'An auspicious day for charity and starting spiritual practices. '
      'Offer water to Peepal tree before sunset.';

  /// Time shown in the "Available offline · Updated {time}" badge.
  static const String offlineUpdatedAt = '6:00 AM';
}

/// Identifies which l10n label a [PanchangElement] row should render with —
/// the widget layer owns that presentation mapping since labels are UI
/// chrome (l10n), not placeholder data.
enum PanchangElementId { tithi, nakshatra, yoga, karana, vaar }

/// One row in the Panchang elements card (Tithi, Nakshatra, Yoga, Karana,
/// Vaar).
@immutable
class PanchangElement {
  const PanchangElement(this.id, this.value, this.tillLabel);

  final PanchangElementId id;
  final String value;

  /// Optional trailing "till HH:mm AM/PM" qualifier — null for rows (like
  /// Vaar) that don't expire during the day.
  final String? tillLabel;
}

/// Whether a [Muhurat] window is auspicious, inauspicious, or merely one to
/// be cautious around — drives the card's colours, so they come from data
/// rather than being hardcoded per card.
enum MuhuratKind { shubh, ashubh, caution }

/// One auspicious/inauspicious time window shown in the Muhurat grid.
@immutable
class Muhurat {
  const Muhurat(this.name, this.time, this.kind);

  final String name;
  final String time;
  final MuhuratKind kind;
}
