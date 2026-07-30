import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Shared motion vocabulary implementing the client-approved Figma motion
/// spec ("spec/motion-microinteractions", node 80:2, mobile page) — see
/// `projects/CLAUDE.md` for the full 8-point list. Centralizing this here
/// means nobody re-derives timing/curve values per screen, and it makes
/// clear which of the 8 spec items are actually wired up in the app today.
///
/// The 8 spec items, and their status:
///  1. Button press (scale + ripple) — IMPLEMENTED: scale 0.96 over 120ms
///     ease-out, spring back on release ([PressableScale], [kPressDuration],
///     [kPressScale]).
///  2. Fade-through page transitions — IMPLEMENTED: 250ms M3 fade-through
///     ([fadeThroughRoute], [kPageTransition]).
///  3. Shimmer loading — PENDING: blocked on real Vedika API responses to
///     know what a loading card should look like; the AI Astrologer chat in
///     particular needs this (client-noted ~1-2 min latency).
///  4. Nav pill slide — PARTIALLY IMPLEMENTED: the tapped tab's icon
///     micro-bounces (`lib/core/widgets/app_bottom_nav.dart`,
///     `_NavItemState._bounceController`). The saffron pill itself "sliding
///     between tabs with a spring curve" is PENDING — each tab push
///     rebuilds `AppBottomNav` from scratch (see that file's doc comment),
///     so there is no shared Hero/AnimatedContainer to slide between; it
///     lands with the
///     IndexedStack shell refactor already planned there.
///  5. Gold glow pulse on premium CTAs — DONE: [GoldGlowPulse], a soft
///     2-second breathing halo. Used on the Horoscope Detail premium teaser
///     (`horoscope_detail_screen.dart`); the Subscription Paywall (M4) will
///     reuse it once that screen exists.
///  6. Rotating ॐ pull-to-refresh — PENDING: blocked on a screen with real
///     refreshable data (Panchang/Home currently show static placeholder
///     data, so refreshing does nothing).
///  7. Gold particle burst on success — PENDING: blocked on a real success
///     event (e.g. payment complete, report generated) that doesn't exist
///     yet.
///  8. Hero-card parallax on scroll — PENDING: blocked on the Home
///     dashboard's scroll behaviour being finalized; deferred to avoid
///     rework.
///
/// [EntranceFadeSlide] (staggered fade+slide entrance, used by the
/// horoscope sign grid) is an additional building block supporting the
/// spec's general "smooth animations" requirement — it isn't one of the 8
/// named items above.

/// Duration of a button/card press-down scale animation.
const Duration kPressDuration = Duration(milliseconds: 120);

/// Scale factor a pressable shrinks to while held down.
const double kPressScale = 0.96;

/// Duration of a fade-through page transition.
const Duration kPageTransition = Duration(milliseconds: 250);

/// Duration of one staggered entrance item's fade+slide animation.
const Duration kEntranceDuration = Duration(milliseconds: 320);

/// Delay added per index in a staggered entrance list.
const Duration kEntranceStagger = Duration(milliseconds: 40);

/// Wraps [child] with a press-down scale animation (spec item 1) and a
/// Material ripple, without the two fighting each other.
///
/// The scale is driven by [GestureDetector.onTapDown]/`onTapUp`/`onTapCancel`
/// so it starts the instant a finger touches down; the ripple is owned by
/// the inner [InkWell], which also owns [onTap] so a tap is only counted
/// once. [borderRadius] is passed to both the [Material]/[InkWell] (so the
/// ripple is clipped correctly) and matched by the outer clip.
///
/// When [enabled] is false, renders [child] unchanged and ignores taps —
/// useful for a pressable that's temporarily disabled without having to be
/// swapped out of the tree.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    required this.onTap,
    this.borderRadius = BorderRadius.zero,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback onTap;
  final BorderRadius borderRadius;
  final bool enabled;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: kPressDuration,
      reverseDuration: const Duration(milliseconds: 260),
      lowerBound: 0,
      upperBound: 1,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (!widget.enabled) return;
    _controller.animateTo(1, duration: kPressDuration, curve: Curves.easeOut);
  }

  void _onTapEnd() {
    if (!widget.enabled) return;
    _controller.animateBack(
      0,
      duration: const Duration(milliseconds: 260),
      curve: Curves.elasticOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = Material(
      color: Colors.transparent,
      borderRadius: widget.borderRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.enabled ? widget.onTap : null,
        borderRadius: widget.borderRadius,
        child: widget.child,
      ),
    );

    if (!widget.enabled) return content;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: (_) => _onTapEnd(),
      onTapCancel: _onTapEnd,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = 1 - (_controller.value * (1 - kPressScale));
          return Transform.scale(scale: scale, child: child);
        },
        child: content,
      ),
    );
  }
}

/// M3 fade-through page route (spec item 2): the outgoing page fades out
/// over the first 30% of the transition, then the incoming page fades in
/// while scaling from 0.96 to 1.0.
Route<T> fadeThroughRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: kPageTransition,
    reverseTransitionDuration: kPageTransition,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final incomingOpacity = CurvedAnimation(
        parent: animation,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOutCubicEmphasized),
      );
      final outgoingOpacity = CurvedAnimation(
        parent: ReverseAnimation(secondaryAnimation),
        curve: const Interval(0.7, 1.0, curve: Curves.easeInOutCubicEmphasized),
      );
      final scale = Tween<double>(begin: 0.96, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(
            0.3,
            1.0,
            curve: Curves.easeInOutCubicEmphasized,
          ),
        ),
      );

      return FadeTransition(
        opacity: outgoingOpacity,
        child: FadeTransition(
          opacity: incomingOpacity,
          child: ScaleTransition(scale: scale, child: child),
        ),
      );
    },
  );
}

/// A single item in a staggered entrance list/grid: fades in and slides up
/// 12px over [kEntranceDuration], starting after `index * kEntranceStagger`
/// (capped so late items in a long list don't hang around waiting).
///
/// Implemented as a [StatefulWidget] with its own [AnimationController] so
/// the animation runs exactly once per mount and never restarts on rebuild
/// (a `TweenAnimationBuilder` keyed only by value would replay whenever its
/// target changed, which isn't what a one-shot entrance needs).
class EntranceFadeSlide extends StatefulWidget {
  const EntranceFadeSlide({
    super.key,
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  /// Cap on the stagger delay so item 20+ in a long list still starts
  /// within a reasonable time of the screen opening.
  static const Duration _maxDelay = Duration(milliseconds: 400);

  @override
  State<EntranceFadeSlide> createState() => _EntranceFadeSlideState();
}

class _EntranceFadeSlideState extends State<EntranceFadeSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: kEntranceDuration);
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _opacity = curved;
    _slide = Tween<Offset>(
      begin: const Offset(0, 12),
      end: Offset.zero,
    ).animate(curved);

    final rawDelay = kEntranceStagger * widget.index;
    final delay = rawDelay > EntranceFadeSlide._maxDelay
        ? EntranceFadeSlide._maxDelay
        : rawDelay;
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(offset: _slide.value, child: child),
        );
      },
      child: widget.child,
    );
  }
}

/// Soft gold glow "breathing halo" behind [child] (spec item 5): a 2-second
/// loop that pulses a gold [BoxShadow]'s blur and opacity, used behind
/// premium CTAs/cards (Yearly plan, Upgrade CTA, the Horoscope Detail
/// premium teaser).
///
/// Deliberately subtle — the shadow blur only ranges ~10→22 and its alpha
/// ~0.15→0.38, so it reads as a gentle glow rather than a flash. [borderRadius]
/// is applied to the same [DecoratedBox] so the glow follows the shape of
/// [child] (e.g. a rounded card).
class GoldGlowPulse extends StatefulWidget {
  const GoldGlowPulse({
    super.key,
    required this.child,
    this.borderRadius = BorderRadius.zero,
  });

  final Widget child;
  final BorderRadius borderRadius;

  @override
  State<GoldGlowPulse> createState() => _GoldGlowPulseState();
}

class _GoldGlowPulseState extends State<GoldGlowPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(
                  alpha: 0.15 + (0.38 - 0.15) * t,
                ),
                blurRadius: 10 + (22 - 10) * t,
                spreadRadius: 1,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
