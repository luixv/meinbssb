import 'package:flutter/material.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider() {
    loadThemePreference();
  }

  Future<void> loadThemePreference() async {
    notifyListeners();
  }

  ThemeData getTheme(bool isDark) {
    final colorScheme = ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: UIConstants.primaryColor,
      onPrimary: UIConstants.whiteColor,
      secondary: UIConstants.foregroundColor,
      onSecondary: UIConstants.whiteColor,
      surface: isDark ? UIConstants.mydarkGreyColor : UIConstants.whiteColor,
      onSurface: isDark ? UIConstants.whiteColor : UIConstants.textColor,
      error: UIConstants.errorColor,
      onError: UIConstants.whiteColor,
    );

    return ThemeData(
      fontFamily: UIConstants.defaultFontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      cardColor: colorScheme.surface,
      textTheme: const TextTheme(
        displayLarge: UIStyles.headerStyle,
        titleLarge: UIStyles.titleStyle,
        titleMedium: UIStyles.subtitleStyle,
        bodyLarge: UIStyles.bodyStyle,
        bodyMedium: UIStyles.bodyTextStyle,
        labelLarge: UIStyles.buttonStyle,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        selectionColor: UIConstants.selectionColor,
        selectionHandleColor: UIConstants.selectionHandleColor,
        cursorColor: UIConstants.cursorColor,
      ),
      highlightColor: UIConstants.highlightColor,
      splashColor: UIConstants.splashColor,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: UIStyles.defaultButtonStyle,
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: UIStyles.formLabelStyle,
        hintStyle: UIStyles.formLabelStyle,
        errorStyle: UIStyles.errorStyle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
          borderSide: const BorderSide(color: UIConstants.mydarkGreyColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
          borderSide: const BorderSide(color: UIConstants.mydarkGreyColor),
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
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        titleTextStyle: UIStyles.appBarTitleStyle,
      ),
      dialogTheme: DialogTheme(
        titleTextStyle: UIStyles.dialogTitleStyle,
        contentTextStyle: UIStyles.dialogContentStyle,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
        ),
      ),
    );
  }
}
