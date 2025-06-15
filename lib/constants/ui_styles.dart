// Project: Mein BSSB
// Filename: ui_styles.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/material.dart';
import 'ui_constants.dart';

class UIStyles {
  // Text styles
  static const TextStyle appBarTitleStyle = TextStyle(
    fontSize: 20.0,
    fontFamily: UIConstants.defaultFontFamily,
    fontWeight: FontWeight.bold,
    color: UIConstants.textColor,
  );

  static const TextStyle titleStyle = TextStyle(
    fontSize: UIConstants.titleFontSize,
    fontFamily: UIConstants.defaultFontFamily,
    fontWeight: FontWeight.bold,
    color: UIConstants.textColor,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: UIConstants.subtitleFontSize,
    fontFamily: UIConstants.defaultFontFamily,
    fontWeight: FontWeight.w500,
    color: UIConstants.textColor,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: UIConstants.bodyFontSize,
    fontFamily: UIConstants.defaultFontFamily,
    color: UIConstants.textColor,
  );

  static const TextStyle buttonStyle = TextStyle(
    fontSize: UIConstants.buttonFontSize,
    fontFamily: UIConstants.defaultFontFamily,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static const TextStyle formLabelStyle = TextStyle(
    fontSize: UIConstants.bodyFontSize,
    fontFamily: UIConstants.defaultFontFamily,
    color: UIConstants.textColor,
  );

  static const TextStyle formValueStyle = TextStyle(
    fontSize: UIConstants.bodyFontSize,
    fontFamily: UIConstants.defaultFontFamily,
    color: UIConstants.textColor,
  );

  static const TextStyle formValueBoldStyle = TextStyle(
    fontSize: UIConstants.bodyFontSize,
    fontFamily: UIConstants.defaultFontFamily,
    fontWeight: FontWeight.bold,
    color: UIConstants.textColor,
  );

  static const TextStyle errorStyle = TextStyle(
    fontSize: UIConstants.bodyFontSize,
    fontFamily: UIConstants.defaultFontFamily,
    color: UIConstants.errorColor,
  );

  static const TextStyle successStyle = TextStyle(
    fontSize: UIConstants.bodyFontSize,
    fontFamily: UIConstants.defaultFontFamily,
    color: UIConstants.successColor,
  );

  static const TextStyle warningStyle = TextStyle(
    fontSize: UIConstants.bodyFontSize,
    fontFamily: UIConstants.defaultFontFamily,
    color: UIConstants.warningColor,
  );

  static const TextStyle newsStyle = TextStyle(
    fontSize: UIConstants.titleFontSize,
    fontFamily: UIConstants.defaultFontFamily,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle listItemTitleStyle = TextStyle(
    fontSize: UIConstants.bodyFontSize,
    fontFamily: UIConstants.defaultFontFamily,
    fontWeight: FontWeight.w500,
    color: UIConstants.textColor,
  );

  static const TextStyle listItemSubtitleStyle = TextStyle(
    fontSize: UIConstants.bodyFontSize,
    fontFamily: UIConstants.defaultFontFamily,
    color: UIConstants.greyColor,
  );

  static const TextStyle dialogTitleStyle = TextStyle(
    fontSize: UIConstants.titleFontSize,
    fontFamily: UIConstants.defaultFontFamily,
    fontWeight: FontWeight.bold,
    color: UIConstants.textColor,
  );

  static const TextStyle dialogContentStyle = TextStyle(
    fontSize: UIConstants.bodyFontSize,
    fontFamily: UIConstants.defaultFontFamily,
    color: UIConstants.textColor,
  );

  static const TextStyle dialogButtonTextStyle = TextStyle(
    fontSize: UIConstants.bodyFontSize,
    fontFamily: UIConstants.defaultFontFamily,
    fontWeight: FontWeight.w500,
    color: UIConstants.whiteColor,
  );

  static const TextStyle linkStyle = TextStyle(
    fontSize: UIConstants.bodyFontSize,
    fontFamily: UIConstants.defaultFontFamily,
    color: UIConstants.linkColor,
    decoration: TextDecoration.underline,
  );

  static const TextStyle headerStyle = TextStyle(
    fontSize: UIConstants.headerFontSize,
    fontFamily: UIConstants.defaultFontFamily,
    fontWeight: FontWeight.bold,
    color: UIConstants.defaultAppColor,
  );

  static const TextStyle userDataTextStyle = TextStyle(
    fontSize: UIConstants.bodyFontSize,
    fontFamily: UIConstants.defaultFontFamily,
    color: UIConstants.textColor,
  );

  static const TextStyle sectionTitleStyle = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: UIConstants.textColor,
  );

  static const TextStyle bodyTextStyle = TextStyle(
    fontSize: 16.0,
    color: UIConstants.textColor,
  );

  // Form Input Decoration
  static InputDecoration get formInputDecoration => InputDecoration(
        labelStyle: formLabelStyle,
        hintStyle: formLabelStyle,
        errorStyle: errorStyle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
          borderSide: const BorderSide(color: UIConstants.greyColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
          borderSide: const BorderSide(color: UIConstants.greyColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
          borderSide: const BorderSide(color: UIConstants.primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
          borderSide: const BorderSide(color: UIConstants.errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
          borderSide: const BorderSide(color: UIConstants.errorColor),
        ),
        filled: true,
        fillColor: UIConstants.whiteColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: UIConstants.spacingM,
          vertical: UIConstants.spacingS,
        ),
      );

  // Card Decoration
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: UIConstants.whiteColor,
        borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            blurRadius: UIConstants.spacingM,
            offset: Offset(0, 2),
          ),
        ],
      );

  // Dialog Styles
  static final ButtonStyle defaultButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: UIConstants.defaultAppColor,
    foregroundColor: UIConstants.whiteColor,
    padding: UIConstants.buttonPadding,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
    ),
  );

  static final ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: UIConstants.cancelButtonBackground,
    foregroundColor: UIConstants.whiteColor,
    padding: UIConstants.buttonPadding,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
    ),
  );

  static final ButtonStyle textButtonStyle = TextButton.styleFrom(
    foregroundColor: UIConstants.linkColor,
    padding: UIConstants.buttonPadding,
  );

  static final ButtonStyle dialogCancelButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.lightGreen,
    foregroundColor: Colors.white,
  );

  static final ButtonStyle dialogAcceptButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: UIConstants.defaultAppColor,
    foregroundColor: Colors.white,
  );

  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: UIConstants.primaryColor,
    foregroundColor: UIConstants.whiteColor,
    padding: const EdgeInsets.symmetric(
      horizontal: UIConstants.spacingM,
      vertical: UIConstants.spacingS,
    ),
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: UIConstants.buttonFontSize,
    fontFamily: UIConstants.defaultFontFamily,
    fontWeight: FontWeight.w500,
    color: UIConstants.whiteColor,
  );

  // List Styles
  static const MainAxisAlignment listItemLeadingAlignment =
      MainAxisAlignment.start;

  // Divider Constants
  static const double dividerHeight = 1.0;
  static const double dividerThickness = 1.0;
  static const Color dividerColor = Colors.grey;
  static const double dividerIndent = 0.0;
  static const double dividerEndIndent = 0.0;

  // Drawer Constants
  static const EdgeInsets drawerPadding =
      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
  static const double drawerAvatarRadius = 32.0;
  static const double drawerAvatarIconSize = 32.0;
  static const TextStyle drawerHeaderStyle =
      TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);

  // Info Message
  static const EdgeInsets infoMessagePadding = EdgeInsets.all(16.0);
  static const EdgeInsets infoMessageMargin =
      EdgeInsets.symmetric(vertical: 8.0);
  static const double infoMessageOpacity = 0.1;
  static const BorderRadius infoMessageBorderRadius =
      BorderRadius.all(Radius.circular(8.0));

  // Error Message
  static const EdgeInsets errorMessagePadding = EdgeInsets.all(16.0);
  static const EdgeInsets errorMessageMargin =
      EdgeInsets.symmetric(vertical: 8.0);
  static const double errorMessageOpacity = 0.1;
  static const BorderRadius errorMessageBorderRadius =
      BorderRadius.all(Radius.circular(8.0));

  // Tooltip
  static const EdgeInsets tooltipPadding =
      EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0);
  static const Color tooltipBackgroundColor = Color(0xFF333333);
  static const BorderRadius tooltipBorderRadius =
      BorderRadius.all(Radius.circular(4.0));
  static const TextStyle tooltipTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 12.0,
  );
  static const Color tooltipTextColor = Colors.white;
  static const double tooltipFontSize = 12.0;

  // SnackBar
  static const TextStyle snackBarTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 14.0,
  );
  static const Color snackBarTextColor = Colors.white;
  static const double snackBarFontSize = 14.0;
  static const Color snackBarBackgroundColor = Color(0xFF333333);
  static const EdgeInsets snackBarPadding =
      EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);
  static const BorderRadius snackBarBorderRadius =
      BorderRadius.all(Radius.circular(4.0));

  // TabBar
  static const double tabBarIndicatorWeight = 2.0;
  static const TextStyle tabBarLabelStyle = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
  );
  static const TextStyle tabBarUnselectedLabelStyle = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
  );

  // ListTile
  static const EdgeInsets listTileContentPadding =
      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
  static const Color listTileBackgroundColor = Colors.white;
  static const Color listTileSelectedBackgroundColor = Color(0xFFF5F5F5);
  static const ShapeBorder listTileShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
  );

  // Success Message
  static const EdgeInsets successMessagePadding = EdgeInsets.all(16.0);
  static const EdgeInsets successMessageMargin =
      EdgeInsets.symmetric(vertical: 8.0);
  static const double successMessageOpacity = 0.1;
  static const BorderRadius successMessageBorderRadius =
      BorderRadius.all(Radius.circular(8.0));

  // Warning Message
  static const EdgeInsets warningMessagePadding = EdgeInsets.all(16.0);
  static const EdgeInsets warningMessageMargin =
      EdgeInsets.symmetric(vertical: 8.0);
  static const double warningMessageOpacity = 0.1;
  static const BorderRadius warningMessageBorderRadius =
      BorderRadius.all(Radius.circular(8.0));

  static const IconData dialogCancelIcon = Icons.close;
  static const IconData dialogAcceptIcon = Icons.check;
}
