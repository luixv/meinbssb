class AuthenticationException implements Exception {
  AuthenticationException([this.message = 'Authentication failed']);
  final String message;

  @override
  String toString() {
    return 'AuthenticationException: $message';
  }
}
