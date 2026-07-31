// TEMPORARY dark-mode visual check harness — delete after review.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vedadarshi/core/theme/app_colors.dart';
import 'package:vedadarshi/core/theme/app_palette.dart';
import 'package:vedadarshi/features/articles/articles_screen.dart';
import 'package:vedadarshi/features/home/home_dashboard_screen.dart';
import 'package:vedadarshi/features/horoscope/horoscope_signs_screen.dart';
import 'package:vedadarshi/features/kundli/kundli_input_screen.dart';
import 'package:vedadarshi/features/notifications/notifications_screen.dart';
import 'package:vedadarshi/features/panchang/panchang_screen.dart';
import 'package:vedadarshi/features/profile/profile_settings_screen.dart';
import 'package:vedadarshi/features/search/search_screen.dart';
import 'package:vedadarshi/l10n/app_localizations.dart';

Future<void> shoot(WidgetTester t, String name, Widget child) async {
  AppColors.applyBrightness(Brightness.dark);
  final key = GlobalKey();
  await t.pumpWidget(
    RepaintBoundary(
      key: key,
      child: ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
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
        home: child,
      ),
      ),
    ),
  );
  for (var i = 0; i < 8; i++) {
    await t.pump(const Duration(milliseconds: 200));
  }
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final img = await boundary.toImage(pixelRatio: 1.5);
  final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
  File('/tmp/darkshot/$name.png')
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('shots', (t) async {
    t.view.physicalSize = const Size(1080, 2340);
    t.view.devicePixelRatio = 3.0;
    addTearDown(t.view.resetPhysicalSize);

    for (final e in <String, Widget>{
      'home': const HomeDashboardScreen(),
      'panchang': const PanchangScreen(),
      'signs': const HoroscopeSignsScreen(),
      'kundli_input': const KundliInputScreen(),
      'articles': const ArticlesScreen(),
      'search': const SearchScreen(),
      'notifications': const NotificationsScreen(),
      'profile': const ProfileSettingsScreen(),
    }.entries) {
      await t.runAsync(() async {
        await shoot(t, e.key, e.value);
      });
    }
  });
}
