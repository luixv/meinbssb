import 'package:flutter/material.dart';

class UIConstants {
  // Colors
  static const Color primaryColor = Color.fromARGB(
    255,
    11,
    75,
    16,
  ); // Main green color 0xFF006400
  static const Color backgroundColor = Color(0xFFe2f0d9);
  static const Color foregroundColor = Colors.lightGreen;
  static const Color textColor = Colors.black;
  static const Color errorColor = Colors.red;
  static const Color successColor = Colors.green;
  static const Color warningColor = Color(0xFFFFA000);
  static const Color linkColor = primaryColor;
  static const Color mydarkGreyColor = Color.fromARGB(255, 46, 46, 46);
  static const Color whiteColor = Colors.white;
  static const Color blackColor = Colors.black;
  static const Color greySubtitleTextColor = mydarkGreyColor;
  static const Color labelTextColor = Colors.grey;

  static const Color news = Colors.lightGreen;
  static const Color defaultAppColor = primaryColor;
  static const Color cookiesDialogColor = Colors.transparent;

  // Button Colors
  static const Color cancelButtonBackground = Colors.lightGreen;
  static const Color acceptButtonBackground = primaryColor;
  static const Color deleteButtonBackground = primaryColor;
  static const Color submitButtonBackground = primaryColor;
  static const Color disabledBackgroundColor = Colors.lightGreen;
  static const Color fontSizeButtonBackground = defaultAppColor;

  static const Color buttonTextColor = Colors.white;
  static const Color cancelButtonText = Colors.white;
  static const Color deleteButtonText = Colors.white;
  static const Color submitButtonText = Colors.white;
  static const Color disabledSubmitButtonText = Colors.white;
  static const Color fontSizeButtonTextColor = Colors.white;

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
  static const Color circularProgressIndicator = defaultAppColor;

  static const Color wifiConnectedColor = Colors.green;

  // Card Colors
  static const Color cardColor = Colors.white;
  static const Color boxDecorationColor = Colors.white;
  static const Color cursorColor = Colors.black;

  // Selection Colors
  static const Color selectionColor = Colors.transparent;
  static const Color selectionHandleColor = Colors.transparent;
  static const Color highlightColor = Colors.transparent;
  static const Color splashColor = Colors.transparent;
  static const Color overlayColor = Color.fromRGBO(
    0,
    0,
    0,
    0.3,
  ); // Semi-transparent black overlay

  //Colors for Schulungen
  static const Color sportColor = Color.fromRGBO(0, 93, 218, 1); //#005dda
  static const Color jugendColor = Color.fromRGBO(153, 30, 124, 1); // #991e7c

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
  static const String defaultFontFamily = 'Roboto'; // OpenSans

  // Font Sizes
  static const double headerFontSize = 24.0;
  static const double bodyFontSize = 14.0;
  static const double fieldValueFontSize = 16.0;

  static const double titleFontSize = 20.0;
  static const double drawerHeaderFontSize = 18.0;
  static const double subtitleFontSize = 16.0;
  static const double buttonFontSize = 16.0;
  static const double defaultFontSize = 16.0;
  static const double tooltipFontSize = 12.0;
  static const double snackBarTextFontSize = 12.0;

  static const double tabBarUnselectedFontSize = 14.0;

  // Spacing constants
  static const double spacingXXS = 1.0;
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingSM = 12.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  static const double spacingXXXL = 64.0;
  static const double helpSpacing = 32.0;
  static const double listItemInterSpace = 3.0;

  static const double loadingIndicatorSize = 20;

  /// Minimal horizontal spacing between columns in info tables/dialogs
  static const double infoTableColumnSpacing = 1.0;

  /// Horizontal padding for info tables/dialogs
  static const double infoTableHorizontalPadding = 20.0;

  /// Bottom padding for info tables/dialogs
  static const double infoTableBottomPadding = 16.0;

  static const double infoTableColumnSpacingWide = infoTableColumnSpacing * 20;
  static const double infoTableBottomPaddingSmall = infoTableBottomPadding / 2;

  // Common Widgets - Using getters instead of const
  static SizedBox get horizontalSpacingXS => const SizedBox(width: spacingXS);
  static SizedBox get horizontalSpacingS => const SizedBox(width: spacingS);
  static SizedBox get horizontalSpacingM => const SizedBox(width: spacingM);
  // static SizedBox get horizontalSpacingL => const SizedBox(width: spacingL);
  // static SizedBox get horizontalSpacingXL => const SizedBox(width: spacingXL);

  static SizedBox get verticalSpacingXS => const SizedBox(height: spacingXS);
  static SizedBox get verticalSpacingS => const SizedBox(height: spacingS);
  static SizedBox get verticalSpacingM => const SizedBox(height: spacingM);
  // static SizedBox get verticalSpacingL => const SizedBox(height: spacingL);
  // static SizedBox get verticalSpacingXL => const SizedBox(height: spacingXL);

  // Padding
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
  static const EdgeInsets defaultHorizontalPadding = EdgeInsets.symmetric(
    horizontal: 16.0,
  );
  static const EdgeInsets defaultVerticalPadding = EdgeInsets.symmetric(
    vertical: 16.0,
  );
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(vertical: 16.0);
  static const EdgeInsets screenPadding = EdgeInsets.fromLTRB(
    16.0,
    60.0,
    16.0,
    16.0,
  );
  static const EdgeInsets appBarRightPadding = EdgeInsets.only(right: 16.0);
  static const EdgeInsets dialogPadding = EdgeInsets.all(16.0);

  // Sizes
  static const double drawerWidth = 309.0;
  static const double logoSize = 100.0;
  static const double cornerRadius = 8.0;
  static const double cornerRadiusFAB = 12.0;
  static const double fabHeight = 16.0;
  static const double fabSize = 56.0; // Standard FAB size (height and width)
  static const double fabIconSize = 24.0; // Standard FAB icon size
  static const double fabLargeIconSize = 32;
  static const double fabLargeTextSize = 18;
  static const double defaultStrokeWidth = 2.0;
  static const double defaultIconSize = 16.0;
  static const double defaultIconWidth = 60.0;
  static const double defaultButtonWidth = 120.0;
  static const double defaultButtonHeight = 36.0;
  static const double defaultImageHeight = 100.0;
  static const double defaultSeparatorHeight = 10.0;

  static const double tooltipIconSize = 24.0;

  static const double iconSizeXL = 64.0;
  static const double iconSizeL = 48.0;
  static const double iconSizeM = 32.0;

  static const double iconSizeS = 24.0;
  static const double iconSizeXS = 20.0;

  static const double dialogFontSize = 18.0;
  static const double largeFontSize = 24.0;

  static const double smallButtonSize = 40.0;
  static const double fabSmallIconSize = 20.0;
  static const double dividerThick = 6.0;
  static const Duration snackbarDuration = Duration(seconds: 3);

  // AppBar
  static const double appBarElevation = 2.0;

  // Text and Layout
  static const int maxSectionHeaderLength = 90;

  // Search and Filter
  static const int maxFilteredDisziplinen = 5;
  static const double maxContentWidth = 600;

  // Alignment
  static const MainAxisAlignment spaceBetweenAlignment =
      MainAxisAlignment.spaceBetween;
  static const MainAxisAlignment centerAlignment = MainAxisAlignment.center;
  static const CrossAxisAlignment startCrossAlignment =
      CrossAxisAlignment.start;

  // Loading Indicator
  static const Widget defaultLoadingIndicator = CircularProgressIndicator(
    valueColor: AlwaysStoppedAnimation<Color>(defaultAppColor),
  );

  // Layout
  static const double newsContainerHeight = 100.0;
  static const MainAxisAlignment listItemLeadingAlignment =
      MainAxisAlignment.start;

  static const double minFontScale = 0.8;
  static const double maxFontScale = 2.0;
  static const double fontScaleStep = 0.1;
  static const double defaultFontScale = 1.0;

  // Navigation Icons
  static const IconData menuIcon = Icons.menu;
  static const IconData homeIcon = Icons.home;
  static const IconData backIcon = Icons.arrow_back;

  // Action Icons
  static const IconData addIconData = Icons.add;
  static const IconData editIcon = Icons.edit;
  static const IconData saveIcon = Icons.save;
  static const IconData deleteIconData = Icons.delete_forever;
  static const IconData checkIconData = Icons.check;
  static const IconData calendarIcon = Icons.calendar_today;

  // Status Icons
  static const IconData successIcon = Icons.check_circle;
  static const IconData errorIcon = Icons.error;

  // Connectivity Icons
  static const IconData wifiIcon = Icons.wifi;
  static const IconData wifiOffIcon = Icons.wifi_off;
  static const IconData signalIcon = Icons.signal_cellular_4_bar;
  static const IconData bluetoothIcon = Icons.bluetooth_connected;
  static const IconData networkCheckIcon = Icons.network_check;

  // Menu Icons
  static const IconData schoolIcon = Icons.school;
  static const IconData taskIcon = Icons.task_alt;
  static const IconData cameraIcon = Icons.photo_camera;
  static const IconData personIcon = Icons.person;
  static const IconData contactIcon = Icons.contact_phone;
  static const IconData bankIcon = Icons.account_balance;
  static const IconData logoutIcon = Icons.logout;
  static const IconData loginIcon = Icons.login;
  static const IconData registrationIcon = Icons.app_registration;
  static const IconData helpIcon = Icons.help_outline;
  static const IconData lockResetIcon = Icons.lock_reset;

  // UI Icons
  static const IconData circleIcon = Icons.circle;

  static const List<String> contactTypes = [
    'Telefon',
    'Mobil',
    'E-Mail',
    'Fax',
  ];

  // Dialog
  static const double dialogWidth = 500.0;
  static const double dialogHeight = 600.0;
  static const double dialogHeaderHeight = 64.0;

  /// Standard margin for FABs in most dialogs
  static const double dialogFabRight = 16.0;
  static const double dialogFabBottom = 48.0;

  static const double profilePictureSize = 90.0; // Size for the profile picture

  /// Tight margin for FABs in special dialogs (e.g., Personen anmelden)
  static const double dialogFabTightRight = 16.0;
  static const double dialogFabTightBottom = 16.0;
  static const double dialogFabDeleteOffset = 56.0;

  /// Compact dialog height for small forms
  static const double dialogHeightCompact = 140.0;

  /// Tall dialog height for overlapping FABs (e.g., Personen anmelden)
  static const double dialogHeightTall = 400.0;

  /// Tall dialog height minus one FAB (for more compact dialogs)
  static const double dialogHeightTallShorter = dialogHeightTall - 56.0;

  /// Offset for overlapping FABs in dialogs
  static const double dialogFabOverlapOffset = 24.0;

  /// Offset for overlapping FABs in dialogs, 10px more to the right
  static const double dialogFabOverlapOffsetRight =
      dialogFabOverlapOffset + 10.0;

  /// Offset for overlapping FABs in dialogs, one FAB more to the right
  static const double dialogFabOverlapOffsetRightMore =
      dialogFabOverlapOffset + 56.0;

  /// Offset for overlapping FABs in dialogs, one FAB more to the bottom
  static const double dialogFabOverlapOffsetBottomMore =
      dialogFabOverlapOffset + 56.0;

  /// Offset for overlapping FABs in dialogs, two FABs more to the right
  static const double dialogFabOverlapOffsetRightDouble =
      dialogFabOverlapOffset + 2 * 56.0;

  /// Offset for overlapping FABs in dialogs, two FABs more to the bottom
  static const double dialogFabOverlapOffsetBottomDouble =
      dialogFabOverlapOffset + 2 * 56.0;

  /// Extra offset for vertically stacked dialog FABs (e.g., for 'Personen anmelden' dialog)
  static const double dialogFabVerticalOffset = 112.0;

  /// Extra offset for horizontally stacked dialog FABs (e.g., for 'Personen anmelden' dialog)
  static const double dialogFabHorizontalOffset = 64.0;

  /// Offset for overlapping FABs in dialogs, three FABs more to the right
  static const double dialogFabOverlapOffsetRightTriple =
      dialogFabOverlapOffset + 3 * 56.0;

  /// Offset for overlapping FABs in dialogs, three FABs more to the bottom
  static const double dialogFabOverlapOffsetBottomTriple =
      dialogFabOverlapOffset + 3 * 56.0;

  // Dialog sizing and spacing
  static const double dialogMaxWidth = 420.0;
  static const double dialogMaxWidthWide = 640.0;
  static const double dialogMaxHeight = 520.0;
  static const double dialogMinWidth = 400.0;
  static const double dialogNarrowWidth = 340.0;
  static const double dialogColumnGap = 8.0;

  // Schulungen (Course Registration) Colors
  static const Color schulungenGesperrtColor =
      Colors.white; // For gesperrt/locked state
  static const Color schulungenNormalColor =
      defaultAppColor; // For normal state

  static const double wifiOffIconSize = 64.0;

  // Drawer header and menu font sizes
  static const double drawerHeaderHeight = 120.0;
  static const double drawerHeaderTopPadding = 40.0;
  static const double drawerHeaderBottomPadding = 8.0;
  static const double drawerHeaderLeftPadding = 16.0;
  static const double menuTitleFontSize = 24.0;
  static const double menuItemFontSize = 18.0;
  static const double stylesPreviewWidth = 200.0;

  static const double borderWidth = 1.0;
  static const double headerFontScale = 1.3;
}
