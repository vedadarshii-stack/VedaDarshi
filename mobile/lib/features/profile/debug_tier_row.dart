import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/app_motion.dart';
import '../../core/purchases/debug_tier_override.dart';
import '../../core/purchases/subscription_tier.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';

/// Debug-only tier switcher for the Profile screen.
///
/// BUILT 9 Sep 2026. Flips the app between free / bronze / silver / gold /
/// platinum at runtime so every entitlement gate can be checked in seconds,
/// without a Play purchase and without a restart.
///
/// ⚠️ **Renders NOTHING unless [DebugTierOverride.isAvailable]**, which is
/// `kDebugMode`. In a release build this widget collapses to a
/// `SizedBox.shrink()` and the whole file tree-shakes away — verified by
/// grepping a built release APK.
///
/// ## Copy is deliberately NOT localized
///
/// Every other user-facing string in this app goes through l10n; this one
/// does not, on purpose. It can never be seen by a user, and adding five
/// translations of "Debug: subscription tier" to the ARB files would put
/// developer scaffolding into the same files a translator reviews. The
/// deliberate exception is noted here so it does not read as an oversight.
class DebugTierRow extends ConsumerWidget {
  const DebugTierRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!DebugTierOverride.isAvailable) return const SizedBox.shrink();

    final locale = Localizations.localeOf(context);
    final forced = ref.watch(debugTierControllerProvider);

    return Container(
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        // Intentionally loud: this must never be mistaken for a real setting
        // if a build ever reaches someone outside the team.
        color: AppColors.ashubhBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.ashubhFg.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bug_report, size: 15, color: AppColors.ashubhFg),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Debug: subscription tier',
                  style: AppFonts.body(
                    locale,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ashubhFg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            forced == null
                ? 'Using the real entitlement. Pick a tier to fake one.'
                : 'Faking ${_capitalise(forced.name)} — client-side gates only. '
                      'Server quotas (AI questions, packs) ignore this.',
            style: AppFonts.body(
              locale,
              fontSize: 10.5,
              color: AppColors.ashubhFg.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              // "Real" is first and is the resting state, so the way back to
              // truth is always the nearest control.
              _TierChip(
                label: 'Real',
                selected: forced == null,
                locale: locale,
                onTap: () =>
                    ref.read(debugTierControllerProvider.notifier).set(null),
              ),
              for (final tier in SubscriptionTier.values)
                _TierChip(
                  // `tier.name` is lowercase ("gold"), which sat next to a
                  // capitalised "Real" and read as a typo. Capitalised here
                  // rather than renaming the enum, whose lowercase values are
                  // correct — they match RevenueCat's entitlement keys.
                  label: _capitalise(tier.name),
                  selected: forced == tier,
                  locale: locale,
                  onTap: () =>
                      ref.read(debugTierControllerProvider.notifier).set(tier),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

String _capitalise(String value) =>
    value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);

class _TierChip extends StatelessWidget {
  const _TierChip({
    required this.label,
    required this.selected,
    required this.locale,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Locale locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: PressableScale(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.ashubhFg : AppColors.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.ashubhFg),
          ),
          child: Text(
            label,
            style: AppFonts.body(
              locale,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.surface : AppColors.ashubhFg,
            ),
          ),
        ),
      ),
    );
  }
}
