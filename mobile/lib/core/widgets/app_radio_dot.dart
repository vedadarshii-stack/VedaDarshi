import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Hand-drawn circular radio-selection indicator (no image asset) — a
/// [size]×[size] circle whose border turns [AppColors.saffron] when
/// [isSelected], with a smaller solid saffron dot centered inside.
///
/// Extracted from the Language Select screen's private `_RadioIndicator`
/// (the first place this look was implemented) once the Kundli input
/// screen's profile card needed the exact same visual — rather than
/// re-implementing it a third time, both screens now share this one widget.
/// The inner dot is sized proportionally to [size] (`size * 10 / 22`), which
/// reproduces the Language Select screen's original 22px-circle/10px-dot
/// ratio exactly at its default `size`.
class AppRadioDot extends StatelessWidget {
  const AppRadioDot({super.key, required this.isSelected, this.size = 20});

  final bool isSelected;
  final double size;

  @override
  Widget build(BuildContext context) {
    final dotSize = size * 10 / 22;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.saffron : AppColors.cardBorder,
          width: 1.5,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.saffron,
                ),
              ),
            )
          : null,
    );
  }
}
