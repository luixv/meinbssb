import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/providers/theme_provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';

class TestThemeProvider extends ThemeProvider {
  int notifyCount = 0;
  @override
  void notifyListeners() {
    notifyCount++;
    super.notifyListeners();
  }
}

void main() {
  group('ThemeProvider', () {
    test('constructs without error', () {
      expect(() => ThemeProvider(), returnsNormally);
    });

    test('getTheme returns correct ThemeData for light mode', () {
      final provider = ThemeProvider();
      final theme = provider.getTheme(false);
      final style = theme.textTheme.titleLarge!;
      const ref = UIStyles.titleStyle;
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, UIConstants.primaryColor);
      expect(style.fontFamily, ref.fontFamily);
      expect(style.fontSize, ref.fontSize);
      expect(style.fontWeight, ref.fontWeight);
      expect(style.color, ref.color);
    });

    test('getTheme returns correct ThemeData for dark mode', () {
      final provider = ThemeProvider();
      final theme = provider.getTheme(true);
      final style = theme.textTheme.titleLarge!;
      const ref = UIStyles.titleStyle;
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, UIConstants.primaryColor);
      expect(style.fontFamily, ref.fontFamily);
      expect(style.fontSize, ref.fontSize);
      expect(style.fontWeight, ref.fontWeight);
      expect(style.color, ref.color);
    });

    test('loadThemePreference calls notifyListeners', () async {
      final provider = TestThemeProvider();
      await provider.loadThemePreference();
      expect(provider.notifyCount, greaterThan(0));
    });
  });
}
