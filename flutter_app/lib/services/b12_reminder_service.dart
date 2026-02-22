import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/b12_reminder_settings.dart';
import 'notification_service.dart';

class B12ReminderService {
  static const String _settingsKey = 'b12_reminder_settings';
  static const int _notificationId = 1000; // Unique ID for B12 notifications
  static const int _biweeklyNotificationId =
      1001; // Second ID for biweekly alternating

  static final NotificationService _notificationService = NotificationService();

  /// Get saved reminder settings
  static Future<B12ReminderSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);

    if (settingsJson != null) {
      try {
        return B12ReminderSettings.fromJson(json.decode(settingsJson));
      } catch (e) {
        // If there's an error parsing, return default settings
        return B12ReminderSettings();
      }
    }

    return B12ReminderSettings();
  }

  /// Save reminder settings
  static Future<void> saveSettings(B12ReminderSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, json.encode(settings.toJson()));
  }

  /// Schedule reminder based on settings
  static Future<void> scheduleReminder(B12ReminderSettings settings) async {
    // Cancel any existing reminders first
    await cancelReminder();

    if (!settings.enabled) {
      await saveSettings(settings);
      return;
    }

    // Request notification permissions
    final hasPermission = await _notificationService.requestPermissions();
    if (!hasPermission) {
      return;
    }

    // Show a test notification to ensure the channel is properly initialized
    await _notificationService.showTestNotification();

    const title = '💊 Rappel B12';
    const body = 'N\'oubliez pas de prendre votre vitamine B12 !';

    switch (settings.frequency) {
      case ReminderFrequency.daily:
        await _notificationService.scheduleDailyNotification(
          id: _notificationId,
          title: title,
          body: body,
          hour: settings.hour,
          minute: settings.minute,
          payload: 'b12_reminder',
        );
        break;

      case ReminderFrequency.weekly:
        if (settings.dayOfWeek != null) {
          await _notificationService.scheduleWeeklyNotification(
            id: _notificationId,
            title: title,
            body: body,
            dayOfWeek: settings.dayOfWeek!,
            hour: settings.hour,
            minute: settings.minute,
            payload: 'b12_reminder',
          );
        }
        break;

      case ReminderFrequency.biweekly:
        if (settings.dayOfWeek != null) {
          // For biweekly, we need to schedule two alternating weekly notifications
          await _scheduleBiweeklyNotification(
            id: _notificationId,
            title: title,
            body: body,
            dayOfWeek: settings.dayOfWeek!,
            hour: settings.hour,
            minute: settings.minute,
            payload: 'b12_reminder_biweekly',
          );
        }
        break;
    }

    // Save the settings
    await saveSettings(settings);
  }

  /// Schedule a biweekly notification
  static Future<void> _scheduleBiweeklyNotification({
    required int id,
    required String title,
    required String body,
    required int dayOfWeek,
    required int hour,
    required int minute,
    String? payload,
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
        daysUntilTarget = 14; // Schedule for two weeks from now
      }
    }

    // Check if we should schedule this week or next (alternating)
    final prefs = await SharedPreferences.getInstance();
    final lastNotificationMillis = prefs.getInt('b12_last_notification_date');

    if (lastNotificationMillis != null) {
      try {
        final lastDate =
            DateTime.fromMillisecondsSinceEpoch(lastNotificationMillis);
        final daysSinceLastNotification = now.difference(lastDate).inDays;

        // If less than 7 days since last notification, schedule in 14 days
        if (daysSinceLastNotification < 7) {
          daysUntilTarget = 14;
        }
      } catch (e) {
        // Ignore parsing errors
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

    await _notificationService.scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      payload: payload,
    );

    // Save the scheduled date for biweekly tracking (as milliseconds since epoch to avoid timezone issues)
    await prefs.setInt(
      'b12_next_notification_date',
      scheduledDate.millisecondsSinceEpoch,
    );
  }

  /// Mark that notification was received (for biweekly tracking)
  static Future<void> markNotificationReceived() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      'b12_last_notification_date',
      DateTime.now().millisecondsSinceEpoch,
    );

    // If biweekly, reschedule the next one
    final settings = await getSettings();
    if (settings.enabled && settings.frequency == ReminderFrequency.biweekly) {
      await scheduleReminder(settings);
    }
  }

  /// Cancel all B12 reminders
  static Future<void> cancelReminder() async {
    await _notificationService.cancelNotification(_notificationId);
    await _notificationService.cancelNotification(_biweeklyNotificationId);
  }

  /// Get next scheduled notification time
  static Future<DateTime?> getNextNotificationTime() async {
    final settings = await getSettings();

    if (!settings.enabled) {
      return null;
    }

    final now = DateTime.now();

    switch (settings.frequency) {
      case ReminderFrequency.daily:
        var nextTime = DateTime(
          now.year,
          now.month,
          now.day,
          settings.hour,
          settings.minute,
        );

        if (nextTime.isBefore(now)) {
          nextTime = nextTime.add(const Duration(days: 1));
        }

        return nextTime;

      case ReminderFrequency.weekly:
        if (settings.dayOfWeek == null) return null;

        int daysUntilTarget = (settings.dayOfWeek! - now.weekday) % 7;
        if (daysUntilTarget == 0) {
          final todayScheduledTime = DateTime(
            now.year,
            now.month,
            now.day,
            settings.hour,
            settings.minute,
          );
          if (todayScheduledTime.isBefore(now)) {
            daysUntilTarget = 7;
          }
        }

        return DateTime(
          now.year,
          now.month,
          now.day,
          settings.hour,
          settings.minute,
        ).add(Duration(days: daysUntilTarget));

      case ReminderFrequency.biweekly:
        // For biweekly, check the saved next notification date
        final prefs = await SharedPreferences.getInstance();
        final nextDateMillis = prefs.getInt('b12_next_notification_date');

        if (nextDateMillis != null) {
          try {
            return DateTime.fromMillisecondsSinceEpoch(nextDateMillis);
            // ignore: empty_catches
          } catch (e) {}
        }

        // Calculate next biweekly occurrence
        if (settings.dayOfWeek == null) return null;

        int daysUntilTarget = (settings.dayOfWeek! - now.weekday) % 7;
        if (daysUntilTarget == 0) {
          final todayScheduledTime = DateTime(
            now.year,
            now.month,
            now.day,
            settings.hour,
            settings.minute,
          );
          if (todayScheduledTime.isBefore(now)) {
            daysUntilTarget = 14;
          }
        }

        return DateTime(
          now.year,
          now.month,
          now.day,
          settings.hour,
          settings.minute,
        ).add(Duration(days: daysUntilTarget));
    }
  }

  /// Check if notifications are enabled in system settings
  static Future<bool> areNotificationsEnabled() async {
    return await _notificationService.areNotificationsEnabled();
  }
}
