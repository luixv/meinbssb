import 'package:http/http.dart' as http;
import 'config_service.dart';
import 'logger_service.dart';

/// Stub implementation for web platform
/// This file is used when building for web where dart:io is not available
http.Client createHttpClientWithSslSupportImpl(
  ConfigService configService, {
  String configKey = 'postgrestIgnoreBadCertificate',
}) {
  // On web, SSL certificates are handled by the browser
  LoggerService.logInfo(
    'Running on web platform - SSL certificate validation is handled by the browser',
  );
  return http.Client();
}
