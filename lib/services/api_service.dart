// Filename: api_service.dart
import 'dart:async';
import 'dart:typed_data'; // Import Uint8List

import 'package:flutter/foundation.dart';
import 'package:meinbssb/services/api_service.dart' as network_ex;
import 'package:meinbssb/services/api/auth_service.dart';
import 'package:meinbssb/services/api/training_service.dart';
import 'package:meinbssb/services/api/user_service.dart';
import 'package:meinbssb/services/api/bank_service.dart';
import 'package:meinbssb/services/api/verein_service.dart';
import 'package:meinbssb/models/bank_data.dart';
import 'package:meinbssb/models/schulung.dart';
import 'package:meinbssb/models/zweitmitgliedschaft_data.dart';
import 'package:meinbssb/models/disziplin.dart';
import 'package:meinbssb/models/pass_data_zve.dart';
import 'package:meinbssb/models/register_schulungen_teilnehmer_response.dart';
import 'package:meinbssb/models/contact.dart';
import 'package:meinbssb/models/verein.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/fremde_verband.dart';
import 'package:meinbssb/models/schulungsart.dart';
import 'package:meinbssb/models/schulungstermine.dart';

import 'core/cache_service.dart';
import 'core/config_service.dart';
import 'core/http_client.dart';
import 'core/image_service.dart';
import 'core/network_service.dart';

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
  })  : _httpClient = httpClient,
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

  Future<Map<String, dynamic>> passwordReset(String passNumber) async {
    return _authService.passwordReset(passNumber);
  }

  Future<Map<String, dynamic>> changePassword(
    int personId,
    String newPassword,
  ) async {
    return _authService.changePassword(personId, newPassword);
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

  Future<List<Schulung>> fetchAbsolvierteSchulungen(int personId) async {
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

  Future<List<Schulungstermine>> fetchSchulungstermine(String abDatum) async {
    return _trainingService.fetchSchulungstermine(abDatum);
  }

  Future<Schulungstermine?> fetchSchulungstermin(
    String schulungenTerminID,
  ) async {
    return _trainingService.fetchSchulungstermin(schulungenTerminID);
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
    return _userService.fetchBankData(webloginId);
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

  Future<RegisterSchulungenTeilnehmerResponse> registerSchulungenTeilnehmer({
    required int schulungTerminId,
    required UserData user,
    required String email,
    required String telefon,
    required BankData bankData,
    required List<Map<String, dynamic>> felderArray,
  }) async {
    return _trainingService.registerSchulungenTeilnehmer(
      schulungTerminId: schulungTerminId,
      user: user,
      email: email,
      telefon: telefon,
      bankData: bankData,
      felderArray: felderArray,
    );
  }

  // Auth service
  Future<bool> findePersonID2(String nachname, String passnummer) async {
    return _authService.findePersonID2(nachname, passnummer);
  }

  /// Clears the schulungen cache for a specific person
  Future<void> clearSchulungenCache(int personId) async {
    await _trainingService.clearSchulungenCache(personId);
  }

  /// Clears all schulungen caches
  Future<void> clearAllSchulungenCache() async {
    await _trainingService.clearAllSchulungenCache();
  }

  /// Clears the passdaten cache for a specific person
  Future<void> clearPassdatenCache(int personId) async {
    await _userService.clearPassdatenCache(personId);
  }

  /// Clears all passdaten caches
  Future<void> clearAllPassdatenCache() async {
    await _userService.clearAllPassdatenCache();
  }

  /// Clears the disziplinen cache
  Future<void> clearDisziplinenCache() async {
    await _trainingService.clearDisziplinenCache();
  }
}
