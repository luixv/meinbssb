// Filename: image_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
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
      await _cacheImageWeb(
        'schuetzenausweis_$personId.jpg',
        imageData,
        timestamp,
      );
    } else {
      await _cacheImageMobileDesktop(
        'schuetzenausweis_$personId.jpg',
        imageData,
        timestamp,
      );
    }
  }

  /// Retrieve a cached Schuetzenausweis
  Future<Uint8List?> getCachedSchuetzenausweis(
    int personId,
    Duration validity,
  ) async {
    if (kIsWeb) {
      return await _getCachedImageWeb(
        'schuetzenausweis_$personId.jpg',
        validity,
        timestampKey: 'schuetzenausweis_${personId}_timestamp',
      );
    } else {
      return await _getCachedImageMobileDesktop(
        'schuetzenausweis_$personId.jpg',
        validity,
      );
    }
  }

  Future<bool> isDeviceOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.isEmpty) {
      return false;
    }
    return connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.mobile);
  }

  Future<Uint8List> fetchAndCacheSchuetzenausweis(
    int personId,
    Future<Uint8List> Function() fetchFunction, // Accepts a function
    Duration validityDuration,
  ) async {
    final cachedImage =
        await getCachedSchuetzenausweis(personId, validityDuration);
    if (cachedImage != null) return cachedImage;

    try {
      final fetchedImage =
          await fetchFunction(); // Execute the network call here
      await cacheSchuetzenausweis(
        personId,
        fetchedImage,
        DateTime.now().millisecondsSinceEpoch,
      );
      return fetchedImage;
    } catch (e) {
      // Fallback to expired cache if available
      final fallback = await getCachedSchuetzenausweis(
        personId,
        const Duration(days: 365 * 100),
      );
      if (fallback != null) return fallback;
      throw Exception('Failed to fetch and no cache available');
    }
  }

//=== Web Implementation ===//
  Future<void> _cacheImageWeb(
    String filename,
    Uint8List imageData,
    int timestamp,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(filename, base64Encode(imageData));
      await prefs.setInt('${filename.split('.').first}_timestamp', timestamp);
    } catch (e) {
      LoggerService.logError('Failed to cache image on web ($filename): $e');
    }
  }

  Future<Uint8List?> _getCachedImageWeb(
    String filename,
    Duration validity, {
    required String timestampKey,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(timestampKey);

      if (timestamp == null) return null;

      if (DateTime.now().difference(
            DateTime.fromMillisecondsSinceEpoch(timestamp),
          ) >
          validity) {
        return null;
      }

      final base64Image = prefs.getString(filename);
      return base64Image != null ? base64Decode(base64Image) : null;
    } catch (e) {
      LoggerService.logError('Failed to retrieve image on web ($filename): $e');
      return null;
    }
  }

  //=== Mobile/Desktop Implementation ===//
  Future<void> _cacheImageMobileDesktop(
    String filename,
    Uint8List imageData,
    int timestamp,
  ) async {
    try {
      final directory = await path_provider.getApplicationDocumentsDirectory();
      final file = io.File('${directory.path}/$filename');
      await file.writeAsBytes(imageData);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('${filename.split('.').first}_timestamp', timestamp);
    } catch (e) {
      LoggerService.logError(
        'Failed to cache image on mobile/desktop ($filename): $e',
      );
    }
  }

  Future<Uint8List?> _getCachedImageMobileDesktop(
    String filename,
    Duration validity,
  ) async {
    try {
      final directory = await path_provider.getApplicationDocumentsDirectory();
      final file = io.File('${directory.path}/$filename');

      if (await file.exists()) {
        final stat = await file.stat();
        if (DateTime.now().difference(stat.modified) <= validity) {
          return await file.readAsBytes();
        }
      }
      return null;
    } catch (e) {
      LoggerService.logError(
        'Failed to retrieve image on mobile/desktop ($filename): $e',
      );
      return null;
    }
  }
}
