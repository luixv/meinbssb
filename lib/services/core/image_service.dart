// Filename: image_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'logger_service.dart';
import '/services/core/http_client.dart';

import 'package:path_provider/path_provider.dart' as path_provider;
import 'dart:io' as io;

class ImageService {
  ImageService({
    required HttpClient httpClient,
    this.getCachedSchuetzenausweisFn,
    this.cacheSchuetzenausweisFn,
    this.connectivity,
  }) : _httpClient = httpClient;

  final HttpClient _httpClient;

  // Dependency injection for testability
  final Future<Uint8List?> Function(int, Duration)? getCachedSchuetzenausweisFn;
  final Future<void> Function(int, Uint8List, int)? cacheSchuetzenausweisFn;
  final dynamic connectivity;

  /// Cache a Schuetzenausweis entry
  Future<void> cacheSchuetzenausweis(
    int personId,
    Uint8List imageData,
    int timestamp,
  ) async {
    if (cacheSchuetzenausweisFn != null) {
      return await cacheSchuetzenausweisFn!(personId, imageData, timestamp);
    }
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
    if (getCachedSchuetzenausweisFn != null) {
      return await getCachedSchuetzenausweisFn!(personId, validity);
    }
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

  Future<Uint8List?> fetchAndCacheSchuetzenausweis(
    int personId,
    Duration validityDuration,
  ) async {
    final endpoint = 'Schuetzenausweis/JPG/$personId';

    try {
      final fetchedImage = await _httpClient.getBytes(endpoint);

      await cacheSchuetzenausweis(
        personId,
        fetchedImage,
        DateTime.now().millisecondsSinceEpoch,
      );
      return fetchedImage;
    } catch (e) {
      final cachedImage = await getCachedSchuetzenausweis(
        personId,
        const Duration(days: 365 * 100),
      );
      // If download fails, use any cached image (regardless of age)
      if (cachedImage != null) return cachedImage;
      // Instead of throwing, just return null to continue gracefully
      return null;
    }
  }

  /// Returns the cached date of the Schuetzenausweis image for the given personId in format DD.MM.YYYY,
  /// or null if not available.
  Future<String?> getSchuetzenausweisCacheDate(int personId) async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getInt('schuetzenausweis_${personId}_timestamp');
    if (ts == null) return null;
    final date = DateTime.fromMillisecondsSinceEpoch(ts);
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day.$month.$year';
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
