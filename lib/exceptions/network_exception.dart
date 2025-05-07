class NetworkException implements Exception {

  NetworkException([this.message = 'An unexpected network error occurred.']);
  final String message;

  @override
  String toString() => 'NetworkException: $message';
}
