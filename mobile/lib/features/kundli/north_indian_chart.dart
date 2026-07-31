import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import 'kundli_chart_static_data.dart';

/// Draws the classic North Indian (diamond) Kundli chart — see "B6 · Kundli
/// Chart" (Figma node 18:2, chart card 18:20).
///
/// The Figma export represents the diamond as six separately-rotated 1.2px
/// rectangles — that's an artefact of how the design tool records the
/// shape, not a real drawing instruction. This widget draws the standard
/// North Indian construction properly instead: a square, its two full
/// diagonals, and a diamond connecting the MIDPOINTS of the four sides.
/// Square + 2 diagonals + midpoint-diamond is exactly the classic layout
/// and yields the 12 house regions.
///
/// Sized by its parent (wrap in e.g. `AspectRatio(aspectRatio: 1, ...)`) —
/// every measurement inside the painter is computed from the canvas
/// [Size] it's given, never a hardcoded pixel value, so it scales to any
/// screen width.
class NorthIndianChart extends StatelessWidget {
  const NorthIndianChart({super.key, required this.planets});

  final List<ChartPlanet> planets;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _NorthIndianChartPainter(planets),
    );
  }
}

class _NorthIndianChartPainter extends CustomPainter {
  _NorthIndianChartPainter(this.planets) : _byHouse = _groupByHouse(planets);

  final List<ChartPlanet> planets;
  final Map<int, List<ChartPlanet>> _byHouse;

  static Map<int, List<ChartPlanet>> _groupByHouse(
    List<ChartPlanet> planets,
  ) {
    final map = <int, List<ChartPlanet>>{};
    for (final planet in planets) {
      map.putIfAbsent(planet.house, () => []).add(planet);
    }
    return map;
  }

  /// Normalized (fraction-of-[Size]) centre points for each house's NUMBER
  /// label, measured on the approved 320×320 Figma chart and expressed as
  /// fractions so they scale to any rendered size.
  static const Map<int, Offset> _houseAnchors = {
    1: Offset(0.500, 0.285),
    2: Offset(0.245, 0.105),
    3: Offset(0.115, 0.235),
    4: Offset(0.295, 0.485),
    5: Offset(0.115, 0.740),
    6: Offset(0.245, 0.870),
    7: Offset(0.500, 0.700),
    8: Offset(0.755, 0.870),
    9: Offset(0.885, 0.740),
    10: Offset(0.700, 0.485),
    11: Offset(0.885, 0.235),
    12: Offset(0.755, 0.105),
  };

  /// Houses in the upper half of the chart: their planet-label group is
  /// offset UPWARD from the house-number anchor. Houses 4–9 (not in this
  /// set) are the lower half and offset DOWNWARD instead — see
  /// [_paintPlanetGroup]. Keeps planet text clear of the house-number digit
  /// regardless of chart size.
  static const Set<int> _upperHalfHouses = {1, 2, 3, 10, 11, 12};

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // 1. Square border, filled paper background, rounded corners.
    const strokeWidth = 1.5;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, width, height).deflate(strokeWidth / 2),
      const Radius.circular(4),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = AppColors.chartPaper
        ..style = PaintingStyle.fill
        ..isAntiAlias = true,
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = AppColors.chartLine
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..isAntiAlias = true,
    );

    // 2. The two full diagonals, then the midpoint diamond.
    final linePaint = Paint()
      ..color = AppColors.chartLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..isAntiAlias = true;

    canvas.drawLine(Offset(0, 0), Offset(width, height), linePaint);
    canvas.drawLine(Offset(width, 0), Offset(0, height), linePaint);

    final topMid = Offset(width / 2, 0);
    final rightMid = Offset(width, height / 2);
    final bottomMid = Offset(width / 2, height);
    final leftMid = Offset(0, height / 2);
    final diamond = Path()
      ..moveTo(topMid.dx, topMid.dy)
      ..lineTo(rightMid.dx, rightMid.dy)
      ..lineTo(bottomMid.dx, bottomMid.dy)
      ..lineTo(leftMid.dx, leftMid.dy)
      ..close();
    canvas.drawPath(diamond, linePaint);

    // 3. House numbers + grouped planet labels.
    for (var house = 1; house <= 12; house++) {
      _paintHouseNumber(canvas, size, house);
      final housePlanets = _byHouse[house];
      if (housePlanets != null && housePlanets.isNotEmpty) {
        _paintPlanetGroup(canvas, size, house, housePlanets);
      }
    }
  }

  void _paintHouseNumber(Canvas canvas, Size size, int house) {
    final anchor = _houseAnchors[house]!;
    final painter = TextPainter(
      text: TextSpan(
        text: '$house',
        // Forced to 'en' regardless of the app's active locale: a house
        // number is graphical chart notation, not translatable UI copy —
        // same reasoning as AppFonts.zodiac() taking no Locale at all.
        style: AppFonts.body(
          const Locale('en'),
          fontSize: size.width * 0.034,
          color: AppColors.chartHouseNumber,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final center = Offset(anchor.dx * size.width, anchor.dy * size.height);
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  void _paintPlanetGroup(
    Canvas canvas,
    Size size,
    int house,
    List<ChartPlanet> housePlanets,
  ) {
    final anchor = _houseAnchors[house]!;
    final fontSize = size.width * 0.039;
    final spans = <InlineSpan>[];

    for (var i = 0; i < housePlanets.length; i++) {
      if (i != 0) {
        spans.add(TextSpan(text: ' ', style: _planetStyle(fontSize, AppColors.ink)));
      }
      final planet = housePlanets[i];
      final color = planet.code.chartColor;
      spans.add(
        TextSpan(text: planet.code.shortLabel, style: _planetStyle(fontSize, color)),
      );
      if (planet.isExalted) {
        spans.add(_exaltedMarkerSpan(fontSize, color));
      }
      if (planet.isRetrograde) {
        spans.add(_retrogradeMarkerSpan(fontSize, color));
      }
    }

    final painter = TextPainter(
      text: TextSpan(children: spans),
      textDirection: TextDirection.ltr,
    )..layout();

    final verticalOffset = size.width * 0.13;
    final dy = _upperHalfHouses.contains(house) ? -verticalOffset : verticalOffset;
    final center = Offset(
      anchor.dx * size.width,
      anchor.dy * size.height + dy,
    );
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  TextStyle _planetStyle(double fontSize, Color color) => AppFonts.body(
    // Same "graphical notation, not translatable copy" reasoning as the
    // house-number style above — planet abbreviations (Su/Ma/Ke/…) are
    // always Latin per the design regardless of app language.
    const Locale('en'),
    fontSize: fontSize,
    fontWeight: FontWeight.w600,
    color: color,
  );

  /// Exalted marker (design shows "↑" after the planet label, e.g. "Ju ↑").
  ///
  /// Verified with fontTools against every bundled TTF in
  /// `assets/google_fonts/` — U+2191 (UPWARDS ARROW) has NO glyph in
  /// Poppins or any bundled Noto Sans Indic face (Playfair has it, but
  /// Playfair isn't used for body/chart text), so rendering it as plain
  /// text would show as tofu on-device — the exact failure mode described
  /// by this project's ICON RULE (see the top-level CLAUDE.md). Falling
  /// back to `Icons.arrow_upward`, painted via the same technique Flutter's
  /// own `Icon` widget uses internally (a `TextSpan` in the `MaterialIcons`
  /// font), keeps it inside this single `TextPainter` alongside the planet
  /// label instead of needing a second widget layered on top.
  InlineSpan _exaltedMarkerSpan(double fontSize, Color color) {
    const icon = Icons.arrow_upward;
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

  /// Retrograde marker (design shows "℞" after the planet label, e.g.
  /// "Sa ℞").
  ///
  /// Same verification as [_exaltedMarkerSpan]: U+211E (RX / PRESCRIPTION
  /// TAKE) has no glyph in any bundled font either. There's no Material
  /// icon that reads as "retrograde" the way arrow_upward reads as
  /// "exalted", so the fallback here is the italic letter 'R' — standard
  /// enough astrological shorthand and guaranteed to render since it's
  /// plain Latin text in the already-bundled Poppins face.
  InlineSpan _retrogradeMarkerSpan(double fontSize, Color color) {
    return TextSpan(
      text: 'R',
      style: _planetStyle(fontSize * 0.72, color).copyWith(
        fontStyle: FontStyle.italic,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _NorthIndianChartPainter oldDelegate) {
    return !listEquals(planets, oldDelegate.planets);
  }
}
