import 'base_exception.dart';

class NetworkException extends BaseException {
  NetworkException({
    super.message = 'An unexpected network error occurred.',
    super.code,
    super.originalError,
    super.stackTrace,
  });
}
