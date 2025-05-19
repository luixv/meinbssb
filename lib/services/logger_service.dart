import 'package:logging/logging.dart';
import 'package:flutter/material.dart';

class LoggerService {
  static final Logger _logger = Logger('MyAppLogger');

  // Initialize the logger
  static void init() {
    // Set the log level
    Logger.root.level = Level
        .ALL; //  Level.OFF to disable logging or to Level.INFO to limit logs

    // Log to the console or a desired output
    Logger.root.onRecord.listen((record) {
      debugPrint('${record.level.name}: ${record.time}: ${record.message}');
      // Here you can redirect log messages to a file if needed
    });
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
