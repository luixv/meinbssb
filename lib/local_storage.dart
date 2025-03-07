import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  // Save a string value for a specific user
  static Future<void> saveString(String key, String value, int personId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${key}_$personId', value);
  }

  // Retrieve a string value for a specific user
  static Future<String?> getString(String key, int personId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('${key}_$personId');
  }

  // Save the last authenticated user's PERSONID
  static Future<void> saveLastUserId(int personId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastUserId', personId);
  }

  // Retrieve the last authenticated user's PERSONID
  static Future<int?> getLastUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('lastUserId');
  }

  // Clear all data (optional, not used for logout)
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}