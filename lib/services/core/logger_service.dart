import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart';
import 'config_service.dart';

class LoggerService {
  static final Logger _logger = Logger('MyAppLogger');
  static bool _initialized = false;

  // Initialize the logger
  static void init([ConfigService? configService]) {
    // Set up the log output handler (only once)
    if (!_initialized) {
      Logger.root.onRecord.listen((record) {
        debugPrint('${record.level.name}: ${record.time}: ${record.message}');
        // Here  log messages cyn be redirected to a file or to a remote server if needed
      });
      _initialized = true;
    }

    // Set the log level based on environment
    // In production (webServer is meinprod.bssb.de), only show WARNING and above (hide INFO and DEBUG)
    // Otherwise, show all logs
    bool isProduction = false;

    if (configService != null) {
      final webServer = configService.getString('webServer');
      isProduction = webServer != 'meintest.bssb.de';
    } else {
      // Fallback to release mode if config is not available yet
      isProduction = kReleaseMode;
    }

    if (isProduction) {
      Logger.root.level = Level.OFF; // No logs in production
    } else {
      Logger.root.level = Level.ALL; // All logs in non-production
    }
  }

  static void logInfo(String message) {
    _logger.info(message);
  }

  static void logWarning(String message) {
    _logger.warning(message);
  }

  static void logError(String message) {
    _logger.severe(message);
  }

  static void logDebug(String message) {
    _logger.fine(message);
  }

  // Add more logging methods if necessary
}
