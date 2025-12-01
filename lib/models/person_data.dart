import 'package:flutter/foundation.dart';
import 'package:meinbssb/helpers/utils.dart';

@immutable
class Person {
  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      personId: json['PERSONID'] as int,
      namen: json['NAMEN'] as String,
      vorname: json['VORNAME'] as String,
      geschlecht:
          json['GESCHLECHT'] is bool
              ? json['GESCHLECHT'] as bool
              : (json['GESCHLECHT'] == 1),
      geburtsdatum:
          json['GEBURTSDATUM'] != null ? parseDate(json['GEBURTSDATUM']) : null,
      passnummer: json['PASSNUMMER'] as String,
      strasse: json['STRASSE'] as String,
      plz: json['PLZ'] as String,
      ort: json['ORT'] as String,
    );
  }

  const Person({
    required this.personId,
    required this.namen,
    required this.vorname,
    required this.geschlecht,
    this.geburtsdatum,
    required this.passnummer,
    required this.strasse,
    required this.plz,
    required this.ort,
  });
  final int personId;
  final String namen;
  final String vorname;
  final bool geschlecht;
  final DateTime? geburtsdatum;
  final String passnummer;
  final String strasse;
  final String plz;
  final String ort;

  Map<String, dynamic> toJson() {
    return {
      'PERSONID': personId,
      'NAMEN': namen,
      'VORNAME': vorname,
      'GESCHLECHT': geschlecht,
      'GEBURTSDATUM': geburtsdatum?.toIso8601String(),
      'PASSNUMMER': passnummer,
      'STRASSE': strasse,
      'PLZ': plz,
      'ORT': ort,
    };
  }
}
