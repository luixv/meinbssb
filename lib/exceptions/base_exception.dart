/// Base exception class for the application
class BaseException implements Exception {

  BaseException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  @override
  String toString() {
    final buffer = StringBuffer('${runtimeType.toString()}: $message');
    if (code != null) {
      buffer.write(' (Code: $code)');
    }
    if (originalError != null) {
      buffer.write('\nOriginal Error: $originalError');
    }
    if (stackTrace != null) {
      buffer.write('\nStack Trace: $stackTrace');
    }
    return buffer.toString();
  }
} 