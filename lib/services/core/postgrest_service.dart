import 'dart:convert';
import 'package:http/http.dart' as http;
import 'logger_service.dart';
import 'config_service.dart';
import 'dart:typed_data'; // Import Uint8List
import 'package:meinbssb/models/beduerfnisse_auswahl_typ_data.dart';
import 'package:meinbssb/models/beduerfnisse_auswahl_data.dart';
import 'package:meinbssb/models/beduerfnisse_antrag_status_data.dart';
import 'package:meinbssb/models/beduerfnisse_antrag_data.dart';
import 'package:meinbssb/models/beduerfnisse_antrag_person.dart';

class PostgrestService {
  PostgrestService({
    required this.configService,
    http.Client? client,
  }) : _httpClient = client ?? http.Client();
  // Expose cache for testing
  Map<String, Uint8List> get profilePhotoCache => _profilePhotoCache;
  // Simple in-memory cache for profile photos
  final Map<String, Uint8List> _profilePhotoCache = {};

  final ConfigService configService;

  final http.Client _httpClient;

  String get _baseUrl {
    final baseUrl = ConfigService.buildBaseUrlForServer(
      configService,
      name: 'postgrest',
      protocolKey: 'postgrestProtocol',
    );
    // Add trailing slash to ensure proper endpoint concatenation
    // (e.g., /api + users = /api/users, not /apiusers)
    return baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
  }

  Map<String, String> get _headers {
    final apiKey = configService.getString('postgrestApiKey');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Prefer': 'return=representation', // This tells PostgREST to return the affected rows
      if (apiKey != null && apiKey.isNotEmpty) 'X-API-Key': apiKey,
    };
  }

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
      final response = await _httpClient.post(
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

  /// Get user by email (excludes deleted users)
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('${_baseUrl}users?email=eq.$email&is_deleted=eq.false'),
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

  /// Get user by Person ID (excludes deleted users)
  Future<Map<String, dynamic>?> getUserByPersonId(String personId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('${_baseUrl}users?person_id=eq.$personId&is_deleted=eq.false'),
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

  /// Get user by pass number (excludes deleted users)
  Future<Map<String, dynamic>?> getUserByPassNumber(String? passNumber) async {
    try {
      
      final response = await _httpClient.get(
        Uri.parse('${_baseUrl}users?pass_number=eq.$passNumber&is_deleted=eq.false'),
        headers: _headers,
      );
      LoggerService.logInfo(
        'Searching DB ${_baseUrl}users?pass_number=eq.$passNumber&is_deleted=eq.false',
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
      final response = await _httpClient.patch(
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
      final response = await _httpClient.delete(
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
      final response = await _httpClient.get(
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
      final response = await _httpClient.get(
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
      final response = await _httpClient.post(
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
      final response = await _httpClient.patch(
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
      final response = await _httpClient.get(uri, headers: _headers);
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
    final response = await _httpClient.patch(
      Uri.parse('${_baseUrl}users?verification_token=eq.$token'),
      headers: _headers,
      body: jsonEncode(fields),
    );
    return response;
  }

  /// Create an email validation entry
  Future<void> createEmailValidationEntry({
    required String personId,
    required String email,
    required String emailType,
    required String verificationToken,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('${_baseUrl}user_email_validation'),
        headers: _headers,
        body: jsonEncode({
          'person_id': personId,
          'email': email,
          'emailtype': emailType,
          'verification_token': verificationToken,
          'created_on': DateTime.now().toIso8601String(),
          'validated': false,
        }),
      );

      if (response.statusCode == 201) {
        LoggerService.logInfo('Email validation entry created successfully');
      } else {
        LoggerService.logError(
          'Failed to create email validation entry. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      LoggerService.logError('Error creating email validation entry: $e');
    }
  }

  /// Get email validation entry by verification token
  Future<Map<String, dynamic>?> getEmailValidationByToken(String token) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('${_baseUrl}user_email_validation?verification_token=eq.$token'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> entries = jsonDecode(response.body);
        return entries.isNotEmpty ? entries[0] : null;
      } else {
        LoggerService.logError(
          'Failed to get email validation entry by token. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return null;
      }
    } catch (e) {
      LoggerService.logError('Error getting email validation entry by token: $e');
      return null;
    }
  }

  /// Mark email validation entry as validated
  Future<bool> markEmailValidationAsValidated(String verificationToken) async {
    try {
      final response = await _httpClient.patch(
        Uri.parse('${_baseUrl}user_email_validation?verification_token=eq.$verificationToken'),
        headers: _headers,
        body: jsonEncode({
          'validated': true,
          'validated_on': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        LoggerService.logInfo('Email validation entry marked as validated');
        return true;
      } else {
        LoggerService.logError(
          'Failed to mark email validation as validated. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return false;
      }
    } catch (e) {
      LoggerService.logError('Error marking email validation as validated: $e');
      return false;
    }
  }

  /// Upload a new profile photo for a user (insert or update)
  Future<bool> uploadProfilePhoto(String userId, List<int> photoBytes) async {
    try {
      // First, check if the user exists
      final existingUser = await getUserByPersonId(userId);

      bool success = false;
      if (existingUser != null) {
        // User exists, do a PATCH update
        final response = await _httpClient.patch(
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
          success = true;
        } else {
          LoggerService.logError(
            'Failed to update profile photo. Status: ${response.statusCode}, Body: ${response.body}',
          );
        }
      } else {
        // User doesn't exist, do an INSERT
        final response = await _httpClient.post(
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
          success = true;
        } else {
          LoggerService.logError(
            'Failed to insert profile photo. Status: ${response.statusCode}, Body: ${response.body}',
          );
        }
      }
      // Refresh cache if upload was successful
      if (success) {
        _profilePhotoCache[userId] = Uint8List.fromList(photoBytes);
      }
      return success;
    } catch (e) {
      LoggerService.logError('Error uploading profile photo: $e');
      return false;
    }
  }

  /// Delete the profile photo for a user (set to null)
  Future<bool> deleteProfilePhoto(String userId) async {
    try {
      final response = await _httpClient.patch(
        Uri.parse('${_baseUrl}users?person_id=eq.$userId'),
        headers: _headers,
        body: jsonEncode({
          'profile_photo': null,
        }),
      );
      if (response.statusCode == 200) {
        LoggerService.logInfo('Profile photo deleted successfully');
        // Remove from cache
        _profilePhotoCache.remove(userId);
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

  /// Soft delete a user by setting is_deleted to true
  Future<bool> softDeleteUser(String personId) async {
    try {
      final response = await _httpClient.patch(
        Uri.parse('${_baseUrl}users?person_id=eq.$personId'),
        headers: _headers,
        body: jsonEncode({
          'is_deleted': true,
        }),
      );

      if (response.statusCode == 200) {
        LoggerService.logInfo('User soft deleted successfully for person_id: $personId');
        // Clear cache for this user
        _profilePhotoCache.remove(personId);
        return true;
      } else {
        LoggerService.logError(
          'Failed to soft delete user. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return false;
      }
    } catch (e) {
      LoggerService.logError('Error soft deleting user: $e');
      return false;
    }
  }

  /// Log an API request to the database
  Future<void> logApiRequest({
    required int? personId,
    required String apiBaseServer,
    required String apiBasePath,
    required String apiBasePort,
    required String endpoint,
    String? body,
  }) async {
    try {
      final logData = {
        'apiBaseServer': apiBaseServer,
        'apiBasePath': apiBasePath,
        'apiBasePort': apiBasePort,
        'endpoint': endpoint,
        if (body != null) 'requestBody': body,
      };

      final response = await _httpClient.post(
        Uri.parse('${_baseUrl}api_request_logs'),
        headers: _headers,
        body: jsonEncode({
          'person_id': personId,
          'logs': logData,
          'created_at': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        LoggerService.logInfo('API request logged successfully');
      } else {
        LoggerService.logError(
          'Failed to log API request. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      // Log error but don't throw - logging failures shouldn't break API calls
      LoggerService.logError('Error logging API request: $e');
    }
  }

  /// Fetch the profile photo for a user
  Future<Uint8List?> getProfilePhoto(String userId) async {
    // Check cache first
    if (_profilePhotoCache.containsKey(userId)) {
      LoggerService.logInfo('Profile photo loaded from cache for user $userId');
      return _profilePhotoCache[userId];
    }
    try {
      final response = await _httpClient.get(
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
          String cleanHex = hexData;
          if (cleanHex.startsWith('\\x')) {
            cleanHex = cleanHex.substring(2);
          }
          final bytes = <int>[];
          for (int i = 0; i < cleanHex.length; i += 2) {
            final hexByte = cleanHex.substring(i, i + 2);
            bytes.add(int.parse(hexByte, radix: 16));
          }
          final photoBytes = Uint8List.fromList(bytes);
          // Save to cache
          _profilePhotoCache[userId] = photoBytes;
          return photoBytes;
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

  //
  // --- bed_auswahl_typ Service Methods ---
  //

  /// Create a new bed_auswahl_typ entry
  Future<BeduerfnisseAuswahlTyp> createBedAuswahlTyp({
    required String kuerzel,
    required String beschreibung,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('${_baseUrl}bed_auswahl_typ'),
        headers: _headers,
        body: jsonEncode({
          'kuerzel': kuerzel,
          'beschreibung': beschreibung,
          'created_at': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        LoggerService.logInfo('bed_auswahl_typ created successfully');
        final List<dynamic> result = jsonDecode(response.body);
        if (result.isNotEmpty) {
          return BeduerfnisseAuswahlTyp.fromJson(result[0] as Map<String, dynamic>);
        }
        throw Exception('Empty response from create bed_auswahl_typ');
      } else {
        LoggerService.logError(
          'Failed to create bed_auswahl_typ. Status: ${response.statusCode}, Body: ${response.body}',
        );
        throw Exception('Failed to create bed_auswahl_typ: ${response.body}');
      }
    } catch (e) {
      LoggerService.logError('Error creating bed_auswahl_typ: $e');
      rethrow;
    }
  }

  /// Get all bed_auswahl_typ entries (excludes deleted)
  Future<List<BeduerfnisseAuswahlTyp>> getBedAuswahlTypen() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('${_baseUrl}bed_auswahl_typ?deleted_at=is.null'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> types = jsonDecode(response.body);
        return types
            .map((json) => BeduerfnisseAuswahlTyp.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        LoggerService.logError(
          'Failed to get bed_auswahl_typ. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return [];
      }
    } catch (e) {
      LoggerService.logError('Error getting bed_auswahl_typ: $e');
      return [];
    }
  }

  /// Get bed_auswahl_typ by ID
  Future<BeduerfnisseAuswahlTyp?> getBedAuswahlTypById(int id) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('${_baseUrl}bed_auswahl_typ?id=eq.$id&deleted_at=is.null'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> types = jsonDecode(response.body);
        if (types.isNotEmpty) {
          return BeduerfnisseAuswahlTyp.fromJson(types[0] as Map<String, dynamic>);
        }
        return null;
      } else {
        LoggerService.logError(
          'Failed to get bed_auswahl_typ by ID. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return null;
      }
    } catch (e) {
      LoggerService.logError('Error getting bed_auswahl_typ by ID: $e');
      return null;
    }
  }

  /// Update bed_auswahl_typ by ID
  Future<bool> updateBedAuswahlTyp(int id, Map<String, dynamic> data) async {
    try {
      final response = await _httpClient.patch(
        Uri.parse('${_baseUrl}bed_auswahl_typ?id=eq.$id'),
        headers: _headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        LoggerService.logInfo('bed_auswahl_typ updated successfully');
        return true;
      } else {
        LoggerService.logError(
          'Failed to update bed_auswahl_typ. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return false;
      }
    } catch (e) {
      LoggerService.logError('Error updating bed_auswahl_typ: $e');
      return false;
    }
  }

  /// Soft delete bed_auswahl_typ by ID
  Future<bool> deleteBedAuswahlTyp(int id) async {
    try {
      final response = await _httpClient.patch(
        Uri.parse('${_baseUrl}bed_auswahl_typ?id=eq.$id'),
        headers: _headers,
        body: jsonEncode({
          'deleted_at': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        LoggerService.logInfo('bed_auswahl_typ deleted successfully');
        return true;
      } else {
        LoggerService.logError(
          'Failed to delete bed_auswahl_typ. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return false;
      }
    } catch (e) {
      LoggerService.logError('Error deleting bed_auswahl_typ: $e');
      return false;
    }
  }

  //
  // --- bed_auswahl Service Methods ---
  //

  /// Create a new bed_auswahl entry
  Future<BeduerfnisseAuswahl> createBedAuswahl({
    required int typId,
    required String kuerzel,
    required String beschreibung,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('${_baseUrl}bed_auswahl'),
        headers: _headers,
        body: jsonEncode({
          'typ_id': typId,
          'kuerzel': kuerzel,
          'beschreibung': beschreibung,
          'created_at': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        LoggerService.logInfo('bed_auswahl created successfully');
        final List<dynamic> result = jsonDecode(response.body);
        if (result.isNotEmpty) {
          return BeduerfnisseAuswahl.fromJson(result[0] as Map<String, dynamic>);
        }
        throw Exception('Empty response from create bed_auswahl');
      } else {
        LoggerService.logError(
          'Failed to create bed_auswahl. Status: ${response.statusCode}, Body: ${response.body}',
        );
        throw Exception('Failed to create bed_auswahl: ${response.body}');
      }
    } catch (e) {
      LoggerService.logError('Error creating bed_auswahl: $e');
      rethrow;
    }
  }

  /// Get all bed_auswahl entries (excludes deleted)
  Future<List<BeduerfnisseAuswahl>> getBedAuswahlList() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('${_baseUrl}bed_auswahl?deleted_at=is.null'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> items = jsonDecode(response.body);
        return items
            .map((json) => BeduerfnisseAuswahl.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        LoggerService.logError(
          'Failed to get bed_auswahl. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return [];
      }
    } catch (e) {
      LoggerService.logError('Error getting bed_auswahl: $e');
      return [];
    }
  }

  /// Get bed_auswahl by type ID
  Future<List<BeduerfnisseAuswahl>> getBedAuswahlByTypId(int typId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('${_baseUrl}bed_auswahl?typ_id=eq.$typId&deleted_at=is.null'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> items = jsonDecode(response.body);
        return items
            .map((json) => BeduerfnisseAuswahl.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        LoggerService.logError(
          'Failed to get bed_auswahl by type. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return [];
      }
    } catch (e) {
      LoggerService.logError('Error getting bed_auswahl by type: $e');
      return [];
    }
  }

  /// Get bed_auswahl by ID
  Future<BeduerfnisseAuswahl?> getBedAuswahlById(int id) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('${_baseUrl}bed_auswahl?id=eq.$id&deleted_at=is.null'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> items = jsonDecode(response.body);
        if (items.isNotEmpty) {
          return BeduerfnisseAuswahl.fromJson(items[0] as Map<String, dynamic>);
        }
        return null;
      } else {
        LoggerService.logError(
          'Failed to get bed_auswahl by ID. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return null;
      }
    } catch (e) {
      LoggerService.logError('Error getting bed_auswahl by ID: $e');
      return null;
    }
  }

  /// Update bed_auswahl by ID
  Future<bool> updateBedAuswahl(int id, Map<String, dynamic> data) async {
    try {
      final response = await _httpClient.patch(
        Uri.parse('${_baseUrl}bed_auswahl?id=eq.$id'),
        headers: _headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        LoggerService.logInfo('bed_auswahl updated successfully');
        return true;
      } else {
        LoggerService.logError(
          'Failed to update bed_auswahl. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return false;
      }
    } catch (e) {
      LoggerService.logError('Error updating bed_auswahl: $e');
      return false;
    }
  }

  /// Soft delete bed_auswahl by ID
  Future<bool> deleteBedAuswahl(int id) async {
    try {
      final response = await _httpClient.patch(
        Uri.parse('${_baseUrl}bed_auswahl?id=eq.$id'),
        headers: _headers,
        body: jsonEncode({
          'deleted_at': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        LoggerService.logInfo('bed_auswahl deleted successfully');
        return true;
      } else {
        LoggerService.logError(
          'Failed to delete bed_auswahl. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return false;
      }
    } catch (e) {
      LoggerService.logError('Error deleting bed_auswahl: $e');
      return false;
    }
  }

  //
  // --- bed_datei Service Methods ---
  //

  /// Create a new bed_datei entry
  Future<Map<String, dynamic>> createBedDatei({
    required String antragsnummer,
    required String dateiname,
    required List<int> fileBytes,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('${_baseUrl}bed_datei'),
        headers: _headers,
        body: jsonEncode({
          'antragsnummer': antragsnummer,
          'dateiname': dateiname,
          'file_bytes': '\\x${fileBytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('')}',
          'created_at': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        LoggerService.logInfo('bed_datei created successfully');
        final List<dynamic> result = jsonDecode(response.body);
        return result.isNotEmpty ? result[0] : {};
      } else {
        LoggerService.logError(
          'Failed to create bed_datei. Status: ${response.statusCode}, Body: ${response.body}',
        );
        throw Exception('Failed to create bed_datei: ${response.body}');
      }
    } catch (e) {
      LoggerService.logError('Error creating bed_datei: $e');
      rethrow;
    }
  }

  /// Get bed_datei entries by antragsnummer (excludes deleted)
  Future<List<Map<String, dynamic>>> getBedDateiByAntragsnummer(
    String antragsnummer,
  ) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('${_baseUrl}bed_datei?antragsnummer=eq.$antragsnummer&deleted_at=is.null'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> files = jsonDecode(response.body);
        return files.cast<Map<String, dynamic>>();
      } else {
        LoggerService.logError(
          'Failed to get bed_datei by antragsnummer. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return [];
      }
    } catch (e) {
      LoggerService.logError('Error getting bed_datei by antragsnummer: $e');
      return [];
    }
  }

  /// Get bed_datei by ID
  Future<Map<String, dynamic>?> getBedDateiById(int id) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('${_baseUrl}bed_datei?id=eq.$id&deleted_at=is.null'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> files = jsonDecode(response.body);
        return files.isNotEmpty ? files[0] : null;
      } else {
        LoggerService.logError(
          'Failed to get bed_datei by ID. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return null;
      }
    } catch (e) {
      LoggerService.logError('Error getting bed_datei by ID: $e');
      return null;
    }
  }

  /// Update bed_datei by ID
  Future<bool> updateBedDatei(int id, Map<String, dynamic> data) async {
    try {
      data['changed_at'] = DateTime.now().toIso8601String();
      final response = await _httpClient.patch(
        Uri.parse('${_baseUrl}bed_datei?id=eq.$id'),
        headers: _headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        LoggerService.logInfo('bed_datei updated successfully');
        return true;
      } else {
        LoggerService.logError(
          'Failed to update bed_datei. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return false;
      }
    } catch (e) {
      LoggerService.logError('Error updating bed_datei: $e');
      return false;
    }
  }

  /// Soft delete bed_datei by ID
  Future<bool> deleteBedDatei(int id) async {
    try {
      final response = await _httpClient.patch(
        Uri.parse('${_baseUrl}bed_datei?id=eq.$id'),
        headers: _headers,
        body: jsonEncode({
          'deleted_at': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        LoggerService.logInfo('bed_datei deleted successfully');
        return true;
      } else {
        LoggerService.logError(
          'Failed to delete bed_datei. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return false;
      }
    } catch (e) {
      LoggerService.logError('Error deleting bed_datei: $e');
      return false;
    }
  }

  //
  // --- bed_sport Service Methods ---
  //

  /// Create a new bed_sport entry
  Future<Map<String, dynamic>> createBedSport({
    required String antragsnummer,
    required String schiessdatum,
    required int waffenartId,
    required int disziplinId,
    required bool training,
    int? wettkampfartId,
    double? wettkampfergebnis,
  }) async {
    try {
      final data = {
        'antragsnummer': antragsnummer,
        'schiessdatum': schiessdatum,
        'waffenart_id': waffenartId,
        'disziplin_id': disziplinId,
        'training': training,
        'created_at': DateTime.now().toIso8601String(),
      };
      if (wettkampfartId != null) data['wettkampfart_id'] = wettkampfartId;
      if (wettkampfergebnis != null) data['wettkampfergebnis'] = wettkampfergebnis;

      final response = await _httpClient.post(
        Uri.parse('${_baseUrl}bed_sport'),
        headers: _headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        LoggerService.logInfo('bed_sport created successfully');
        final List<dynamic> result = jsonDecode(response.body);
        return result.isNotEmpty ? result[0] : {};
      } else {
        LoggerService.logError(
          'Failed to create bed_sport. Status: ${response.statusCode}, Body: ${response.body}',
        );
        throw Exception('Failed to create bed_sport: ${response.body}');
      }
    } catch (e) {
      LoggerService.logError('Error creating bed_sport: $e');
      rethrow;
    }
  }

  /// Get bed_sport entries by antragsnummer (excludes deleted)
  Future<List<Map<String, dynamic>>> getBedSportByAntragsnummer(
    String antragsnummer,
  ) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('${_baseUrl}bed_sport?antragsnummer=eq.$antragsnummer&deleted_at=is.null'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> records = jsonDecode(response.body);
        return records.cast<Map<String, dynamic>>();
      } else {
        LoggerService.logError(
          'Failed to get bed_sport by antragsnummer. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return [];
      }
    } catch (e) {
      LoggerService.logError('Error getting bed_sport by antragsnummer: $e');
      return [];
    }
  }

  /// Get bed_sport by ID
  Future<Map<String, dynamic>?> getBedSportById(int id) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('${_baseUrl}bed_sport?id=eq.$id&deleted_at=is.null'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> records = jsonDecode(response.body);
        return records.isNotEmpty ? records[0] : null;
      } else {
        LoggerService.logError(
          'Failed to get bed_sport by ID. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return null;
      }
    } catch (e) {
      LoggerService.logError('Error getting bed_sport by ID: $e');
      return null;
    }
  }

  /// Update bed_sport by ID
  Future<bool> updateBedSport(int id, Map<String, dynamic> data) async {
    try {
      data['changed_at'] = DateTime.now().toIso8601String();
      final response = await _httpClient.patch(
        Uri.parse('${_baseUrl}bed_sport?id=eq.$id'),
        headers: _headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        LoggerService.logInfo('bed_sport updated successfully');
        return true;
      } else {
        LoggerService.logError(
          'Failed to update bed_sport. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return false;
      }
    } catch (e) {
      LoggerService.logError('Error updating bed_sport: $e');
      return false;
    }
  }

  /// Soft delete bed_sport by ID
  Future<bool> deleteBedSport(int id) async {
    try {
      final response = await _httpClient.patch(
        Uri.parse('${_baseUrl}bed_sport?id=eq.$id'),
        headers: _headers,
        body: jsonEncode({
          'deleted_at': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        LoggerService.logInfo('bed_sport deleted successfully');
        return true;
      } else {
        LoggerService.logError(
          'Failed to delete bed_sport. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return false;
      }
    } catch (e) {
      LoggerService.logError('Error deleting bed_sport: $e');
      return false;
    }
  }

  //
  // --- bed_waffe_besitz Service Methods ---
  //

  /// Create a new bed_waffe_besitz entry
  Future<Map<String, dynamic>> createBedWaffeBesitz({
    required String antragsnummer,
    required String wbkNr,
    required String lfdWbk,
    required int waffenartId,
    String? hersteller,
    required int kaliberId,
    int? lauflaengeId,
    String? gewicht,
    required bool kompensator,
    int? beduerfnisgrundId,
    int? verbandId,
    String? bemerkung,
  }) async {
    try {
      final data = {
        'antragsnummer': antragsnummer,
        'wbk_nr': wbkNr,
        'lfd_wbk': lfdWbk,
        'waffenart_id': waffenartId,
        'kaliber_id': kaliberId,
        'kompensator': kompensator,
        'created_at': DateTime.now().toIso8601String(),
      };
      if (hersteller != null) data['hersteller'] = hersteller;
      if (lauflaengeId != null) data['lauflaenge_id'] = lauflaengeId;
      if (gewicht != null) data['gewicht'] = gewicht;
      if (beduerfnisgrundId != null) data['beduerfnisgrund_id'] = beduerfnisgrundId;
      if (verbandId != null) data['verband_id'] = verbandId;
      if (bemerkung != null) data['bemerkung'] = bemerkung;

      final response = await _httpClient.post(
        Uri.parse('${_baseUrl}bed_waffe_besitz'),
        headers: _headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        LoggerService.logInfo('bed_waffe_besitz created successfully');
        final List<dynamic> result = jsonDecode(response.body);
        return result.isNotEmpty ? result[0] : {};
      } else {
        LoggerService.logError(
          'Failed to create bed_waffe_besitz. Status: ${response.statusCode}, Body: ${response.body}',
        );
        throw Exception('Failed to create bed_waffe_besitz: ${response.body}');
      }
    } catch (e) {
      LoggerService.logError('Error creating bed_waffe_besitz: $e');
      rethrow;
    }
  }

  /// Get bed_waffe_besitz entries by antragsnummer (excludes deleted)
  Future<List<Map<String, dynamic>>> getBedWaffeBesitzByAntragsnummer(
    String antragsnummer,
  ) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('${_baseUrl}bed_waffe_besitz?antragsnummer=eq.$antragsnummer&deleted_at=is.null'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> records = jsonDecode(response.body);
        return records.cast<Map<String, dynamic>>();
      } else {
        LoggerService.logError(
          'Failed to get bed_waffe_besitz by antragsnummer. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return [];
      }
    } catch (e) {
      LoggerService.logError('Error getting bed_waffe_besitz by antragsnummer: $e');
      return [];
    }
  }

  /// Get bed_waffe_besitz by ID
  Future<Map<String, dynamic>?> getBedWaffeBesitzById(int id) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('${_baseUrl}bed_waffe_besitz?id=eq.$id&deleted_at=is.null'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> records = jsonDecode(response.body);
        return records.isNotEmpty ? records[0] : null;
      } else {
        LoggerService.logError(
          'Failed to get bed_waffe_besitz by ID. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return null;
      }
    } catch (e) {
      LoggerService.logError('Error getting bed_waffe_besitz by ID: $e');
      return null;
    }
  }

  /// Update bed_waffe_besitz by ID
  Future<bool> updateBedWaffeBesitz(int id, Map<String, dynamic> data) async {
    try {
      data['changed_at'] = DateTime.now().toIso8601String();
      final response = await _httpClient.patch(
        Uri.parse('${_baseUrl}bed_waffe_besitz?id=eq.$id'),
        headers: _headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        LoggerService.logInfo('bed_waffe_besitz updated successfully');
        return true;
      } else {
        LoggerService.logError(
          'Failed to update bed_waffe_besitz. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return false;
      }
    } catch (e) {
      LoggerService.logError('Error updating bed_waffe_besitz: $e');
      return false;
    }
  }

  /// Soft delete bed_waffe_besitz by ID
  Future<bool> deleteBedWaffeBesitz(int id) async {
    try {
      final response = await _httpClient.patch(
        Uri.parse('${_baseUrl}bed_waffe_besitz?id=eq.$id'),
        headers: _headers,
        body: jsonEncode({
          'deleted_at': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        LoggerService.logInfo('bed_waffe_besitz deleted successfully');
        return true;
      } else {
        LoggerService.logError(
          'Failed to delete bed_waffe_besitz. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return false;
      }
    } catch (e) {
      LoggerService.logError('Error deleting bed_waffe_besitz: $e');
      return false;
    }
  }

  //
  // --- bed_antrag_status Service Methods ---
  //

  /// Create a new bed_antrag_status entry
  Future<BeduerfnisseAntragStatus> createBedAntragStatus({
    required String status,
    String? beschreibung,
  }) async {
    try {
      final body = {
        'status': status,
        if (beschreibung != null) 'beschreibung': beschreibung,
      };

      final response = await _httpClient.post(
        Uri.parse('${_baseUrl}bed_antrag_status'),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        final List<dynamic> data = jsonDecode(response.body);
        LoggerService.logInfo('bed_antrag_status created successfully');
        if (data.isNotEmpty) {
          return BeduerfnisseAntragStatus.fromJson(data[0] as Map<String, dynamic>);
        }
        throw Exception('Empty response from create bed_antrag_status');
      } else {
        LoggerService.logError(
          'Failed to create bed_antrag_status. Status: ${response.statusCode}, Body: ${response.body}',
        );
        throw Exception('Failed to create bed_antrag_status');
      }
    } catch (e) {
      LoggerService.logError('Error creating bed_antrag_status: $e');
      rethrow;
    }
  }

  /// Get all bed_antrag_status entries (excluding soft deleted)
  Future<List<BeduerfnisseAntragStatus>> getBedAntragStatusList() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('${_baseUrl}bed_antrag_status?deleted_at=is.null'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => BeduerfnisseAntragStatus.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        LoggerService.logError(
          'Failed to fetch bed_antrag_status list. Status: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      LoggerService.logError('Error fetching bed_antrag_status list: $e');
      return [];
    }
  }

  /// Get a bed_antrag_status entry by ID
  Future<BeduerfnisseAntragStatus?> getBedAntragStatusById(int id) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('${_baseUrl}bed_antrag_status?id=eq.$id&deleted_at=is.null'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return BeduerfnisseAntragStatus.fromJson(data[0] as Map<String, dynamic>);
        }
        return null;
      } else {
        LoggerService.logError(
          'Failed to fetch bed_antrag_status. Status: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      LoggerService.logError('Error fetching bed_antrag_status by ID: $e');
      return null;
    }
  }

  /// Get a bed_antrag_status entry by status value
  Future<BeduerfnisseAntragStatus?> getBedAntragStatusByStatus(
    String status,
  ) async {
    try {
      final response = await _httpClient.get(
        Uri.parse(
          '${_baseUrl}bed_antrag_status?status=eq.$status&deleted_at=is.null',
        ),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return BeduerfnisseAntragStatus.fromJson(data[0] as Map<String, dynamic>);
        }
        return null;
      } else {
        LoggerService.logError(
          'Failed to fetch bed_antrag_status by status. Status: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      LoggerService.logError('Error fetching bed_antrag_status by status: $e');
      return null;
    }
  }

  /// Update a bed_antrag_status entry
  Future<bool> updateBedAntragStatus(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _httpClient.patch(
        Uri.parse('${_baseUrl}bed_antrag_status?id=eq.$id'),
        headers: _headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        LoggerService.logInfo('bed_antrag_status updated successfully');
        return true;
      } else {
        LoggerService.logError(
          'Failed to update bed_antrag_status. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return false;
      }
    } catch (e) {
      LoggerService.logError('Error updating bed_antrag_status: $e');
      return false;
    }
  }

  /// Soft delete a bed_antrag_status entry
  Future<bool> deleteBedAntragStatus(int id) async {
    try {
      final response = await _httpClient.patch(
        Uri.parse('${_baseUrl}bed_antrag_status?id=eq.$id'),
        headers: _headers,
        body: jsonEncode({
          'deleted_at': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        LoggerService.logInfo('bed_antrag_status deleted successfully');
        return true;
      } else {
        LoggerService.logError(
          'Failed to delete bed_antrag_status. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return false;
      }
    } catch (e) {
      LoggerService.logError('Error deleting bed_antrag_status: $e');
      return false;
    }
  }

  //
  // --- bed_antrag Service Methods ---
  //

  /// Create a new bed_antrag entry
  Future<BeduerfnisseAntrag> createBedAntrag({
    required String antragsnummer,
    required int personId,
    int? statusId,
    bool? wbkNeu,
    String? wbkArt,
    String? beduerfnisart,
    int? anzahlWaffen,
    bool? vereinGenehmigt,
    String? email,
    Map<String, dynamic>? bankdaten,
    bool? abbuchungErfolgt,
    String? bemerkung,
  }) async {
    try {
      final body = {
        'antragsnummer': antragsnummer,
        'person_id': personId,
        if (statusId != null) 'status_id': statusId,
        if (wbkNeu != null) 'wbk_neu': wbkNeu,
        if (wbkArt != null) 'wbk_art': wbkArt,
        if (beduerfnisart != null) 'beduerfnisart': beduerfnisart,
        if (anzahlWaffen != null) 'anzahl_waffen': anzahlWaffen,
        if (vereinGenehmigt != null) 'verein_genehmigt': vereinGenehmigt,
        if (email != null) 'email': email,
        if (bankdaten != null) 'bankdaten': bankdaten,
        if (abbuchungErfolgt != null) 'abbuchung_erfolgt': abbuchungErfolgt,
        if (bemerkung != null) 'bemerkung': bemerkung,
      };

      final response = await _httpClient.post(
        Uri.parse('${_baseUrl}bed_antrag'),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        final List<dynamic> data = jsonDecode(response.body);
        LoggerService.logInfo('bed_antrag created successfully');
        if (data.isNotEmpty) {
          return BeduerfnisseAntrag.fromJson(data[0] as Map<String, dynamic>);
        }
        throw Exception('Empty response from create bed_antrag');
      } else {
        LoggerService.logError(
          'Failed to create bed_antrag. Status: ${response.statusCode}, Body: ${response.body}',
        );
        throw Exception('Failed to create bed_antrag');
      }
    } catch (e) {
      LoggerService.logError('Error creating bed_antrag: $e');
      rethrow;
    }
  }

  /// Get all bed_antrag entries (excluding soft deleted)
  Future<List<BeduerfnisseAntrag>> getBedAntragList() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('${_baseUrl}bed_antrag?deleted_at=is.null'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => BeduerfnisseAntrag.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        LoggerService.logError(
          'Failed to fetch bed_antrag list. Status: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      LoggerService.logError('Error fetching bed_antrag list: $e');
      return [];
    }
  }

  /// Get bed_antrag entries by antragsnummer
  Future<List<BeduerfnisseAntrag>> getBedAntragByAntragsnummer(
    String antragsnummer,
  ) async {
    try {
      final response = await _httpClient.get(
        Uri.parse(
          '${_baseUrl}bed_antrag?antragsnummer=eq.$antragsnummer&deleted_at=is.null',
        ),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => BeduerfnisseAntrag.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        LoggerService.logError(
          'Failed to fetch bed_antrag by antragsnummer. Status: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      LoggerService.logError('Error fetching bed_antrag by antragsnummer: $e');
      return [];
    }
  }

  /// Get bed_antrag entries by person_id
  Future<List<BeduerfnisseAntrag>> getBedAntragByPersonId(int personId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse(
          '${_baseUrl}bed_antrag?person_id=eq.$personId&deleted_at=is.null',
        ),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => BeduerfnisseAntrag.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        LoggerService.logError(
          'Failed to fetch bed_antrag by person_id. Status: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      LoggerService.logError('Error fetching bed_antrag by person_id: $e');
      return [];
    }
  }

  /// Get bed_antrag entries by status_id
  Future<List<BeduerfnisseAntrag>> getBedAntragByStatusId(int statusId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse(
          '${_baseUrl}bed_antrag?status_id=eq.$statusId&deleted_at=is.null',
        ),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => BeduerfnisseAntrag.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        LoggerService.logError(
          'Failed to fetch bed_antrag by status_id. Status: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      LoggerService.logError('Error fetching bed_antrag by status_id: $e');
      return [];
    }
  }

  /// Get a bed_antrag entry by ID
  Future<BeduerfnisseAntrag?> getBedAntragById(int id) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('${_baseUrl}bed_antrag?id=eq.$id&deleted_at=is.null'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return BeduerfnisseAntrag.fromJson(data[0] as Map<String, dynamic>);
        }
        return null;
      } else {
        LoggerService.logError(
          'Failed to fetch bed_antrag. Status: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      LoggerService.logError('Error fetching bed_antrag by ID: $e');
      return null;
    }
  }

  /// Update a bed_antrag entry
  Future<bool> updateBedAntrag(int id, Map<String, dynamic> data) async {
    try {
      // Always update changed_at when updating
      final updateData = {
        ...data,
        'changed_at': DateTime.now().toIso8601String(),
      };

      final response = await _httpClient.patch(
        Uri.parse('${_baseUrl}bed_antrag?id=eq.$id'),
        headers: _headers,
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        LoggerService.logInfo('bed_antrag updated successfully');
        return true;
      } else {
        LoggerService.logError(
          'Failed to update bed_antrag. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return false;
      }
    } catch (e) {
      LoggerService.logError('Error updating bed_antrag: $e');
      return false;
    }
  }

  /// Soft delete a bed_antrag entry
  Future<bool> deleteBedAntrag(int id) async {
    try {
      final response = await _httpClient.patch(
        Uri.parse('${_baseUrl}bed_antrag?id=eq.$id'),
        headers: _headers,
        body: jsonEncode({
          'deleted_at': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        LoggerService.logInfo('bed_antrag deleted successfully');
        return true;
      } else {
        LoggerService.logError(
          'Failed to delete bed_antrag. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return false;
      }
    } catch (e) {
      LoggerService.logError('Error deleting bed_antrag: $e');
      return false;
    }
  }

  //
  // --- bed_antrag_person Service Methods ---
  //

  /// Create a new bed_antrag_person entry
  Future<BeduerfnisseAntragPerson> createBedAntragPerson({
    required String antragsnummer,
    required int personId,
    int? statusId,
    String? name,
    String? nachname,
    String? vereinsname,
  }) async {
    try {
      final body = {
        'antragsnummer': antragsnummer,
        'person_id': personId,
        'created_at': DateTime.now().toIso8601String(),
        if (statusId != null) 'status_id': statusId,
        if (name != null) 'name': name,
        if (nachname != null) 'nachname': nachname,
        if (vereinsname != null) 'vereinsname': vereinsname,
      };

      final response = await _httpClient.post(
        Uri.parse('${_baseUrl}bed_antrag_person'),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        final List<dynamic> data = jsonDecode(response.body);
        LoggerService.logInfo('bed_antrag_person created successfully');
        if (data.isNotEmpty) {
          return BeduerfnisseAntragPerson.fromJson(data[0] as Map<String, dynamic>);
        }
        throw Exception('Empty response from create bed_antrag_person');
      } else {
        LoggerService.logError(
          'Failed to create bed_antrag_person. Status: ${response.statusCode}, Body: ${response.body}',
        );
        throw Exception('Failed to create bed_antrag_person');
      }
    } catch (e) {
      LoggerService.logError('Error creating bed_antrag_person: $e');
      rethrow;
    }
  }

  /// Get bed_antrag_person entries by antragsnummer
  Future<List<BeduerfnisseAntragPerson>> getBedAntragPersonByAntragsnummer(
    String antragsnummer,
  ) async {
    try {
      final response = await _httpClient.get(
        Uri.parse(
          '${_baseUrl}bed_antrag_person?antragsnummer=eq.$antragsnummer&deleted_at=is.null',
        ),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => BeduerfnisseAntragPerson.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        LoggerService.logError(
          'Failed to fetch bed_antrag_person by antragsnummer. Status: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      LoggerService.logError('Error fetching bed_antrag_person by antragsnummer: $e');
      return [];
    }
  }

  /// Get bed_antrag_person entries by person_id
  Future<List<BeduerfnisseAntragPerson>> getBedAntragPersonByPersonId(int personId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse(
          '${_baseUrl}bed_antrag_person?person_id=eq.$personId&deleted_at=is.null',
        ),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => BeduerfnisseAntragPerson.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        LoggerService.logError(
          'Failed to fetch bed_antrag_person by person_id. Status: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      LoggerService.logError('Error fetching bed_antrag_person by person_id: $e');
      return [];
    }
  }

  /// Update a bed_antrag_person entry
  Future<bool> updateBedAntragPerson(BeduerfnisseAntragPerson bedAntragPerson) async {
    try {
      if (bedAntragPerson.id == null) {
        LoggerService.logError('Cannot update bed_antrag_person without an ID');
        return false;
      }

      // Convert to JSON and add changed_at timestamp
      final updateData = {
        ...bedAntragPerson.toJson(),
        'changed_at': DateTime.now().toIso8601String(),
      };

      // Remove id, created_at, deleted_at, antragsnummer from update data
      updateData.remove('ID');
      updateData.remove('CREATED_AT');
      updateData.remove('ANTRAGSNUMMER');

      // Convert keys to snake_case for PostgREST
      final snakeCaseData = {
        if (updateData['PERSON_ID'] != null) 'person_id': updateData['PERSON_ID'],
        if (updateData['STATUS_ID'] != null) 'status_id': updateData['STATUS_ID'],
        if (updateData['VORNAME'] != null) 'name': updateData['VORNAME'],
        if (updateData['NACHNAME'] != null) 'nachname': updateData['NACHNAME'],
        if (updateData['VEREINSNAME'] != null) 'vereinsname': updateData['VEREINSNAME'],
        'changed_at': updateData['changed_at'],
      };

      final response = await _httpClient.patch(
        Uri.parse('${_baseUrl}bed_antrag_person?id=eq.${bedAntragPerson.id}'),
        headers: _headers,
        body: jsonEncode(snakeCaseData),
      );

      if (response.statusCode == 200) {
        LoggerService.logInfo('bed_antrag_person updated successfully');
        return true;
      } else {
        LoggerService.logError(
          'Failed to update bed_antrag_person. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return false;
      }
    } catch (e) {
      LoggerService.logError('Error updating bed_antrag_person: $e');
      return false;
    }
  }
}
