import 'package:web/web.dart' as web;

class WebStorage {
  static String? getItem(String key) => web.window.sessionStorage.getItem(key);
  static void setItem(String key, String value) =>
      web.window.sessionStorage.setItem(key, value);
  static void removeItem(String key) =>
      web.window.sessionStorage.removeItem(key);
}
