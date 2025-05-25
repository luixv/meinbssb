import 'base_exception.dart';

class ApiException extends BaseException {

  factory ApiException.fromResponse(Map<String, dynamic> response, {StackTrace? stackTrace}) {
    final message = response['ResultMessage'] as String? ?? 'An unexpected API error occurred';
    final code = response['ResultCode'] as String?;
    return ApiException(
      message: message,
      code: code,
      response: response,
      stackTrace: stackTrace,
    );
  }

  ApiException({
    required super.message,
    this.statusCode,
    this.response,
    super.code,
    super.originalError,
    super.stackTrace,
  });
  final int? statusCode;
  final Map<String, dynamic>? response;
} 