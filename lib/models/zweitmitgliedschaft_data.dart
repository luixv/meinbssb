class ZweitmitgliedschaftData {

  factory ZweitmitgliedschaftData.fromJson(Map<String, dynamic> json) {
    return ZweitmitgliedschaftData(
      vereinId: json['VEREINID'] as int,
      vereinNr: json['VEREINNR'] as int,
      vereinName: json['VEREINNAME'] as String,
      eintrittVerein: DateTime.parse(json['EINTRITTVEREIN'] as String),
    );
  }
  ZweitmitgliedschaftData({
    required this.vereinId,
    required this.vereinNr,
    required this.vereinName,
    required this.eintrittVerein,
  });

  final int vereinId;
  final int vereinNr;
  final String vereinName;
  final DateTime eintrittVerein;

  Map<String, dynamic> toJson() {
    return {
      'VEREINID': vereinId,
      'VEREINNR': vereinNr,
      'VEREINNAME': vereinName,
      'EINTRITTVEREIN': eintrittVerein.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ZweitmitgliedschaftData(vereinId: $vereinId, vereinNr: $vereinNr, '
        'vereinName: $vereinName, eintrittVerein: $eintrittVerein)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ZweitmitgliedschaftData &&
        other.vereinId == vereinId &&
        other.vereinNr == vereinNr &&
        other.vereinName == vereinName &&
        other.eintrittVerein == eintrittVerein;
  }

  @override
  int get hashCode {
    return vereinId.hashCode ^
        vereinNr.hashCode ^
        vereinName.hashCode ^
        eintrittVerein.hashCode;
  }
}
