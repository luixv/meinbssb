import 'base_exception.dart';

class NetworkException extends BaseException {
  NetworkException({
    String message = 'An unexpected network error occurred.',
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}
