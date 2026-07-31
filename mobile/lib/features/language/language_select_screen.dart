import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/locale/locale_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/widgets/app_radio_dot.dart';
import '../../l10n/app_localizations.dart';
import '../auth/welcome_login_screen.dart';

/// Language options offered on the language select screen, in display
/// order. Each name is rendered in its own script/locale (see
/// [_LanguageCard]) regardless of the currently active app locale.
class _LanguageOption {
  const _LanguageOption(this.languageCode, this.nativeName, this.englishName);

  final String languageCode;
  final String nativeName;
  final String englishName;
}

const List<_LanguageOption> _languageOptions = [
  _LanguageOption('en', 'English', 'English'),
  _LanguageOption('hi', 'हिन्दी', 'Hindi'),
  _LanguageOption('te', 'తెలుగు', 'Telugu'),
  _LanguageOption('ta', 'தமிழ்', 'Tamil'),
  _LanguageOption('kn', 'ಕನ್ನಡ', 'Kannada'),
];

const List<String> _supportedLanguageCodes = ['en', 'hi', 'te', 'ta', 'kn'];

/// Language select screen, matching the approved Figma "A2 · Language
/// Select" (node 6:2) concept.
///
/// Tapping a card previews the choice live — the whole screen (and, since
/// locale is app-wide state, the whole app) instantly re-renders in that
/// language — before the user confirms with Continue and proceeds to Home.
class LanguageSelectScreen extends ConsumerStatefulWidget {
  const LanguageSelectScreen({super.key});

  @override
  ConsumerState<LanguageSelectScreen> createState() =>
      _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends ConsumerState<LanguageSelectScreen> {
  String? _selectedCode;

  /// The decorative native-script prompt is always shown in Hindi when the
  /// active app locale is English (per the approved design); every other
  /// locale shows its own native prompt.
  Locale _promptLocale(Locale locale) {
    return locale.languageCode == 'en' ? const Locale('hi') : locale;
  }

  void _selectLanguage(String code) {
    setState(() => _selectedCode = code);
    ref.read(localeControllerProvider.notifier).setLocale(Locale(code));
  }

  /// Confirms the chosen language and proceeds to the Welcome/Login screen
  /// (per the confirmed onboarding flow: Language Select → Welcome/Login →
  /// Home).
  void _goToWelcome() {
    Navigator.of(context).pushReplacement<void, void>(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const WelcomeLoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final chosenLocale = ref.watch(localeControllerProvider);
    final selectedCode =
        _selectedCode ??
        (_supportedLanguageCodes.contains(chosenLocale?.languageCode)
            ? chosenLocale!.languageCode
            : (_supportedLanguageCodes.contains(locale.languageCode)
                  ? locale.languageCode
                  : 'en'));

    // Five cards plus a header and CTA is a tall stack, so compact phones
    // get tighter padding/spacing to fit the whole screen without scrolling;
    // taller screens keep the roomier Figma proportions.
    final isCompact = MediaQuery.sizeOf(context).height < 840;
    final sectionGap = isCompact ? 18.0 : 28.0;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: isCompact ? 32 : 64,
            bottom: 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(l10n: l10n, locale: locale, promptLocale: _promptLocale),
              SizedBox(height: sectionGap),
              Column(
                children: [
                  for (final option in _languageOptions) ...[
                    _LanguageCard(
                      option: option,
                      isSelected: option.languageCode == selectedCode,
                      isCompact: isCompact,
                      onTap: () => _selectLanguage(option.languageCode),
                    ),
                    if (option != _languageOptions.last)
                      SizedBox(height: isCompact ? 10 : 12),
                  ],
                ],
              ),
              SizedBox(height: sectionGap),
              _ContinueButton(l10n: l10n, locale: locale, onTap: _goToWelcome),
            ],
          ),
        ),
      ),
    );
  }
}

/// Section 1 — "ॐ" glyph, title and script-mixed subtitle.
class _Header extends StatelessWidget {
  const _Header({
    required this.l10n,
    required this.locale,
    required this.promptLocale,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final Locale Function(Locale) promptLocale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Forced to the 'hi' locale because ॐ is Devanagari and has no
        // glyph in the Latin-only Poppins/Playfair faces.
        Text(
          'ॐ',
          style: AppFonts.body(
            const Locale('hi'),
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppColors.saffron,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          l10n.languageTitle,
          style: AppFonts.heading(
            locale,
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 10),
        // The two spans need different fonts: the native-script prompt is
        // rendered via its own locale's Noto face (Latin-only Poppins has
        // no Devanagari/Telugu/Tamil/Kannada glyphs), while the separator
        // and settings hint follow the active app locale.
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: l10n.languageNativePrompt,
                style: AppFonts.body(
                  promptLocale(locale),
                  fontSize: 13,
                  color: AppColors.muted,
                ),
              ),
              TextSpan(
                text: ' · ${l10n.languageSettingsHint}',
                style: AppFonts.body(
                  locale,
                  fontSize: 13,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Section 2 — a single tappable, animated language choice card.
class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.option,
    required this.isSelected,
    required this.isCompact,
    required this.onTap,
  });

  final _LanguageOption option;
  final bool isSelected;
  final bool isCompact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: option.englishName,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: double.infinity,
            padding: EdgeInsets.all(isCompact ? 14 : 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.saffron : AppColors.cardBorder,
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.saffron.withValues(alpha: 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Each option is styled in its OWN locale, so e.g.
                      // Telugu/Tamil/Kannada names always get their correct
                      // Noto face regardless of the currently active app
                      // language.
                      Text(
                        option.nativeName,
                        style: AppFonts.body(
                          Locale(option.languageCode),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        option.englishName,
                        style: AppFonts.body(
                          const Locale('en'),
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // size: 22 preserves this screen's original radio-indicator
                // size exactly (the shared widget's default of 20 is for the
                // Kundli input screen's smaller profile-card indicator).
                AppRadioDot(isSelected: isSelected, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Section 3 — full-width saffron-gradient "Continue" CTA.
class _ContinueButton extends StatelessWidget {
  const _ContinueButton({
    required this.l10n,
    required this.locale,
    required this.onTap,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: AppColors.saffron.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 17),
            decoration: BoxDecoration(gradient: AppColors.saffronGradient),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.continueLabel,
                  style: AppFonts.body(
                    locale,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
