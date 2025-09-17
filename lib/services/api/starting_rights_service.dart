import 'dart:async';

import 'package:meinbssb/services/api/user_service.dart';
import 'package:meinbssb/services/api/verein_service.dart';
import 'package:meinbssb/services/core/email_service.dart';
import 'package:meinbssb/services/core/logger_service.dart';

class StartingRightsService {
  StartingRightsService({
    required UserService userService,
    required VereinService vereinService,
    required EmailService emailService,
  })  : _userService = userService,
        _vereinService = vereinService,
        _emailService = emailService;

  final UserService _userService;
  final VereinService _vereinService;
  final EmailService _emailService;

  /// Sends starting rights change notifications to user and club email addresses
  Future<void> sendStartingRightsChangeNotifications({
    required int personId,
  }) async {
    try {
      // 1. Get pass data from ZMI API
      final passdaten = await _userService.fetchPassdaten(personId);
      if (passdaten == null) {
        LoggerService.logError('Could not fetch Passdaten from ZMI for person $personId');
        return;
      }

      // 2. Get user's email addresses
      final userEmailAddresses = (await _emailService.getEmailAddressesByPersonId(personId.toString())).toSet().toList();

      // 3. Get ERSTVEREINNR from pass data
      final erstVereinNr = passdaten.vereinNr;
      
      // 4. Get secondary club memberships
      final zweitmitgliedschaften = await _userService.fetchZweitmitgliedschaften(personId);
      
      // 5. Get ZVE data (Zweitvereine with disciplines)
      final zveData = await _userService.fetchPassdatenAkzeptierterOderAktiverPass(personId);
      
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
        final vereinData = await _vereinService.fetchVerein(vereinNr);
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
