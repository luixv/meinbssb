import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cunning_document_scanner/cunning_document_scanner.dart';

/// Service class for handling document scanning functionality
/// Provides a reusable interface for scanning documents across the application
class DocumentScannerService {
  /// Scans a document using the device camera
  /// Returns the scanned image bytes and filename if successful
  /// Returns null if scanning was cancelled or failed
  /// Throws an exception if the platform doesn't support scanning
  Future<ScanResult?> scanDocument() async {
    // Check if platform supports document scanning
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      throw UnsupportedPlatformException(
        'Dokument-Scanning ist nur auf Android und iOS verfügbar. '
        'Bitte verwenden Sie die Upload-Funktion.',
      );
    }

    try {
      List<String> pictures = await CunningDocumentScanner.getPictures() ?? [];

      if (pictures.isEmpty) {
        // User cancelled scanning
        return null;
      }

      // Process the first scanned image
      final String imagePath = pictures[0];
      final File imageFile = File(imagePath);
      final bytes = await imageFile.readAsBytes();
      final fileName = imagePath.split('/').last;

      if (bytes.isEmpty) {
        throw ScanException('Fehler: Datei konnte nicht gelesen werden');
      }

      return ScanResult(bytes: bytes, fileName: fileName);
    } catch (e) {
      if (e is ScanException || e is UnsupportedPlatformException) {
        rethrow;
      }
      throw ScanException('Fehler beim Scannen: $e');
    }
  }
}

/// Result of a successful document scan
class ScanResult {
  ScanResult({required this.bytes, required this.fileName});

  final List<int> bytes;
  final String fileName;
}

/// Exception thrown when document scanning fails
class ScanException implements Exception {
  ScanException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Exception thrown when the platform doesn't support document scanning
class UnsupportedPlatformException implements Exception {
  UnsupportedPlatformException(this.message);
  final String message;

  @override
  String toString() => message;
}
