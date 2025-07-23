import 'dart:convert';
import 'package:http/http.dart' as http;
import 'logger_service.dart';
import 'config_service.dart';
import 'dart:typed_data'; // Import Uint8List

class PostgrestService {
  PostgrestService({
    required this.configService,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final ConfigService configService;

  final http.Client _client;

  String get _baseUrl => ConfigService.buildBaseUrlForServer(
        configService,
        name: 'postgrest',
        protocolKey: 'postgrestProtocol',
      );
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Prefer':
            'return=representation', // This tells PostgREST to return the affected rows
      };

  /// Create a new user registration
  Future<Map<String, dynamic>> createUser({
    required String? firstName,
    required String? lastName,
    required String? email,
    required String? passNumber,
    required String? personId,
    required String? verificationToken,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('${_baseUrl}users'),
        headers: _headers,
        body: jsonEncode({
          'firstname': firstName,
          'lastname': lastName,
          'email': email,
          'pass_number': passNumber,
          'person_id': personId,
          'verification_token': verificationToken,
          'created_at': DateTime.now().toIso8601String(),
          'is_verified': false,
        }),
      );

      if (response.statusCode == 201) {
        LoggerService.logInfo(
          'User registration created successfully in PostgreSQL',
        );
        return jsonDecode(response.body)[0]; // PostgREST returns an array
      } else {
        LoggerService.logError(
          'Failed to create user registration. Status: ${response.statusCode}, Body: ${response.body}',
        );
        throw Exception('Failed to create user registration: ${response.body}');
      }
    } catch (e) {
      LoggerService.logError('Error creating user registration: $e');
      rethrow;
    }
  }

  /// Get user by email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final response = await _client.get(
        Uri.parse('${_baseUrl}users?email=eq.$email'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> users = jsonDecode(response.body);
        return users.isNotEmpty ? users[0] : null;
      } else {
        LoggerService.logError(
          'Failed to get user registration. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return null;
      }
    } catch (e) {
      LoggerService.logError('Error getting user registration: $e');
      return null;
    }
  }

  /// Get user by pass number
  Future<Map<String, dynamic>?> getUserByPassNumber(String? passNumber) async {
    try {
      final response = await _client.get(
        Uri.parse('${_baseUrl}users?pass_number=eq.$passNumber'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> users = jsonDecode(response.body);
        return users.isNotEmpty ? users[0] : null;
      } else {
        LoggerService.logError(
          'Failed to get user registration. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return null;
      }
    } catch (e) {
      LoggerService.logError('Error getting user registration: $e');
      return null;
    }
  }

  /// Update user verification status
  Future<bool> verifyUser(String? verificationToken) async {
    try {
      final response = await _client.patch(
        Uri.parse(
          '${_baseUrl}users?verification_token=eq.$verificationToken',
        ),
        headers: _headers,
        body: jsonEncode({
          'is_verified': true,
          'verified_at': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        LoggerService.logInfo('User registration verified successfully');
        return true;
      } else {
        LoggerService.logError(
          'Failed to verify user registration. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return false;
      }
    } catch (e) {
      LoggerService.logError('Error verifying user registration: $e');
      return false;
    }
  }

  /// Delete a user registration by ID
  Future<bool> deleteUserRegistration(int id) async {
    try {
      final response = await _client.delete(
        Uri.parse('${_baseUrl}users?id=eq.$id'),
        headers: _headers,
      );

      if (response.statusCode == 204) {
        LoggerService.logInfo('User registration deleted successfully');
        return true;
      } else {
        LoggerService.logError(
          'Failed to delete user registration. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return false;
      }
    } catch (e) {
      LoggerService.logError('Error deleting user registration: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserByVerificationToken(String token) async {
    try {
      final response = await _client.get(
        Uri.parse('${_baseUrl}users?verification_token=eq.$token'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> users = jsonDecode(response.body);
        return users.isNotEmpty ? users[0] : null;
      } else {
        LoggerService.logError(
          'Failed to get user by verification_token. Status: \\${response.statusCode}, Body: \\${response.body}',
        );
        return null;
      }
    } catch (e) {
      LoggerService.logError('Error getting user by verification_token: $e');
      return null;
    }
  }

  Future<http.Response> updateUserByVerificationToken(
    String token,
    Map<String, dynamic> fields,
  ) async {
    final response = await _client.patch(
      Uri.parse('${_baseUrl}users?verification_token=eq.$token'),
      headers: _headers,
      body: jsonEncode(fields),
    );
    return response;
  }

  /// Upload a new profile photo for a user (insert or update)
  Future<bool> uploadProfilePhoto(String userId, List<int> photoBytes) async {
    try {
      final response = await _client.patch(
        Uri.parse('${_baseUrl}users?id=eq.$userId'),
        headers: _headers,
        body: jsonEncode({
          'profile_photo': base64Encode(photoBytes),
        }),
      );
      if (response.statusCode == 200) {
        LoggerService.logInfo('Profile photo uploaded successfully');
        return true;
      } else {
        LoggerService.logError(
          'Failed to upload profile photo. Status: \\${response.statusCode}, Body: \\${response.body}',
        );
        return false;
      }
    } catch (e) {
      LoggerService.logError('Error uploading profile photo: $e');
      return false;
    }
  }

  /// Delete the profile photo for a user (set to null)
  Future<bool> deleteProfilePhoto(String userId) async {
    try {
      final response = await _client.patch(
        Uri.parse('${_baseUrl}users?id=eq.$userId'),
        headers: _headers,
        body: jsonEncode({
          'profile_photo': null,
        }),
      );
      if (response.statusCode == 200) {
        LoggerService.logInfo('Profile photo deleted successfully');
        return true;
      } else {
        LoggerService.logError(
          'Failed to delete profile photo. Status: \\${response.statusCode}, Body: \\${response.body}',
        );
        return false;
      }
    } catch (e) {
      LoggerService.logError('Error deleting profile photo: $e');
      return false;
    }
  }

  /// Fake method to fetch a profile picture URL for a given user ID.
  /// Returns a placeholder image URL or null if no picture is available.
  /// Fake method to fetch a profile picture as Uint8List for a given user ID.
  /// Returns dummy image data or null if no picture is available.
  Future<Uint8List?> fetchProfilPicture(String userId) async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Simulate network delay
    if (userId == 'user123') {
      // Return a very small, simple dummy image (e.g., a 1x1 transparent PNG)
      // In a real application, you would fetch actual image bytes from a server.
      // This is a base64 encoded 1x1 transparent PNG.
      const String base64Image =
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=';
      return Uint8List.fromList(
        List.from(base64Decode(base64Image)),
      ); // Decode base64 to Uint8List
    }
    return null; // No picture available for other users
  }
}

// Helper function to decode base64 string (not part of Flutter, usually in dart:convert)
Uint8List base64Decode(String source) {
  // This is a simplified example. In a real Flutter app, you'd use dart:convert:
  // import 'dart:convert';
  // return base64Decode(source);
  // For this isolated example, we'll just return a dummy list.
  // This part needs to be replaced with actual base64 decoding if running outside a full Flutter env.
  // For demonstration purposes, we'll just return an empty list if dart:convert is not available.
  try {
    return Uint8List.fromList(
      List.from(source.codeUnits),
    ); // Placeholder for actual base64 decoding
  } catch (e) {
    return Uint8List(0); // Return empty list on error
  }
}
