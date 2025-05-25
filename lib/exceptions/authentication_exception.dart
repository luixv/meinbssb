import 'base_exception.dart';

class AuthenticationException extends BaseException {
  AuthenticationException({
    super.message = 'Authentication failed',
    super.code,
    super.originalError,
    super.stackTrace,
  });
}
