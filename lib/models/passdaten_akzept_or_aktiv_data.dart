import 'package:flutter/foundation.dart'; // For listEquals
import 'package:meinbssb/models/zve_data.dart'; // Import ZVE model

class PassdatenAkzeptOrAktiv {
  factory PassdatenAkzeptOrAktiv.fromJson(Map<String, dynamic> json) {
    return PassdatenAkzeptOrAktiv(
      passdatenId: json['PASSDATENID'] as int,
      passStatus: json['PASSSTATUS'] as int,
      passStatusText: json['PASSSTATUSTEXT'] as String?,
      digitalerPass: json['DIGITALERPASS'] as int,
      personId: json['PERSONID'] as int,
      erstVereinId: json['ERSTVEREINID'] as int,
      evVereinNr: json['EVVEREINNR'] as int,
      evVereinName: json['EVVEREINNAME'] as String?,
      passNummer: json['PASSNUMMER'] as String?,
      erstelltAm:
          json['ERSTELLTAM'] != null
              ? DateTime.parse(json['ERSTELLTAM'])
              : null,
      erstelltVon: json['ERSTELLTVON'] as String?,
      zves:
          (json['ZVEs'] is List)
              ? (json['ZVEs'] as List)
                  .map((e) => ZVE.fromJson(e as Map<String, dynamic>))
                  .toList()
              : [],
    );
  }

  PassdatenAkzeptOrAktiv({
    required this.passdatenId,
    required this.passStatus,
    this.passStatusText,
    required this.digitalerPass,
    required this.personId,
    required this.erstVereinId,
    required this.evVereinNr,
    this.evVereinName,
    this.passNummer,
    this.erstelltAm,
    this.erstelltVon,
    this.zves = const [],
  });

  final int passdatenId;
  final int passStatus;
  final String? passStatusText;
  final int digitalerPass;
  final int personId;
  final int erstVereinId;
  final int evVereinNr;
  final String? evVereinName;
  final String? passNummer;
  final DateTime? erstelltAm;
  final String? erstelltVon;
  final List<ZVE> zves;

  Map<String, dynamic> toJson() {
    return {
      'PASSDATENID': passdatenId,
      'PASSSTATUS': passStatus,
      'PASSSTATUSTEXT': passStatusText,
      'DIGITALERPASS': digitalerPass,
      'PERSONID': personId,
      'ERSTVEREINID': erstVereinId,
      'EVVEREINNR': evVereinNr,
      'EVVEREINNAME': evVereinName,
      'PASSNUMMER': passNummer,
      'ERSTELLTAM': erstelltAm?.toIso8601String(),
      'ERSTELLTVON': erstelltVon,
      'ZVEs': zves.map((e) => e.toJson()).toList(),
    };
  }

  PassdatenAkzeptOrAktiv copyWith({
    int? passdatenId,
    int? passStatus,
    String? passStatusText,
    int? digitalerPass,
    int? personId,
    int? erstVereinId,
    int? evVereinNr,
    String? evVereinName,
    String? passNummer,
    DateTime? erstelltAm,
    String? erstelltVon,
    List<ZVE>? zves,
  }) {
    return PassdatenAkzeptOrAktiv(
      passdatenId: passdatenId ?? this.passdatenId,
      passStatus: passStatus ?? this.passStatus,
      passStatusText: passStatusText ?? this.passStatusText,
      digitalerPass: digitalerPass ?? this.digitalerPass,
      personId: personId ?? this.personId,
      erstVereinId: erstVereinId ?? this.erstVereinId,
      evVereinNr: evVereinNr ?? this.evVereinNr,
      evVereinName: evVereinName ?? this.evVereinName,
      passNummer: passNummer ?? this.passNummer,
      erstelltAm: erstelltAm ?? this.erstelltAm,
      erstelltVon: erstelltVon ?? this.erstelltVon,
      zves: zves ?? this.zves,
    );
  }

  @override
  String toString() {
    final zvesString = zves.map((z) => z.toString()).join(', ');
    return 'PassdatenAkzeptOrAktiv(passdatenId: $passdatenId, passStatus: $passStatus, passStatusText: $passStatusText, digitalerPass: $digitalerPass, personId: $personId, erstVereinId: $erstVereinId, evVereinNr: $evVereinNr, evVereinName: $evVereinName, passNummer: $passNummer, erstelltAm: $erstelltAm, erstelltVon: $erstelltVon, zves: [$zvesString])';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PassdatenAkzeptOrAktiv &&
        other.passdatenId == passdatenId &&
        other.passStatus == passStatus &&
        other.passStatusText == passStatusText &&
        other.digitalerPass == digitalerPass &&
        other.personId == personId &&
        other.erstVereinId == erstVereinId &&
        other.evVereinNr == evVereinNr &&
        other.evVereinName == evVereinName &&
        other.passNummer == passNummer &&
        other.erstelltAm == erstelltAm &&
        other.erstelltVon == erstelltVon &&
        listEquals(other.zves, zves);
  }

  @override
  int get hashCode {
    return passdatenId.hashCode ^
        passStatus.hashCode ^
        passStatusText.hashCode ^
        digitalerPass.hashCode ^
        personId.hashCode ^
        erstVereinId.hashCode ^
        evVereinNr.hashCode ^
        evVereinName.hashCode ^
        passNummer.hashCode ^
        erstelltAm.hashCode ^
        erstelltVon.hashCode ^
        Object.hashAll(zves);
  }
}
