// Project: Mein BSSB
// Filename: network_service.dart
// Author: Luis Mandel / NTT DATA

import 'dart:async';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '/services/config_service.dart';

class NetworkService {
  Future<bool> hasInternet() async {
    return await InternetConnectionChecker.createInstance().hasConnection;
  }

  Duration getCacheExpirationDuration() {
    return Duration(hours: _getCacheExpirationHoursFromConfig());
  }

  // Helper method to get cache expiration from config
  int _getCacheExpirationHoursFromConfig() {
    final expirationString = ConfigService.getString('cacheExpirationHours');
    return int.tryParse(expirationString ?? '24') ?? 24; // Default to 24
  }
}
