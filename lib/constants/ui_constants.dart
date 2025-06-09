// Project: Mein BSSB
// Filename: ui_constants.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/material.dart';

class UIConstants {
  // Colors
  static const Color primaryColor = Color(0xFF006400); // Main green color
  static const Color backgroundColor = Color(0xFFe2f0d9);
  static const Color foregroundColor = Colors.lightGreen;
  static const Color textColor = Colors.black;
  static const Color errorColor = Colors.red;
  static const Color successColor = Colors.green;
  static const Color warningColor = Color(0xFFFFA000);
  static const Color infoColor = Color(0xFF2196F3);
  static const Color linkColor = Colors.lightGreen;
  static const Color greyColor = Colors.grey;
  static const Color whiteColor = Colors.white;

  // Button Colors
  static const Color cancelButtonBackground = Colors.lightGreen;
  static const Color acceptButtonBackground = Colors.white;
  static const Color deleteButtonBackground = primaryColor;
  static const Color submitButtonBackground = Colors.lightGreen;

  static const Color buttonTextColor = Colors.white;
  static const Color cancelButtonText = Colors.white;
  static const Color deleteButtonText = Colors.white;
  static const Color submitButtonText = Colors.white;

  // Icon Colors
  static const Color deleteIcon = primaryColor;
  static const Color closeIcon = Colors.white;
  static const Color checkIcon = Colors.white;
  static const Color addIcon = Colors.white;
  static const Color saveEditIcon = Colors.white;
  static const Color connectivityIcon = Colors.green;
  static const Color noConnectivityIcon = Colors.red;
  static const Color bluetoothConnected = Colors.grey;
  static const Color networkCheck = Colors.grey;
  static const Color circularProgressIndicator = Colors.white;

  // Card Colors
  static const Color cardColor = Colors.white;
  static const Color boxDecorationColor = Colors.white;
  static const Color cursorColor = Colors.black;

  // Selection Colors
  static const Color selectionColor = Colors.transparent;
  static const Color selectionHandleColor = Colors.transparent;
  static const Color highlightColor = Colors.transparent;
  static const Color splashColor = Colors.transparent;

  // Table Colors
  static const Color tableBackground = Colors.white;
  static const Color tableBorder = Colors.white;
  static const Color tableContentColor = Colors.black;
  static const Color tileColor = Colors.white;

  // Calendar Colors
  static const Color calendarBackgroundColor = backgroundColor;
  static const Color calendarHeaderColor = Colors.lightGreen;
  static const Color calendarHeaderTextColor = primaryColor;
  static const Color calendarTextColor = Colors.black;
  static const Color calendarTodayColor = Colors.white;
  static const Color calendarTodayTextColor = Colors.black;
  static const Color calendarWeekendColor = Colors.white;
  static const Color calendarWeekendTextColor = Colors.black;
  static const Color calendarSelectedTextColor = Colors.white;
  static const Color calendarSelectedBackgroundColor = primaryColor;
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

  // Font Properties
  static const String defaultFontFamily = 'OpenSans';

  // Font Sizes
  static const double headerFontSize = 24.0;
  static const double bodyFontSize = 14.0;
  static const double titleFontSize = 20.0;
  static const double subtitleFontSize = 16.0;
  static const double buttonFontSize = 16.0;

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // Common Widgets
  static const SizedBox spacingXS = SizedBox(width: spacingXS, height: spacingXS);
  static const SizedBox spacingS = SizedBox(width: spacingS, height: spacingS);
  static const SizedBox spacingM = SizedBox(width: spacingM, height: spacingM);
  static const SizedBox spacingL = SizedBox(width: spacingL, height: spacingL);
  static const SizedBox spacingXL = SizedBox(width: spacingXL, height: spacingXL);

  static const SizedBox horizontalSpacingXS = SizedBox(width: spacingXS);
  static const SizedBox horizontalSpacingS = SizedBox(width: spacingS);
  static const SizedBox horizontalSpacingM = SizedBox(width: spacingM);
  static const SizedBox horizontalSpacingL = SizedBox(width: spacingL);
  static const SizedBox horizontalSpacingXL = SizedBox(width: spacingXL);

  static const SizedBox verticalSpacingXS = SizedBox(height: spacingXS);
  static const SizedBox verticalSpacingS = SizedBox(height: spacingS);
  static const SizedBox verticalSpacingM = SizedBox(height: spacingM);
  static const SizedBox verticalSpacingL = SizedBox(height: spacingL);
  static const SizedBox verticalSpacingXL = SizedBox(height: spacingXL);

  // Padding
  static const EdgeInsets defaultPadding = EdgeInsets.all(spacingM);
  static const EdgeInsets defaultHorizontalPadding = EdgeInsets.symmetric(horizontal: spacingM);
  static const EdgeInsets defaultVerticalPadding = EdgeInsets.symmetric(vertical: spacingM);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(vertical: spacingM);
  static const EdgeInsets screenPadding = EdgeInsets.fromLTRB(
    spacingM,
    60.0,
    spacingM,
    spacingM,
  );

  // Sizes
  static const double logoSize = 100.0;
  static const double cornerRadius = 8.0;
  static const double fabHeight = 16.0;
  static const double defaultStrokeWidth = 2.0;
  static const double defaultIconSize = 16.0;
  static const double defaultIconWidth = 60.0;
  static const double defaultButtonWidth = 120.0;
  static const double defaultImageHeight = 100.0;
  static const double defaultSeparatorHeight = 10.0;

  // Text Styles
  static final titleStyle = TextStyle(
    fontSize: titleFontSize,
    fontFamily: defaultFontFamily,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static final subtitleStyle = TextStyle(
    fontSize: subtitleFontSize,
    fontFamily: defaultFontFamily,
    fontWeight: FontWeight.w600,
    color: textColor,
  );

  static final bodyStyle = TextStyle(
    fontSize: bodyFontSize,
    fontFamily: defaultFontFamily,
    color: textColor,
  );

  static final headerStyle = TextStyle(
    fontSize: headerFontSize,
    fontFamily: defaultFontFamily,
    fontWeight: FontWeight.bold,
  );

  static final appBarTitleStyle = TextStyle(
    fontSize: titleFontSize,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );

  static final listItemTitleStyle = TextStyle(
    fontSize: subtitleFontSize,
    fontWeight: FontWeight.bold,
    color: tableContentColor,
  );

  static final listItemSubtitleStyle = TextStyle(
    fontSize: bodyFontSize,
    color: greyColor,
  );

  // Form Styles
  static final formLabelStyle = TextStyle(
    fontSize: subtitleFontSize,
    color: textColor,
  );

  static final formValueStyle = TextStyle(
    fontSize: bodyFontSize,
    color: textColor,
  );

  static final formValueBoldStyle = TextStyle(
    fontSize: bodyFontSize,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static final formErrorStyle = TextStyle(
    fontSize: bodyFontSize,
    color: errorColor,
  );

  // Message Styles
  static final errorMessageStyle = TextStyle(
    fontSize: bodyFontSize,
    color: errorColor,
  );

  static final successMessageStyle = TextStyle(
    fontSize: bodyFontSize,
    color: successColor,
  );

  static final warningMessageStyle = TextStyle(
    fontSize: bodyFontSize,
    color: warningColor,
  );

  static final infoMessageStyle = TextStyle(
    fontSize: bodyFontSize,
    color: infoColor,
  );

  static final offlineMessageStyle = TextStyle(
    fontSize: subtitleFontSize,
    color: greyColor,
  );

  // Dialog Styles
  static final dialogTitleStyle = TextStyle(
    fontSize: titleFontSize,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static final dialogContentStyle = TextStyle(
    fontSize: bodyFontSize,
    color: textColor,
  );

  static final dialogButtonStyle = TextStyle(
    fontSize: buttonFontSize,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );

  static const dialogPadding = EdgeInsets.all(spacingM);
  static const dialogButtonPadding = EdgeInsets.symmetric(
    horizontal: spacingM,
    vertical: spacingS,
  );

  // Dialog Button Styles
  static final dialogAcceptButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: acceptButtonBackground,
    padding: buttonPadding,
  );

  static final dialogCancelButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: cancelButtonBackground,
    padding: buttonPadding,
  );

  // Button Styles
  static final primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    padding: buttonPadding,
  );

  static final secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: backgroundColor,
    padding: buttonPadding,
  );

  // Input Decoration
  static final formInputDecoration = InputDecoration(
    labelStyle: formLabelStyle,
    hintStyle: formLabelStyle,
    errorStyle: formErrorStyle,
    border: const OutlineInputBorder(),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: spacingM,
      vertical: spacingS,
    ),
  );
}
