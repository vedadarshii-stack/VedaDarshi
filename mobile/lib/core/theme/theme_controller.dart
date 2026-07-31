import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _prefsKey = 'app_theme_mode';

/// Maps [ThemeMode] <-> the string stored in SharedPreferences. Mirrors
/// `locale_controller.dart`'s `_supportedLanguageCodes` pattern — a small,
/// explicit whitelist rather than relying on enum name stability.
const Map<ThemeMode, String> _modeToCode = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};

/// App-wide theme mode (system/light/dark), same shape as
/// `LocaleController` (`locale_controller.dart`) — Riverpod app-wide state
/// rather than screen-local state, because the choice must apply instantly
/// everywhere (see [MainApp]'s `build` in `main.dart`) and survive app
/// restarts.
class ThemeController extends Notifier<ThemeMode> {
  /// [initial] seeds state from a value already loaded (via
  /// [loadSavedThemeMode]) before `runApp`, so cold starts never flash the
  /// wrong theme while `SharedPreferences` loads asynchronously later.
  ThemeController([this._initial]);

  final ThemeMode? _initial;

  @override
  ThemeMode build() => _initial ?? ThemeMode.system;

  /// Applies [mode] app-wide and persists it so the choice survives a cold
  /// start (read back via [loadSavedThemeMode] before `runApp`).
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, _modeToCode[mode]!);
  }
}

final themeControllerProvider = NotifierProvider<ThemeController, ThemeMode>(
  ThemeController.new,
);

/// Reads the persisted theme choice, if any, for seeding app state before
/// the first frame (avoids a flash of the wrong theme on launch).
///
/// Defaults to [ThemeMode.system] — including when nothing was saved yet, or
/// when the saved value is corrupt/unrecognized. Never throws.
Future<ThemeMode> loadSavedThemeMode() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    for (final entry in _modeToCode.entries) {
      if (entry.value == code) return entry.key;
    }
    return ThemeMode.system;
  } catch (_) {
    return ThemeMode.system;
  }
}
