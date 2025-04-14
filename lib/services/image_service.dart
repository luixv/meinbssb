import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;
import '/services/logger_service.dart';

// Conditional imports with explicit prefixes
import 'package:path_provider/path_provider.dart' as path_provider;
import 'dart:io' as io;

class ImageService {
  /// Cache a Schuetzenausweis entry
  Future<void> cacheSchuetzenausweis(
    int personId,
    Uint8List imageData,
    int timestamp,
  ) async {
    if (kIsWeb) {
      await _cacheImageWeb(personId, imageData, timestamp);
    } else {
      await _cacheImageMobileDesktop(personId, imageData, timestamp);
    }
  }

  Future<Uint8List> rotatedImage(Uint8List imageData) async {
    try {
      // Decode the image from Uint8List
      final image = img.decodeImage(imageData);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      final rotatedImage = img.copyRotate(image, angle: 270);
      final rotatedImageData = img.encodeJpg(rotatedImage);

      return Uint8List.fromList(rotatedImageData);
    } catch (e) {
      LoggerService.logError('Error rotating image: $e');
      throw Exception('Failed to rotate image');
    }
  }

  /// Retrieve a cached Schuetzenausweis
  Future<Uint8List?> getCachedSchuetzenausweis(
    int personId,
    Duration validity,
  ) async {
    if (kIsWeb) {
      return await _getCachedImageWeb(personId, validity);
    } else {
      return await _getCachedImageMobileDesktop(personId, validity);
    }
  }

  //=== Web Implementation ===//
  Future<void> _cacheImageWeb(
    int personId,
    Uint8List imageData,
    int timestamp,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('image_$personId.jpg', base64Encode(imageData));
      await prefs.setInt('image_${personId}_timestamp', timestamp);
    } catch (e) {
      LoggerService.logError('Failed to cache image on web: $e');
    }
  }

  Future<Uint8List?> _getCachedImageWeb(int personId, Duration validity) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt('image_${personId}_timestamp');

      if (timestamp == null) return null;

      if (DateTime.now().difference(
            DateTime.fromMillisecondsSinceEpoch(timestamp),
          ) >
          validity) {
        return null;
      }

      final base64Image = prefs.getString('image_$personId.jpg');
      return base64Image != null ? base64Decode(base64Image) : null;
    } catch (e) {
      LoggerService.logError('Failed to retrieve image on web: $e');
      return null;
    }
  }

  //=== Mobile/Desktop Implementation ===//
  Future<void> _cacheImageMobileDesktop(
    int personId,
    Uint8List imageData,
    int timestamp,
  ) async {
    try {
      final directory = await path_provider.getApplicationDocumentsDirectory();
      final file = io.File('${directory.path}/image_$personId.jpg');
      await file.writeAsBytes(imageData);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('image_${personId}_timestamp', timestamp);
    } catch (e) {
      LoggerService.logError('Failed to cache image on mobile/desktop: $e');
    }
  }

  Future<Uint8List?> _getCachedImageMobileDesktop(
    int personId,
    Duration validity,
  ) async {
    try {
      final directory = await path_provider.getApplicationDocumentsDirectory();
      final file = io.File('${directory.path}/image_$personId.jpg');

      if (await file.exists()) {
        final stat = await file.stat();
        if (DateTime.now().difference(stat.modified) <= validity) {
          return await file.readAsBytes();
        }
      }
      return null;
    } catch (e) {
      LoggerService.logError('Failed to retrieve image on mobile/desktop: $e');
      return null;
    }
  }
}
