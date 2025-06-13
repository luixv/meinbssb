class PassDataZVE {

  factory PassDataZVE.fromJson(Map<String, dynamic> json) {
    return PassDataZVE(
      passdatenZvId: json['PASSDATENZVID'] as int,
      zvVereinId: json['ZVEREINID'] as int,
      vVereinNr: json['VVEREINNR'] as int,
      disziplinNr: json['DISZIPLINNR'] as String?,
      gauId: json['GAUID'] as int,
      bezirkId: json['BEZIRKID'] as int,
      disziAusblenden: json['DISZIAUSBLENDEN'] as int,
      ersaetzendurchId: json['ERSAETZENDURCHID'] as int,
      zvMitgliedschaftId: json['ZVMITGLIEDSCHAFTID'] as int,
      vereinName: json['VEREINNAME'] as String?,
      disziplin: json['DISZIPLIN'] as String?,
      disziplinId: json['DISZIPLINID'] as int,
    );
  }
  PassDataZVE({
    required this.passdatenZvId,
    required this.zvVereinId,
    required this.vVereinNr,
    this.disziplinNr,
    required this.gauId,
    required this.bezirkId,
    required this.disziAusblenden,
    required this.ersaetzendurchId,
    required this.zvMitgliedschaftId,
    this.vereinName,
    this.disziplin,
    required this.disziplinId,
  });

  final int passdatenZvId;
  final int zvVereinId;
  final int vVereinNr;
  final String? disziplinNr;
  final int gauId;
  final int bezirkId;
  final int disziAusblenden;
  final int ersaetzendurchId;
  final int zvMitgliedschaftId;
  final String? vereinName;
  final String? disziplin;
  final int disziplinId;

  Map<String, dynamic> toJson() {
    return {
      'PASSDATENZVID': passdatenZvId,
      'ZVEREINID': zvVereinId,
      'VVEREINNR': vVereinNr,
      'DISZIPLINNR': disziplinNr,
      'GAUID': gauId,
      'BEZIRKID': bezirkId,
      'DISZIAUSBLENDEN': disziAusblenden,
      'ERSAETZENDURCHID': ersaetzendurchId,
      'ZVMITGLIEDSCHAFTID': zvMitgliedschaftId,
      'VEREINNAME': vereinName,
      'DISZIPLIN': disziplin,
      'DISZIPLINID': disziplinId,
    };
  }

  @override
  String toString() {
    return 'PassDataZVE(passdatenZvId: $passdatenZvId, zvVereinId: $zvVereinId, vVereinNr: $vVereinNr, disziplinNr: $disziplinNr, gauId: $gauId, bezirkId: $bezirkId, disziAusblenden: $disziAusblenden, ersaetzendurchId: $ersaetzendurchId, zvMitgliedschaftId: $zvMitgliedschaftId, vereinName: $vereinName, disziplin: $disziplin, disziplinId: $disziplinId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PassDataZVE &&
        other.passdatenZvId == passdatenZvId &&
        other.zvVereinId == zvVereinId &&
        other.vVereinNr == vVereinNr &&
        other.disziplinNr == disziplinNr &&
        other.gauId == gauId &&
        other.bezirkId == bezirkId &&
        other.disziAusblenden == disziAusblenden &&
        other.ersaetzendurchId == ersaetzendurchId &&
        other.zvMitgliedschaftId == zvMitgliedschaftId &&
        other.vereinName == vereinName &&
        other.disziplin == disziplin &&
        other.disziplinId == disziplinId;
  }

  @override
  int get hashCode {
    return passdatenZvId.hashCode ^
        zvVereinId.hashCode ^
        vVereinNr.hashCode ^
        disziplinNr.hashCode ^
        gauId.hashCode ^
        bezirkId.hashCode ^
        disziAusblenden.hashCode ^
        ersaetzendurchId.hashCode ^
        zvMitgliedschaftId.hashCode ^
        vereinName.hashCode ^
        disziplin.hashCode ^
        disziplinId.hashCode;
  }
}
