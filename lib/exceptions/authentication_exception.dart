import 'base_exception.dart';

class AuthenticationException extends BaseException {
  AuthenticationException({
    String message = 'Authentication failed',
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
