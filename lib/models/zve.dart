class ZVE {
  factory ZVE.fromJson(Map<String, dynamic> json) {
    return ZVE(
      vereinId: json['VEREINID'] as int,
      vereinNr: json['VEREINNR'] as int,
      vereinName: json['VEREINNAME'] as String?,
      disziplinId: json['DISZIPLINID'] as int,
      disziplinNr: json['DISZIPLINNR'] as String?,
      disziplin: json['DISZIPLIN'] as String?,
    );
  }

  const ZVE({
    required this.vereinId,
    required this.vereinNr,
    this.vereinName,
    required this.disziplinId,
    this.disziplinNr,
    this.disziplin,
  });

  final int vereinId;
  final int vereinNr;
  final String? vereinName;
  final int disziplinId;
  final String? disziplinNr;
  final String? disziplin;

  Map<String, dynamic> toJson() {
    return {
      'VEREINID': vereinId,
      'VEREINNR': vereinNr,
      'VEREINNAME': vereinName,
      'DISZIPLINID': disziplinId,
      'DISZIPLINNR': disziplinNr,
      'DISZIPLIN': disziplin,
    };
  }

  ZVE copyWith({
    int? vereinId,
    int? vereinNr,
    String? vereinName,
    int? disziplinId,
    String? disziplinNr,
    String? disziplin,
  }) {
    return ZVE(
      vereinId: vereinId ?? this.vereinId,
      vereinNr: vereinNr ?? this.vereinNr,
      vereinName: vereinName ?? this.vereinName,
      disziplinId: disziplinId ?? this.disziplinId,
      disziplinNr: disziplinNr ?? this.disziplinNr,
      disziplin: disziplin ?? this.disziplin,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ZVE &&
        other.vereinId == vereinId &&
        other.vereinNr == vereinNr &&
        other.vereinName == vereinName &&
        other.disziplinId == disziplinId &&
        other.disziplinNr == disziplinNr &&
        other.disziplin == disziplin;
  }

  @override
  int get hashCode {
    return Object.hash(
      vereinId,
      vereinNr,
      vereinName,
      disziplinId,
      disziplinNr,
      disziplin,
    );
  }

  @override
  String toString() {
    return 'ZVE(vereinId: $vereinId, vereinNr: $vereinNr, vereinName: $vereinName, disziplinId: $disziplinId, disziplinNr: $disziplinNr, disziplin: $disziplin)';
  }
}
