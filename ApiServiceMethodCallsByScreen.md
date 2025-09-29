# API Service Method Calls by Screen File

This document lists the Dart/Flutter screen files (from the `../lib/screens` folder) and the associated API service methods used in each file.

| Nr. | Screen File                                | Used API Service Methods                                                                                                                                   |
|-----|---------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 1   | `absolvierte_schulungen_screen.dart`        | AbsolvierteSchulungen                                                                                                                                       |
| 2   | `ausweis_bestellen_screen.dart`             | bssbAppPassantrag                                                                                                                                            |
| 3   | `bank_data_screen.dart`                     | BankData(webloginId)                                                                                                                                        |
| 4   | `change_password_screen.dart`               | login, myBSSBPasswortAendern                                                                                                                                |
| 5   | `contact_data_screen.dart`                  | Kontakte, KontaktAendern, KontaktHinzufuegen                                                                                                                |
| 6   | `email_verification_screen.dart`            | KontaktHinzufuegen                                                                                                                                          |
| 7   | `login_screen.dart`                         | Passdaten, Schuetzenausweis                                                                                                                                 |
| 8   | `oktoberfest_gewinn_screen.dart`            | BankData                                                                                                                                                    |
| 9   | `oktoberfest_results_screen.dart`           | results                                                                                                                                                     |
| 10  | `password_reset_screen.dart`                | PersonID, FindeMailadressen                                                                                                                                 |
| 11  | `personal_data_screen.dart`                 | Passdaten, KritischeFelderUndAdresse                                                                                                                        |
| 12  | `personal_pict_upload_screen.dart`          | `apiService.getProfilePhoto(userId)`, `apiService.uploadProfilePhoto(userId, imageBytes)`, `apiService.deleteProfilePhoto(userId)`                         |
| 13  | `registration_screen.dart`                  | findePersonID, ErstelleMyBSSBAccount *(uses AuthService)*                                                                                                   |
| 14  | `reset_password_screen.dart`                | MyBSSBPasswortAendern                                                                                                                                       |
| 15  | `schuetzenausweis_screen.dart`              | Schuetzenausweis                                                                                                                                            |
| 16  | `schulungen_screen.dart`                    | Schulungstermine, BankData, Kontakte, Schulungstermin, Passdaten                                                                                           |
| 17  | `set_password_screen.dart`                  | ErstelleMyBSSBAccount *(uses AuthService)*                                                                                                                  |
| 18  | `splash_screen.dart`                        | Bezirke, Disziplinen                                                                                                                                        |
| 19  | `start_screen.dart`                         | `apiService.getProfilePhoto(personId)`, AngemeldeteSchulungen, SchulungenTeilnehmer, FindeMailadressen, Schulungstermin                                   |
| 20  | `starting_rights_screen.dart`               | bssbAppPassantrag, Passdaten, FindeMailadressen, Disziplinen, PassdatenZVE, PassdatenAkzeptierterOderAktiverPass, ZweitmitgliedschaftenZVE                |
| 21  | `schulungen_details_dialog.dart`            | AngemeldeteSchulungen                                                                                                                                       |
| 22  | `schulungen_register_person_dialog.dart`    | SchulungstermineZusatzfelder, findePersonID2, SchulungenTeilnehmer                                                                                          |
| 23  | `schulungen_search_screen.dart`             | Bezirke                                                                                                                                                     |
