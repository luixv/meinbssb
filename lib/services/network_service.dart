// Project: Mein BSSB
// Filename: network_service.dart
// Author: Luis Mandel / NTT DATA

import 'dart:async';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '/services/config_service.dart';

class NetworkService {
  final InternetConnectionChecker _connectionChecker;

  NetworkService({InternetConnectionChecker? connectionChecker})
    : _connectionChecker =
          connectionChecker ?? InternetConnectionChecker.createInstance();

  Future<bool> hasInternet() async {
    return await _connectionChecker.hasConnection;
  }

  Duration getCacheExpirationDuration() {
    return Duration(hours: _getCacheExpirationHoursFromConfig());
  }

  int _getCacheExpirationHoursFromConfig() {
    final expirationString = ConfigService.getString(
      'cacheExpirationHours',
    ); // Call the static method directly
    return int.tryParse(expirationString ?? '24') ?? 24;
  }
}
