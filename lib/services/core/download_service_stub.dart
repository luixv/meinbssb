import 'dart:typed_data';

/// Stub implementation for non-web platforms
Future<void> downloadFile(Uint8List bytes, String fileName) async {
  throw UnsupportedError('Web download is only supported on web platform');
}
