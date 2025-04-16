// Project: Mein BSSB
// Filename: network_service.dart
// Author: Luis Mandel / NTT DATA

import 'dart:async';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../config/app_config.dart';
import '../services/config_service.dart';

class NetworkService {
  NetworkService({
    InternetConnectionChecker? connectionChecker,
    required ConfigService configService,
  }) : _connectionChecker =
           connectionChecker ?? InternetConnectionChecker.createInstance(),
       _configService = configService;
  final InternetConnectionChecker _connectionChecker;
  final ConfigService _configService;

  Future<bool> hasInternet() async {
    return await _connectionChecker.hasConnection;
  }

  Duration getCacheExpirationDuration() {
    return AppConfig.cacheExpirationDuration;
  }

  int _getCacheExpirationHoursFromConfig() {
    final expirationString = _configService.getString('cacheExpirationHours');
    return int.tryParse(expirationString ?? AppConfig.cacheExpirationHours.toString()) ?? 
           AppConfig.cacheExpirationHours;
  }
}
