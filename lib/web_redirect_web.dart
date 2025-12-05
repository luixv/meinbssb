import 'package:web/web.dart' as web;

class WebRedirect {
  static void redirectTo(String url) {
    web.window.location.href = url;
  }
}