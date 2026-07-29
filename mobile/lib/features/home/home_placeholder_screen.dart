import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/widgets/app_logo.dart';
import '../../l10n/app_localizations.dart';

/// Temporary shell shown after the splash screen.
///
/// This is a placeholder until the M1 home dashboard screens (per the
/// approved Figma "Core" section) are implemented.
class HomePlaceholderScreen extends StatelessWidget {
  const HomePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(size: 88),
            const SizedBox(height: 16),
            Text(
              l10n.appName,
              style: AppFonts.heading(
                locale,
                fontWeight: FontWeight.w700,
                fontSize: 26,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
