import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/notifications/notifications_screen.dart';
import '../../firebase_options.dart';
import '../data/firestore_refs.dart';

/// Global key handed to [MaterialApp.navigatorKey] so a notification tap can
/// push a route from OUTSIDE the widget tree — there is no [BuildContext]
/// available in a background isolate or in the top-level
/// [firebaseMessagingBackgroundHandler].
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Android notification channel every push renders into. Must match the
/// `com.google.firebase.messaging.default_notification_channel_id` meta-data
/// in `android/app/src/main/AndroidManifest.xml` — that's what makes a
/// background/terminated-state push (rendered by the OS, not by this file)
/// land in the same channel as a foreground one (rendered by
/// [PushNotificationService] via `flutter_local_notifications`).
const String _defaultChannelId = 'vedadarshi_default';
const String _defaultChannelName = 'General';
const String _defaultChannelDescription =
    'Daily horoscope, festival alerts, AI replies and other Vedadarshi updates.';

/// Monochrome small-icon drawable (white silhouette on transparency, as
/// Android 5+ requires) bundled at
/// `android/app/src/main/res/drawable-*/ic_notification.png`. MUST be
/// referenced without an extension here — `flutter_local_notifications`
/// resolves it as an Android drawable resource name, not a file path.
const String _notificationIcon = 'ic_notification';

/// Top-level background message handler, registered with
/// [FirebaseMessaging.onBackgroundMessage] in `main.dart`.
///
/// THE SINGLE MOST COMMON FCM BUG: this function runs in a separate,
/// throwaway Dart isolate spun up just for this call — it does NOT share
/// memory with the running app, so none of the app's already-initialized
/// state (including the [Firebase] app instance) is visible here. It must
/// re-initialize Firebase itself, every time, or any Firebase call below
/// throws "[core/no-app] No Firebase App has been created".
///
/// It must also be a top-level (or static) function — an instance method
/// cannot be torn off and handed to a background isolate — and it must carry
/// `@pragma('vm:entry-point')` so Flutter's tree-shaking build step doesn't
/// strip it (nothing in the app's normal call graph references it, since
/// it's only ever invoked by the OS/FCM SDK).
///
/// Android already renders the system tray notification for a
/// background/terminated-state push itself (using the
/// `default_notification_*` manifest meta-data), so there is deliberately no
/// `flutter_local_notifications` call here — this handler exists for
/// bookkeeping/data-only messages, not for display.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('FCM background message received: ${message.messageId}');
}

/// The app's whole Firebase Cloud Messaging surface: channel setup, foreground
/// rendering, notification-tap navigation, and per-device token bookkeeping.
///
/// `firebase_messaging` alone CANNOT show a notification while the app is in
/// the FOREGROUND on Android — a foreground push only ever reaches
/// [FirebaseMessaging.onMessage] as data, with nothing rendered by the OS.
/// `flutter_local_notifications` is what actually draws it (see
/// [_showForegroundNotification]); background/terminated-state pushes, by
/// contrast, ARE auto-rendered by the OS from the FCM payload, which is why
/// only the foreground path needs it.
///
/// This is deliberately a SINGLETON (private constructor + static
/// [instance]) rather than the plain-class-behind-a-`Provider` pattern used
/// by [AuthService]/`UserRepository` elsewhere in `lib/core`. Those are only
/// ever touched from inside the widget tree, where a [ProviderScope] already
/// exists. This service must also be reachable from `main()` — to register
/// [firebaseMessagingBackgroundHandler] and call [initialize] right after
/// `Firebase.initializeApp`, BEFORE `runApp`/`ProviderScope` exist — so
/// [pushNotificationServiceProvider] simply hands back the same singleton
/// instead of constructing a second, un-initialized instance with its own
/// disconnected listeners.
class PushNotificationService {
  PushNotificationService._({
    FirebaseMessaging? messaging,
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Locale of the most recent [syncTokenForCurrentUser] call, reused by
  /// [_onTokenRefresh] (which has no direct line to the app's active locale)
  /// so a token written by a refresh mid-session still carries a sensible
  /// value instead of `null`.
  String? _lastKnownLocale;

  /// Sets up the local-notifications plugin/channel, wires the
  /// foreground/tap listeners, and resolves a terminated-state launch (the
  /// app process didn't exist until the user tapped a notification).
  ///
  /// Guarded end-to-end and idempotent: called once from `main()` before
  /// `runApp`, so a failure here (missing plugin registration, a platform
  /// quirk, anything) must never stop the app booting — same contract as the
  /// existing `dotenv.load()` guard in `main.dart`.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    try {
      const channel = AndroidNotificationChannel(
        _defaultChannelId,
        _defaultChannelName,
        description: _defaultChannelDescription,
        importance: Importance.high,
      );
      const androidInit = AndroidInitializationSettings(_notificationIcon);
      const initSettings = InitializationSettings(android: androidInit);
      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: _onLocalNotificationResponse,
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);

      FirebaseMessaging.onMessage.listen(_showForegroundNotification);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleRemoteMessageTap);
      _messaging.onTokenRefresh.listen(_onTokenRefresh);

      // Terminated-state launch: the app process didn't exist until the user
      // tapped a notification, so the navigator isn't mounted yet at this
      // point (this runs before `runApp`). Deferring to the first drawn
      // frame guarantees `rootNavigatorKey.currentState` is attached by the
      // time navigation actually runs.
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleRemoteMessageTap(initialMessage);
        });
      }
    } catch (e) {
      debugPrint('PushNotificationService.initialize failed: $e');
    }
  }

  /// Requests the user's permission to show notifications. On Android 13+
  /// (API 33) this is what actually triggers the POST_NOTIFICATIONS runtime
  /// prompt; on older Android versions the permission is granted implicitly
  /// and this resolves immediately as authorized. Never throws — a failure
  /// here (e.g. Firebase not ready) is reported as "not granted" rather than
  /// crashing the caller.
  Future<bool> requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      debugPrint('PushNotificationService.requestPermission failed: $e');
      return false;
    }
  }

  /// Current authorization state, without ever showing a system prompt —
  /// used by [NotificationsScreen] to decide whether to render the
  /// permission-denied empty state.
  Future<AuthorizationStatus> currentAuthorizationStatus() async {
    try {
      final settings = await _messaging.getNotificationSettings();
      return settings.authorizationStatus;
    } catch (e) {
      debugPrint(
        'PushNotificationService.currentAuthorizationStatus failed: $e',
      );
      return AuthorizationStatus.notDetermined;
    }
  }

  /// Reads the current device's FCM registration token and, if a user is
  /// signed in, writes it to `/users/{uid}/fcmTokens/{token}` (see
  /// [fcmTokensCollection]). A silent no-op for guests (no uid to key on) or
  /// if Firebase/Auth isn't ready — this must never throw or block whatever
  /// triggered it (sign-in, app resume, etc.).
  Future<void> syncTokenForCurrentUser({String? locale}) async {
    if (locale != null) _lastKnownLocale = locale;
    try {
      final User? user;
      try {
        user = _firebaseAuth.currentUser;
      } catch (_) {
        return;
      }
      if (user == null) return;

      final token = await _messaging.getToken();
      if (token == null) return;

      await _writeToken(user.uid, token, locale: _lastKnownLocale);
    } catch (e) {
      debugPrint('PushNotificationService.syncTokenForCurrentUser failed: $e');
    }
  }

  /// Removes THIS device's token from the signed-in user's Firestore
  /// subcollection and invalidates it with FCM. Call it on sign-out.
  ///
  /// MUST run BEFORE `FirebaseAuth.signOut()`: the deployed Firestore rules
  /// only allow writes under `/users/{uid}` when `request.auth.uid == uid`,
  /// so once the user is signed out the delete is denied and the token is
  /// orphaned — leaving the previous account still receiving push
  /// notifications on a phone it no longer owns.
  ///
  /// Never throws; a failure here must not block sign-out.
  Future<void> removeTokenForCurrentUser() async {
    try {
      final User? user;
      try {
        user = _firebaseAuth.currentUser;
      } catch (_) {
        return;
      }
      if (user == null) return;

      final token = await _messaging.getToken();
      if (token != null) {
        await _firestore
            .collection(usersCollection)
            .doc(user.uid)
            .collection(fcmTokensCollection)
            .doc(token)
            .delete();
      }

      // Also invalidate the registration token itself, so the old token
      // can't be used to reach this device at all. FCM mints a fresh one
      // automatically on the next getToken() (i.e. the next sign-in).
      await _messaging.deleteToken();
    } catch (e) {
      debugPrint('PushNotificationService.removeTokenForCurrentUser: $e');
    }
  }

  Future<void> _onTokenRefresh(String token) async {
    // Tokens rotate — FCM can mint a new one at any time (app data cleared,
    // token expiry, etc.). A stale token left in Firestore silently stops
    // receiving pushes with no visible error, so this must re-sync on every
    // refresh, not just at sign-in.
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return;
      await _writeToken(user.uid, token, locale: _lastKnownLocale);
    } catch (e) {
      debugPrint('PushNotificationService: token refresh sync failed: $e');
    }
  }

  Future<void> _writeToken(String uid, String token, {String? locale}) async {
    final docRef = _firestore
        .collection(usersCollection)
        .doc(uid)
        .collection(fcmTokensCollection)
        .doc(token);

    bool docExists = true;
    try {
      docExists = (await docRef.get()).exists;
    } catch (_) {
      docExists = true;
    }

    await docRef.set({
      'token': token,
      'platform': 'android',
      'locale': locale,
      'updatedAt': FieldValue.serverTimestamp(),
      if (!docExists) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Renders a system-tray notification for a message received while the
  /// app is in the FOREGROUND — see the class doc for why this is needed at
  /// all (Android never shows one on its own in this case).
  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) {
      return; // Data-only message — nothing to render, caller handles data.
    }
    try {
      await _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _defaultChannelId,
            _defaultChannelName,
            channelDescription: _defaultChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
            icon: _notificationIcon,
            // Mirrors android/app/src/main/res/values/colors.xml's
            // notification_accent — kept in sync manually, Dart can't read
            // Android resource values.
            color: const Color(0xFFE8720C),
          ),
        ),
        payload: jsonEncode(message.data),
      );
    } catch (e) {
      debugPrint(
        'PushNotificationService: failed to show foreground notification: $e',
      );
    }
  }

  /// Tap on a notification `flutter_local_notifications` rendered itself
  /// (i.e. one shown while the app was in the foreground).
  void _onLocalNotificationResponse(NotificationResponse response) {
    Map<String, dynamic> data = const {};
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      try {
        final decoded = jsonDecode(payload);
        if (decoded is Map<String, dynamic>) data = decoded;
      } catch (_) {
        // Malformed payload — fall through with an empty data map rather
        // than crash; _navigateFromData has a safe default destination.
      }
    }
    _navigateFromData(data);
  }

  /// Tap on a notification the OS rendered (app was backgrounded, via
  /// [FirebaseMessaging.onMessageOpenedApp]) or a terminated-state launch
  /// (via [FirebaseMessaging.getInitialMessage] in [initialize]).
  void _handleRemoteMessageTap(RemoteMessage message) {
    _navigateFromData(message.data);
  }

  /// `data['route']` is reserved for future deep-link targets (a specific
  /// article, report, etc.). No other destination exists yet, so every
  /// notification — and any missing/unrecognized route value — opens
  /// [NotificationsScreen]. Must never throw on a malformed payload; a
  /// not-yet-mounted navigator (e.g. this fires before the first frame) is a
  /// silent no-op rather than an error.
  void _navigateFromData(Map<String, dynamic> data) {
    try {
      final navigator = rootNavigatorKey.currentState;
      if (navigator == null) return;
      navigator.push(
        MaterialPageRoute<void>(builder: (_) => const NotificationsScreen()),
      );
    } catch (e) {
      debugPrint('PushNotificationService: navigation from tap failed: $e');
    }
  }
}

/// Riverpod access point for [PushNotificationService.instance] — see the
/// class doc for why this hands back a singleton instead of constructing a
/// fresh instance the way `authServiceProvider`/`userRepositoryProvider` do.
final pushNotificationServiceProvider = Provider<PushNotificationService>(
  (ref) => PushNotificationService.instance,
);
