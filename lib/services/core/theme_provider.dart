import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/ui_constants.dart';
import '../../constants/ui_styles.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider() {
    _loadThemePreference();
  }
  static const String _highContrastKey = 'highContrastMode';
  bool _isHighContrast = false;

  bool get isHighContrast => _isHighContrast;

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isHighContrast = prefs.getBool(_highContrastKey) ?? false;
    notifyListeners();
  }

  Future<void> _saveThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_highContrastKey, _isHighContrast);
  }

  void toggleHighContrast() {
    _isHighContrast = !_isHighContrast;
    _saveThemePreference();
    notifyListeners();
  }

  ThemeData getTheme(bool isDark) {
    final colorScheme = ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: UIConstants.primaryColor,
      onPrimary: UIConstants.whiteColor,
      secondary: UIConstants.foregroundColor,
      onSecondary: UIConstants.whiteColor,
      surface: isDark ? UIConstants.greyColor : UIConstants.whiteColor,
      onSurface: isDark ? UIConstants.whiteColor : UIConstants.textColor,
      error: UIConstants.errorColor,
      onError: UIConstants.whiteColor,
    );

    final baseTheme = ThemeData(
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

    if (_isHighContrast) {
      return baseTheme.copyWith(
        colorScheme: colorScheme.copyWith(
          primary: UIConstants.foregroundColor,
          onPrimary: UIConstants.textColor,
          secondary: UIConstants.foregroundColor,
          onSecondary: UIConstants.textColor,
          surface: UIConstants.textColor,
          onSurface: UIConstants.foregroundColor,
        ),
        textTheme: baseTheme.textTheme.apply(
          bodyColor: UIConstants.foregroundColor,
          displayColor: UIConstants.foregroundColor,
        ),
      );
    }

    return baseTheme;
  }
}
