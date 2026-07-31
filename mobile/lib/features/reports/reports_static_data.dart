/// Static placeholder data for the Premium Reports screen, per the approved
/// Figma "C4 · Premium Reports" (node 22:2) concept.
///
/// Standing in for the real Vedika API report catalogue AND the entitlement
/// check that decides which reports a given user has unlocked. In
/// production, WHICH report is unlocked MUST be resolved from RevenueCat
/// entitlements checked SERVER-SIDE (same rule as the free-question quota on
/// the AI Astrologer chat, and the Vedika/OpenAI API keys — see
/// `projects/CLAUDE.md`'s "Confirmed stack decisions"), never trusted from a
/// client-side flag like [AstrologyReport.access] here. This file exists
/// purely to drive the static UI pass; wiring RevenueCat + the real
/// catalogue later should only touch this file, not the widget tree.
library;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Whether a report requires an active subscription.
enum ReportAccess { premium, free }

/// One report card's presentation + access data. The `id` is resolved to a
/// localized title/description in the screen — never hardcode English copy
/// for those outside l10n.
class AstrologyReport {
  const AstrologyReport({
    required this.id,
    required this.emoji,
    required this.tileBg,
    required this.tileFg,
    required this.readMinutes,
    required this.access,
  });

  final String id;
  final String emoji;
  final Color tileBg;
  final Color tileFg;
  final int readMinutes;
  final ReportAccess access;
}

abstract final class ReportsStaticData {
  /// The 7 reports shown in the design, in the exact order approved in
  /// Figma node 22:14.
  static final List<AstrologyReport> reports = [
    AstrologyReport(
      id: 'career',
      emoji: '💼',
      tileBg: AppColors.tileBlueBg,
      tileFg: AppColors.tileBlueFg,
      readMinutes: 12,
      access: ReportAccess.premium,
    ),
    AstrologyReport(
      id: 'marriage',
      emoji: '💍',
      tileBg: AppColors.tilePinkBg,
      tileFg: AppColors.tilePinkFg,
      readMinutes: 15,
      access: ReportAccess.premium,
    ),
    AstrologyReport(
      id: 'wealth',
      emoji: '🪙',
      tileBg: AppColors.mantraBg,
      tileFg: AppColors.tileGoldFg,
      readMinutes: 10,
      access: ReportAccess.premium,
    ),
    AstrologyReport(
      id: 'health',
      emoji: '🌿',
      tileBg: AppColors.geoChipBg,
      tileFg: AppColors.tileGreenFg,
      readMinutes: 9,
      access: ReportAccess.premium,
    ),
    AstrologyReport(
      id: 'sadeSati',
      emoji: '🧿',
      tileBg: AppColors.tilePurpleBg,
      tileFg: AppColors.tilePurpleFg,
      readMinutes: 8,
      access: ReportAccess.premium,
    ),
    AstrologyReport(
      id: 'gemstone',
      emoji: '💎',
      tileBg: AppColors.tileCyanBg,
      tileFg: AppColors.tileCyanFg,
      readMinutes: 6,
      access: ReportAccess.free,
    ),
    AstrologyReport(
      id: 'numerology',
      emoji: '🔢',
      tileBg: AppColors.terracottaBg,
      tileFg: AppColors.terracottaFg,
      readMinutes: 7,
      access: ReportAccess.free,
    ),
  ];

  /// Total reports the finished catalogue will offer (the banner promises
  /// "all 9 reports" and the footer says "+2 more"). Only 7 are approved in
  /// the current design — the remaining 2 arrive with the real Vedika API
  /// catalogue. Kept as one constant so the banner/footer copy can never
  /// drift out of sync with [reports].length.
  static const int totalReports = 9;
}
