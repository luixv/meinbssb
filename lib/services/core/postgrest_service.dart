import 'dart:convert';
import 'package:http/http.dart' as http;
import 'logger_service.dart';
import 'config_service.dart';

class PostgrestService {
  PostgrestService({
    required ConfigService configService,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final http.Client _client;

  String get _baseUrl => 'http://localhost:8081/api'; // Caddy server

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
        Uri.parse('$_baseUrl/user_registrations'),
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
        Uri.parse('$_baseUrl/user_registrations?email=eq.$email'),
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
        Uri.parse('$_baseUrl/user_registrations?pass_number=eq.$passNumber'),
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
          '$_baseUrl/user_registrations?verification_token=eq.$verificationToken',
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
        Uri.parse('$_baseUrl/user_registrations?id=eq.$id'),
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
        Uri.parse('$_baseUrl/user_registrations?verification_token=eq.$token'),
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
      String token, Map<String, dynamic> fields,) async {
    final response = await _client.patch(
      Uri.parse('$_baseUrl/user_registrations?verification_token=eq.$token'),
      headers: _headers,
      body: jsonEncode(fields),
    );
    return response;
  }
}
