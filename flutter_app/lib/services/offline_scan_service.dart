import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'api_service.dart';

/// Handle offline "interesting products" scan events with automatic retry
/// We need this in case the user scans a product while offline
class OfflineScanService {
  static const String _pendingScanEventsKey = 'pending_scan_events';
  static const String _failedScanEventsKey = 'failed_scan_events';

  /// Save a pending scan event to local storage
  static Future<void> savePendingScanEvent({
    required String ean,
    double? latitude,
    double? longitude,
    int? userId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> pendingEvents =
          prefs.getStringList(_pendingScanEventsKey) ?? [];

      final scanEvent = {
        'ean': ean,
        'latitude': latitude,
        'longitude': longitude,
        'user_id': userId,
        'timestamp': DateTime.now().toIso8601String(),
      };

      pendingEvents.add(json.encode(scanEvent));
      await prefs.setStringList(_pendingScanEventsKey, pendingEvents);
    } catch (e) {
      print('Failed to save pending scan event: $e');
    }
  }

  /// Save a failed scan event to retry later
  static Future<void> saveFailedScanEvent({
    required String ean,
    double? latitude,
    double? longitude,
    int? userId,
    int? scanEventId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> failedEvents =
          prefs.getStringList(_failedScanEventsKey) ?? [];

      final scanEvent = {
        'ean': ean,
        'latitude': latitude,
        'longitude': longitude,
        'user_id': userId,
        'scan_event_id': scanEventId,
        'timestamp': DateTime.now().toIso8601String(),
        'retry_count': 0,
      };

      failedEvents.add(json.encode(scanEvent));
      await prefs.setStringList(_failedScanEventsKey, failedEvents);
    } catch (e) {
      print('Failed to save failed scan event: $e');
    }
  }

  /// Get all pending scan events
  static Future<List<Map<String, dynamic>>> getPendingScanEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> pendingEvents =
          prefs.getStringList(_pendingScanEventsKey) ?? [];

      return pendingEvents
          .map((event) => json.decode(event) as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Failed to get pending scan events: $e');
      return [];
    }
  }

  /// Get all failed scan events
  static Future<List<Map<String, dynamic>>> getFailedScanEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> failedEvents =
          prefs.getStringList(_failedScanEventsKey) ?? [];

      return failedEvents
          .map((event) => json.decode(event) as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Failed to get failed scan events: $e');
      return [];
    }
  }

  /// Remove a pending scan event
  static Future<void> removePendingScanEvent(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> pendingEvents =
          prefs.getStringList(_pendingScanEventsKey) ?? [];

      if (index >= 0 && index < pendingEvents.length) {
        pendingEvents.removeAt(index);
        await prefs.setStringList(_pendingScanEventsKey, pendingEvents);
      }
    } catch (e) {
      print('Failed to remove pending scan event: $e');
    }
  }

  /// Remove a failed scan event
  static Future<void> removeFailedScanEvent(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> failedEvents =
          prefs.getStringList(_failedScanEventsKey) ?? [];

      if (index >= 0 && index < failedEvents.length) {
        failedEvents.removeAt(index);
        await prefs.setStringList(_failedScanEventsKey, failedEvents);
      }
    } catch (e) {
      print('Failed to remove failed scan event: $e');
    }
  }

  /// Clear all pending scan events
  static Future<void> clearPendingScanEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pendingScanEventsKey);
    } catch (e) {
      print('Failed to clear pending scan events: $e');
    }
  }

  /// Clear all failed scan events
  static Future<void> clearFailedScanEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_failedScanEventsKey);
    } catch (e) {
      print('Failed to clear failed scan events: $e');
    }
  }

  /// Post a scan event with offline support
  /// Returns a tuple: (success, response, shouldShowDialog)
  static Future<(bool, Map<String, dynamic>?, bool)>
      postScanEventWithOfflineSupport({
    required String ean,
    double? latitude,
    double? longitude,
    int? userId,
  }) async {
    // First, save to local storage as a pending event
    await savePendingScanEvent(
      ean: ean,
      latitude: latitude,
      longitude: longitude,
      userId: userId,
    );

    // Check connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    final hasConnection = !connectivityResult.contains(ConnectivityResult.none);

    if (!hasConnection) {
      return (false, null, false);
    }

    // Try to post to API
    try {
      final response = await ApiService.postScanEvent(
        ean: ean,
        latitude: latitude,
        longitude: longitude,
      );

      if (response != null) {
        // Success! Remove from pending
        final pendingEvents = await getPendingScanEvents();
        for (int i = 0; i < pendingEvents.length; i++) {
          final event = pendingEvents[i];
          if (event['ean'] == ean &&
              event['latitude'] == latitude &&
              event['longitude'] == longitude) {
            await removePendingScanEvent(i);
            break;
          }
        }
        return (true, response, true);
      } else {
        // Failed to post
        await saveFailedScanEvent(
          ean: ean,
          latitude: latitude,
          longitude: longitude,
          userId: userId,
        );
        return (false, null, false);
      }
    } catch (e) {
      await saveFailedScanEvent(
        ean: ean,
        latitude: latitude,
        longitude: longitude,
        userId: userId,
      );
      return (false, null, false);
    }
  }

  /// Retry all pending and failed scan events
  /// Returns a tuple: (successCount, List of events that need shop confirmation)
  /// Each shop confirmation event contains: {ean, shop_name, scan_event_id}
  static Future<(int, List<Map<String, dynamic>>)> retryPendingScans() async {
    int successCount = 0;
    List<Map<String, dynamic>> shopConfirmationsNeeded = [];

    // Check connectivity first
    final connectivityResult = await Connectivity().checkConnectivity();
    final hasConnection = !connectivityResult.contains(ConnectivityResult.none);

    if (!hasConnection) {
      return (0, <Map<String, dynamic>>[]);
    }

    // Retry pending events
    final pendingEvents = await getPendingScanEvents();
    for (int i = pendingEvents.length - 1; i >= 0; i--) {
      final event = pendingEvents[i];
      try {
        final response = await ApiService.postScanEvent(
          ean: event['ean'],
          latitude: event['latitude'],
          longitude: event['longitude'],
        );

        if (response != null) {
          await removePendingScanEvent(i);
          successCount++;

          // Check if shop confirmation is needed
          final shopName = response['shop_name'] as String?;
          final scanEventId = response['id'] as int?;
          if (shopName != null && scanEventId != null) {
            shopConfirmationsNeeded.add({
              'ean': event['ean'],
              'shop_name': shopName,
              'scan_event_id': scanEventId,
            });
          }
        }
      } catch (e) {
        // Move to failed events after too many retries
        await saveFailedScanEvent(
          ean: event['ean'],
          latitude: event['latitude'],
          longitude: event['longitude'],
          userId: event['user_id'],
        );
        await removePendingScanEvent(i);
      }
    }

    // Retry failed events
    final failedEvents = await getFailedScanEvents();
    for (int i = failedEvents.length - 1; i >= 0; i--) {
      final event = failedEvents[i];
      final retryCount = event['retry_count'] ?? 0;

      // Max 3 retries
      if (retryCount >= 3) {
        continue;
      }

      try {
        final response = await ApiService.postScanEvent(
          ean: event['ean'],
          latitude: event['latitude'],
          longitude: event['longitude'],
        );

        if (response != null) {
          await removeFailedScanEvent(i);
          successCount++;

          // Check if shop confirmation is needed
          final shopName = response['shop_name'] as String?;
          final scanEventId = response['id'] as int?;
          if (shopName != null && scanEventId != null) {
            shopConfirmationsNeeded.add({
              'ean': event['ean'],
              'shop_name': shopName,
              'scan_event_id': scanEventId,
            });
          }
        } else {
          // Increment retry count
          event['retry_count'] = retryCount + 1;
          final prefs = await SharedPreferences.getInstance();
          final List<String> failedEvents =
              prefs.getStringList(_failedScanEventsKey) ?? [];
          failedEvents[i] = json.encode(event);
          await prefs.setStringList(_failedScanEventsKey, failedEvents);
        }
      } catch (e) {
        print('❌ Failed to retry failed scan event: $e');
        // Increment retry count
        event['retry_count'] = retryCount + 1;
        final prefs = await SharedPreferences.getInstance();
        final List<String> failedEvents =
            prefs.getStringList(_failedScanEventsKey) ?? [];
        if (i < failedEvents.length) {
          failedEvents[i] = json.encode(event);
          await prefs.setStringList(_failedScanEventsKey, failedEvents);
        }
      }
    }

    if (successCount > 0) {
      print('📤 Successfully synced $successCount scan event(s)');
    }

    return (successCount, shopConfirmationsNeeded);
  }

  /// Get count of pending events
  static Future<int> getPendingCount() async {
    final pending = await getPendingScanEvents();
    final failed = await getFailedScanEvents();
    return pending.length + failed.length;
  }
}
