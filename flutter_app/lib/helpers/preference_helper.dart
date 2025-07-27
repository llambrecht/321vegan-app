import 'dart:convert'; // Import for JSON encoding/decoding
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  // Method to add a selected date to shared preferences
  static Future<void> addSelectedDateToPrefs(DateTime? selectedDate) async {
    final prefs = await SharedPreferences.getInstance();
    String? dateString;
    if (selectedDate == null) {
      dateString = "none";
    } else {
      dateString = selectedDate.toIso8601String();
    }
    await prefs.setString('selected_date', dateString);
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
    int totalSuccessful = prefs.getInt('total_successful_submissions') ?? 0;
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
      Map<String, bool> codesWithStatus =
          await getCodesWithStatusFromPreferences();
      total =
          codesWithStatus.entries.where((entry) => entry.value == true).length;
      await prefs.setInt('total_successful_submissions', total);
    }

    total = prefs.getInt('total_successful_submissions') ?? 0;

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
}
