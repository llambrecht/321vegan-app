import 'package:flutter/material.dart';

class FirstLaunchStyles {
  static TextStyle get titleTextStyle => const TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );

  static ButtonStyle get buttonStyle => ElevatedButton.styleFrom(
        minimumSize: const Size(150, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        textStyle: const TextStyle(fontSize: 18.0),
      );
}
