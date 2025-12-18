import 'package:http/http.dart' as http;
import 'config_service.dart';

// Conditional imports - different implementations for web vs non-web
import 'http_client_helper_stub.dart'
    if (dart.library.io) 'http_client_helper_io.dart';

/// Creates an HTTP client that can optionally ignore SSL certificate errors.
/// This is useful for development environments with self-signed certificates.
/// 
/// Note: On web platforms, SSL certificate validation is handled by the browser
/// and cannot be bypassed programmatically. This function will return a standard
/// client on web platforms regardless of the ignoreBadCertificate setting.
/// 
/// [configService] - The configuration service to check for ignoreBadCertificate setting
/// [configKey] - The config key to check (e.g., 'postgrestIgnoreBadCertificate')
/// 
/// Returns an http.Client that respects the ignoreBadCertificate setting.
http.Client createHttpClientWithSslSupport(
  ConfigService configService, {
  String configKey = 'postgrestIgnoreBadCertificate',
}) {
  // Delegate to platform-specific implementation
  return createHttpClientWithSslSupportImpl(
    configService,
    configKey: configKey,
  );
}
