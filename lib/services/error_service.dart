// Project: Mein BSSB
// Filename: error_service.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/material.dart';
import 'package:meinbssb/constants/ui_constants.dart';

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

  /// Formats API error messages for display
  static String formatApiError(Map<String, dynamic> response) {
    if (response.containsKey('ResultMessage') &&
        response['ResultMessage'] != null) {
      return response['ResultMessage'];
    }
    return 'Ein unbekannter Fehler ist aufgetreten.';
  }

  /// Handles network errors
  static String handleNetworkError(dynamic error) {
    return 'Netzwerkfehler: Bitte überprüfen Sie Ihre Internetverbindung und versuchen Sie es später erneut.';
  }

  /// Handles validation errors
  static String handleValidationError(String field, String message) {
    return '$field: $message';
  }

  /// Handles general errors
  static String handleGeneralError(dynamic error) {
    return 'Ein Fehler ist aufgetreten: ${error.toString()}';
  }
}
