class PassdataZVE {
  factory PassdataZVE.fromJson(Map<String, dynamic> json) {
    return PassdataZVE(
      passdatenId: json['PASSDATENID'] as int,
      personId: json['PERSONID'] as int,
      passnummer: json['PASSNUMMER'] as String?,
      vereinNr: json['VEREINNR'] as int?,
      vereinName: json['VEREINNAME'] as String?,
      namen: json['NAMEN'] as String?,
      vorname: json['VORNAME'] as String?,
      titel: json['TITEL'] as String?,
      geburtsdatum: json['GEBURTSDATUM'] != null
          ? DateTime.parse(json['GEBURTSDATUM']).toUtc()
          : null,
      geschlecht: json['GESCHLECHT'] as int?,
      strasse: json['STRASSE'] as String?,
      plz: json['PLZ'] as String?,
      ort: json['ORT'] as String?,
      isOnline: json['ONLINE'] as bool? ?? false,
    );
  }

  PassdataZVE({
    required this.passdatenId,
    required this.personId,
    this.passnummer,
    this.vereinNr,
    this.vereinName,
    this.namen,
    this.vorname,
    this.titel,
    this.geburtsdatum,
    this.geschlecht,
    this.strasse,
    this.plz,
    this.ort,
    this.isOnline = false,
  });

  final int passdatenId;
  final int personId;
  final String? passnummer;
  final int? vereinNr;
  final String? vereinName;
  final String? namen;
  final String? vorname;
  final String? titel;
  final DateTime? geburtsdatum;
  final int? geschlecht;
  final String? strasse;
  final String? plz;
  final String? ort;
  final bool isOnline;

  Map<String, dynamic> toJson() {
    return {
      'PASSDATENID': passdatenId,
      'PERSONID': personId,
      'PASSNUMMER': passnummer,
      'VEREINNR': vereinNr,
      'VEREINNAME': vereinName,
      'NAMEN': namen,
      'VORNAME': vorname,
      'TITEL': titel,
      'GEBURTSDATUM': geburtsdatum?.toIso8601String(),
      'GESCHLECHT': geschlecht,
      'STRASSE': strasse,
      'PLZ': plz,
      'ORT': ort,
      'ONLINE': isOnline,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PassdataZVE &&
        other.passdatenId == passdatenId &&
        other.personId == personId &&
        other.passnummer == passnummer &&
        other.vereinNr == vereinNr &&
        other.vereinName == vereinName &&
        other.namen == namen &&
        other.vorname == vorname &&
        other.titel == titel &&
        other.geburtsdatum == geburtsdatum &&
        other.geschlecht == geschlecht &&
        other.strasse == strasse &&
        other.plz == plz &&
        other.ort == ort &&
        other.isOnline == isOnline;
  }

  @override
  int get hashCode {
    return Object.hash(
      passdatenId,
      personId,
      passnummer,
      vereinNr,
      vereinName,
      namen,
      vorname,
      titel,
      geburtsdatum,
      geschlecht,
      strasse,
      plz,
      ort,
      isOnline,
    );
  }

  @override
  String toString() {
    return 'PassdataZVE(passdatenId: $passdatenId, personId: $personId, passnummer: $passnummer, vereinNr: $vereinNr, vereinName: $vereinName, namen: $namen, vorname: $vorname, titel: $titel, geburtsdatum: $geburtsdatum, geschlecht: $geschlecht, strasse: $strasse, plz: $plz, ort: $ort, isOnline: $isOnline)';
  }
}
