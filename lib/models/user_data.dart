import 'package:flutter/foundation.dart';

/// Represents the complete user data for a BSSB member.
/// This model encapsulates all user-related information including personal data,
/// contact information, and authentication details.
@immutable
class UserData {
  /// Creates a [UserData] instance from a JSON map.
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      passnummer: json['PASSNUMMER']?.toString() ?? '',
      vereinNr: (json['VEREINNR'] is int) ? json['VEREINNR'] as int : 0,
      namen: json['NAMEN']?.toString() ?? '',
      vorname: json['VORNAME']?.toString() ?? '',
      titel: json['TITEL']?.toString(),
      geburtsdatum: json['GEBURTSDATUM'] != null
          ? DateTime.parse(json['GEBURTSDATUM'])
          : null,
      geschlecht: json['GESCHLECHT'] as int?,
      vereinName: json['VEREINNAME']?.toString() ?? '',
      passdatenId: json['PASSDATENID'] as int? ?? 0,
      mitgliedschaftId: json['MITGLIEDSCHAFTID'] as int? ?? 0,
      personId: json['PERSONID'] as int? ?? 0,
      strasse: json['STRASSE']?.toString(),
      plz: json['PLZ']?.toString(),
      ort: json['ORT']?.toString(),
      webLoginId: (json['WEBLOGINID'] is int) ? json['WEBLOGINID'] as int : 0,
      isOnline: json['ONLINE'] as bool? ?? false,
      disziplin: json['DISZIPLIN']?.toString(),
    );
  }

  /// Creates a new instance of [UserData].
  const UserData({
    required this.personId,
    required this.webLoginId,
    required this.passnummer,
    required this.vereinNr,
    required this.namen,
    required this.vorname,
    this.titel,
    this.geburtsdatum,
    this.geschlecht,
    required this.vereinName,
    required this.passdatenId,
    required this.mitgliedschaftId,
    this.strasse,
    this.plz,
    this.ort,
    this.land = '',
    this.nationalitaet = '',
    this.passStatus = 0,
    this.eintrittVerein,
    this.austrittVerein,
    this.telefon = '',
    this.erstLandesverbandId = 0,
    this.produktionsDatum,
    this.erstVereinId = 0,
    this.digitalerPass = 0,
    this.isOnline = false,
    this.disziplin,
  });

  /// The unique identifier for the person.
  final int personId;

  /// The web login identifier.
  final int webLoginId;

  /// The pass number of the member.
  final String passnummer;

  /// The club number.
  final int vereinNr;

  /// The last name of the member.
  final String namen;

  /// The first name of the member.
  final String vorname;

  /// The title of the member (e.g., Dr., Prof.).
  final String? titel;

  /// The birth date of the member.
  final DateTime? geburtsdatum;

  /// The gender of the member (1 = male, 2 = female).
  final int? geschlecht;

  /// The name of the club.
  final String vereinName;

  /// The street address of the member.
  final String? strasse;

  /// The postal code of the member.
  final String? plz;

  /// The city of the member.
  final String? ort;

  /// The country code of the member.
  final String land;

  /// The nationality of the member.
  final String nationalitaet;

  /// The status of the pass.
  final int passStatus;

  /// The ID of the pass data.
  final int passdatenId;

  /// The date when the member joined the club.
  final DateTime? eintrittVerein;

  /// The date when the member left the club.
  final DateTime? austrittVerein;

  /// The membership ID.
  final int mitgliedschaftId;

  /// The phone number of the member.
  final String telefon;

  /// The ID of the first state association.
  final int erstLandesverbandId;

  /// The production date of the pass.
  final DateTime? produktionsDatum;

  /// The ID of the first club.
  final int erstVereinId;

  /// Whether the member has a digital pass.
  final int digitalerPass;

  /// Whether the data was fetched from online source.
  final bool isOnline;

  /// The discipline of the member.
  final String? disziplin;

  /// Converts the [UserData] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'PERSONID': personId,
      'WEBLOGINID': webLoginId,
      'PASSNUMMER': passnummer,
      'VEREINNR': vereinNr,
      'NAMEN': namen,
      'VORNAME': vorname,
      'TITEL': titel,
      'GEBURTSDATUM': geburtsdatum?.toIso8601String(),
      'GESCHLECHT': geschlecht,
      'VEREINNAME': vereinName,
      'STRASSE': strasse,
      'PLZ': plz,
      'ORT': ort,
      'LAND': land,
      'NATIONALITAET': nationalitaet,
      'PASSSTATUS': passStatus,
      'PASSDATENID': passdatenId,
      'EINTRITTVEREIN': eintrittVerein?.toIso8601String(),
      'AUSTRITTVEREIN': austrittVerein?.toIso8601String(),
      'MITGLIEDSCHAFTID': mitgliedschaftId,
      'TELEFON': telefon,
      'ERSTLANDESVERBANDID': erstLandesverbandId,
      'PRODUKTIONSDATUM': produktionsDatum?.toIso8601String(),
      'ERSTVEREINID': erstVereinId,
      'DIGITALERPASS': digitalerPass,
      'ONLINE': isOnline,
      'DISZIPLIN': disziplin,
    };
  }

  /// Creates a copy of this [UserData] with the given fields replaced with the new values.
  UserData copyWith({
    int? personId,
    int? webLoginId,
    String? passnummer,
    int? vereinNr,
    String? namen,
    String? vorname,
    String? titel,
    DateTime? geburtsdatum,
    int? geschlecht,
    String? vereinName,
    String? strasse,
    String? plz,
    String? ort,
    String? land,
    String? nationalitaet,
    int? passStatus,
    int? passdatenId,
    DateTime? eintrittVerein,
    DateTime? austrittVerein,
    int? mitgliedschaftId,
    String? telefon,
    int? erstLandesverbandId,
    DateTime? produktionsDatum,
    int? erstVereinId,
    int? digitalerPass,
    bool? isOnline,
    String? disziplin,
  }) {
    return UserData(
      personId: personId ?? this.personId,
      webLoginId: webLoginId ?? this.webLoginId,
      passnummer: passnummer ?? this.passnummer,
      vereinNr: vereinNr ?? this.vereinNr,
      namen: namen ?? this.namen,
      vorname: vorname ?? this.vorname,
      titel: titel ?? this.titel,
      geburtsdatum: geburtsdatum ?? this.geburtsdatum,
      geschlecht: geschlecht ?? this.geschlecht,
      vereinName: vereinName ?? this.vereinName,
      strasse: strasse ?? this.strasse,
      plz: plz ?? this.plz,
      ort: ort ?? this.ort,
      land: land ?? this.land,
      nationalitaet: nationalitaet ?? this.nationalitaet,
      passStatus: passStatus ?? this.passStatus,
      passdatenId: passdatenId ?? this.passdatenId,
      eintrittVerein: eintrittVerein ?? this.eintrittVerein,
      austrittVerein: austrittVerein ?? this.austrittVerein,
      mitgliedschaftId: mitgliedschaftId ?? this.mitgliedschaftId,
      telefon: telefon ?? this.telefon,
      erstLandesverbandId: erstLandesverbandId ?? this.erstLandesverbandId,
      produktionsDatum: produktionsDatum ?? this.produktionsDatum,
      erstVereinId: erstVereinId ?? this.erstVereinId,
      digitalerPass: digitalerPass ?? this.digitalerPass,
      isOnline: isOnline ?? this.isOnline,
      disziplin: disziplin ?? this.disziplin,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserData &&
        other.personId == personId &&
        other.webLoginId == webLoginId &&
        other.passnummer == passnummer &&
        other.vereinNr == vereinNr &&
        other.namen == namen &&
        other.vorname == vorname &&
        other.titel == titel &&
        other.geburtsdatum == geburtsdatum &&
        other.geschlecht == geschlecht &&
        other.vereinName == vereinName &&
        other.strasse == strasse &&
        other.plz == plz &&
        other.ort == ort &&
        other.land == land &&
        other.nationalitaet == nationalitaet &&
        other.passStatus == passStatus &&
        other.passdatenId == passdatenId &&
        other.eintrittVerein == eintrittVerein &&
        other.austrittVerein == austrittVerein &&
        other.mitgliedschaftId == mitgliedschaftId &&
        other.telefon == telefon &&
        other.erstLandesverbandId == erstLandesverbandId &&
        other.produktionsDatum == produktionsDatum &&
        other.erstVereinId == erstVereinId &&
        other.digitalerPass == digitalerPass &&
        other.isOnline == isOnline &&
        other.disziplin == disziplin;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      personId,
      webLoginId,
      passnummer,
      vereinNr,
      namen,
      vorname,
      titel,
      geburtsdatum,
      geschlecht,
      vereinName,
      strasse,
      plz,
      ort,
      land,
      nationalitaet,
      passStatus,
      passdatenId,
      eintrittVerein,
      austrittVerein,
      mitgliedschaftId,
      telefon,
      erstLandesverbandId,
      produktionsDatum,
      erstVereinId,
      digitalerPass,
      isOnline,
      disziplin,
    ]);
  }

  @override
  String toString() {
    return 'UserData(personId: $personId, webLoginId: $webLoginId, passnummer: $passnummer, vereinNr: $vereinNr, namen: $namen, vorname: $vorname, titel: $titel, geburtsdatum: $geburtsdatum, geschlecht: $geschlecht, vereinName: $vereinName, strasse: $strasse, plz: $plz, ort: $ort, land: $land, nationalitaet: $nationalitaet, passStatus: $passStatus, passdatenId: $passdatenId, eintrittVerein: $eintrittVerein, austrittVerein: $austrittVerein, mitgliedschaftId: $mitgliedschaftId, telefon: $telefon, erstLandesverbandId: $erstLandesverbandId, produktionsDatum: $produktionsDatum, erstVereinId: $erstVereinId, digitalerPass: $digitalerPass, isOnline: $isOnline, disziplin: $disziplin)';
  }
}
