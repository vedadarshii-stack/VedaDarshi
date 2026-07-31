/// Static placeholder data for the Notifications feature, per the approved
/// Figma "D4 · Notifications" (node 28:2) concept.
///
/// Standing in for real push delivery (Firebase Cloud Messaging) plus a
/// per-user Firestore `notifications` subcollection that the console writes
/// to and the app reads/marks-as-read against. Wiring FCM + Firestore is a
/// separate, later task — every id/title/body/time value below is static
/// placeholder content, not real notification history.
library;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Broad editorial category a notification belongs to — informational only
/// today (not yet used for filtering), kept for parity with how
/// [ArticleCategoryId]/[AstrologyReport] model their own content.
enum NotificationCategory { horoscope, festival, ai, alert, premium, article }

/// Which date-group section (Figma's "TODAY"/"YESTERDAY" labels) a
/// notification renders under.
enum NotificationGroup { today, yesterday }

/// One notification card's presentation + content data (Figma node 28:2).
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.category,
    required this.title,
    required this.body,
    required this.time,
    required this.group,
    required this.isUnread,
    this.emoji,
    this.icon,
    required this.tileBg,
    required this.tileFg,
  }) : assert(
         emoji != null || icon != null,
         'A notification needs either an emoji or a Material icon.',
       );

  final String id;
  final NotificationCategory category;

  /// Notification content — CMS/push content, not app UI chrome, so it
  /// deliberately does NOT go through the l10n layer (same convention as
  /// [ArticlesStaticData]'s article titles/bodies).
  final String title;
  final String body;
  final String time;

  final NotificationGroup group;
  final bool isUnread;

  /// True colour emoji tile glyph — null only for the one card ([icon] set
  /// instead) whose design glyph is CSS-tinted a specific colour, which a
  /// colour emoji can't do (project ICON RULE).
  final String? emoji;
  final IconData? icon;

  final Color tileBg;
  final Color tileFg;
}

abstract final class NotificationsStaticData {
  /// The 6 notification cards from "D4 · Notifications" (Figma node 28:2),
  /// in the exact TODAY-then-YESTERDAY order shown in the design.
  static const List<NotificationItem> items = [
    NotificationItem(
      id: 'daily-horoscope',
      category: NotificationCategory.horoscope,
      title: 'Your daily horoscope is ready',
      body:
          'Simha: A favourable day for new beginnings. Jupiter blesses '
          'your career house.',
      time: '7:00 AM',
      group: NotificationGroup.today,
      isUnread: true,
      emoji: '🌅',
      tileBg: AppColors.genderSelectedBg,
      tileFg: AppColors.genderSelectedText,
    ),
    NotificationItem(
      id: 'sawan-somvar',
      category: NotificationCategory.festival,
      title: 'Sawan Somvar tomorrow',
      body: 'Fasting day for Lord Shiva. See rituals, muhurat & vrat rules.',
      time: '6:30 AM',
      group: NotificationGroup.today,
      isUnread: true,
      emoji: '🛕',
      tileBg: AppColors.mantraBg,
      tileFg: AppColors.mantraIcon,
    ),
    NotificationItem(
      id: 'rishi-ai-reply',
      category: NotificationCategory.ai,
      title: 'Rishi AI replied',
      body:
          '"With Jupiter transiting your 10th house…" Continue the '
          'conversation.',
      time: '9:12 AM',
      group: NotificationGroup.today,
      isUnread: false,
      emoji: '🔮',
      tileBg: AppColors.tilePinkBg,
      tileFg: AppColors.tilePinkFg,
    ),
    NotificationItem(
      id: 'rahu-kaal-alert',
      category: NotificationCategory.alert,
      title: 'Rahu Kaal alert',
      body: 'Avoid new beginnings 09:06 – 10:42 AM today.',
      time: '8:00 AM',
      group: NotificationGroup.yesterday,
      isUnread: false,
      // The design's ⚠ is CSS-tinted a specific red, and colour emoji
      // ignore TextStyle.color (project ICON RULE) — a tinted glyph must be
      // a Material icon instead of text here.
      icon: Icons.warning_amber_rounded,
      tileBg: AppColors.ashubhBg,
      tileFg: AppColors.ashubhFg,
    ),
    NotificationItem(
      id: 'premium-offer',
      category: NotificationCategory.premium,
      title: 'Premium offer ends tonight',
      body: 'Get yearly at ₹1,999 — save 44% before midnight.',
      time: '7:45 PM',
      group: NotificationGroup.yesterday,
      isUnread: false,
      emoji: '👑',
      tileBg: AppColors.mantraBg,
      tileFg: AppColors.mantraIcon,
    ),
    NotificationItem(
      id: 'new-article',
      category: NotificationCategory.article,
      title: 'New article published',
      body: '"Ganesha Chaturthi 2026: complete puja vidhi & muhurat"',
      time: '11:00 AM',
      group: NotificationGroup.yesterday,
      isUnread: false,
      emoji: '📖',
      tileBg: AppColors.tileBlueBg,
      tileFg: AppColors.tileBlueFg,
    ),
  ];

  /// Count of unread notifications in [items] — drives the Home top bar's
  /// bell badge. NEVER hardcode this count elsewhere.
  static int get unreadCount => items.where((item) => item.isUnread).length;
}
