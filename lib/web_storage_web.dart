// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as web;

class WebStorage {
  static String? getItem(String key) => web.window.sessionStorage[key];
  static void setItem(String key, String value) =>
      web.window.sessionStorage[key] = value;
  static void removeItem(String key) => web.window.sessionStorage.remove(key);
}
