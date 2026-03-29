import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:drop_now/core/models/models.dart';
import 'package:drop_now/core/services/deep_link_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  DeepLinkService? _deepLinkService;

  /// Set deep link service for notification tap routing.
  void setDeepLinkService(DeepLinkService service) {
    _deepLinkService = service;
  }

  /// Whether the current platform supports local notifications.
  bool get isPlatformSupported {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid ||
          Platform.isIOS ||
          Platform.isLinux ||
          Platform.isWindows;
    } catch (_) {
      return false;
    }
  }

  Future<void> init() async {
    if (_initialized || !isPlatformSupported) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open DropNow',
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    _deepLinkService?.handleNotificationTap(response.payload);
  }

  /// Request notification permissions (Android 13+, iOS).
  Future<bool> requestPermission() async {
    if (!isPlatformSupported) return false;

    try {
      if (!kIsWeb && Platform.isAndroid) {
        final android = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        final granted = await android?.requestNotificationsPermission();
        return granted ?? false;
      }

      if (!kIsWeb && Platform.isIOS) {
        final ios = _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
        final granted = await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (_) {
      return false;
    }

    return true; // Other platforms don't need explicit permission
  }

  /// Show an immediate notification with a command.
  Future<void> showCommandNotification(WorkoutCommand command) async {
    if (!isPlatformSupported || !_initialized) return;

    const androidDetails = AndroidNotificationDetails(
      'dropnow_commands',
      'Workout Commands',
      channelDescription: 'DropNow exercise command notifications',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'DropNow Command!',
      styleInformation: BigTextStyleInformation(''),
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
      linux: LinuxNotificationDetails(),
    );

    await _plugin.show(
      id: command.hashCode,
      title: 'DropNow Command! 💪',
      body: command.displayText,
      notificationDetails: details,
      payload: 'check_in',
    );
  }

  /// Schedule a notification for a specific time.
  Future<void> scheduleCommandNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    if (!isPlatformSupported || !_initialized) return;

    // For scheduling, we use zonedSchedule with TZDateTime.
    // In this phase we use the simpler approach of calculating delay
    // and using a periodic/scheduled approach. For a robust implementation
    // we store the schedule data and rely on show() at the right time.
    // Full timezone-aware scheduling will be enhanced in future phases.

    final delay = scheduledTime.difference(DateTime.now());
    if (delay.isNegative) return;

    // Use Future.delayed as a lightweight scheduling approach for this phase.
    // Production-grade timezone scheduling comes with background isolates in future phases.
    Future.delayed(delay, () async {
      const androidDetails = AndroidNotificationDetails(
        'dropnow_commands',
        'Workout Commands',
        channelDescription: 'DropNow exercise command notifications',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'DropNow Command!',
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
        linux: LinuxNotificationDetails(),
      );

      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
        payload: 'check_in',
      );
    });
  }

  /// Cancel all scheduled notifications.
  Future<void> cancelAll() async {
    if (!isPlatformSupported || !_initialized) return;
    await _plugin.cancelAll();
  }
}
