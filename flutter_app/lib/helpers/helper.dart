import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}

class Helper {
  static void saveLastSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastSearch', query);
  }

  static void saveLastSearchCosmetics(String query) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastSearchCosmetics', query);
  }

  static void showTopSnackBar(
      BuildContext context, Widget content, Color color) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 60, // Distance from the top
        left: MediaQuery.of(context).size.width * 0,
        width: MediaQuery.of(context).size.width,
        child: Material(
          elevation: 10.0,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(8),
            color: color,
            child: content,
          ),
        ),
      ),
    );
    overlay.insert(overlayEntry);
    // Automatically remove the snack bar after some duration
    Future.delayed(const Duration(seconds: 3))
        .then((value) => overlayEntry.remove());
  }
}
