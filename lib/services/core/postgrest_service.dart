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
          'firstname': firstName ?? '',
          'lastname': lastName ?? '',
          'email': email ?? '',
          'pass_number': passNumber ?? '',
          'person_id': personId ?? '',
          'verification_token': verificationToken ?? '',
          'created_at': DateTime.now().toIso8601String(),
          'is_verified': false,
        }),
      );

      if (response.statusCode == 201) {
        LoggerService.logInfo(
          'User registration created successfully in PostgreSQL',
        );
        return {}; // PostgREST returns an array
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

  /// Get user by Person ID
  Future<Map<String, dynamic>?> getUserByPersonId(String personId) async {
    try {
      final response = await _client.get(
        Uri.parse('${_baseUrl}users?person_id=eq.$personId'),
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
    LoggerService.logInfo('Verifying user');
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

  Future<Map<String, dynamic>?> getUserByPasswordResetVerificationToken(
    String token,
  ) async {
    LoggerService.logInfo('Checking if verification_token $token is valid');
    try {
      final response = await _client.get(
        Uri.parse('${_baseUrl}password_reset?verification_token=eq.$token'),
        headers: _headers,
      );
      LoggerService.logInfo('Got response: $response');
      if (response.statusCode == 200) {
        final List<dynamic> entries = jsonDecode(response.body);
        return entries.isNotEmpty ? entries[0] : null;
      } else {
        LoggerService.logError(
          'Failed to get entry by verification token at password reset. Status: \\${response.statusCode}, Body: \\${response.body}',
        );
        return null;
      }
    } catch (e) {
      LoggerService.logError(
        'Error getting entry by verification token at password reset: $e',
      );
      return null;
    }
  }

  /// Create a password reset entry
  /// Inserts a new row into password_reset with person_id, verification_token, created_at
  Future<void> createPasswordResetEntry({
    required String personId,
    required String verificationToken,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('${_baseUrl}password_reset'),
        headers: _headers,
        body: jsonEncode({
          'person_id': personId,
          'verification_token': verificationToken,
          'created_at': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        LoggerService.logInfo('Password reset entry created successfully');
      } else {
        LoggerService.logError(
          'Failed to create password reset entry. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      LoggerService.logError('Error creating password reset entry: $e');
    }
  }

  /// Mark password reset entry as used by verification token
  Future<void> markPasswordResetEntryUsed({
    required String verificationToken,
  }) async {
    try {
      final response = await _client.patch(
        Uri.parse(
            // ignore: require_trailing_commas
            '${_baseUrl}password_reset?verification_token=eq.$verificationToken'),
        headers: _headers,
        body: jsonEncode({
          'is_used': true,
          'used_at': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        LoggerService.logInfo('Password reset entry marked as used');
      } else {
        LoggerService.logError(
          'Failed to mark password reset as used. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      LoggerService.logError('Error marking password reset as used: $e');
    }
  }

  /// Get the latest password reset entry for a person_id
  Future<Map<String, dynamic>?> getLatestPasswordResetForPerson(
    String personId,
  ) async {
    try {
      final uri = Uri.parse(
        '${_baseUrl}password_reset?person_id=eq.$personId&order=created_at.desc&limit=1',
      );
      final response = await _client.get(uri, headers: _headers);
      if (response.statusCode == 200) {
        final List<dynamic> entries = jsonDecode(response.body);
        return entries.isNotEmpty ? entries[0] as Map<String, dynamic> : null;
      } else {
        LoggerService.logError(
          'Failed to get latest password reset by person. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return null;
      }
    } catch (e) {
      LoggerService.logError(
        'Error getting latest password reset by person: $e',
      );
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
      // First, check if the user exists
      final existingUser = await getUserByPersonId(userId);

      if (existingUser != null) {
        // User exists, do a PATCH update
        final response = await _client.patch(
          Uri.parse('${_baseUrl}users?person_id=eq.$userId'),
          headers: _headers,
          body: jsonEncode({
            'profile_photo':
                '\\x${photoBytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('')}',
          }),
        );
        if (response.statusCode == 200) {
          LoggerService.logInfo(
            'Profile photo updated successfully for existing user',
          );
          return true;
        } else {
          LoggerService.logError(
            'Failed to update profile photo. Status: ${response.statusCode}, Body: ${response.body}',
          );
          return false;
        }
      } else {
        // User doesn't exist, do an INSERT
        final response = await _client.post(
          Uri.parse('${_baseUrl}users'),
          headers: _headers,
          body: jsonEncode({
            'person_id': userId,
            'profile_photo':
                '\\x${photoBytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('')}',
            'created_at': DateTime.now().toIso8601String(),
          }),
        );
        if (response.statusCode == 201) {
          LoggerService.logInfo(
            'Profile photo uploaded successfully for new user',
          );
          return true;
        } else {
          LoggerService.logError(
            'Failed to insert profile photo. Status: ${response.statusCode}, Body: ${response.body}',
          );
          return false;
        }
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
        Uri.parse('${_baseUrl}users?person_id=eq.$userId'),
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

  /// Fetch the profile photo for a user
  Future<Uint8List?> getProfilePhoto(String userId) async {
    try {
      final response = await _client.get(
        Uri.parse('${_baseUrl}users?person_id=eq.$userId&select=profile_photo'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> users = jsonDecode(response.body);
        if (users.isNotEmpty && users[0]['profile_photo'] != null) {
          final String hexData = users[0]['profile_photo'];
          LoggerService.logInfo(
            'Profile photo fetched successfully for user $userId',
          );
          // Convert hexadecimal string to bytes
          String cleanHex = hexData;
          if (cleanHex.startsWith('\\x')) {
            cleanHex = cleanHex.substring(2);
          }
          // Convert hex string to bytes
          final bytes = <int>[];
          for (int i = 0; i < cleanHex.length; i += 2) {
            final hexByte = cleanHex.substring(i, i + 2);
            bytes.add(int.parse(hexByte, radix: 16));
          }
          return Uint8List.fromList(bytes);
        } else {
          LoggerService.logInfo('No profile photo found for user $userId');
          return null;
        }
      } else {
        LoggerService.logError(
          'Failed to fetch profile photo. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return null;
      }
    } catch (e) {
      LoggerService.logError('Error fetching profile photo: $e');
      return null;
    }
  }
}
