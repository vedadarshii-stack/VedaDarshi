import '../../l10n/app_localizations.dart';
import 'report_content.dart';

/// Localized copy for report ids and section kinds.
///
/// EXTRACTED 2 Sep 2026 from `premium_reports_screen.dart`, where these were
/// private, once the report DETAIL screen needed the same titles. Keeping one
/// copy means a report can never be called one thing in the list and another
/// on its own screen.
String reportTitle(String id, AppLocalizations l10n) {
  return switch (id) {
    'complete' => l10n.reportComplete,
    'career' => l10n.reportCareer,
    'marriage' => l10n.reportMarriage,
    'wealth' => l10n.reportWealth,
    'health' => l10n.reportHealth,
    'sadeSati' => l10n.reportSadeSati,
    'gemstone' => l10n.reportGemstone,
    'numerology' => l10n.reportNumerology,
    'remedies' => l10n.reportRemedies,
    'rudraksha' => l10n.reportRudraksha,
    'property' => l10n.reportProperty,
    'childFamily' => l10n.reportChildFamily,
    'business' => l10n.reportBusiness,
    // An unknown id is a bug, but showing the raw id beats showing nothing —
    // it names the thing that is broken instead of hiding it.
    _ => id,
  };
}

String reportDescription(String id, AppLocalizations l10n) {
  return switch (id) {
    'complete' => l10n.reportCompleteDesc,
    'career' => l10n.reportCareerDesc,
    'marriage' => l10n.reportMarriageDesc,
    'wealth' => l10n.reportWealthDesc,
    'health' => l10n.reportHealthDesc,
    'sadeSati' => l10n.reportSadeSatiDesc,
    'gemstone' => l10n.reportGemstoneDesc,
    'numerology' => l10n.reportNumerologyDesc,
    'remedies' => l10n.reportRemediesDesc,
    'rudraksha' => l10n.reportRudrakshaDesc,
    'property' => l10n.reportPropertyDesc,
    'childFamily' => l10n.reportChildFamilyDesc,
    'business' => l10n.reportBusinessDesc,
    _ => '',
  };
}

String reportSectionTitle(ReportSectionKind kind, AppLocalizations l10n) {
  return switch (kind) {
    ReportSectionKind.overview => l10n.reportSectionOverview,
    ReportSectionKind.highlights => l10n.reportSectionHighlights,
    ReportSectionKind.timing => l10n.reportSectionTiming,
    ReportSectionKind.guidance => l10n.reportSectionGuidance,
    ReportSectionKind.remedies => l10n.reportSectionRemedies,
    ReportSectionKind.strengths => l10n.reportSectionStrengths,
    ReportSectionKind.challenges => l10n.reportSectionChallenges,
  };
}
