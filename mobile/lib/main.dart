import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'core/locale/locale_controller.dart';
import 'core/notifications/push_notification_service.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_palette.dart';
import 'core/theme/theme_controller.dart';
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

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Offline persistence is what lets a birth-profile Firestore write survive
  // a bad connection at save time — it lands in Firestore's local cache
  // immediately and is replayed to the server automatically once
  // connectivity returns, instead of being lost (see
  // BirthProfileRepository.save/pushLocalProfileToCloud).
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  // Push notifications (Firebase Cloud Messaging). The background handler
  // MUST be registered before runApp so FCM can deliver to it even if the
  // app process was launched solely to handle the message; `initialize()`
  // sets up the local-notifications channel/listeners for the foreground and
  // tap-to-open paths (see PushNotificationService's doc comment for the
  // full breakdown). Wrapped in try/catch on purpose, same as the
  // `dotenv.load()` guard above — a push-setup failure (missing Google
  // Play services on an emulator, a plugin hiccup, anything) must never stop
  // the app from booting.
  try {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await PushNotificationService.instance.initialize();
  } catch (e) {
    debugPrint(
      'main: push notification setup failed ($e) — continuing without it',
    );
  }

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

  // Same idea for the theme (light/dark/system) — read before the first
  // frame so a returning user never sees a flash of the wrong theme while
  // SharedPreferences loads asynchronously later (see theme_controller.dart).
  final savedThemeMode = await loadSavedThemeMode();

  runApp(
    ProviderScope(
      overrides: [
        if (savedLocale != null)
          localeControllerProvider.overrideWith(
            () => LocaleController(savedLocale),
          ),
        themeControllerProvider.overrideWith(
          () => ThemeController(savedThemeMode),
        ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  /// The brightness the tree was last BUILT with, so [build] can detect an
  /// actual light↔dark flip (as opposed to any other rebuild) and force the
  /// repaint described in [_markEntireTreeDirty].
  Brightness? _builtBrightness;

  /// Marks every element below this one as needing rebuild.
  ///
  /// **Why this is necessary:** `AppColors` is process-global mutable state
  /// (see its doc comment) — a widget picks up the new palette only when its
  /// own `build()` re-runs. Flipping `themeMode` rebuilds `MaterialApp` and
  /// everything that depends on `Theme.of(context)`, but almost nothing in
  /// this app does; screens read `AppColors.*` directly. So the widgets that
  /// happened to be listening to `themeControllerProvider` repainted in the
  /// new palette while every other card/label/background kept the colors it
  /// was last painted with, producing a half-light/half-dark screen (the
  /// Profile "Appearance" row rendered its label in light-mode ink on a
  /// still-dark card).
  ///
  /// `markNeedsBuild` only re-runs `build()`; `State` objects, scroll
  /// positions and the whole navigation stack are preserved — which is why
  /// this is used instead of re-keying the subtree.
  void _markEntireTreeDirty() {
    void mark(Element element) {
      element.markNeedsBuild();
      element.visitChildren(mark);
    }

    (context as Element).visitChildren(mark);
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeControllerProvider);
    final themeMode = ref.watch(themeControllerProvider);

    // Resolve which brightness is ACTUALLY about to render (ThemeMode.system
    // depends on the platform) and point AppColors at the matching palette
    // BEFORE this build's widget tree is constructed. Every AppColors.*
    // getter reads from that palette, so this is what keeps ~639 existing
    // call sites in sync with `theme`/`darkTheme` below without threading
    // a BuildContext through any of them — see AppColors' doc comment.
    final effectiveBrightness = switch (themeMode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => MediaQuery.platformBrightnessOf(context),
    };
    AppColors.applyBrightness(effectiveBrightness);

    if (_builtBrightness != null && _builtBrightness != effectiveBrightness) {
      // Deferred to a post-frame callback because the element tree is being
      // rebuilt right now and marking descendants dirty mid-build is not
      // allowed. The one intermediate frame this costs is the frame
      // MaterialApp's own AnimatedTheme is already cross-fading through.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _markEntireTreeDirty();
      });
    }
    _builtBrightness = effectiveBrightness;

    return MaterialApp(
      // Lets a notification tap push a route from outside the widget tree
      // (see PushNotificationService._navigateFromData) — there is no
      // BuildContext available when that fires from a background isolate or
      // before the first frame.
      navigatorKey: rootNavigatorKey,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppPalette.light.saffron,
          brightness: Brightness.light,
        ).copyWith(surface: AppPalette.light.surface),
        scaffoldBackgroundColor: AppPalette.light.cream,
        cardColor: AppPalette.light.surface,
        dividerColor: AppPalette.light.cardBorder,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppPalette.dark.saffron,
          brightness: Brightness.dark,
        ).copyWith(surface: AppPalette.dark.surface),
        scaffoldBackgroundColor: AppPalette.dark.cream,
        cardColor: AppPalette.dark.surface,
        dividerColor: AppPalette.dark.cardBorder,
      ),
      themeMode: themeMode,
      // RootGate — not SplashScreen — so a returning user resumes straight
      // into the app instead of replaying onboarding on every launch.
      home: const RootGate(),
    );
  }
}
