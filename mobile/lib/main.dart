import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/locale/locale_controller.dart';
import 'core/theme/app_colors.dart';
import 'features/splash/splash_screen.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // All brand/UI fonts are bundled in assets/google_fonts/ (see AppFonts).
  // Disabling runtime fetching means a missing font throws immediately in
  // debug instead of silently falling back to a network request, and it
  // guarantees offline launches always show the correct branding fonts.
  GoogleFonts.config.allowRuntimeFetching = false;

  // Read any previously-saved language choice before the first frame, so a
  // returning user never sees a flash of the wrong (device-default)
  // language while SharedPreferences loads asynchronously later.
  final savedLocale = await loadSavedLocale();

  runApp(
    ProviderScope(
      overrides: [
        if (savedLocale != null)
          localeControllerProvider.overrideWith(
            () => LocaleController(savedLocale),
          ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeControllerProvider);
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.saffron),
      ),
      home: const SplashScreen(),
    );
  }
}
