import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'config_service.dart';
import 'logger_service.dart';

/// Implementation for non-web platforms (mobile/desktop)
/// This file uses dart:io which is only available on non-web platforms
http.Client createHttpClientWithSslSupportImpl(
  ConfigService configService, {
  String configKey = 'postgrestIgnoreBadCertificate',
}) {
  // Check if we should ignore bad certificates
  final ignoreBadCert = configService.getBool(configKey) ?? false;
  
  if (!ignoreBadCert) {
    // Return standard client if we shouldn't ignore bad certificates
    return http.Client();
  }

  // Create a custom HttpClient that ignores bad certificates
  final httpClient = HttpClient();
  httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) {
    LoggerService.logWarning(
      'Ignoring SSL certificate error for $host:$port (configured via $configKey)',
    );
    return true; // Accept any certificate
  };

  // Wrap the HttpClient in an IOClient to use it with the http package
  return IOClient(httpClient);
}
