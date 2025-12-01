import 'package:meinbssb/helpers/utils.dart';

class PassData {
  factory PassData.fromJson(Map<String, dynamic> json) {
    return PassData(
      personId: json['PERSONID'] as int,
      passnummer: json['PASSNUMMER'] as String?,
      vereinNr: json['VEREINNR'] as int?,
      vereinName: json['VEREINNAME'] as String?,
      passdatenId: json['PASSDATENID'] as int?,
      mitgliedschaftId: json['MITGLIEDSCHAFTID'] as int?,
      geburtsdatum:
          json['GEBURTSDATUM'] != null ? parseDate(json['GEBURTSDATUM']) : null,
      titel: json['TITEL'] as String?,
      vorname: json['VORNAME'] as String?,
      namen: json['NAMEN'] as String?,
      strasse: json['STRASSE'] as String?,
      plz: json['PLZ'] as String?,
      ort: json['ORT'] as String?,
      geschlecht: json['GESCHLECHT'] as int?,
      isOnline: json['ONLINE'] as bool? ?? false,
    );
  }

  PassData({
    required this.personId,
    this.passnummer,
    this.vereinNr,
    this.vereinName,
    this.passdatenId,
    this.mitgliedschaftId,
    this.geburtsdatum,
    this.titel,
    this.vorname,
    this.namen,
    this.strasse,
    this.plz,
    this.ort,
    this.geschlecht,
    this.isOnline = false,
  });
  final int personId;
  final String? passnummer;
  final int? vereinNr;
  final String? vereinName;
  final int? passdatenId;
  final int? mitgliedschaftId;
  final DateTime? geburtsdatum;
  final String? titel;
  final String? vorname;
  final String? namen;
  final String? strasse;
  final String? plz;
  final String? ort;
  final int? geschlecht;
  final bool isOnline;

  Map<String, dynamic> toJson() {
    return {
      'PERSONID': personId,
      'PASSNUMMER': passnummer,
      'VEREINNR': vereinNr,
      'VEREINNAME': vereinName,
      'PASSDATENID': passdatenId,
      'MITGLIEDSCHAFTID': mitgliedschaftId,
      'GEBURTSDATUM': geburtsdatum?.toIso8601String(),
      'TITEL': titel,
      'VORNAME': vorname,
      'NAMEN': namen,
      'STRASSE': strasse,
      'PLZ': plz,
      'ORT': ort,
      'GESCHLECHT': geschlecht,
      'ONLINE': isOnline,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PassData &&
        other.personId == personId &&
        other.passnummer == passnummer &&
        other.geburtsdatum == geburtsdatum &&
        other.titel == titel &&
        other.vorname == vorname &&
        other.namen == namen &&
        other.strasse == strasse &&
        other.plz == plz &&
        other.ort == ort &&
        other.geschlecht == geschlecht &&
        other.isOnline == isOnline;
  }

  @override
  int get hashCode {
    return Object.hash(
      personId,
      passnummer,
      vereinNr,
      vereinName,
      passdatenId,
      mitgliedschaftId,
      geburtsdatum,
      titel,
      vorname,
      namen,
      strasse,
      plz,
      ort,
      geschlecht,
      isOnline,
    );
  }

  @override
  String toString() {
    return 'PassData(personId: $personId, passnummer: $passnummer, vereinNr: $vereinNr, vereinName: $vereinName, passdatenId: $passdatenId, mitgliedschaftId: $mitgliedschaftId, geburtsdatum: $geburtsdatum, titel: $titel, vorname: $vorname, namen: $namen, strasse: $strasse, plz: $plz, ort: $ort, geschlecht: $geschlecht, isOnline: $isOnline)';
  }
}
