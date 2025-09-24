import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/constants/ui_constants.dart';

class FontSizeProvider extends ChangeNotifier {
  FontSizeProvider() {
    _loadSavedScale();
  }

  static const String _fontSizeKey = 'font_size_scale';
  double _scaleFactor = UIConstants.defaultFontScale;

  double get scaleFactor => _scaleFactor;

  Future<void> _loadSavedScale() async {
    final prefs = await SharedPreferences.getInstance();
    _scaleFactor =
        prefs.getDouble(_fontSizeKey) ?? UIConstants.defaultFontScale;
    notifyListeners();
  }

  Future<void> _saveScale() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, _scaleFactor);
  }

  void increaseFontSize() {
    if (_scaleFactor < UIConstants.maxFontScale) {
      _scaleFactor += UIConstants.fontScaleStep;
      _saveScale();
      notifyListeners();
    }
  }

  void decreaseFontSize() {
    if (_scaleFactor > UIConstants.minFontScale) {
      _scaleFactor -= UIConstants.fontScaleStep;
      _saveScale();
      notifyListeners();
    }
  }

  void resetFontSize() {
    _scaleFactor = UIConstants.defaultFontScale;
    _saveScale();
    notifyListeners();
  }

  void setScaleFactor(double value) {
    _scaleFactor = value;
    _saveScale();
    notifyListeners();
  }

  double getScaledFontSize(double baseSize) {
    return baseSize * _scaleFactor;
  }

  String getScalePercentage() {
    return '${(_scaleFactor * 100).toInt()}%';
  }
}
