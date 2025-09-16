// Filename: api_service.dart
import 'dart:async';
import 'dart:typed_data'; // Import Uint8List

import 'package:flutter/foundation.dart';
import 'package:meinbssb/models/gewinn_data.dart';
import 'package:meinbssb/services/api_service.dart' as network_ex;
import 'package:meinbssb/services/api/auth_service.dart';
import 'package:meinbssb/services/api/training_service.dart';
import 'package:meinbssb/services/api/user_service.dart';
import 'package:meinbssb/services/api/bank_service.dart';
import 'package:meinbssb/services/api/verein_service.dart';
import 'package:meinbssb/services/api/oktoberfest_service.dart';
import 'package:meinbssb/services/api/bezirk_service.dart';

import 'package:meinbssb/models/bank_data.dart';
import 'package:meinbssb/models/schulung_data.dart';
import 'package:meinbssb/models/zweitmitgliedschaft_data.dart';
import 'package:meinbssb/models/disziplin_data.dart';
import 'package:meinbssb/models/passdaten_akzept_or_aktiv_data.dart';
import 'package:meinbssb/models/pass_data_zve_data.dart';
import 'package:meinbssb/models/register_schulungen_teilnehmer_response_data.dart';
import 'package:meinbssb/models/contact_data.dart';
import 'package:meinbssb/models/verein_data.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/fremde_verband_data.dart';
import 'package:meinbssb/models/schulungsart_data.dart';
import 'package:meinbssb/models/schulungstermin_data.dart';
import 'package:meinbssb/models/person_data.dart';
import 'package:meinbssb/models/result_data.dart';
import 'package:meinbssb/models/bezirk_data.dart';

import 'core/cache_service.dart';
import 'core/config_service.dart';
import 'core/http_client.dart';
import 'core/image_service.dart'; // Make sure this import exists
import 'core/logger_service.dart';
import 'core/network_service.dart';
import 'core/postgrest_service.dart';
import 'core/email_service.dart';
import 'core/calendar_service.dart';

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
    required PostgrestService postgrestService,
    required EmailService emailService,
    required OktoberfestService oktoberfestService,
    required CalendarService calendarService,
    required BezirkService bezirkService,
  })  : _imageService = imageService,
        _networkService = networkService,
        _trainingService = trainingService,
        _userService = userService,
        _authService = authService,
        _bankService = bankService,
        _vereinService = vereinService,
        _postgrestService = postgrestService,
        _emailService = emailService,
        _oktoberfestService = oktoberfestService,
        _bezirkService = bezirkService;

  final ImageService _imageService;
  final NetworkService _networkService;
  final TrainingService _trainingService;
  final UserService _userService;
  final AuthService _authService;
  final BankService _bankService;
  final VereinService _vereinService;
  final PostgrestService _postgrestService;
  final EmailService _emailService;
  final OktoberfestService _oktoberfestService;
  final BezirkService _bezirkService;

  Future<bool> hasInternet() => _networkService.hasInternet();

  ImageService get imageService => _imageService;

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
    required String personId,
  }) async {
    return _authService.register(
      firstName: firstName,
      lastName: lastName,
      passNumber: passNumber,
      email: email,
      birthDate: birthDate,
      zipCode: zipCode,
      personId: personId,
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
    return _authService.resetPasswordStep1(passNumber);
  }

  Future<Map<String, dynamic>> finalizeResetPassword(
    String token,
    String personId,
    String newPassword,
  ) async {
    return _authService.resetPasswordStep2(token, personId, newPassword);
  }

  Future<Map<String, dynamic>?> getUserByPasswordResetVerificationToken(
    String token,
  ) async {
    return _postgrestService.getUserByPasswordResetVerificationToken(token);
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

  Future<PassdatenAkzeptOrAktiv?> fetchPassdatenAkzeptierterOderAktiverPass(
    int personId,
  ) async {
    return _userService.fetchPassdatenAkzeptierterOderAktiverPass(personId);
  }

  Future<bool> postBSSBAppPassantrag(
    Map<int, Map<String, int?>> secondColumns,
    int? passdatenId,
    int? personId,
    int? erstVereinId,
    int digitalerPass,
  ) async {
    return _userService.postBSSBAppPassantrag(
      secondColumns,
      passdatenId,
      personId,
      erstVereinId,
      digitalerPass,
    );
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

  Future<List<ZweitmitgliedschaftData>> fetchZweitmitgliedschaftenZVE(
    int personId,
    int passStatus,
  ) async {
    return _userService.fetchZweitmitgliedschaftenZVE(personId, passStatus);
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
      getCacheExpirationDuration(),
    );
  }

  // Training Service
  Future<List<Schulungsart>> fetchSchulungsarten() async {
    return _trainingService.fetchSchulungsarten();
  }

  Future<List<Schulungstermin>> fetchAngemeldeteSchulungen(
    int personId,
    String abDatum,
  ) async {
    return _trainingService.fetchAngemeldeteSchulungen(personId, abDatum);
  }

  Future<List<Schulungstermin>> fetchSchulungstermine(
    String abDatum,
    String webGruppe,
    String bezirk,
    String fuerVerlaengerung,
    String fuerVuelVerlaengerung,
  ) async {
    return _trainingService.fetchSchulungstermine(
      abDatum,
      webGruppe,
      bezirk,
      fuerVerlaengerung,
      fuerVuelVerlaengerung,
    );
  }

  Future<Schulungstermin?> fetchSchulungstermin(
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
  Future<int> findePersonID2(String nachname, String passnummer) async {
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

  /// Sends a training unregistration email notification
  Future<void> sendSchulungAbmeldungEmail({
    required String personId,
    required String schulungName,
    required String schulungDate,
    required String firstName,
    required String lastName,
  }) async {
    await _emailService.sendSchulungAbmeldungEmail(
      personId: personId,
      schulungName: schulungName,
      schulungDate: schulungDate,
      firstName: firstName,
      lastName: lastName,
    );
  }

  /// Sends a training registration email notification
  Future<void> sendSchulungAnmeldungEmail({
    required String personId,
    required String schulungName,
    required String schulungDate,
    required String firstName,
    required String lastName,
    required String passnumber,
    required String email,
    required int schulungRegistered,
    required int schulungTotal,
    String? location,
    DateTime? eventDateTime,
  }) async {
    await _emailService.sendSchulungAnmeldungEmail(
      personId: personId,
      schulungName: schulungName,
      schulungDate: schulungDate,
      firstName: firstName,
      lastName: lastName,
      passnumber: passnumber,
      email: email,
      schulungRegistered: schulungRegistered,
      schulungTotal: schulungTotal,
      location: location,
      eventDateTime: eventDateTime,
    );
  }

  /// Clears all passdaten caches
  Future<void> clearAllPassdatenCache() async {
    await _userService.clearAllPassdatenCache();
  }

  /// Clears the disziplinen cache
  Future<void> clearDisziplinenCache() async {
    await _trainingService.clearDisziplinenCache();
  }

  Future<List<Person>> fetchAdresseVonPersonID(int personId) async {
    return _userService.fetchAdresseVonPersonID(personId);
  }

  // --- Bank validation helpers ---
  bool validateIBAN(String? iban) {
    return BankService.validateIBAN(iban);
  }

  String? validateBIC(String? bic) {
    return BankService.validateBIC(bic);
  }

  // --- PostgrestService methods ---
  Future<Map<String, dynamic>> createUser({
    required String? firstName,
    required String? lastName,
    required String? email,
    required String? passNumber,
    required String? personId,
    required String? verificationToken,
  }) async {
    return _postgrestService.createUser(
      firstName: firstName,
      lastName: lastName,
      email: email,
      passNumber: passNumber,
      personId: personId,
      verificationToken: verificationToken,
    );
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    return _postgrestService.getUserByEmail(email);
  }

  Future<Map<String, dynamic>?> getUserByPersonId(String personId) async {
    return _postgrestService.getUserByPersonId(personId);
  }

  Future<Map<String, dynamic>?> getUserByPassNumber(String? passNumber) async {
    return _postgrestService.getUserByPassNumber(passNumber);
  }

  Future<bool> verifyUser(String? verificationToken) async {
    return _postgrestService.verifyUser(verificationToken);
  }

  Future<bool> deleteUserRegistration(int id) async {
    return _postgrestService.deleteUserRegistration(id);
  }

  Future<Map<String, dynamic>?> getUserByVerificationToken(String token) async {
    return _postgrestService.getUserByVerificationToken(token);
  }

  Future<bool> uploadProfilePhoto(String userId, List<int> photoBytes) async {
    return _postgrestService.uploadProfilePhoto(userId, photoBytes);
  }

  Future<bool> deleteProfilePhoto(String userId) async {
    return _postgrestService.deleteProfilePhoto(userId);
  }

  /// Fetch a profile picture for a given user ID.
  /// Returns the profile photo as bytes or null if no picture is available.
  Future<Uint8List?> getProfilePhoto(String userId) async {
    return _postgrestService.getProfilePhoto(userId);
  }

  // --- EmailService methods ---
  Future<String?> getFromEmail() async {
    return _emailService.getFromEmail();
  }

  Future<String?> getRegistrationSubject() async {
    return _emailService.getRegistrationSubject();
  }

  Future<String?> getRegistrationContent() async {
    return _emailService.getRegistrationContent();
  }

  Future<Map<String, dynamic>> sendEmail({
    required String from,
    required String recipient,
    required String subject,
    String? htmlBody,
    int? emailId,
  }) async {
    return _emailService.sendEmail(
      sender: from,
      recipient: recipient,
      subject: subject,
      htmlBody: htmlBody,
      emailId: emailId,
    );
  }

  Future<void> sendAccountCreationNotifications(
    String personId,
    String email,
  ) async {
    return _emailService.sendAccountCreationNotifications(personId, email);
  }

  Future<List<Result>> fetchResults(
    String passnummer,
    ConfigService configService,
  ) async {
    return _oktoberfestService.fetchResults(
      passnummer: passnummer,
      configService: configService,
    );
  }

  Future<List<Gewinn>> fetchGewinne(
    int jahr,
    String passnummer,
    ConfigService configService,
  ) async {
    return _oktoberfestService.fetchGewinne(
      jahr: jahr,
      passnummer: passnummer,
      configService: configService,
    );
  }

  // Bezirke Service
  Future<List<Bezirk>> fetchBezirke() async {
    return _bezirkService.fetchBezirke();
  }

  Future<List<Bezirk>> fetchBezirk(
    int bezirkNr,
  ) async {
    return _bezirkService.fetchBezirk(
      bezirkNr,
    );
  }

  Future<List<BezirkSearchTriple>> fetchBezirkeforSearch() async {
    return _bezirkService.fetchBezirkeforSearch();
  }

  // Email validation methods
  Future<void> createEmailValidationEntry({
    required String personId,
    required String email,
    required String emailType,
    required String verificationToken,
  }) async {
    return _postgrestService.createEmailValidationEntry(
      personId: personId,
      email: email,
      emailType: emailType,
      verificationToken: verificationToken,
    );
  }

  Future<Map<String, dynamic>?> getEmailValidationByToken(String token) async {
    return _postgrestService.getEmailValidationByToken(token);
  }

  Future<bool> markEmailValidationAsValidated(String verificationToken) async {
    return _postgrestService.markEmailValidationAsValidated(verificationToken);
  }

  Future<void> sendEmailValidationNotifications({
    required String personId,
    required String email,
    required String firstName,
    required String lastName,
    required String title,
    required String emailType,
    required String verificationToken,
  }) async {
    return _emailService.sendEmailValidationNotifications(
      personId: personId,
      email: email,
      firstName: firstName,
      lastName: lastName,
      title: title,
      emailType: emailType,
      verificationToken: verificationToken,
    );
  }

  Future<void> sendStartingRightsChangeNotifications({
    required int personId,
  }) async {
    try {
      // 1. Get pass data from ZMI API
      final passdaten = await fetchPassdaten(personId);
      if (passdaten == null) {
        LoggerService.logError('Could not fetch Passdaten from ZMI for person $personId');
        return;
      }

      // 2. Get user's email addresses
      final userEmailAddresses = (await _emailService.getEmailAddressesByPersonId(personId.toString())).toSet().toList();

      // 3. Get ERSTVEREINNR from pass data
      final erstVereinNr = passdaten.vereinNr;
      
      // 4. Get secondary club memberships
      final zweitmitgliedschaften = await fetchZweitmitgliedschaften(personId);
      
      // 5. Get ZVE data (Zweitvereine with disciplines)
      final zveData = await fetchPassdatenAkzeptierterOderAktiverPass(personId);
      
      // 6. Collect all club numbers (first club + secondary clubs)
      final vereinNumbers = <int>[];
      vereinNumbers.add(erstVereinNr);
      for (final membership in zweitmitgliedschaften) {
        final vereinNr = membership.vereinNr;
        vereinNumbers.add(vereinNr);
      }

      // 7. Get email addresses from all clubs
      final clubEmailAddresses = <String>[];
      for (final vereinNr in vereinNumbers) {
        final vereinData = await fetchVerein(vereinNr);
        if (vereinData.isEmpty) {
          continue;
        }
        final email = vereinData[0].email;
        final pEmail = vereinData[0].pEmail;
        
        if (email != null && email.isNotEmpty && email != 'null') {
          clubEmailAddresses.add(email);
        }
        if (pEmail != null && pEmail.isNotEmpty && pEmail != 'null') {
          clubEmailAddresses.add(pEmail);
        }
      }

      // 8. Send notifications
      await _emailService.sendStartingRightsChangeNotifications(
        personId: personId,
        passdaten: passdaten,
        userEmailAddresses: userEmailAddresses,
        clubEmailAddresses: clubEmailAddresses,
        zweitmitgliedschaften: zweitmitgliedschaften,
        zveData: zveData!,
      );

      LoggerService.logInfo('Starting rights change notifications sent for person $personId');
    } catch (e) {
      LoggerService.logError('Error sending starting rights change notifications: $e');
    }
  }
}
