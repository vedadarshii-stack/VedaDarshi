import 'package:flutter/material.dart';

import '../../features/ai/ai_astrologer_screen.dart';
import '../../l10n/app_localizations.dart';
import '../motion/app_motion.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';

/// "Ask Rishi AI about this" — opens the AI chat with a question already
/// typed about whatever the user is currently looking at.
///
/// BUILT 2 Sep 2026 for the client's request: *"in kundali section on
/// planets page and vimsottara dasha and predictions pages add ask ai for
/// any details so that if anyone get any doubt they can simply ask ai"*, and
/// the same for the Gun Milan compatibility page.
///
/// ## Why one widget rather than four buttons
///
/// It appears in four places already and the behaviour must not drift
/// between them — particularly the decision NOT to auto-send (see
/// [AiAstrologerScreen.initialQuestion]).
///
/// ## Why it is not premium-gated
///
/// Deliberately open to everyone, consistent with the client's reasoning
/// when they un-gated the AI profile picker: the free tier already allows a
/// question a day and the server enforces that, so the gate adds nothing but
/// friction in front of the very thing that sells AI packs.
class AskAiButton extends StatelessWidget {
  const AskAiButton({super.key, required this.locale, required this.question});

  final Locale locale;

  /// The question to pre-fill. Pass one of the `askAiSeed*` l10n strings so
  /// it arrives in the user's own language.
  final String question;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      button: true,
      child: PressableScale(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.of(context).push(
          fadeThroughRoute(AiAstrologerScreen(initialQuestion: question)),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.surface,
            // An OUTLINED button, not the saffron gradient: this is a
            // helpful side-door, and giving it the same weight as the
            // screen's real primary action (Generate, Upgrade) would compete
            // with it on every screen it appears on.
            border: Border.all(color: AppColors.saffron.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome_outlined,
                size: 16,
                color: AppColors.saffron,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  l10n.askAiButton,
                  textAlign: TextAlign.center,
                  style: AppFonts.body(
                    locale,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.saffron,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
