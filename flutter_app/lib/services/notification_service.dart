import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'b12_reminder_service.dart';
import '../main.dart' show navigatorKey;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone database
      tz.initializeTimeZones();

      // Get the device's local timezone
      final TimezoneInfo timeZoneInfos =
          await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneInfos.identifier));

      // Use default icon (app icon) for Android
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      final iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        notificationCategories: [
          DarwinNotificationCategory(
            'b12_reminder_category',
            actions: <DarwinNotificationAction>[
              DarwinNotificationAction.plain(
                'b12_taken',
                'B12 prise ✓',
              ),
            ],
          ),
        ],
      );

      final initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      // Explicitly create notification channel for Android
      await _createNotificationChannel();

      _isInitialized = true;

      if (kDebugMode) {
        print('Notification service initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing notification service: $e');
      }
      // Try to recover by canceling all notifications
      try {
        await _notifications.cancelAll();
        if (kDebugMode) {
          print('Cleared all notifications after initialization error');
        }
      } catch (clearError) {
        if (kDebugMode) {
          print('Failed to clear notifications: $clearError');
        }
      }
      _isInitialized = true; // Mark as initialized even with errors
    }
  }

  /// Create notification channel for Android
  Future<void> _createNotificationChannel() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        const androidChannel = AndroidNotificationChannel(
          'b12_reminders',
          'Rappels B12',
          description:
              'Notifications pour les rappels de supplémentation en B12',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
          showBadge: true,
        );

        await androidPlugin.createNotificationChannel(androidChannel);

        if (kDebugMode) {
          print('Notification channel created for Android');

          // Verify the channel was created
          final channels = await androidPlugin.getNotificationChannels();
          print('Available channels: ${channels?.map((c) => c.id).toList()}');
        }
      }
    }
  }

  /// Handle notification tap or action button press
  void _onNotificationTap(NotificationResponse response) {
    if (kDebugMode) {
      print('Notification tapped: ${response.payload}, actionId: ${response.actionId}');
    }

    // Handle "B12 prise" action button (from notification tray, no UI)
    if (response.actionId == 'b12_taken') {
      B12ReminderService.recordB12Intake();
      B12ReminderService.markNotificationReceived();
      return;
    }

    // Handle notification tap (opens app) - show confirmation dialog
    final payload = response.payload ?? '';
    if (payload.startsWith('b12_reminder')) {
      _showB12ConfirmationDialog();
    }
  }

  /// Show a dialog asking if the user took their B12
  void _showB12ConfirmationDialog() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          '💊 Vitamine B12',
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'Avez-vous pris votre vitamine B12 ?',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Non',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              B12ReminderService.recordB12Intake();
              B12ReminderService.markNotificationReceived();
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('B12 prise enregistrée !'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('B12 prise ✓'),
          ),
        ],
      ),
    );
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Android 13+ requires runtime permission
      final androidPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        // Request notification permission
        final granted = await androidPlugin.requestNotificationsPermission();
        if (kDebugMode) {
          print('Notification permission granted: $granted');
        }

        // Request exact alarm permission for Android 12+
        final canScheduleExact =
            await androidPlugin.canScheduleExactNotifications();
        if (kDebugMode) {
          print('Can schedule exact alarms: $canScheduleExact');
        }

        if (canScheduleExact == false) {
          final exactAlarmGranted =
              await androidPlugin.requestExactAlarmsPermission();
          if (kDebugMode) {
            print('Exact alarm permission granted: $exactAlarmGranted');
          }
        }

        return granted ?? false;
      }
      return true; // Older Android versions
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();

      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    }
    return true;
  }

  /// Get notification details configuration
  NotificationDetails _getNotificationDetails() {
    const androidDetails = AndroidNotificationDetails(
      'b12_reminders',
      'Rappels B12',
      channelDescription:
          'Notifications pour les rappels de complémentation en B12',
      importance: Importance.high,
      priority: Priority.high,
      // Small white icon for status bar
      icon: 'ic_notification',
      // Large colored icon showing the app's logo
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      playSound: true,
      enableVibration: true,
      channelShowBadge: true,
      visibility: NotificationVisibility.public,
      ongoing: false,
      autoCancel: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  /// Get B12 notification details with "B12 prise" action button
  NotificationDetails _getB12NotificationDetails() {
    const androidDetails = AndroidNotificationDetails(
      'b12_reminders',
      'Rappels B12',
      channelDescription:
          'Notifications pour les rappels de complémentation en B12',
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_notification',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      playSound: true,
      enableVibration: true,
      channelShowBadge: true,
      visibility: NotificationVisibility.public,
      ongoing: false,
      autoCancel: true,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'b12_taken',
          'B12 prise ✓',
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'b12_reminder_category',
    );

    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  /// Show an immediate test notification
  Future<void> showTestNotification() async {
    const title = '💊 Rappel B12';
    const body = 'Votre rappel a été configuré avec succès !';

    if (kDebugMode) {
      print('Showing immediate test notification');
    }

    final details = _getNotificationDetails();

    await _notifications.show(
      9999,
      title,
      body,
      details,
      payload: 'test_notification',
    );

    if (kDebugMode) {
      print('Test notification shown');
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        return await androidPlugin.areNotificationsEnabled() ?? false;
      }
      return true;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return true;
    }
    return true;
  }

  /// Schedule a notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    String? payload,
    bool isB12 = false,
  }) async {
    final details = isB12 ? _getB12NotificationDetails() : _getNotificationDetails();

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  /// Schedule a daily notification
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
    bool isB12 = false,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the scheduled time is in the past, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    if (kDebugMode) {
      print('Scheduling daily notification for: $scheduledDate');
    }

    final details = isB12 ? _getB12NotificationDetails() : _getNotificationDetails();

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );

    if (kDebugMode) {
      final pending = await getPendingNotifications();
      print('Pending notifications after scheduling: ${pending.length}');
    }
  }

  /// Schedule a weekly notification
  Future<void> scheduleWeeklyNotification({
    required int id,
    required String title,
    required String body,
    required int dayOfWeek, // 1 = Monday, 7 = Sunday
    required int hour,
    required int minute,
    String? payload,
    bool isB12 = false,
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    // Calculate days until target day
    int daysUntilTarget = (dayOfWeek - now.weekday) % 7;
    if (daysUntilTarget == 0) {
      // Same day - check if time has passed
      final todayScheduledTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      if (todayScheduledTime.isBefore(now)) {
        daysUntilTarget = 7; // Schedule for next week
      }
    }

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    ).add(Duration(days: daysUntilTarget));

    final details = isB12 ? _getB12NotificationDetails() : _getNotificationDetails();

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: payload,
    );
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
