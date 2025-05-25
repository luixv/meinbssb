import 'base_exception.dart';

class ValidationException extends BaseException {
  final String field;
  final Map<String, String>? errors;

  ValidationException({
    required String message,
    required this.field,
    this.errors,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  factory ValidationException.fromErrors(Map<String, String> errors) {
    final firstError = errors.entries.first;
    return ValidationException(
      message: firstError.value,
      field: firstError.key,
      errors: errors,
    );
  }
} 