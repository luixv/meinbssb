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
import 'package:meinbssb/services/api/starting_rights_service.dart';

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
import 'package:meinbssb/models/schulungstermine_zusatzfelder_data.dart';
import 'package:meinbssb/models/beduerfnisse_auswahl_typ_data.dart';
import 'package:meinbssb/models/beduerfnisse_auswahl_data.dart';
import 'package:meinbssb/models/beduerfnisse_antrag_status_data.dart';
import 'package:meinbssb/models/beduerfnisse_antrag_data.dart';
import 'package:meinbssb/models/beduerfnisse_antrag_person_data.dart';

import 'core/cache_service.dart';
import 'core/config_service.dart';
import 'core/http_client.dart';
import 'core/image_service.dart';
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
    required StartingRightsService startingRightsService,
  }) : _configService = configService,
       _imageService = imageService,
       _cacheService = cacheService,
       _networkService = networkService,
       _trainingService = trainingService,
       _userService = userService,
       _authService = authService,
       _bankService = bankService,
       _vereinService = vereinService,
       _postgrestService = postgrestService,
       _emailService = emailService,
       _oktoberfestService = oktoberfestService,
       _bezirkService = bezirkService,
       _startingRightsService = startingRightsService;

  final ConfigService _configService;
  final ImageService _imageService;
  final CacheService _cacheService;
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
  StartingRightsService _startingRightsService;

  /// Sets the StartingRightsService instance.
  /// This is used to break the circular dependency during initialization.
  void setStartingRightsService(StartingRightsService service) {
    _startingRightsService = service;
  }

  Future<bool> hasInternet() => _networkService.hasInternet();

  ImageService get imageService => _imageService;
  ConfigService get configService => _configService;
  EmailService get emailService => _emailService;
  AuthService get authService => _authService;
  CacheService get cacheService => _cacheService;

  Duration getCacheExpirationDuration() =>
      _networkService.getCacheExpirationDuration();

  //
  // --- Cache Service Methods ---
  //
  Future<String?> getCachedUsername() => _cacheService.getString('username');

  //
  // --- Image Service Methods --
  //
  Future<Uint8List?> fetchSchuetzenausweis(int personId) async {
    return _imageService.fetchAndCacheSchuetzenausweis(
      personId,
      getCacheExpirationDuration(),
    );
  }

  //
  // --- Auth Service Methods ---
  //
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String passNumber,
    required String email,
    required String personId,
  }) async {
    return _authService.register(
      firstName: firstName,
      lastName: lastName,
      passNumber: passNumber,
      email: email,
      personId: personId,
    );
  }

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

  Future<Map<String, dynamic>> myBSSBPasswortAendern(
    int personId,
    String newPassword,
  ) async {
    return _authService.myBSSBPasswortAendern(personId, newPassword);
  }

  //
  // --- User Service Methods ---
  //

  Future<String> findeLoginMail(String passNumber) async {
    return _authService.fetchLoginEmail(passNumber);
  }

  Future<UserData?> fetchPassdaten(int personId) async {
    return _userService.fetchPassdaten(personId);
  }

  Future<PassdatenAkzeptOrAktiv?> fetchPassdatenAkzeptierterOderAktiverPass(
    int? personId,
  ) async {
    return _userService.fetchPassdatenAkzeptierterOderAktiverPass(personId);
  }

  Future<bool> bssbAppPassantrag(
    List<Map<String, dynamic>> zves,
    int? passdatenId,
    int? personId,
    int? erstVereinId,
    int digitalerPass,
    int antragsTyp,
  ) async {
    return _userService.bssbAppPassantrag(
      zves,
      passdatenId,
      personId,
      erstVereinId,
      digitalerPass,
      antragsTyp,
    );
  }

  Future<List<PassDataZVE>> fetchPassdatenZVE(
    int passdatenId,
    int personId,
  ) async {
    return _userService.fetchPassdatenZVE(passdatenId, personId);
  }

  Future<bool> deleteMeinBSSBLogin(int webloginId) async {
    final email = await getCachedUsername();
    if (email == null) {
      throw ArgumentError('Cached username (email) must not be null');
    }
    return _userService.deleteMeinBSSBLogin(webloginId, email);
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

  Future<List<Map<String, dynamic>>> fetchKontakte(int personId) async {
    return _userService.fetchKontakte(personId);
  }

  Future<bool> addKontakt(Contact contact) async {
    return _userService.addKontakt(contact);
  }

  Future<bool> deleteKontakt(Contact contact) async {
    return _userService.deleteKontakt(contact);
  }

  /// Clears all passdaten caches
  Future<void> clearAllPassdatenCache() async {
    await _userService.clearAllPassdatenCache();
  }

  /// Clears the passdaten cache for a specific person
  Future<void> clearPassdatenCache(int personId) async {
    await _userService.clearPassdatenCache(personId);
  }

  Future<List<Person>> fetchAdresseVonPersonID(int personId) async {
    return _userService.fetchAdresseVonPersonID(personId);
  }

  //
  // --- Training Service Methods ---
  //
  Future<List<Schulung>> fetchAbsolvierteSchulungen(int personId) async {
    return _trainingService.fetchAbsolvierteSchulungen(personId);
  }

  Future<List<Schulungsart>> fetchSchulungsarten() async {
    return _trainingService.fetchSchulungsarten();
  }

  Future<List<Schulungstermin>> fetchAngemeldeteSchulungen(
    int personId,
    String abDatum,
  ) async {
    return _trainingService.fetchAngemeldeteSchulungen(personId, abDatum);
  }

  Future<bool> isRegisterForThisSchulung(
    int personId,
    int schulungsterminId,
  ) async {
    return _trainingService.isRegisterForThisSchulung(
      personId,
      schulungsterminId,
    );
  }

  Future<List<SchulungstermineZusatzfelder>> fetchSchulungstermineZusatzfelder(
    int schulungsTerminId,
  ) async {
    return _trainingService.fetchSchulungstermineZusatzfelder(
      schulungsTerminId,
    );
  }

  Future<int> findePersonID2(String name, String passnummer) async {
    return _authService.findePersonID2(name, passnummer);
  }

  Future<int> findePersonIDSimple(
    String name,
    String nachname,
    String passnummer,
  ) async {
    return _authService.findePersonIDSimple(name, nachname, passnummer);
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

  Future<void> clearAllSchulungenCache() async {
    await _trainingService.clearAllSchulungenCache();
  }

  Future<Schulungstermin?> fetchSchulungstermin(
    String schulungenTerminId,
  ) async {
    return _trainingService.fetchSchulungstermin(schulungenTerminId);
  }

  /// Clears the disziplinen cache
  Future<void> clearDisziplinenCache() async {
    await _trainingService.clearDisziplinenCache();
  }

  Future<RegisterSchulungenTeilnehmerResponse> registerSchulungenTeilnehmer({
    required int schulungTerminId,
    required UserData user,
    required String email,
    required String telefon,
    required BankData bankData,
    required List<Map<String, dynamic>> felderArray,
    required String angemeldetUeber,
    required String angemeldetUeberEmail,
    required String angemeldetUeberTelefon,
  }) async {
    return _trainingService.registerSchulungenTeilnehmer(
      schulungTerminId: schulungTerminId,
      user: user,
      email: email,
      telefon: telefon,
      bankData: bankData,
      felderArray: felderArray,
      angemeldetUeber: angemeldetUeber,
      angemeldetUeberEmail: angemeldetUeberEmail,
      angemeldetUeberTelefon: angemeldetUeberTelefon,
    );
  }

  /// Clears the schulungen cache for a specific person
  Future<void> clearSchulungenCache(int personId) async {
    await _trainingService.clearSchulungenCache(personId);
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

  //
  // --- Bank Service Methods ---
  //
  Future<List<BankData>> fetchBankdatenMyBSSB(int webloginId) async {
    return _bankService.fetchBankdatenMyBSSB(webloginId);
  }

  bool validateIBAN(String? iban) {
    return BankService.validateIBAN(iban);
  }

  String? validateBIC(String? bic) {
    return BankService.validateBIC(bic);
  }

  Future<bool> registerBankData(BankData bankData) async {
    return _bankService.registerBankData(bankData);
  }

  Future<bool> deleteBankData(BankData bankData) async {
    return _bankService.deleteBankData(bankData);
  }

  //
  // --- Verein Service Methods ---
  //
  /// Fetches a list of all Vereine (clubs/associations).
  /// Returns a list of [Verein] objects containing basic club information.
  Future<List<Verein>> fetchVereine() async {
    return await _vereinService.fetchVereine();
  }

  Future<List<Map<String, dynamic>>> fetchVereinFunktionaer(
    int vereinId,
    int funktyp,
  ) async {
    return await _vereinService.fetchVereinFunktionaer(vereinId, funktyp);
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

  //
  // --- Postgrest Service methods ---
  //
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

  Future<Map<String, dynamic>?> getUserByPasswordResetVerificationToken(
    String token,
  ) async {
    return _postgrestService.getUserByPasswordResetVerificationToken(token);
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

  Future<bool> softDeleteUser(String personId) async {
    return _postgrestService.softDeleteUser(personId);
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

  //
  // --- Email Service Methods ---
  //

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

  Future<List<String>> getEmailAddressesByPersonId(String personId) async {
    return _emailService.getEmailAddressesByPersonId(personId);
  }

  Future<void> sendStartingRightsChangeNotifications({
    required int personId,
    required UserData passdaten,
    required List<String> userEmailAddresses,
    required List<String> clubEmailAddresses,
    required List<ZweitmitgliedschaftData> zweitmitgliedschaften,
    required PassdatenAkzeptOrAktiv zveData,
  }) async {
    return _emailService.sendStartingRightsChangeNotifications(
      personId: personId,
      passdaten: passdaten,
      userEmailAddresses: userEmailAddresses,
      clubEmailAddresses: clubEmailAddresses,
      zweitmitgliedschaften: zweitmitgliedschaften,
      zveData: zveData,
    );
  }

  //
  // --- Oktoberfest Service Methods ---
  //
  Future<List<Result>> fetchResults(String passnummer) async {
    return _oktoberfestService.fetchResults(
      passnummer: passnummer,
      configService: _configService,
    );
  }

  Future<List<Gewinn>> fetchGewinne(int jahr, String passnummer) async {
    return _oktoberfestService.fetchGewinne(
      jahr: jahr,
      passnummer: passnummer,
      configService: _configService,
    );
  }

  Future<List<Gewinn>> fetchGewinneEx(int jahr, String passnummer) async {
    return _oktoberfestService.fetchGewinneEx(
      jahr: jahr,
      passnummer: passnummer,
      configService: _configService,
    );
  }

  Future<bool> gewinneAbrufen({
    required List<int> gewinnIDs,
    required String iban,
    required String passnummer,
  }) async {
    return _oktoberfestService.gewinneAbrufen(
      gewinnIDs: gewinnIDs,
      iban: iban,
      passnummer: passnummer,
      configService: _configService,
    );
  }

  Future<bool> gewinneAbrufenEx({
    required List<int> gewinnIDs,
    required String iban,
    required String passnummer,
  }) async {
    return _oktoberfestService.gewinneAbrufenEx(
      gewinnIDs: gewinnIDs,
      iban: iban,
      passnummer: passnummer,
      configService: _configService,
    );
  }

  //
  // --- Bezirke Service Methods ---
  //
  Future<List<Bezirk>> fetchBezirke() async {
    return _bezirkService.fetchBezirke();
  }

  Future<List<Bezirk>> fetchBezirk(int bezirkNr) async {
    return _bezirkService.fetchBezirk(bezirkNr);
  }

  Future<List<BezirkSearchTriple>> fetchBezirkeforSearch() async {
    return _bezirkService.fetchBezirkeforSearch();
  }

  Future<void> sendStartingRightsChangeNotificationsForPerson({
    required int personId,
  }) async {
    return _startingRightsService.sendStartingRightsChangeNotifications(
      personId: personId,
    );
  }

  //
  // --- bed_auswahl_typ Service Methods ---
  //

  Future<BeduerfnisseAuswahlTyp> createBedAuswahlTyp({
    required String kuerzel,
    required String beschreibung,
  }) async {
    return _postgrestService.createBedAuswahlTyp(kuerzel: kuerzel, beschreibung: beschreibung);
  }

  Future<List<BeduerfnisseAuswahlTyp>> getBedAuswahlTypen() async {
    return _postgrestService.getBedAuswahlTypen();
  }

  Future<BeduerfnisseAuswahlTyp?> getBedAuswahlTypById(int id) async {
    return _postgrestService.getBedAuswahlTypById(id);
  }

  Future<bool> updateBedAuswahlTyp(int id, Map<String, dynamic> data) async {
    return _postgrestService.updateBedAuswahlTyp(id, data);
  }

  Future<bool> deleteBedAuswahlTyp(int id) async {
    return _postgrestService.deleteBedAuswahlTyp(id);
  }

  //
  // --- bed_auswahl Service Methods ---
  //

  Future<BeduerfnisseAuswahl> createBedAuswahl({
    required int typId,
    required String kuerzel,
    required String beschreibung,
  }) async {
    return _postgrestService.createBedAuswahl(
      typId: typId,
      kuerzel: kuerzel,
      beschreibung: beschreibung,
    );
  }

  Future<List<BeduerfnisseAuswahl>> getBedAuswahlList() async {
    return _postgrestService.getBedAuswahlList();
  }

  Future<List<BeduerfnisseAuswahl>> getBedAuswahlByTypId(int typId) async {
    return _postgrestService.getBedAuswahlByTypId(typId);
  }

  Future<BeduerfnisseAuswahl?> getBedAuswahlById(int id) async {
    return _postgrestService.getBedAuswahlById(id);
  }

  Future<bool> updateBedAuswahl(int id, Map<String, dynamic> data) async {
    return _postgrestService.updateBedAuswahl(id, data);
  }

  Future<bool> deleteBedAuswahl(int id) async {
    return _postgrestService.deleteBedAuswahl(id);
  }

  //
  // --- bed_datei Service Methods ---
  //

  Future<Map<String, dynamic>> createBedDatei({
    required String antragsnummer,
    required String dateiname,
    required List<int> fileBytes,
  }) async {
    return _postgrestService.createBedDatei(
      antragsnummer: antragsnummer,
      dateiname: dateiname,
      fileBytes: fileBytes,
    );
  }

  Future<List<Map<String, dynamic>>> getBedDateiByAntragsnummer(
    String antragsnummer,
  ) async {
    return _postgrestService.getBedDateiByAntragsnummer(antragsnummer);
  }

  Future<Map<String, dynamic>?> getBedDateiById(int id) async {
    return _postgrestService.getBedDateiById(id);
  }

  Future<bool> updateBedDatei(int id, Map<String, dynamic> data) async {
    return _postgrestService.updateBedDatei(id, data);
  }

  Future<bool> deleteBedDatei(int id) async {
    return _postgrestService.deleteBedDatei(id);
  }

  //
  // --- bed_sport Service Methods ---
  //

  Future<Map<String, dynamic>> createBedSport({
    required String antragsnummer,
    required String schiessdatum,
    required int waffenartId,
    required int disziplinId,
    required bool training,
    int? wettkampfartId,
    double? wettkampfergebnis,
  }) async {
    return _postgrestService.createBedSport(
      antragsnummer: antragsnummer,
      schiessdatum: schiessdatum,
      waffenartId: waffenartId,
      disziplinId: disziplinId,
      training: training,
      wettkampfartId: wettkampfartId,
      wettkampfergebnis: wettkampfergebnis,
    );
  }

  Future<List<Map<String, dynamic>>> getBedSportByAntragsnummer(
    String antragsnummer,
  ) async {
    return _postgrestService.getBedSportByAntragsnummer(antragsnummer);
  }

  Future<Map<String, dynamic>?> getBedSportById(int id) async {
    return _postgrestService.getBedSportById(id);
  }

  Future<bool> updateBedSport(int id, Map<String, dynamic> data) async {
    return _postgrestService.updateBedSport(id, data);
  }

  Future<bool> deleteBedSport(int id) async {
    return _postgrestService.deleteBedSport(id);
  }

  //
  // --- bed_waffe_besitz Service Methods ---
  //

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
    return _postgrestService.createBedWaffeBesitz(
      antragsnummer: antragsnummer,
      wbkNr: wbkNr,
      lfdWbk: lfdWbk,
      waffenartId: waffenartId,
      hersteller: hersteller,
      kaliberId: kaliberId,
      lauflaengeId: lauflaengeId,
      gewicht: gewicht,
      kompensator: kompensator,
      beduerfnisgrundId: beduerfnisgrundId,
      verbandId: verbandId,
      bemerkung: bemerkung,
    );
  }

  Future<List<Map<String, dynamic>>> getBedWaffeBesitzByAntragsnummer(
    String antragsnummer,
  ) async {
    return _postgrestService.getBedWaffeBesitzByAntragsnummer(antragsnummer);
  }

  Future<Map<String, dynamic>?> getBedWaffeBesitzById(int id) async {
    return _postgrestService.getBedWaffeBesitzById(id);
  }

  Future<bool> updateBedWaffeBesitz(int id, Map<String, dynamic> data) async {
    return _postgrestService.updateBedWaffeBesitz(id, data);
  }

  Future<bool> deleteBedWaffeBesitz(int id) async {
    return _postgrestService.deleteBedWaffeBesitz(id);
  }

  //
  // --- bed_antrag_status Service Methods ---
  //

  Future<BeduerfnisseAntragStatus> createBedAntragStatus({
    required String status,
    String? beschreibung,
  }) async {
    return _postgrestService.createBedAntragStatus(
      status: status,
      beschreibung: beschreibung,
    );
  }

  Future<List<BeduerfnisseAntragStatus>> getBedAntragStatusList() async {
    return _postgrestService.getBedAntragStatusList();
  }

  Future<BeduerfnisseAntragStatus?> getBedAntragStatusById(int id) async {
    return _postgrestService.getBedAntragStatusById(id);
  }

  Future<BeduerfnisseAntragStatus?> getBedAntragStatusByStatus(
    String status,
  ) async {
    return _postgrestService.getBedAntragStatusByStatus(status);
  }

  Future<bool> updateBedAntragStatus(int id, Map<String, dynamic> data) async {
    return _postgrestService.updateBedAntragStatus(id, data);
  }

  Future<bool> deleteBedAntragStatus(int id) async {
    return _postgrestService.deleteBedAntragStatus(id);
  }

  //
  // --- bed_antrag Service Methods ---
  //

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
    return _postgrestService.createBedAntrag(
      antragsnummer: antragsnummer,
      personId: personId,
      statusId: statusId,
      wbkNeu: wbkNeu,
      wbkArt: wbkArt,
      beduerfnisart: beduerfnisart,
      anzahlWaffen: anzahlWaffen,
      vereinGenehmigt: vereinGenehmigt,
      email: email,
      bankdaten: bankdaten,
      abbuchungErfolgt: abbuchungErfolgt,
      bemerkung: bemerkung,
    );
  }

  Future<List<BeduerfnisseAntrag>> getBedAntragList() async {
    return _postgrestService.getBedAntragList();
  }

  Future<List<BeduerfnisseAntrag>> getBedAntragByAntragsnummer(
    String antragsnummer,
  ) async {
    return _postgrestService.getBedAntragByAntragsnummer(antragsnummer);
  }

  Future<List<BeduerfnisseAntrag>> getBedAntragByPersonId(int personId) async {
    return _postgrestService.getBedAntragByPersonId(personId);
  }

  Future<List<BeduerfnisseAntrag>> getBedAntragByStatusId(int statusId) async {
    return _postgrestService.getBedAntragByStatusId(statusId);
  }

  Future<BeduerfnisseAntrag?> getBedAntragById(int id) async {
    return _postgrestService.getBedAntragById(id);
  }

  Future<bool> updateBedAntrag(int id, Map<String, dynamic> data) async {
    return _postgrestService.updateBedAntrag(id, data);
  }

  Future<bool> deleteBedAntrag(int id) async {
    return _postgrestService.deleteBedAntrag(id);
  }

  //
  // --- bed_antrag_person Service Methods ---
  //

  Future<BeduerfnisseAntragPerson> createBedAntragPerson({
    required String antragsnummer,
    required int personId,
    int? statusId,
    String? vorname,
    String? nachname,
    String? vereinsname,
  }) async {
    return _postgrestService.createBedAntragPerson(
      antragsnummer: antragsnummer,
      personId: personId,
      statusId: statusId,
      name: vorname,
      nachname: nachname,
      vereinsname: vereinsname,
    );
  }

  Future<List<BeduerfnisseAntragPerson>> getBedAntragPersonByAntragsnummer(
    String antragsnummer,
  ) async {
    return _postgrestService.getBedAntragPersonByAntragsnummer(antragsnummer);
  }

  Future<List<BeduerfnisseAntragPerson>> getBedAntragPersonByPersonId(
    int personId,
  ) async {
    return _postgrestService.getBedAntragPersonByPersonId(personId);
  }

  Future<bool> updateBedAntragPerson(
    BeduerfnisseAntragPerson bedAntragPerson,
  ) async {
    return _postgrestService.updateBedAntragPerson(bedAntragPerson);
  }
}
