class PassData {
  factory PassData.fromJson(Map<String, dynamic> json) {
    return PassData(
      personId: json['PERSONID'] as int,
      passnummer: json['PASSNUMMER'] as String?,
      geburtsdatum: json['GEBURTSDATUM'] as String?,
      titel: json['TITEL'] as String?,
      vorname: json['VORNAME'] as String?,
      namen: json['NAMEN'] as String?,
      strasse: json['STRASSE'] as String?,
      plz: json['PLZ'] as String?,
      ort: json['ORT'] as String?,
      geschlecht: json['GESCHLECHT'] as int?,
    );
  }

  PassData({
    required this.personId,
    this.passnummer,
    this.geburtsdatum,
    this.titel,
    this.vorname,
    this.namen,
    this.strasse,
    this.plz,
    this.ort,
    this.geschlecht,
  });
  final int personId;
  final String? passnummer;
  final String? geburtsdatum;
  final String? titel;
  final String? vorname;
  final String? namen;
  final String? strasse;
  final String? plz;
  final String? ort;
  final int? geschlecht;

  Map<String, dynamic> toJson() {
    return {
      'PERSONID': personId,
      'PASSNUMMER': passnummer,
      'GEBURTSDATUM': geburtsdatum,
      'TITEL': titel,
      'VORNAME': vorname,
      'NAMEN': namen,
      'STRASSE': strasse,
      'PLZ': plz,
      'ORT': ort,
      'GESCHLECHT': geschlecht,
    };
  }
}
