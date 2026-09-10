import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../l10n/app_localizations.dart';
import 'report_content.dart';
import 'report_labels.dart';

/// Renders any report as a branded PDF.
///
/// BUILT 10 Sep 2026. Until now **no PDF generation existed anywhere in the
/// app** — no `pdf` package, no code, and Vedika's contract has no PDF
/// endpoint. The only "PDF" was badge copy on report cards and a "Downloaded
/// PDFs" row on Profile, both cosmetic.
///
/// That also answers the client's earlier note that *"the PDF should be in
/// the name of our company, not Vedika"*: we generate it ourselves, so the
/// branding is ours by construction — there was never a Vedika-branded PDF to
/// replace.
///
/// ## One renderer for every report
///
/// All eight reports (and the five new purchasable types) reduce to the same
/// [ReportContent] — a list of [ReportSection]s of [ReportLine]s. So this
/// takes that model, not a specific report, and a new report type gets a PDF
/// for free.
///
/// ## ⚠️ Fonts are the whole difficulty
///
/// The `pdf` package does NOT use the app's Flutter fonts. A PDF built with
/// its defaults renders Devanagari, Telugu, Tamil and Kannada as blank boxes
/// — so a Hindi user would download an empty-looking document. Every face is
/// therefore loaded from `assets/google_fonts/` and registered as a
/// fallback chain.
///
/// The four Indic faces are ALL registered as fallbacks on every text style,
/// not just the one matching the current locale: a Hindi report can quote a
/// Sanskrit mantra, and report content routinely mixes scripts.
class ReportPdf {
  const ReportPdf._();

  /// Cached across calls — decoding five TTFs on every export would make the
  /// button feel broken on an older phone.
  static _Fonts? _cached;

  static Future<_Fonts> _loadFonts() async {
    if (_cached != null) return _cached!;
    Future<pw.Font> load(String name) async =>
        pw.Font.ttf(await rootBundle.load('assets/google_fonts/$name'));

    final fonts = _Fonts(
      base: await load('Poppins-Regular.ttf'),
      bold: await load('Poppins-SemiBold.ttf'),
      heading: await load('PlayfairDisplay-SemiBold.ttf'),
      fallbacks: [
        await load('NotoSansDevanagari-Regular.ttf'),
        await load('NotoSansTelugu-Regular.ttf'),
        await load('NotoSansTamil-Regular.ttf'),
        await load('NotoSansKannada-Regular.ttf'),
      ],
    );
    _cached = fonts;
    return fonts;
  }

  /// Builds the document bytes.
  ///
  /// [personName] and [birthSummary] are printed on the cover so a saved or
  /// shared file says whose chart it is — a report with no name is
  /// indistinguishable from anyone else's once it leaves the phone.
  static Future<Uint8List> build({
    required String reportId,
    required ReportContent content,
    required AppLocalizations l10n,
    required String personName,
    required String birthSummary,
  }) async {
    final fonts = await _loadFonts();
    final theme = pw.ThemeData.withFont(
      base: fonts.base,
      bold: fonts.bold,
      fontFallback: fonts.fallbacks,
    );

    final doc = pw.Document(
      title: reportTitle(reportId, l10n),
      author: _brand,
      creator: _brand,
    );

    doc.addPage(
      pw.MultiPage(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(40, 44, 40, 52),
        header: (context) => context.pageNumber == 1
            ? pw.SizedBox()
            : _runningHeader(reportId, l10n, fonts),
        footer: (context) => _footer(context, fonts),
        build: (context) => [
          _cover(reportId, l10n, fonts, personName, birthSummary),
          pw.SizedBox(height: 18),
          for (final section in content.sections)
            if (section.lines.isNotEmpty) ..._section(section, l10n, fonts),
        ],
      ),
    );

    return doc.save();
  }

  static const String _brand = 'Vedadarshi';
  static const PdfColor _ink = PdfColor.fromInt(0xFF1B1E28);
  static const PdfColor _muted = PdfColor.fromInt(0xFF6B7280);
  static const PdfColor _saffron = PdfColor.fromInt(0xFFE8720C);
  static const PdfColor _navy = PdfColor.fromInt(0xFF22315E);
  static const PdfColor _rule = PdfColor.fromInt(0xFFE6E1D8);

  static pw.Widget _cover(
    String reportId,
    AppLocalizations l10n,
    _Fonts fonts,
    String personName,
    String birthSummary,
  ) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(22),
      decoration: const pw.BoxDecoration(
        color: _navy,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(12)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            _brand.toUpperCase(),
            style: pw.TextStyle(
              font: fonts.bold,
              fontFallback: fonts.fallbacks,
              fontSize: 10,
              letterSpacing: 2,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            reportTitle(reportId, l10n),
            style: pw.TextStyle(
              font: fonts.heading,
              fontFallback: fonts.fallbacks,
              fontSize: 24,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            reportDescription(reportId, l10n),
            style: pw.TextStyle(
              font: fonts.base,
              fontFallback: fonts.fallbacks,
              fontSize: 10.5,
              color: PdfColor.fromInt(0xFFCBD2E4),
            ),
          ),
          if (personName.trim().isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Text(
              personName,
              style: pw.TextStyle(
                font: fonts.bold,
                fontFallback: fonts.fallbacks,
                fontSize: 13,
                color: PdfColor.fromInt(0xFFFFD9A8),
              ),
            ),
          ],
          if (birthSummary.trim().isNotEmpty)
            pw.Text(
              birthSummary,
              style: pw.TextStyle(
                font: fonts.base,
                fontFallback: fonts.fallbacks,
                fontSize: 10,
                color: PdfColor.fromInt(0xFFCBD2E4),
              ),
            ),
        ],
      ),
    );
  }

  static List<pw.Widget> _section(
    ReportSection section,
    AppLocalizations l10n,
    _Fonts fonts,
  ) {
    return [
      pw.SizedBox(height: 14),
      pw.Text(
        reportSectionTitle(section.kind, l10n),
        style: pw.TextStyle(
          font: fonts.heading,
          fontFallback: fonts.fallbacks,
          fontSize: 14,
          color: _ink,
        ),
      ),
      pw.SizedBox(height: 3),
      pw.Container(height: 1, color: _rule),
      pw.SizedBox(height: 8),
      for (final line in section.lines) _line(line, fonts),
    ];
  }

  static pw.Widget _line(ReportLine line, _Fonts fonts) {
    final label = line.label;
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (label != null && label.isNotEmpty)
            pw.Text(
              label,
              style: pw.TextStyle(
                font: fonts.bold,
                fontFallback: fonts.fallbacks,
                fontSize: 10,
                color: _saffron,
              ),
            ),
          if (line.text.isNotEmpty)
            pw.Text(
              line.text,
              // 1.4 leading: report bodies are multi-sentence, and the
              // default makes a page of them a solid block.
              style: pw.TextStyle(
                font: fonts.base,
                fontFallback: fonts.fallbacks,
                fontSize: 10.5,
                lineSpacing: 1.6,
                color: _ink,
              ),
            ),
        ],
      ),
    );
  }

  static pw.Widget _runningHeader(
    String reportId,
    AppLocalizations l10n,
    _Fonts fonts,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.only(bottom: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _rule)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            reportTitle(reportId, l10n),
            style: pw.TextStyle(
              font: fonts.bold,
              fontFallback: fonts.fallbacks,
              fontSize: 9,
              color: _muted,
            ),
          ),
          pw.Text(
            _brand,
            style: pw.TextStyle(
              font: fonts.bold,
              fontFallback: fonts.fallbacks,
              fontSize: 9,
              color: _saffron,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _footer(pw.Context context, _Fonts fonts) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        '${context.pageNumber} / ${context.pagesCount}',
        style: pw.TextStyle(
          font: fonts.base,
          fontFallback: fonts.fallbacks,
          fontSize: 9,
          color: _muted,
        ),
      ),
    );
  }
}

class _Fonts {
  const _Fonts({
    required this.base,
    required this.bold,
    required this.heading,
    required this.fallbacks,
  });

  final pw.Font base;
  final pw.Font bold;
  final pw.Font heading;

  /// Devanagari, Telugu, Tamil, Kannada — attached to EVERY style, because
  /// report text mixes scripts (a Hindi reading quoting a Sanskrit mantra,
  /// a Tamil report naming a Sanskrit yoga).
  final List<pw.Font> fallbacks;
}
