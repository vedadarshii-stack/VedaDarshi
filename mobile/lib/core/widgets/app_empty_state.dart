import 'package:flutter/material.dart';

import '../motion/app_motion.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';

/// Shared empty-state card, matching the approved Figma "F1 · Empty States"
/// gallery (node 56:3) — a white, bordered, rounded card with a tinted icon
/// circle, a title, a short message and an optional action pill.
///
/// The gallery shows 7 example states (No Internet, No Notifications, No
/// Results, No Reports Yet, No Articles, No AI Chats Yet, No Birth Profiles)
/// as a DESIGN REFERENCE, not a screen to route to — this widget is the
/// reusable building block extracted from it. Only 2 of the 7 have a real
/// call site in the app today (Search's no-results state and Notifications'
/// empty state); the rest are not wired up because nothing in the app can
/// currently reach that state (see each skipped state's rationale in
/// `projects/CLAUDE.md`'s progress notes rather than duplicated here).
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    this.icon,
    this.emoji,
    required this.iconBackgroundColor,
    required this.iconForegroundColor,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  }) : assert(
         (icon == null) != (emoji == null),
         'Provide exactly one of icon or emoji',
       );

  /// A Material icon for the tinted circle — use this for a symbol that has
  /// no true colour-emoji glyph (per the project's ICON RULE), e.g.
  /// [Icons.search_off].
  final IconData? icon;

  /// A colour emoji for the tinted circle, rendered as text (per the ICON
  /// RULE, colour emoji render fine via the system emoji font) — e.g. `'🔕'`.
  final String? emoji;

  final Color iconBackgroundColor;
  final Color iconForegroundColor;

  final String title;
  final String message;

  /// Optional action pill (e.g. "Retry", "Enable alerts"). Both
  /// [actionLabel] and [onAction] must be supplied together for the pill to
  /// render — a call site with no real action simply omits both.
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final hasAction = actionLabel != null && onAction != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 30, 18, 26),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: icon != null
                ? Icon(icon, size: 28, color: iconForegroundColor)
                : Text(emoji!, style: AppFonts.body(locale, fontSize: 28)),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.heading(
              locale,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.body(
              locale,
              fontSize: 11.5,
              color: AppColors.muted,
            ),
          ),
          if (hasAction) ...[
            const SizedBox(height: 12),
            Semantics(
              button: true,
              label: actionLabel,
              child: PressableScale(
                borderRadius: BorderRadius.circular(999),
                onTap: onAction!,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.genderSelectedBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    actionLabel!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.body(
                      locale,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.genderSelectedText,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
