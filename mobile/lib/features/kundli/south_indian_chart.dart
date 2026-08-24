import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import 'kundli_chart_static_data.dart';

/// South Indian (grid) birth chart.
///
/// BUILT 21 Aug 2026, replacing the "South Indian chart layout is coming
/// soon." placeholder that had shipped behind a prominent, fully-styled
/// toggle since the screen was first built.
///
/// ## How it differs from [NorthIndianChart] — the whole point
///
/// North Indian: the twelve compartments ARE the houses. House 1 is always
/// the top diamond, and the RASHIS rotate around it. A planet is placed by
/// its house number alone.
///
/// South Indian: the exact inverse. The twelve boxes are fixed RASHIS in a
/// fixed 4×4 ring — Aries is always second-from-left on the top row, and the
/// signs run CLOCKWISE from there — and the house numbers rotate depending
/// on where the Ascendant falls. A planet therefore cannot be placed by
/// house; it must be placed by sign, which is why [ChartPlanet.signNumber]
/// was added alongside this widget.
///
/// The centre 2×2 is empty by convention; this implementation puts the
/// chart's identity there (Lagna sign) rather than leaving dead space.
///
/// Sized by its parent — like [NorthIndianChart], every measurement derives
/// from the canvas [Size], never a hardcoded pixel, so it scales to any
/// width. Wrap in `AspectRatio(aspectRatio: 1, …)`.
class SouthIndianChart extends StatelessWidget {
  const SouthIndianChart({super.key, required this.planets});

  final List<ChartPlanet> planets;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _SouthIndianChartPainter(planets),
    );
  }
}

/// Grid position of each rashi, as (column, row) in the 4×4 ring.
///
/// This layout is FIXED and traditional — it is not a design choice and must
/// not be "tidied". Aries sits at column 1 of the top row and the signs
/// advance clockwise; every South Indian chart a user has ever seen reads
/// this way, so any other arrangement would be read as simply wrong.
const Map<int, ({int col, int row})> _signCells = {
  12: (col: 0, row: 0), // Pisces
  1: (col: 1, row: 0), // Aries
  2: (col: 2, row: 0), // Taurus
  3: (col: 3, row: 0), // Gemini
  11: (col: 0, row: 1), // Aquarius
  4: (col: 3, row: 1), // Cancer
  10: (col: 0, row: 2), // Capricorn
  5: (col: 3, row: 2), // Leo
  9: (col: 0, row: 3), // Sagittarius
  8: (col: 1, row: 3), // Scorpio
  7: (col: 2, row: 3), // Libra
  6: (col: 3, row: 3), // Virgo
};

/// Three-letter rashi labels, Latin script.
///
/// Deliberately not localised, for the same reason the planet abbreviations
/// and house numbers in [NorthIndianChart] are not: these are graphical
/// chart notation, not UI copy.
const Map<int, String> _signLabels = {
  1: 'Ari',
  2: 'Tau',
  3: 'Gem',
  4: 'Can',
  5: 'Leo',
  6: 'Vir',
  7: 'Lib',
  8: 'Sco',
  9: 'Sag',
  10: 'Cap',
  11: 'Aqu',
  12: 'Pis',
};

class _SouthIndianChartPainter extends CustomPainter {
  _SouthIndianChartPainter(this.planets)
    : _ascendantSign = _resolveAscendantSign(planets),
      _bySign = _groupBySign(planets);

  final List<ChartPlanet> planets;
  final int? _ascendantSign;
  final Map<int, List<ChartPlanet>> _bySign;

  static int? _resolveAscendantSign(List<ChartPlanet> planets) {
    for (final planet in planets) {
      if (planet.code == PlanetCode.ascendant) return planet.signNumber;
    }
    return null;
  }

  /// Groups planets by the rashi they occupy.
  ///
  /// Prefers each planet's own `signNumber`. When Vedika omitted it, the
  /// sign is DERIVED from the Ascendant: house 1 is by definition the
  /// Ascendant's rashi, so sign = ascendantSign + (house - 1), wrapped to
  /// 1–12. That keeps a planet on the chart instead of silently dropping
  /// it — and the derivation is exact, not a guess, because the two
  /// coordinate systems are related by that single rotation.
  ///
  /// A planet with neither its own sign nor a resolvable Ascendant is
  /// dropped, matching `KundliPlanet.toChartPlanet`'s existing rule of
  /// never guessing a placement.
  static Map<int, List<ChartPlanet>> _groupBySign(List<ChartPlanet> planets) {
    final ascendantSign = _resolveAscendantSign(planets);
    final map = <int, List<ChartPlanet>>{};
    for (final planet in planets) {
      final sign =
          planet.signNumber ??
          (ascendantSign == null
              ? null
              : ((ascendantSign - 1 + planet.house - 1) % 12) + 1);
      if (sign == null || sign < 1 || sign > 12) continue;
      map.putIfAbsent(sign, () => []).add(planet);
    }
    return map;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cell = Size(size.width / 4, size.height / 4);

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = AppColors.chartPaper,
    );

    final line = Paint()
      ..color = AppColors.chartLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.004;

    for (final entry in _signCells.entries) {
      final sign = entry.key;
      final rect = Rect.fromLTWH(
        entry.value.col * cell.width,
        entry.value.row * cell.height,
        cell.width,
        cell.height,
      );

      // The Lagna box gets a filled tint plus a corner diagonal — the
      // traditional way a South Indian chart marks the ascendant. Drawn
      // BEFORE the border so the stroke stays crisp on top.
      if (sign == _ascendantSign) {
        canvas.drawRect(
          rect,
          Paint()..color = AppColors.saffron.withValues(alpha: 0.16),
        );
        canvas.drawLine(
          rect.topLeft,
          rect.topLeft + Offset(cell.width * 0.28, cell.height * 0.28),
          Paint()
            ..color = AppColors.saffron
            ..strokeWidth = size.width * 0.006,
        );
      }

      canvas.drawRect(rect, line);
      _paintSignLabel(canvas, size, rect, sign);

      final signPlanets = _bySign[sign];
      if (signPlanets != null && signPlanets.isNotEmpty) {
        _paintPlanets(canvas, size, rect, signPlanets);
      }
    }

    _paintCentre(canvas, size, cell);
  }

  void _paintSignLabel(Canvas canvas, Size size, Rect rect, int sign) {
    final painter = TextPainter(
      text: TextSpan(
        text: _signLabels[sign] ?? '',
        style: AppFonts.body(
          const Locale('en'),
          fontSize: size.width * 0.028,
          color: AppColors.chartHouseNumber,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    // Bottom-left of the box, so it never collides with the planet stack
    // that grows downward from the top.
    painter.paint(
      canvas,
      Offset(
        rect.left + size.width * 0.014,
        rect.bottom - painter.height - size.width * 0.012,
      ),
    );
  }

  /// Planets stacked vertically from the top of the box.
  ///
  /// Vertical rather than the North chart's single line: a South Indian box
  /// is a quarter of the chart's width, and a stellium of four or five
  /// planets in one rashi is common — laid out horizontally they would
  /// overflow the box.
  void _paintPlanets(
    Canvas canvas,
    Size size,
    Rect rect,
    List<ChartPlanet> signPlanets,
  ) {
    final fontSize = size.width * 0.036;
    final lineHeight = fontSize * 1.25;
    var dy = rect.top + size.width * 0.016;

    for (final planet in signPlanets) {
      final color = planet.code.chartColor;
      final spans = <InlineSpan>[
        TextSpan(
          text: planet.code.shortLabel,
          style: AppFonts.body(
            const Locale('en'),
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ];
      if (planet.isExalted) spans.add(_markerSpan(Icons.arrow_upward, fontSize, color));
      if (planet.isRetrograde) spans.add(_retrogradeSpan(fontSize, color));

      final painter = TextPainter(
        text: TextSpan(children: spans),
        textDirection: TextDirection.ltr,
      )..layout();

      // Stop before spilling out of the box rather than drawing over the
      // sign label or the neighbouring cell.
      if (dy + painter.height > rect.bottom - size.width * 0.05) break;
      painter.paint(canvas, Offset(rect.left + size.width * 0.014, dy));
      dy += lineHeight;
    }
  }

  /// Lagna sign in the empty 2×2 centre — the convention leaves it blank,
  /// but naming the chart's anchor there is what makes the rotating house
  /// numbers interpretable at a glance.
  void _paintCentre(Canvas canvas, Size size, Size cell) {
    final label = _ascendantSign == null
        ? null
        : _signLabels[_ascendantSign];
    if (label == null) return;

    final painter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Lagna\n',
            style: AppFonts.body(
              const Locale('en'),
              fontSize: size.width * 0.030,
              color: AppColors.chartHouseNumber,
            ),
          ),
          TextSpan(
            text: label,
            style: AppFonts.heading(
              const Locale('en'),
              fontSize: size.width * 0.055,
              fontWeight: FontWeight.w600,
              color: AppColors.saffron,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    final centre = Offset(size.width / 2, size.height / 2);
    painter.paint(
      canvas,
      centre - Offset(painter.width / 2, painter.height / 2),
    );
  }

  /// Same rationale as `NorthIndianChart`'s exalted marker: U+2191 has no
  /// glyph in any bundled font and would render as tofu, so the Material
  /// icon is painted inside the same TextPainter. See the ICON RULE in
  /// projects/CLAUDE.md.
  InlineSpan _markerSpan(IconData icon, double fontSize, Color color) {
    return TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        fontSize: fontSize * 0.7,
        color: color,
      ),
    );
  }

  /// Retrograde is drawn as an italic 'R' — U+211E (℞) is likewise absent
  /// from every bundled face.
  InlineSpan _retrogradeSpan(double fontSize, Color color) {
    return TextSpan(
      text: 'R',
      style: AppFonts.body(
        const Locale('en'),
        fontSize: fontSize * 0.72,
        color: color,
      ).copyWith(fontStyle: FontStyle.italic),
    );
  }

  @override
  bool shouldRepaint(covariant _SouthIndianChartPainter oldDelegate) =>
      oldDelegate.planets != planets;
}
