/// Messages used throughout the application
class Messages {
  // Registration Screen Messages
  static const String registrationOfflineTitle =
      'Registrierung ist offline nicht verfügbar';
  static const String registrationOfflineMessage =
      'Bitte stellen Sie sicher, dass Sie mit dem Internet verbunden sind, um sich zu registrieren.';
  static const String firstNameRequired = 'Vorname ist erforderlich.';
  static const String lastNameRequired = 'Nachname ist erforderlich.';
  static const String emailRequired = 'E-Mail ist erforderlich.';

  static const String invalidEmail =
      'Bitte geben Sie eine gültige E-Mail Adresse ein.';
  static const String passNumberRequired =
      'Schützenausweisnummer ist erforderlich.';
  static const String invalidPassNumber =
      'Schützenausweisnummer muss 8 Ziffern enthalten.';
  static const String zipCodeRequired = 'Postleitzahl ist erforderlich.';
  static const String invalidZipCode = 'Postleitzahl muss 5 Ziffern enthalten.';
  static const String selectBirthDate = 'Wählen Sie Ihr Geburtsdatum';
  static const String privacyPolicyText =
      'Ich habe die Datenschutzbestimmungen gelesen und akzeptiere sie.';
  static const String privacyPolicyLinkText = 'Datenschutzbestimmungen';

  // Registration Process Messages
  static const String noPersonIdFound =
      'Keine PersonID gefunden. Bitte überprüfen Sie Ihre Schützenausweisnummer und versuchen Sie es erneut.';
  static const String configError =
      'Systemkonfigurationsfehler. Bitte kontaktieren Sie den Support.';
  static const String emailConfigError =
      'E-Mail-Konfigurationsfehler. Bitte kontaktieren Sie den Support.';
  static const String emailSentSuccess =
      'E-Mail wurde gesendet. Bitte folgen Sie den Anweisungen zur Registrierung Ihres Kontos.';
  static const String emailAlreadyRegistered =
      'Diese Person ist bereits mit einer anderen E-Mail-Adresse registriert.';
  static const String registrationDataStored =
      'Registrierungsdaten erfolgreich gespeichert';
  static const String registrationDataStoreFailed =
      'Fehler beim Speichern der Registrierungsdaten';
  static const String registrationDataNotFound =
      'Registrierungsdaten nicht gefunden. Bitte registrieren Sie sich erneut.';
  static const String registrationDataExpired =
      'Registrierungsdaten abgelaufen. Bitte registrieren Sie sich erneut.';
  static const String registrationDataAlreadyUsed =
      'Sie sind bereits registriert. Bitte melden Sie sich an.';
  static const String registrationDataNotVerified =
      'Registrierungsdaten nicht verifiziert. Bitte registrieren Sie sich erneut.';
  static const String registrationDataAlreadyExists =
      'Eine Registrierung für diese Schützenausweisnummer ist bereits in Bearbeitung. Bitte überprüfen Sie Ihre E-Mails oder warten Sie 24 Stunden, um es erneut zu versuchen.';
  static const String registrationOffline =
      'Registrierung ist offline nicht verfügbar. Bitte stellen Sie sicher, dass Sie mit dem Internet verbunden sind.';
  static const String registrationSuccess =
      'Registrierung erfolgreich. Bitte überprüfen Sie Ihre E-Mail für die Bestätigung.';

  // Password Setting Messages
  static const String passwordSetSuccess =
      'Passwort erfolgreich gesetzt! Sie können sich jetzt anmelden.';
  static const String passwordSetError = 'Fehler beim Setzen des Passworts.';
  static const String generalError =
      'Ein Fehler ist aufgetreten. Bitte versuchen Sie es später erneut.';
  static const String passwordRequired = 'Passwort ist erforderlich.';
  static const String passwordTooShort =
      'Passwort muss mindestens 8 Zeichen lang sein.';
  static const String passwordNoMatch = 'Passwörter stimmen nicht überein.';
  static const String confirmPasswordRequired =
      'Bitte bestätigen Sie Ihr Passwort.';

  static const String loginButtonLabel = 'Anmelden';
  static const String loginTitle = 'Anmeldung';
  static const String forgotPasswordLabel = 'Passwort vergessen?';
  static const String bankDataTitle = 'Bankdaten';
  static const String bankDataSubtitle = 'Bitte geben Sie Ihre Bankdaten ein';
  static const String ibanLabel = 'IBAN';
  static const String ibanRequired = 'Bitte geben Sie Ihre IBAN ein';
  static const String bicLabel = 'BIC';
  static const String bicRequired = 'Bitte geben Sie Ihre BIC ein';
  static const String kontoinhaberLabel = 'Kontoinhaber';
  static const String kontoinhaberRequired =
      'Bitte geben Sie den Kontoinhaber ein';
  static const String personalDataTitle = 'Persönliche Daten';
  static const String homeTitle = 'Home';
  static const String welcomeMessage = 'Willkommen';
  static const String checkPassNumberButtonLabel = 'Passnummer prüfen';
  static const String passwordResetTitle = 'Passwort zurücksetzen';
  static const String passwordResetSuccessTitle =
      'Passwort erfolgreich zurückgesetzt';
  static const String passwordResetSuccessMessage =
      'Sie können sich jetzt mit Ihrem neuen Passwort anmelden.';
  static const String backToLoginButtonLabel = 'Zurück zum Login';
  static const String passNumberLabel = 'Schützenausweisnummer';
  static const String resetPasswordButtonLabel = 'Passwort zurücksetzen';
  static const String logoutLabel = 'Abmelden';
  static const String registerButtonLabel = 'Registrieren';
  static const String registrationTitle = 'Registrierung';
  static const String cancelButtonLabel = 'Abbrechen';
  static const String deleteBankDataConfirmation =
      'Möchten Sie Ihre Bankdaten wirklich löschen?';
  static const String deleteButtonLabel = 'Löschen';
  static const String saveButtonLabel = 'Speichern';
  static const String savingLabel = 'Wird gespeichert...';

// Help screen
  static const String helpTitle = 'FAQ';

// Contact Data Screen
  static const String telefonLabel = 'Telefon';
  static const String telefonRequired =
      'Bitte geben Sie Ihre Telefonnummer ein';
  static const String mobilLabel = 'Mobil';
  static const String mobilRequired = 'Bitte geben Sie Ihre Mobilnummer ein';
  static const String emailLabel = 'E-Mail';
  static const String emailInvalid =
      'Bitte geben Sie eine gültige E-Mail-Adresse ein';
  static const String contactTypeLabel = 'Kontakttyp';
  static const String contactValueLabel = 'Kontaktwert';
  static const String deleteContactDataConfirmation =
      'Möchten Sie diese Kontaktdaten wirklich löschen?';

// Password Change Messages
  static const String passwordChangeSuccess = 'Passwort erfolgreich geändert';
  static const String passwordChangeError =
      'Fehler beim Ändern des Passworts: ';
  static const String currentPasswordIncorrect =
      'Das aktuelle Passwort ist nicht korrekt';
  static const String usernameNotFound = 'Benutzername nicht gefunden';
  static const String personIdMissing = 'Person ID is missing';

  // Settings Screen
  static const String settingsTitle = 'Einstellungen';
  static const String fontSizeTitle = 'Textgröße';
  static const String fontSizeDescription =
      'Anpassung der Textgröße für bessere Lesbarkeit';

  static const String firstNameLabel = 'Vorname';
  static const String lastNameLabel = 'Nachname';
  static const String clubLabel = 'Erstverein';
  static const String noPersonalDataAvailable =
      'Keine persönlichen Daten verfügbar.';
  static const String noPrimaryClubDataAvailable =
      'Keine Erstvereinsdaten verfügbar.';
  static const String noSecondaryClubsAvailable =
      'Keine Zweitvereine verfügbar.';
  static const String registrationSuccessTitle = 'Registrierung erfolgreich';
  static const String registrationSuccessMessage =
      'Ihre Registrierung war erfolgreich.';
  static const String contactDataDeleteTitle = 'Kontaktdaten löschen';
  static const String contactDataDeleteQuestion =
      'Sind Sie sicher, dass Sie die Kontaktdaten löschen möchten? ';
  static const String errorOccurred = 'Es ist ein Fehler aufgetreten.';
  static const String personalDataSaved =
      'Ihre persönlichen Daten wurden erfolgreich gespeichert.';

  // Cookie Consent
  static const String cookieConsentTitle = 'Wir verwenden Cookies';
  static const String cookieConsentMessage =
      'Um diese App offline nutzen zu können, verwenden wir Cookies.';
  static const String cookieSettingsButtonLabel = 'Einstellungen';
  static const String cookieAcceptAllButtonLabel = 'Alle akzeptieren';

  // API Error Messages
  static const String apiError = 'API-Fehler: ';
  static const String networkError = 'Netzwerkfehler: ';
  static const String serverError = 'Serverfehler: ';
  static const String accountCreationFailed =
      'Fehler beim Erstellen des Kontos. Bitte versuchen Sie es später erneut.';

  static const String startingRightsHeaderTooltip =
      'Hier finden Sie Ihren digitalen Schützenausweis mit Ihrem Erstverein und ggf. Zweitvereinen sowie den für Sie hinterlegten Startrechten. \nWurde ein Startrecht in einer Disziplin auf einen Zweitverein umgeschrieben, so finden Sie diese unter dem jeweiligen Zweitverein. \nFalls keine Disziplinen auf Zweitvereine umgeschrieben wurden, liegen alle Startrechte bei Ihrem Erstverein. \n\nSie können Ihre Startrechte jederzeit ändern. \nBitte beachten Sie, dass die beantragten Änderungen nicht während der laufenden Saison, sondern immer erst zum neuen Sportjahr aktiv werden. \nVorgemerkte Startrechte für das neue Sportjahr sind in der 2. Spalte ersichtlich. \n\nSollte ein Verein, in dem Sie Mitglied sind, in der Übersicht fehlen, so wurde dem BSSB die Mitgliedschaft noch nicht gemeldet. \nBitte wenden Sie sich in diesem Fall an die Mitgliederverwaltung des betroffenen Vereins.';
}
