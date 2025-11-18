import 'dart:async';

import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/core/logger_service.dart';

class StartingRightsService {
  StartingRightsService({
    ApiService? apiService,
  }) : _apiService = apiService;

  ApiService? _apiService;

  /// Sets the ApiService instance.
  /// This is used to break the circular dependency during initialization.
  void setApiService(ApiService apiService) {
    _apiService = apiService;
  }

  /// Sends starting rights change notifications to user and club email addresses
  Future<void> sendStartingRightsChangeNotifications({
    required int personId,
  }) async {
    if (_apiService == null) {
      LoggerService.logError('ApiService is not initialized');
      return;
    }
    try {
      // 1. Get pass data from ZMI API
      final passdaten = await _apiService!.fetchPassdaten(personId);
      if (passdaten == null) {
        LoggerService.logError('Could not fetch Passdaten from ZMI for person $personId');
        return;
      }

      // 2. Get user's email addresses
      final userEmailAddresses = (await _apiService!.getEmailAddressesByPersonId(personId.toString())).toSet().toList();

      // 3. Get ERSTVEREINNR from pass data
      final erstVereinId = passdaten.erstVereinId;
      
      // 4. Get secondary club memberships
      final zweitmitgliedschaften = await _apiService!.fetchZweitmitgliedschaften(personId);
      
      // 5. Get ZVE data (Zweitvereine with disciplines)
      final zveData = await _apiService!.fetchPassdatenAkzeptierterOderAktiverPass(personId);
      
      // 6. Collect all club numbers (first club + secondary clubs)
      final vereinIds = <int>[];
      vereinIds.add(erstVereinId);
      for (final membership in zweitmitgliedschaften) {
        final vereinId = membership.vereinId;
        vereinIds.add(vereinId);
      }

      // 7. Get email addresses from all clubs
      final clubEmailAddresses = <String>[];
      for (final vereinId in vereinIds) {
        var vereinData = await _apiService!.fetchVereinFunktionaer(vereinId, 1);
        if (vereinData.isEmpty) {
          vereinData = await _apiService!.fetchVereinFunktionaer(vereinId, 201);
        }
        if (vereinData.isEmpty) {
          continue;
        }
        final amtsEmail = vereinData[0]['AMTSEMAIL'] as String?;
        final emailList = vereinData[0]['EMAILLIST'] as String?;
        
        // Parse and add AMTSEMAIL addresses
        if (amtsEmail != null && amtsEmail.isNotEmpty && amtsEmail != 'null') {
          final parsedEmails = _parseEmailAddresses(amtsEmail);
          clubEmailAddresses.addAll(parsedEmails);
        }
        
        // Parse and add EMAILLIST addresses only if AMTSEMAIL is not empty
        if ((amtsEmail == null || amtsEmail.isEmpty) && emailList != null && emailList.isNotEmpty && emailList != 'null') {
          final parsedEmails = _parseEmailAddresses(emailList);
          clubEmailAddresses.addAll(parsedEmails);
        }
      }

      // 8. Send notifications
      await _apiService!.sendStartingRightsChangeNotifications(
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

  /// Parses email addresses from a string that may contain multiple emails
  /// separated by comma (,) or semicolon (;).
  /// Returns a list of valid email addresses.
  List<String> _parseEmailAddresses(String emailString) {
    final emails = <String>[];
    
    // Check if the string contains delimiters
    if (emailString.contains(',') || emailString.contains(';')) {
      // Split by both comma and semicolon
      final parts = emailString.split(RegExp(r'[,;]'));
      for (final part in parts) {
        final trimmedEmail = part.trim();
        if (trimmedEmail.isNotEmpty && trimmedEmail != 'null') {
          emails.add(trimmedEmail);
        }
      }
    } else {
      // Single email address
      final trimmedEmail = emailString.trim();
      if (trimmedEmail.isNotEmpty && trimmedEmail != 'null') {
        emails.add(trimmedEmail);
      }
    }
    
    return emails;
  }
}
