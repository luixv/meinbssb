// Project: Mein BSSB
// Filename: ui_constants.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/material.dart';

class UIConstants {
  // Colors "apiBackground": "e2f0d9",

  static const Color defaultAppColor = Color(0xFF006400); // Main green color
  static const Color backgroundGreen = Color(0xFFe2f0d9);
  static const Color lightGreen = Colors.lightGreen;
  static const Color black = Colors.black;
  static const Color white = Colors.white;
  static const Color green = Colors.green;
  static const Color grey = Colors.grey;
  static const Color red = Colors.red;

  // Font Properties
  static const String defaultFontFamily = 'Arial'; // Roboto (no more)

  // Font Sizes
  static const double headerFontSize = 24.0; // "Hier Registrieren"
  static const double bodyFontSize = 14.0; // Normal text, form fields
  static const double titleFontSize = 20.0; // AppBar title
  static const double subtitleFontSize = 16.0; // Form labels

  // Spacing and Padding
  static const double defaultSpacing = 20.0; // Major section spacing
  static const double smallSpacing = 8.0; // Minor element spacing
  static const double defaultPadding = 16.0; // Standard padding
  static const double topPadding = 60.0; // Top padding in scroll view

  // Button Properties
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(vertical: 16.0);

  // Screen Padding
  static const EdgeInsets screenPadding = EdgeInsets.fromLTRB(
    defaultPadding, // left
    topPadding, // top
    defaultPadding, // right
    defaultPadding, // bottom
  );

  // Logo Size
  static const double logoSize = 100.0;

  // Text Styles
  static const TextStyle headerStyle = TextStyle(
    fontSize: headerFontSize,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle titleStyle = TextStyle(
    fontSize: titleFontSize,
    fontWeight: FontWeight.bold,
    color: black,
    backgroundColor: Colors.transparent,
    decorationColor: Colors.transparent,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: bodyFontSize,
    color: black,
    fontWeight: FontWeight.normal,
    backgroundColor: Colors.transparent,
    decorationColor: Colors.transparent,
  );

  static const TextStyle linkStyle = TextStyle(
    fontSize: bodyFontSize,
    decoration: TextDecoration.underline,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle successStyle = TextStyle(
    fontSize: bodyFontSize,
    color: green,
  );

  static const TextStyle errorStyle = TextStyle(
    fontSize: bodyFontSize,
    color: Colors.red,
  );

  // Form Styles
  static const InputDecoration defaultInputDecoration = InputDecoration(
    contentPadding: EdgeInsets.symmetric(
      vertical: smallSpacing,
      horizontal: defaultPadding,
    ),
    border: OutlineInputBorder(),
    errorStyle: errorStyle,
  );

  // Duration Constants
  static const Duration snackBarDuration = Duration(seconds: 5);
  static const Duration loadingDelay = Duration(milliseconds: 100);
}
