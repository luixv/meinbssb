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
  static const Color linkColor = primaryColor;
  static const Color greyColor = Colors.grey;
  static const Color whiteColor = Colors.white;
  static const Color greySubtitleTextColor = Colors.grey;
  static const Color labelTextColor = Colors.grey;

  static const Color news = Colors.lightGreen;
  static const Color defaultAppColor = primaryColor;
  static const Color cookiesDialogColor = Colors.transparent;

  // Button Colors
  static const Color cancelButtonBackground = Colors.lightGreen;
  static const Color acceptButtonBackground = primaryColor;
  static const Color deleteButtonBackground = primaryColor;
  static const Color submitButtonBackground = Colors.lightGreen;
  static const Color disabledBackgroundColor = Colors.grey;

  static const Color buttonTextColor = Colors.white;
  static const Color cancelButtonText = Colors.white;
  static const Color deleteButtonText = Colors.white;
  static const Color submitButtonText = Colors.white;
  static const Color disabledSubmitButtonText = Colors.white;

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

  // Spacing constants
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  static const double helpSpacing = 16.0;
  static const double listItemInterSpace = 3.0;

  // Common Widgets - Using getters instead of const
  static SizedBox get horizontalSpacingXS => const SizedBox(width: spacingXS);
  static SizedBox get horizontalSpacingS => const SizedBox(width: spacingS);
  static SizedBox get horizontalSpacingM => const SizedBox(width: spacingM);
  static SizedBox get horizontalSpacingL => const SizedBox(width: spacingL);
  static SizedBox get horizontalSpacingXL => const SizedBox(width: spacingXL);

  static SizedBox get verticalSpacingXS => const SizedBox(height: spacingXS);
  static SizedBox get verticalSpacingS => const SizedBox(height: spacingS);
  static SizedBox get verticalSpacingM => const SizedBox(height: spacingM);
  static SizedBox get verticalSpacingL => const SizedBox(height: spacingL);
  static SizedBox get verticalSpacingXL => const SizedBox(height: spacingXL);

  // Padding
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
  static const EdgeInsets defaultHorizontalPadding =
      EdgeInsets.symmetric(horizontal: 16.0);
  static const EdgeInsets defaultVerticalPadding =
      EdgeInsets.symmetric(vertical: 16.0);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(vertical: 16.0);
  static const EdgeInsets screenPadding =
      EdgeInsets.fromLTRB(16.0, 60.0, 16.0, 16.0);
  static const EdgeInsets appBarRightPadding = EdgeInsets.only(right: 16.0);
  static const EdgeInsets dialogPadding = EdgeInsets.all(16.0);

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

  // Strings
  static const String loginButtonLabel = 'Anmelden';
  static const String forgotPasswordLabel = 'Passwort vergessen?';
  static const String bankDataTitle = 'Bankdaten';
  static const String bankDataSubtitle = 'Bitte geben Sie Ihre Bankdaten ein';
  static const String homeTitle = 'Home';
  static const String welcomeMessage = 'Willkommen';
  static const String checkPassNumberButtonLabel = 'Passnummer prüfen';
  static const String passwordResetTitle = 'Passwort zurücksetzen';
  static const String passwordResetSuccessTitle =
      'Passwort erfolgreich zurückgesetzt';
  static const String passwordResetSuccessMessage =
      'Sie können sich jetzt mit Ihrem neuen Passwort anmelden.';
  static const String backToLoginButtonLabel = 'Zurück zum Login';
  static const String passNumberLabel = 'Schützenausweisnummer';
  static const String resetPasswordButtonLabel = 'Passwort zurücksetzen';
  static const String logoutLabel = 'Abmelden';
  static const String registerButtonLabel = 'Registrieren';
  static const String cancelButtonLabel = 'Abbrechen';

  // Alignment
  static const MainAxisAlignment spaceBetweenAlignment =
      MainAxisAlignment.spaceBetween;
  static const MainAxisAlignment centerAlignment = MainAxisAlignment.center;
  static const CrossAxisAlignment startCrossAlignment =
      CrossAxisAlignment.start;

  // Loading Indicator
  static const Widget defaultLoadingIndicator = CircularProgressIndicator(
    valueColor: AlwaysStoppedAnimation<Color>(circularProgressIndicator),
  );

  // Help screen
  static const String helpTitle = 'FAQ';

  // Cookie Consent
  static const String cookieConsentTitle = 'Wir verwenden Cookies';
  static const String cookieConsentMessage =
      'Um diese App offline nutzen zu können, verwenden wir Cookies.';
  static const String cookieSettingsButtonLabel = 'Einstellungen';
  static const String cookieAcceptAllButtonLabel = 'Alle akzeptieren';

  // Layout
  static const double newsContainerHeight = 100.0;
  static const MainAxisAlignment listItemLeadingAlignment =
      MainAxisAlignment.start;
}
