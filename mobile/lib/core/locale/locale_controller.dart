import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Locales the app ships translations for (per the localization requirement:
/// English, Hindi, Telugu, Tamil, Kannada).
const List<String> _supportedLanguageCodes = ['en', 'hi', 'te', 'ta', 'kn'];

const String _prefsKey = 'app_locale';

/// App-wide selected locale, overriding the device locale once the user
/// makes an explicit choice.
///
/// Locale lives in app-wide (Riverpod) state, not screen-local state,
/// because choosing a language on the Language Select screen must change
/// every already-built widget in the tree immediately (title, hints, CTA
/// labels — see the language select screen's live-preview behaviour) and
/// the choice must also survive app restarts. A `ConsumerWidget` at the
/// `MaterialApp` root watches this provider and feeds it into
/// `MaterialApp.locale`, so a single `setLocale` call here is enough to
/// re-localize the whole app.
///
/// `null` state means "no explicit choice made yet" — `MaterialApp.locale`
/// treats that as "resolve from the device locale / supported locales list".
class LocaleController extends Notifier<Locale?> {
  /// [initial] seeds state from a value already loaded (via
  /// [loadSavedLocale]) before `runApp`, so cold starts never flash the
  /// wrong language while `SharedPreferences` loads asynchronously later.
  /// Left `null` for a fresh install with no saved choice yet.
  LocaleController([this._initial]);

  final Locale? _initial;

  @override
  Locale? build() => _initial;

  /// Applies [locale] app-wide and persists it so the choice survives a
  /// cold start (read back via [loadSavedLocale] before `runApp`).
  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.languageCode);
  }
}

final localeControllerProvider = NotifierProvider<LocaleController, Locale?>(
  LocaleController.new,
);

/// Reads the persisted language choice, if any, for seeding app state
/// before the first frame (avoids a flash of the wrong language on launch).
///
/// Returns `null` when nothing was saved yet, or when the saved code is no
/// longer one of the app's supported locales.
Future<Locale?> loadSavedLocale() async {
  final prefs = await SharedPreferences.getInstance();
  final code = prefs.getString(_prefsKey);
  if (code == null || !_supportedLanguageCodes.contains(code)) {
    return null;
  }
  return Locale(code);
}
