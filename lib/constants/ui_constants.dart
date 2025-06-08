// Project: Mein BSSB
// Filename: ui_constants.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/material.dart';

class UIConstants {
  // Colors "apiBackground": "e2f0d9",

  static const Color defaultAppColor = Color(0xFF006400); // Main green color
  static const Color backgroundColor = Color(0xFFe2f0d9);
  static const Color foregroundColor = Colors.lightGreen;

  // Button Properties
  static const Color cancelButtonBackground = Colors.lightGreen;
  static const Color acceptButtonBackground = Colors.lightGreen;
  static const Color submitButtonText = Colors.white;
  static const Color cancelButtonText = Colors.white;
  static const Color deleteButtonText = Colors.white;

  static const Color disabledSubmitButtonText = Colors.white;

  // Icon Properties
  static const Color deleteIcon = defaultAppColor;
  static const Color closeIcon = Colors.white;
  static const Color checkIcon = Colors.white;
  static const Color addIcon = Colors.white;
  static const Color saveEditIcon = Colors.white;
  static const Color connectivityIcon = Colors.green;
  static const Color noConnectivityIcon = Colors.red;
  static const Color bluetoothConnected = Colors.grey;
  static const Color networkCheck = Colors.grey;

  static const Color circularProgressIndicator = Colors.white;
  static const Color cardColor = Colors.white;

  static const Color primarySwatch = Colors.blue;
  static const Color greySubtitleText = Colors.grey;

//Selection Properties
  static const Color selectionColor = Colors.transparent;
  static const Color selectionHandleColor = Colors.transparent;
  static const Color highlightColor = Colors.transparent;
  static const Color splashColor = Colors.transparent;

// Errors Properties
  static const Color error = Colors.red;
  static const Color success = Colors.green;

// Cookies Dialog color
  static const Color cookiesDialogColor = Colors.transparent;

// Link Color
  static const Color linkColor = Colors.lightGreen;

// News Properties
  static const Color news = Color(0xFFF4B183);
  static const Color newsText = Colors.white;

//Table Properties
  static const Color tableBackground = Colors.white;
  static const Color tableBorder = Colors.white;
  static const Color tableContentColor = Colors.black;
  static const Color tileColor = Colors.white;

  static const Color boxDecorationColor = Colors.white;
  static const Color cursorColor = Colors.black;

  // Calendar Properties
  static const Color calendarBackgroundColor = backgroundColor;
  static const Color calendarHeaderColor = Colors.lightGreen;
  static const Color calendarHeaderTextColor = defaultAppColor;
  static const Color calendarTextColor = Colors.black;
  static const Color calendarTodayColor = Colors.white;
  static const Color calendarTodayTextColor = Colors.black;
  static const Color calendarWeekendColor = Colors.white;
  static const Color calendarWeekendTextColor = Colors.black;
  static const Color calendarSelectedTextColor = Colors.white;
  static const Color calendarSelectedBackgroundColor = defaultAppColor;
  static const Color calendarDisabledTextColor = Colors.grey;
  static const Color calendarDisabledBackgroundColor = Colors.white;
  static const Color calendarDisabledSelectedTextColor = Colors.white;
  static const Color calendarDisabledSelectedBackgroundColor = Colors.grey;
  static const Color calendarHeaderBorderColor = Colors.black;
  static const Color calendarBorderColor = Colors.black;
  static const Color calendarTodayBorderColor = Colors.black;
  static const Color calendarWeekendBorderColor = Colors.black;
  static const Color calendarDisabledBorderColor = Colors.grey;
  static const Color calendarDisabledSelectedBorderColor = Colors.grey;
  static const Color calendarHeaderTextBorderColor = Colors.black;
  static const Color calendarTextBorderColor = Colors.black;
  static const Color calendarTodayTextBorderColor = Colors.black;
  static const Color calendarWeekendTextBorderColor = Colors.black;
  static const Color calendarSelectedTextBorderColor = Colors.white;
  static const Color calendarSelectedBackgroundBorderColor = defaultAppColor;
  static const Color calendarDisabledTextBorderColor = Colors.grey;
  static const Color calendarDisabledBackgroundBorderColor = Colors.white;
  static const Color calendarDisabledSelectedTextBorderColor = Colors.white;
  static const Color calendarDisabledSelectedBackgroundBorderColor =
      Colors.grey;
  static const Color calendarHeaderTextColorBorder = Colors.black;
  static const Color calendarTextColorBorder = Colors.black;

  static const Color calendarColor = Colors.black;
  static const Color calendarSelectedColor = defaultAppColor;

  // Font Properties  Arial, Calibri, OpenSans, Roboto (no more)
  static const String defaultFontFamily = 'OpenSans'; //

  // Font Sizes
  static const double headerFontSize = 24.0; // "Hier Registrieren"
  static const double bodyFontSize = 14.0; // Normal text, form fields
  static const double titleFontSize = 20.0; // AppBar title
  static const double subtitleFontSize = 16.0; // Form labels

  // Spacing and Padding
  static const double defaultSpacing = 20.0; // Major section spacing
  static const double smallSpacing = 8.0; // Minor element spacing
  static const double mediumSpacing = 10.0; // Medium element spacing
  static const double largeSpacing = 12.0; // large element spacing
  static const double largerSpacing = 16.0; // larger element spacing
  static const double defaultPadding = 16.0; // Standard padding

  static const double topPadding = 60.0; // Top padding in scroll view

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

  static const double cornerRadius = 8.0;

  // Text Styles
  static const TextStyle headerStyle = TextStyle(
    fontSize: headerFontSize,
    fontFamily: defaultFontFamily,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 18.0, // Example size, adjust as needed
    fontWeight: FontWeight.w600, // Example weight, adjust as needed
    fontFamily: defaultFontFamily,
    color: Colors.black87, // Default color, can be overridden
  );

  static const TextStyle titleStyle = TextStyle(
    fontSize: titleFontSize,
    fontFamily: defaultFontFamily,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    backgroundColor: Colors.transparent,
    decorationColor: Colors.transparent,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: bodyFontSize,
    fontFamily: defaultFontFamily,
    color: Colors.black,
    fontWeight: FontWeight.normal,
    backgroundColor: Colors.transparent,
    decorationColor: Colors.transparent,
  );

  static const TextStyle linkStyle = TextStyle(
    fontSize: bodyFontSize,
    fontFamily: defaultFontFamily,
    decoration: TextDecoration.underline,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle successStyle = TextStyle(
    fontSize: bodyFontSize,
    fontFamily: defaultFontFamily,
    color: Colors.green,
  );

  static const TextStyle errorStyle = TextStyle(
    fontSize: bodyFontSize,
    fontFamily: defaultFontFamily,
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
