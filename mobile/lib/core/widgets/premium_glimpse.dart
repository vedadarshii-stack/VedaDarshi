import 'package:flutter/material.dart';

import '../motion/app_motion.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';

/// Shows the FIRST part of a premium reading, fades it out, and puts an
/// upgrade call-to-action over the fade.
///
/// BUILT 2 Sep 2026. The client asked for the same thing in three separate
/// places — *"for reports after clicking show sample glimpse report set like
/// that so that it can engage users"*, *"for detailed description show
/// glimpse and call to action for taking subscription"* (Gun Milan), and the
/// same for Kundli Predictions. This exists so that is ONE component with
/// one behaviour, rather than three hand-rolled teasers that drift apart.
///
/// ## Why a glimpse instead of a locked door
///
/// Every one of those screens previously did the same thing: tapping a
/// premium item pushed the paywall immediately, showing the user nothing.
/// That asks someone to pay for a thing they have not seen. A glimpse
/// inverts it — real content, genuinely theirs, cut off at the point it gets
/// specific.
///
/// ## The content must be REAL
///
/// [child] must be the actual reading, not a mock. Fading out invented text
/// would be worse than the locked door, because the user cannot tell that
/// what they are being sold does not exist. Every caller passes content
/// already fetched from Vedika. If a caller has nothing real to show, it
/// should render nothing and not use this widget.
///
/// ## Why the fade is a mask, not an opacity
///
/// The gradient paints the SURFACE colour over the content, so the cut-off
/// reads as the page continuing underneath rather than as broken/greyed-out
/// text. `AppColors.surface` is theme-aware, so this works in both
/// brightnesses without a second code path — see the SURFACE RULE in
/// `projects/CLAUDE.md`.
class PremiumGlimpse extends StatelessWidget {
  const PremiumGlimpse({
    super.key,
    required this.locale,
    required this.child,
    required this.ctaLabel,
    required this.onUpgrade,
    this.previewHeight = 190,
    this.subtitle,
    this.isBusy = false,
  });

  final Locale locale;

  /// The REAL reading. See the class doc — never a placeholder.
  final Widget child;

  /// Upgrade button copy, e.g. "Unlock the full reading".
  final String ctaLabel;

  final VoidCallback onUpgrade;

  /// Whether a purchase is in flight.
  ///
  /// ADDED 10 Sep 2026. The buy buttons previously gave NO feedback between
  /// the tap and Play's sheet appearing — which on a slow connection is
  /// several seconds of a button that looks like it did nothing. The result
  /// is a second tap, and the caller's `_isBusy` guard silently swallowing
  /// it, so the user is left believing the purchase is broken.
  ///
  /// The spinner replaces the label rather than sitting beside it, so the
  /// button never changes width mid-press.
  final bool isBusy;

  /// One line above the button saying what unlocking actually gets them.
  /// Keep it concrete ("all 8 koota readings and remedies"), not "go
  /// premium" — a vague promise is what makes a paywall feel like a wall.
  final String? subtitle;

  /// How much of the reading is visible before the fade begins.
  ///
  /// Deliberately generous: the glimpse has to be worth reading on its own,
  /// or it is a tease rather than a sample. Callers with short content
  /// should lower it so the fade never starts past the end of the text,
  /// which would look like a rendering bug.
  final double previewHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The preview is CLIPPED, not scrollable — a scrollable preview
        // inside a scrolling page traps the user's drag and, worse, would
        // let them read the whole thing.
        ClipRect(
          child: SizedBox(
            height: previewHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Aligned to the top so the reading starts at its first
                // line rather than being vertically centred inside the box.
                OverflowBox(
                  alignment: Alignment.topLeft,
                  minHeight: 0,
                  maxHeight: double.infinity,
                  child: child,
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: previewHeight * 0.55,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.surface.withValues(alpha: 0),
                            AppColors.surface.withValues(alpha: 0.85),
                            AppColors.surface,
                          ],
                          stops: const [0, 0.6, 1],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (subtitle case final text?) ...[
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppFonts.body(locale, fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 10),
        ],
        PressableScale(
          borderRadius: BorderRadius.circular(999),
          onTap: onUpgrade,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: AppColors.saffronGradient,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: AppColors.saffron.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: isBusy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Text(
                      ctaLabel,
                      style: AppFonts.body(
                        locale,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
