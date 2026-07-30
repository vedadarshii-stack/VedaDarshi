import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'core/locale/locale_controller.dart';
import 'core/theme/app_colors.dart';
import 'features/startup/root_gate.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Build-time secrets (currently just GOOGLE_PLACES_API_KEY) come from the
  // gitignored `.env` asset — see `.env.example`. Wrapped in try/catch on
  // purpose: a missing or malformed `.env` must never stop the app booting,
  // because every key in it is optional (an absent Places key simply makes
  // the Place-of-Birth search fall back to the bundled offline city dataset).
  try {
    await dotenv.load();
  } catch (e) {
    debugPrint('main: .env not loaded ($e) — continuing without it');
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Offline persistence is what lets a birth-profile Firestore write survive
  // a bad connection at save time — it lands in Firestore's local cache
  // immediately and is replayed to the server automatically once
  // connectivity returns, instead of being lost (see
  // BirthProfileRepository.save/pushLocalProfileToCloud).
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  // All brand/UI fonts are bundled in assets/google_fonts/ (see AppFonts).
  // Disabling runtime fetching means a missing font throws immediately in
  // debug instead of silently falling back to a network request, and it
  // guarantees offline launches always show the correct branding fonts.
  GoogleFonts.config.allowRuntimeFetching = false;

  // Loads the IANA timezone database bundled with package:timezone, needed
  // by BirthProfile.utcOffsetLabel to resolve the historically-correct UTC
  // offset for a birth city + date/time (see lib/features/profile/birth_profile.dart).
  tz_data.initializeTimeZones();

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
      // RootGate — not SplashScreen — so a returning user resumes straight
      // into the app instead of replaying onboarding on every launch.
      home: const RootGate(),
    );
  }
}
