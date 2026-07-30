import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../l10n/app_localizations.dart';
import 'horoscope_static_data.dart';
import 'zodiac_sign.dart';

/// Which period a horoscope reading is shown for.
enum _HoroscopePeriod { daily, weekly, monthly, yearly }

/// Horoscope — All Signs, per the approved Figma "B3 · Horoscope — All
/// Signs" (node 15:2) concept.
///
/// Pushed from the Home dashboard's "Today's Horoscope" section (see
/// `_HoroscopeSection` in `home_dashboard_screen.dart`) via its "All signs"
/// action. Unlike Home and Panchang, this screen has NO bottom nav in the
/// design — it gets a back button instead, since it's a level deeper in the
/// navigation stack rather than a top-level tab.
///
/// The 12 signs themselves are fixed DATA ([kZodiacSigns]); which one is
/// the user's own sign is STATIC PLACEHOLDER DATA from
/// [HoroscopeStaticData]; see that file's doc comment for what eventually
/// replaces it (the Vedika API).
class HoroscopeSignsScreen extends ConsumerStatefulWidget {
  const HoroscopeSignsScreen({super.key});

  @override
  ConsumerState<HoroscopeSignsScreen> createState() =>
      _HoroscopeSignsScreenState();
}

class _HoroscopeSignsScreenState extends ConsumerState<HoroscopeSignsScreen> {
  _HoroscopePeriod _selectedPeriod = _HoroscopePeriod.daily;

  void _selectPeriod(_HoroscopePeriod period) {
    if (period == _selectedPeriod) return;
    setState(() => _selectedPeriod = period);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final isCompact = MediaQuery.sizeOf(context).height < 840;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, isCompact ? 32 : 56, 20, 24),
          children: [
            _Header(l10n: l10n, locale: locale),
            const SizedBox(height: 18),
            _PeriodChips(
              l10n: l10n,
              locale: locale,
              selectedPeriod: _selectedPeriod,
              onSelect: _selectPeriod,
            ),
            const SizedBox(height: 18),
            _SignGrid(l10n: l10n, locale: locale),
          ],
        ),
      ),
    );
  }
}

/// Back button + screen title.
class _Header extends StatelessWidget {
  const _Header({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Semantics(
          button: true,
          child: Material(
            color: Colors.white,
            shape: CircleBorder(side: BorderSide(color: AppColors.cardBorder)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: const SizedBox(
                width: 42,
                height: 42,
                child: Center(
                  child: Icon(Icons.arrow_back, size: 18, color: AppColors.ink),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            l10n.horoscopeTitle,
            style: AppFonts.heading(
              locale,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}

/// Daily / Weekly / Monthly / Yearly period selector.
///
/// Selection is fully functional local state, but the horoscope CONTENT on
/// this screen doesn't change with it yet — the selected period will drive
/// the Vedika API call once that data source is wired up in place of
/// [kZodiacSigns]' static presentation.
class _PeriodChips extends StatelessWidget {
  const _PeriodChips({
    required this.l10n,
    required this.locale,
    required this.selectedPeriod,
    required this.onSelect,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final _HoroscopePeriod selectedPeriod;
  final ValueChanged<_HoroscopePeriod> onSelect;

  @override
  Widget build(BuildContext context) {
    final periods = [
      (_HoroscopePeriod.daily, l10n.periodDaily),
      (_HoroscopePeriod.weekly, l10n.periodWeekly),
      (_HoroscopePeriod.monthly, l10n.periodMonthly),
      (_HoroscopePeriod.yearly, l10n.periodYearly),
    ];

    return Row(
      children: [
        for (var i = 0; i < periods.length; i++) ...[
          if (i != 0) const SizedBox(width: 8),
          Expanded(
            child: _PeriodChip(
              label: periods[i].$2,
              locale: locale,
              isSelected: periods[i].$1 == selectedPeriod,
              onTap: () => onSelect(periods[i].$1),
            ),
          ),
        ],
      ],
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.locale,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final Locale locale;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      child: PressableScale(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.saffron : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: isSelected ? null : Border.all(color: AppColors.cardBorder),
          ),
          child: Center(
            // Allowed to shrink: 4 chips across a 360dp screen is tight,
            // and "Monthly"/"Yearly" run noticeably longer in
            // Telugu/Tamil/Kannada.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppFonts.body(
                  locale,
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white : AppColors.muted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 3-column grid of all 12 zodiac sign cards, laid out as four [Row]s
/// rather than a [GridView] with a fixed aspect ratio: the user's-own-sign
/// card carries an extra "Your sign" badge that the other 11 don't, so a
/// fixed aspect ratio would either clip that badge or leave dead space in
/// every other card. Each row is wrapped in [IntrinsicHeight] so its three
/// cards match height regardless.
class _SignGrid extends StatelessWidget {
  const _SignGrid({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var row = 0; row < 4; row++) ...[
          if (row != 0) const SizedBox(height: 12),
          _SignRow(
            signs: kZodiacSigns.sublist(row * 3, row * 3 + 3),
            baseIndex: row * 3,
            l10n: l10n,
            locale: locale,
          ),
        ],
      ],
    );
  }
}

class _SignRow extends StatelessWidget {
  const _SignRow({
    required this.signs,
    required this.baseIndex,
    required this.l10n,
    required this.locale,
  });

  final List<ZodiacSign> signs;
  final int baseIndex;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          for (var i = 0; i < signs.length; i++) ...[
            if (i != 0) const SizedBox(width: 12),
            Expanded(
              child: EntranceFadeSlide(
                index: baseIndex + i,
                child: _SignCard(sign: signs[i], l10n: l10n, locale: locale),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SignCard extends StatelessWidget {
  const _SignCard({
    required this.sign,
    required this.l10n,
    required this.locale,
  });

  final ZodiacSign sign;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final isUserSign = sign.id == HoroscopeStaticData.userSignId;

    return Semantics(
      button: true,
      selected: isUserSign,
      label: '${sign.sanskritName} ${sign.englishName}',
      child: PressableScale(
        borderRadius: BorderRadius.circular(18),
        // No-op for now: opens "B4 · Horoscope Detail" once that screen
        // is built.
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.only(top: 16, bottom: 14),
          decoration: BoxDecoration(
            color: isUserSign ? AppColors.genderSelectedBg : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isUserSign ? AppColors.saffron : AppColors.cardBorder,
              width: isUserSign ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.navyHeroGradient,
                ),
                child: Text(
                  sign.glyph,
                  style: AppFonts.zodiac(fontSize: 22, color: AppColors.gold),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                sign.sanskritName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.body(
                  locale,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              // Forced to 'en' regardless of the app's active locale —
              // these are the English zodiac names, not translated UI
              // chrome.
              Text(
                sign.englishName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.body(
                  const Locale('en'),
                  fontSize: 10,
                  color: AppColors.hint,
                ),
              ),
              if (isUserSign) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.saffron,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    l10n.yourSign,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.body(
                      locale,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
