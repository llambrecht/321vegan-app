import 'dart:convert'; // Import for JSON encoding/decoding
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class PreferencesHelper {
  // Internal method: saves date to local storage only (no backend update)
  // Used by AuthService to avoid circular backend calls during login sync
  static Future<void> saveSelectedDateToPrefsOnly(
      DateTime? selectedDate) async {
    final prefs = await SharedPreferences.getInstance();
    String? dateString;
    if (selectedDate == null) {
      dateString = "none";
    } else {
      dateString = selectedDate.toIso8601String();
    }
    await prefs.setString('selected_date', dateString);
  }

  // Method to add a selected date to shared preferences and update backend if logged in
  static Future<void> addSelectedDateToPrefs(DateTime? selectedDate) async {
    await saveSelectedDateToPrefsOnly(selectedDate);

    // If user is logged in, also update on the backend
    if (selectedDate != null && AuthService.isLoggedIn) {
      await AuthService.updateUser(veganSince: selectedDate);
    }
  }

  // Method to get a selected date from shared preferences
  static Future<DateTime?> getSelectedDateFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    String? dateString = prefs.getString('selected_date');
    if (dateString != null && dateString != "none") {
      return DateTime.parse(dateString);
    }
    return null;
  }

  static Future<bool> isCodeInPreferences(String code) async {
    final prefs = await SharedPreferences.getInstance();
    String? codesJson = prefs.getString('codes_with_status');
    if (codesJson != null) {
      Map<String, bool> codesWithStatus =
          Map<String, bool>.from(json.decode(codesJson));
      bool containsCode = codesWithStatus.containsKey(code);
      return containsCode;
    }
    return false;
  }

  // Save 'open on scan page' preference
  static Future<void> setOpenOnScanPagePref(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('open_on_scan_page', value);
  }

  // Load 'open on scan page' preference
  static Future<bool> getOpenOnScanPagePref() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('open_on_scan_page') ?? false;
  }

  // Save 'show boycott' preference
  static Future<void> setShowBoycottPref(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_boycott', value);
  }

  // Load 'show boycott' preference
  static Future<bool> getShowBoycottPref() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('show_boycott') ??
        true; // Default to true to show boycott
  }

  // Method to add or remove a code based on success status
  static Future<void> addCodeToPreferences(String? code, bool success) async {
    if (code == null) return;

    final prefs = await SharedPreferences.getInstance();
    String? codesJson = prefs.getString('codes_with_status');

    // Decode the JSON string to a Map
    Map<String, bool> codesWithStatus =
        codesJson != null ? Map<String, bool>.from(json.decode(codesJson)) : {};

    if (!success && codesWithStatus[code] != true) {
      codesWithStatus[code] = false;
    } else if (success) {
      // If success is true, set the status to true
      codesWithStatus[code] = true;
    }

    // Track total successful submissions
    int totalSuccessful = 0;
    if (prefs.getInt('total_successful_submissions') == null) {
      totalSuccessful = await migrateTotalSuccessfulSubmissions();
    } else {
      totalSuccessful = prefs.getInt('total_successful_submissions') ?? 0;
    }
    if (success) {
      totalSuccessful++;
      await prefs.setInt('total_successful_submissions', totalSuccessful);
    }

    // Ensure the codes list contains a maximum of 300 items
    if (codesWithStatus.length > 300) {
      List<MapEntry<String, bool>> entries = codesWithStatus.entries.toList();
      // Remove the oldest entries (first in the list)
      entries.removeRange(0, entries.length - 300);
      codesWithStatus = Map.fromEntries(entries);
    }

    await prefs.setString('codes_with_status', json.encode(codesWithStatus));
  }

  // Method to get all codes with their status from shared preferences
  static Future<Map<String, bool>> getCodesWithStatusFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String? codesJson = prefs.getString('codes_with_status');

    if (codesJson != null) {
      // Decode the JSON string back to a Map
      return Map<String, bool>.from(json.decode(codesJson));
    }
    return {};
  }

  // Method to get only successfully sent codes
  static Future<List<String>> getSuccessfulCodesFromPreferences() async {
    Map<String, bool> codesWithStatus =
        await getCodesWithStatusFromPreferences();
    return codesWithStatus.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();
  }

  // Method to get total number of successful submissions (including removed ones)
  static Future<int> getTotalSuccessfulSubmissions() async {
    final prefs = await SharedPreferences.getInstance();
    int total = 0;
    if (prefs.getInt('total_successful_submissions') == null) {
      total = await migrateTotalSuccessfulSubmissions();
    } else {
      total = prefs.getInt('total_successful_submissions') ?? 0;
    }

    return total;
  }

  static Future<int> migrateTotalSuccessfulSubmissions() async {
    final prefs = await SharedPreferences.getInstance();
    int total = 0;

    Map<String, bool> codesWithStatus =
        await getCodesWithStatusFromPreferences();
    total =
        codesWithStatus.entries.where((entry) => entry.value == true).length;
    await prefs.setInt('total_successful_submissions', total);
    return total;
  }

  static Future<void> addBarcodeToHistory(String barcode) async {
    final prefs = await SharedPreferences.getInstance();
    String? historyJson = prefs.getString('scan_history');

    List<Map<String, dynamic>> history = historyJson != null
        ? List<Map<String, dynamic>>.from(json.decode(historyJson))
        : [];

    // Get the current timestamp
    final now = DateTime.now();

    // Check if the barcode already exists in the same minute
    final alreadyExists = history.any((item) {
      final itemTimestamp = DateTime.parse(item['timestamp']);
      return item['barcode'] == barcode &&
          itemTimestamp.year == now.year &&
          itemTimestamp.month == now.month &&
          itemTimestamp.day == now.day &&
          itemTimestamp.hour == now.hour &&
          itemTimestamp.minute == now.minute;
    });

    // If it doesn't exist, add it to the history
    if (!alreadyExists) {
      history.add({
        'barcode': barcode,
        'timestamp': now.toIso8601String(),
      });

      // Ensure the history contains a maximum of 50 items
      if (history.length > 50) {
        history.removeAt(0); // Remove the oldest entry
      }

      // Save the updated history back to shared preferences
      await prefs.setString('scan_history', json.encode(history));
    }
  }

  static Future<List<Map<String, dynamic>>> getScanHistory() async {
    final prefs = await SharedPreferences.getInstance();
    String? historyJson = prefs.getString('scan_history');

    if (historyJson != null) {
      return List<Map<String, dynamic>>.from(json.decode(historyJson))
          .reversed
          .toList();
    }
    return [];
  }

  static Future<void> clearScanHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('scan_history');
  }

  // Avatar preference methods
  static Future<void> saveAvatar(String? avatar) async {
    final prefs = await SharedPreferences.getInstance();
    if (avatar == null) {
      await prefs.remove('user_avatar');
    } else {
      await prefs.setString('user_avatar', avatar);
    }
  }

  static Future<String?> getAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_avatar');
  }

  static Future<void> saveRandomAvatarEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('random_avatar_enabled', enabled);
  }

  static Future<bool> getRandomAvatarEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('random_avatar_enabled') ?? false;
  }

  // Profile badge preference methods
  static Future<void> setHasVisitedProfile(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_visited_profile', value);
  }

  static Future<bool> getHasVisitedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_visited_profile') ?? false;
  }
}
