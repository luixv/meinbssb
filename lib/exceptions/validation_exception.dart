import 'base_exception.dart';

class ValidationException extends BaseException {

  ValidationException({
    required super.message,
    required this.field,
    this.errors,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory ValidationException.fromErrors(Map<String, String> errors) {
    final firstError = errors.entries.first;
    return ValidationException(
      message: firstError.value,
      field: firstError.key,
      errors: errors,
    );
  }
  final String field;
  final Map<String, String>? errors;
} 