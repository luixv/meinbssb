// Stub implementation for non-web platforms
class Window {
  final SessionStorage sessionStorage = SessionStorage();
}

class SessionStorage {
  String? operator [](String key) => null;
  void operator []=(String key, String value) {}
  void removeItem(String key) {}
}

final Window window = Window();
