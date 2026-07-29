// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Vedadarshi';

  @override
  String get splashTagline => 'Your trusted Vedic companion';

  @override
  String get introStarsTitle => 'Your Stars, Decoded';

  @override
  String get introStarsSubtitle =>
      'Daily horoscope, Panchang & Kundli — from authentic Vedic calculations';

  @override
  String get introAiTitle => 'Ask the AI Astrologer';

  @override
  String get introAiSubtitle =>
      'Personal guidance from your birth chart — in your own language';

  @override
  String get getStarted => 'Get Started';
}
