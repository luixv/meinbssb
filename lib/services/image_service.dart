import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:shared_preferences/shared_preferences.dart';

// Conditional imports with explicit prefixes
import 'package:path_provider/path_provider.dart' as mobile;
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
      debugPrint('Failed to cache image on web: $e');
    }
  }

  Future<Uint8List?> _getCachedImageWeb(
    int personId,
    Duration validity,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt('image_${personId}_timestamp');
      
      if (timestamp == null) return null;

      if (DateTime.now().difference(
        DateTime.fromMillisecondsSinceEpoch(timestamp),
      ) > validity) {
        return null;
      }

      final base64Image = prefs.getString('image_$personId.jpg');
      if (base64Image != null) {
        return base64Decode(base64Image);
      }
    } catch (e) {
      debugPrint('Failed to retrieve image on web: $e');
    }
    return null;
  }

  //=== Mobile/Desktop Implementation ===//
  Future<void> _cacheImageMobileDesktop(
    int personId,
    Uint8List imageData,
    int timestamp,
  ) async {
    try {
      final directory = await mobile.getApplicationDocumentsDirectory();
      final file = io.File('${directory.path}/image_$personId.jpg');
      await file.writeAsBytes(imageData);
      
      // Store timestamp in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('image_${personId}_timestamp', timestamp);
    } catch (e) {
      debugPrint('Failed to cache image on mobile/desktop: $e');
    }
  }

  Future<Uint8List?> _getCachedImageMobileDesktop(
    int personId,
    Duration validity,
  ) async {
    try {
      final directory = await mobile.getApplicationDocumentsDirectory();
      final file = io.File('${directory.path}/image_$personId.jpg');
      
      if (await file.exists()) {
        final stat = await file.stat();
        if (DateTime.now().difference(stat.modified) <= validity) {
          return await file.readAsBytes();
        }
      }
    } catch (e) {
      debugPrint('Failed to retrieve image on mobile/desktop: $e');
    }
    return null;
  }
}