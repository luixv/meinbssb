// Filename: api_service.dart
import 'dart:async';
import 'dart:typed_data'; // Import Uint8List

import 'package:flutter/foundation.dart';
import 'package:meinbssb/services/api_service.dart' as network_ex;
import '/services/api/auth_service.dart';
import '/services/api/training_service.dart';
import '/services/api/user_service.dart';
import '/services/api/bank_service.dart';
import '/services/api/verein_service.dart';
import '/models/bank_data.dart';
import '/models/schulung.dart';
import '/models/zweitmitgliedschaft_data.dart';
import '/models/disziplin.dart';
import '/models/pass_data_zve.dart';

import 'core/cache_service.dart';
import 'core/config_service.dart';
import 'core/http_client.dart';
import 'core/image_service.dart';
import 'core/network_service.dart';
import '/models/contact.dart';
import '/models/verein.dart';
import '/models/user_data.dart';
import '/models/fremde_verband.dart';
import '/models/schulungsart.dart';

class NetworkException implements Exception {
  NetworkException(this.message);
  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

class ApiService {
  ApiService({
    required ConfigService configService,
    required HttpClient httpClient,
    required ImageService imageService,
    required CacheService cacheService,
    required NetworkService networkService,
    required TrainingService trainingService,
    required UserService userService,
    required AuthService authService,
    required BankService bankService,
    required VereinService vereinService,
  }) : _httpClient = httpClient,
       _imageService = imageService,
       _networkService = networkService,
       _trainingService = trainingService,
       _userService = userService,
       _authService = authService,
       _bankService = bankService,
       _vereinService = vereinService;

  final HttpClient _httpClient;
  final ImageService _imageService;
  final NetworkService _networkService;
  final TrainingService _trainingService;
  final UserService _userService;
  final AuthService _authService;
  final BankService _bankService;
  final VereinService _vereinService;

  Future<bool> hasInternet() => _networkService.hasInternet();

  Duration getCacheExpirationDuration() =>
      _networkService.getCacheExpirationDuration();

  // Use the register method from AuthService
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String passNumber,
    required String email,
    required String birthDate,
    required String zipCode,
  }) async {
    return _authService.register(
      firstName: firstName,
      lastName: lastName,
      passNumber: passNumber,
      email: email,
      birthDate: birthDate,
      zipCode: zipCode,
    );
  }

  // Auth service
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _authService.login(username, password);
      return response;
    } on network_ex.NetworkException {
      return {
        'ResultType': 0,
        'ResultMessage': 'Benutzername oder Passwort ist falsch',
      };
    } catch (e) {
      return {
        'ResultType': 0,
        'ResultMessage': 'Benutzername oder Passwort ist falsch',
      };
    }
  }

  Future<Map<String, dynamic>> resetPassword(String passNumber) async {
    return _authService.resetPassword(passNumber);
  }

  // User Service
  Future<UserData?> fetchPassdaten(int personId) async {
    return _userService.fetchPassdaten(personId);
  }

  Future<List<PassDataZVE>> fetchPassdatenZVE(
    int passdatenId,
    int personId,
  ) async {
    return _userService.fetchPassdatenZVE(passdatenId, personId);
  }

  Future<bool> updateKritischeFelderUndAdresse(UserData userData) async {
    return _userService.updateKritischeFelderUndAdresse(userData);
  }

  Future<List<ZweitmitgliedschaftData>> fetchZweitmitgliedschaften(
    int personId,
  ) async {
    return _userService.fetchZweitmitgliedschaften(personId);
  }

  Future<List<Schulung>> fetchAbsolvierteSeminare(int personId) async {
    return _trainingService.fetchAbsolvierteSchulungen(personId);
  }

  // User Service - Kontakte
  Future<List<Map<String, dynamic>>> fetchKontakte(int personId) async {
    return _userService.fetchKontakte(personId);
  }

  Future<bool> addKontakt(Contact contact) async {
    return _userService.addKontakt(contact);
  }

  Future<bool> deleteKontakt(Contact contact) async {
    return _userService.deleteKontakt(contact);
  }

  // Image Service
  Future<Uint8List> fetchSchuetzenausweis(int personId) async {
    return _imageService.fetchAndCacheSchuetzenausweis(
      personId,
      () => _httpClient.getBytes('Schuetzenausweis/JPG/$personId'), // Now valid
      getCacheExpirationDuration(),
    );
  }

  // Training Service
  Future<List<Schulungsart>> fetchSchulungsarten() async {
    return _trainingService.fetchSchulungsarten();
  }

  Future<List<Schulung>> fetchAngemeldeteSchulungen(
    int personId,
    String abDatum,
  ) async {
    return _trainingService.fetchAngemeldeteSchulungen(personId, abDatum);
  }

  Future<List<Schulung>> fetchAvailableSchulungen() async {
    return _trainingService.fetchAvailableSchulungen();
  }

  Future<bool> unregisterFromSchulung(int schulungenTeilnehmerID) async {
    return _trainingService.unregisterFromSchulung(schulungenTeilnehmerID);
  }

  Future<bool> registerFromSchulung(int personId, int schulungId) async {
    return _trainingService.registerForSchulung(personId, schulungId);
  }

  Future<List<Disziplin>> fetchDisziplinen() async {
    return _trainingService.fetchDisziplinen();
  }

  // Bank Service
  Future<List<BankData>> fetchBankData(int webloginId) async {
    return _bankService.fetchBankData(webloginId);
  }

  Future<bool> registerBankData(BankData bankData) async {
    return _bankService.registerBankData(bankData);
  }

  Future<bool> deleteBankData(BankData bankData) async {
    return _bankService.deleteBankData(bankData);
  }

  /// Fetches a list of all Vereine (clubs/associations).
  /// Returns a list of [Verein] objects containing basic club information.
  Future<List<Verein>> fetchVereine() async {
    return await _vereinService.fetchVereine();
  }

  /// Fetches detailed information for a specific Verein by its Vereinsnummer.
  /// Returns a list containing a single [Verein] object with complete club details.
  ///
  /// [vereinsNr] The registration number of the Verein to fetch.
  Future<List<Verein>> fetchVerein(int vereinsNr) async {
    return await _vereinService.fetchVerein(vereinsNr);
  }

  Future<List<FremdeVerband>> fetchFremdeVerbaende(int vereinsNr) async {
    return await _vereinService.fetchFremdeVerbaende();
  }
}
