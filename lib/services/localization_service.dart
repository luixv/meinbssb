import 'dart:convert';
import 'package:flutter/services.dart';

class LocalizationService {
  static Map<String, String> _localizedStrings = {}; 

  static Future<void> load(String filePath) async {
    String jsonString = await rootBundle.loadString(filePath);
    _localizedStrings = json.decode(jsonString).cast<String, String>();
  }

  static String getString(String key) {
    return _localizedStrings[key] ?? ''; 
  }
}