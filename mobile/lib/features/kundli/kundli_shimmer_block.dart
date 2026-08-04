import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// A single pulsing placeholder block — [AppColors.cardBorder] breathing
/// into [AppColors.surfaceAlt] and back over 1.1s, looping. Shared by every
/// loading state on the Kundli Chart screen (Chart tab, Planet Positions
/// tab, Vimshottari Dasha tab) — per the app's motion spec ("shimmer
/// skeletons on all cards, NO spinners on content screens",
/// `projects/CLAUDE.md`'s motion-spec table item 3). Originally private to
/// `kundli_chart_screen.dart`; promoted to a shared widget once the Planet
/// Positions and Dasha tabs needed the same loading treatment as the Chart
/// tab, rather than duplicating the animation three times.
class KundliShimmerBlock extends StatefulWidget {
  const KundliShimmerBlock({super.key, this.height, required this.borderRadius});

  final double? height;
  final BorderRadius borderRadius;

  @override
  State<KundliShimmerBlock> createState() => _KundliShimmerBlockState();
}

class _KundliShimmerBlockState extends State<KundliShimmerBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
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
      builder: (context, _) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: Color.lerp(
              AppColors.cardBorder,
              AppColors.surfaceAlt,
              _controller.value,
            ),
            borderRadius: widget.borderRadius,
          ),
        );
      },
    );
  }
}
