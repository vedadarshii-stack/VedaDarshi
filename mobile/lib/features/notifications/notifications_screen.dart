import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import '../../core/motion/app_motion.dart';
import '../../core/notifications/push_notification_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../l10n/app_localizations.dart';
import 'notifications_static_data.dart';

/// Notifications, per the approved Figma "D4 · Notifications" (node 28:2)
/// concept.
///
/// Reached from the Home top bar's bell icon. Like the Search/Articles/
/// Reports screens, this has NO bottom nav in the design — it's a pushed
/// destination with its own back button.
///
/// Every notification shown below is STATIC PLACEHOLDER DATA from
/// [NotificationsStaticData]; see that file's doc comment for what
/// eventually replaces it (Firebase Cloud Messaging + a Firestore
/// `notifications` subcollection).
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with WidgetsBindingObserver {
  /// Real LOCAL read-state — a notification starts read/unread per
  /// [NotificationItem.isUnread] and is added here once tapped or once
  /// "Mark all read" runs. Not persisted, and not shared with the Home top
  /// bar's badge count (which reads the static seed directly) — there is no
  /// shared state/provider between the two screens yet, same limitation as
  /// the Articles bookmark toggles being screen-local.
  final Set<String> _readIds = {};

  /// Push permission state, per [PushNotificationService]. Starts optimistic
  /// (`true`) so the screen never flashes the denied prompt before the first
  /// async check completes; genuinely denied devices settle to `false` a
  /// frame or two later.
  bool _notificationsEnabled = true;

  /// Whether a further [PushNotificationService.requestPermission] call
  /// would show the system dialog again or silently no-op — Android hides
  /// the dialog after the user has denied it enough times, at which point
  /// the only way back in is the app's OS settings page. `firebase_messaging`
  /// has no notion of this distinction, so `permission_handler` answers it.
  bool _permanentlyDenied = false;

  bool _isUnread(NotificationItem item) =>
      item.isUnread && !_readIds.contains(item.id);

  void _markRead(String id) => setState(() => _readIds.add(id));

  void _markAllRead() {
    setState(() {
      _readIds.addAll(NotificationsStaticData.items.map((item) => item.id));
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Deliberately requested HERE — the first time the user reaches this
    // screen — rather than on app cold start. A cold-start prompt has no
    // context and gets denied far more often; by the time the user opens
    // Notifications they've shown intent, which is the moment platform
    // guidance recommends asking.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _requestPermissionIfNeeded(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Reflects a permission change the user made in the OS Settings app
    // (reached via the "open settings" action below) once they return —
    // read-only, never re-shows the system request dialog on resume.
    if (state == AppLifecycleState.resumed) {
      _loadPermissionStatus();
    }
  }

  Future<void> _loadPermissionStatus() async {
    // Also guarded — see _requestPermissionIfNeeded. This runs on app resume
    // too, so an unavailable Firebase must not crash a screen the user is
    // already looking at.
    final AuthorizationStatus status;
    try {
      final service = ref.read(pushNotificationServiceProvider);
      status = await service.currentAuthorizationStatus();
    } catch (e) {
      debugPrint('NotificationsScreen: permission status unavailable: $e');
      return;
    }
    if (!mounted) return;
    final enabled =
        status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
    setState(() => _notificationsEnabled = enabled);
    if (!enabled) {
      await _refreshPermanentlyDeniedFlag();
    } else if (_permanentlyDenied) {
      setState(() => _permanentlyDenied = false);
    }
  }

  Future<void> _requestPermissionIfNeeded() async {
    // Guarded: reading the push service touches FirebaseMessaging, which
    // throws if Firebase isn't initialised (its setup in main() is itself
    // try/catch'd, so that IS reachable on a device with a bad config). A
    // missing permission prompt is a degraded state, never a reason to take
    // the whole screen down — the list itself doesn't need Firebase.
    try {
      final service = ref.read(pushNotificationServiceProvider);
      final status = await service.currentAuthorizationStatus();
      if (status != AuthorizationStatus.notDetermined) {
        await _loadPermissionStatus();
        return;
      }
      final granted = await service.requestPermission();
      if (!mounted) return;
      setState(() => _notificationsEnabled = granted);
      if (!granted) await _refreshPermanentlyDeniedFlag();
    } catch (e) {
      debugPrint('NotificationsScreen: permission check unavailable: $e');
    }
  }

  Future<void> _refreshPermanentlyDeniedFlag() async {
    try {
      final status = await ph.Permission.notification.status;
      if (!mounted) return;
      setState(() => _permanentlyDenied = status.isPermanentlyDenied);
    } catch (_) {
      // permission_handler unavailable/erroring — treat as "not permanently
      // denied" so the action still offers a retry rather than settings.
    }
  }

  Future<void> _onEnableNotificationsTap() async {
    if (_permanentlyDenied) {
      await ph.openAppSettings();
      return;
    }
    final service = ref.read(pushNotificationServiceProvider);
    final granted = await service.requestPermission();
    if (!mounted) return;
    setState(() => _notificationsEnabled = granted);
    if (!granted) await _refreshPermanentlyDeniedFlag();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final isCompact = MediaQuery.sizeOf(context).height < 840;
    final items = NotificationsStaticData.items;

    final todayItems = items
        .where((item) => item.group == NotificationGroup.today)
        .toList();
    final yesterdayItems = items
        .where((item) => item.group == NotificationGroup.yesterday)
        .toList();

    var flatIndex = 0;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, isCompact ? 28 : 52, 20, 24),
          children: [
            _Header(l10n: l10n, locale: locale, onMarkAllRead: _markAllRead),
            const SizedBox(height: 16),
            if (!_notificationsEnabled) ...[
              _PermissionPrompt(
                l10n: l10n,
                permanentlyDenied: _permanentlyDenied,
                onTap: _onEnableNotificationsTap,
              ),
              const SizedBox(height: 16),
            ],
            if (items.isEmpty)
              _EmptyState(l10n: l10n)
            else ...[
              if (todayItems.isNotEmpty) ...[
                _SectionLabel(l10n.notificationsToday, locale: locale),
                const SizedBox(height: 8),
                for (var i = 0; i < todayItems.length; i++) ...[
                  if (i != 0) const SizedBox(height: 9),
                  EntranceFadeSlide(
                    index: flatIndex++,
                    child: _NotificationCard(
                      item: todayItems[i],
                      locale: locale,
                      isUnread: _isUnread(todayItems[i]),
                      onTap: () => _markRead(todayItems[i].id),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],
              if (yesterdayItems.isNotEmpty) ...[
                _SectionLabel(l10n.notificationsYesterday, locale: locale),
                const SizedBox(height: 8),
                for (var i = 0; i < yesterdayItems.length; i++) ...[
                  if (i != 0) const SizedBox(height: 9),
                  EntranceFadeSlide(
                    index: flatIndex++,
                    child: _NotificationCard(
                      item: yesterdayItems[i],
                      locale: locale,
                      isUnread: _isUnread(yesterdayItems[i]),
                      onTap: () => _markRead(yesterdayItems[i].id),
                    ),
                  ),
                ],
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// Back button + screen title + "Mark all read" action (Figma node 28:2).
class _Header extends StatelessWidget {
  const _Header({
    required this.l10n,
    required this.locale,
    required this.onMarkAllRead,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final VoidCallback onMarkAllRead;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Semantics(
          button: true,
          child: PressableScale(
            borderRadius: BorderRadius.circular(999),
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Icon(Icons.arrow_back, size: 18, color: AppColors.ink),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            l10n.notificationsTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.heading(
              locale,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Semantics(
          button: true,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onMarkAllRead,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              child: Text(
                l10n.notificationsMarkAllRead,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.body(
                  locale,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.saffron,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label, {required this.locale});

  final String label;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppFonts.body(
        locale,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.muted,
        letterSpacing: 0.88,
      ),
    );
  }
}

/// One notification card (Figma node 28:2) — unread cards get a white
/// background, a warmer border and a small saffron dot next to the title;
/// read cards fall back to the app's default card treatment.
class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.item,
    required this.locale,
    required this.isUnread,
    required this.onTap,
  });

  final NotificationItem item;
  final Locale locale;
  final bool isUnread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: item.title,
      child: PressableScale(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: isUnread ? AppColors.surface : AppColors.cream,
            border: Border.all(
              color: isUnread
                  ? AppColors.notificationUnreadBorder
                  : AppColors.cardBorder,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: item.tileBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: item.emoji != null
                    ? Text(
                        item.emoji!,
                        style: AppFonts.body(locale, fontSize: 17),
                      )
                    : Icon(item.icon, size: 18, color: item.tileFg),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.body(
                              locale,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        if (isUnread) ...[
                          const SizedBox(width: 8),
                          // The design exports the unread indicator as an
                          // image asset whose exact hex couldn't be
                          // extracted — AppColors.saffron is the brand's
                          // existing "new/active" accent and a reasonable
                          // stand-in (judgment call).
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.saffron,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.body(
                        locale,
                        fontSize: 11.5,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.time,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.body(
                        locale,
                        fontSize: 10,
                        color: AppColors.hint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown above the notification list whenever push permission isn't granted
/// — [PushNotificationService] can register a device's token regardless, but
/// nothing will ever actually arrive on it without this. Reuses
/// [AppEmptyState] rather than a hand-rolled banner, per the project's
/// convention of one shared building block for this "tinted icon + title +
/// message + action" shape.
class _PermissionPrompt extends StatelessWidget {
  const _PermissionPrompt({
    required this.l10n,
    required this.permanentlyDenied,
    required this.onTap,
  });

  final AppLocalizations l10n;
  final bool permanentlyDenied;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.notifications_off_outlined,
      iconBackgroundColor: AppColors.ashubhBg,
      iconForegroundColor: AppColors.ashubhFg,
      title: l10n.notificationsPermissionDeniedTitle,
      message: l10n.notificationsPermissionDeniedMessage,
      actionLabel: permanentlyDenied
          ? l10n.notificationsPermissionOpenSettingsAction
          : l10n.notificationsPermissionEnableAction,
      onAction: onTap,
    );
  }
}

/// Defensive empty state — [NotificationsStaticData.items] is never
/// actually empty today, but the screen should still render sensibly if it
/// were. Uses the shared [AppEmptyState] (Figma "F1 · Empty States" gallery,
/// node 56:3, "No Notifications" card) instead of a hand-rolled column, so
/// this and [SearchScreen]'s no-results state share one implementation.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      // The design's 🔕 muted-bell is a colour emoji (ICON RULE).
      emoji: '🔕',
      iconBackgroundColor: AppColors.tileBlueBg,
      iconForegroundColor: AppColors.tileBlueFg,
      title: l10n.notificationsEmptyState,
      message: l10n.notificationsEmptyMessage,
    );
  }
}
