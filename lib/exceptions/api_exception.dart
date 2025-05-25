import 'base_exception.dart';

class ApiException extends BaseException {
  final int? statusCode;
  final Map<String, dynamic>? response;

  ApiException({
    required String message,
    this.statusCode,
    this.response,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );

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
} 