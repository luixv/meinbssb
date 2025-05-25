// Project: Mein BSSB
// Filename: error_service.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
import '/exceptions/api_exception.dart';
import '/exceptions/authentication_exception.dart';
import '/exceptions/network_exception.dart';
import '/exceptions/validation_exception.dart';
import '/exceptions/base_exception.dart';
import '/services/logger_service.dart';

/// A service for handling errors consistently across the application
class ErrorService {
  /// Shows a snackbar with an error message
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: UIConstants.bodyStyle),
        backgroundColor: Colors.red.shade700,
        duration: UIConstants.snackBarDuration,
      ),
    );
  }

  /// Shows a snackbar with a success message
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: UIConstants.bodyStyle),
        backgroundColor: Colors.green.shade700,
        duration: UIConstants.snackBarDuration,
      ),
    );
  }

  /// Handles any exception and returns a user-friendly error message
  static String handleException(dynamic error, [StackTrace? stackTrace]) {
    if (error is BaseException) {
      return _handleBaseException(error);
    }

    if (error is ApiException) {
      return _handleApiException(error);
    }

    if (error is NetworkException) {
      return _handleNetworkException(error);
    }

    if (error is AuthenticationException) {
      return _handleAuthenticationException(error);
    }

    if (error is ValidationException) {
      return _handleValidationException(error);
    }

    // Handle unknown errors
    return 'Ein unerwarteter Fehler ist aufgetreten. Bitte versuchen Sie es später erneut.';
  }

  /// Handles validation errors and returns a user-friendly error message
  static String handleValidationError(String field, String message) {
    return ValidationException(
      message: message,
      field: field,
    ).message;
  }

  /// Handles network errors and returns a user-friendly error message
  static String handleNetworkError(dynamic error) {
    if (error is NetworkException) {
      return error.message;
    }

    // Handle common network error cases
    if (error.toString().contains('SocketException')) {
      return 'Keine Internetverbindung verfügbar. Bitte überprüfen Sie Ihre Verbindung.';
    }

    if (error.toString().contains('TimeoutException')) {
      return 'Die Anfrage hat zu lange gedauert. Bitte versuchen Sie es später erneut.';
    }

    if (error.toString().contains('Connection refused')) {
      return 'Verbindung zum Server nicht möglich. Bitte versuchen Sie es später erneut.';
    }

    return 'Ein Netzwerkfehler ist aufgetreten. Bitte überprüfen Sie Ihre Internetverbindung und versuchen Sie es später erneut.';
  }

  static String _handleBaseException(BaseException error) {
    return error.message;
  }

  static String _handleApiException(ApiException error) {
    if (error.response != null) {
      return formatApiError(error.response!);
    }
    return error.message;
  }

  static String _handleNetworkException(NetworkException error) {
    return error.message;
  }

  static String _handleAuthenticationException(AuthenticationException error) {
    return error.message;
  }

  static String _handleValidationException(ValidationException error) {
    if (error.errors != null && error.errors!.isNotEmpty) {
      return error.errors!.values.first;
    }
    return '${error.field}: ${error.message}';
  }

  /// Formats API error messages for display
  static String formatApiError(Map<String, dynamic> response) {
    if (response.containsKey('ResultMessage') &&
        response['ResultMessage'] != null) {
      return response['ResultMessage'];
    }
    return 'Ein unbekannter Fehler ist aufgetreten.';
  }

  /// Logs an error with its stack trace
  static void logError(dynamic error, [StackTrace? stackTrace]) {
    LoggerService.logError('Error: $error');
    if (stackTrace != null) {
      LoggerService.logError('Stack trace: $stackTrace');
    }
  }
}
