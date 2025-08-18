class ZweitmitgliedschaftData {
  factory ZweitmitgliedschaftData.fromJson(Map<String, dynamic> json) {
    return ZweitmitgliedschaftData(
      vereinId: json['VEREINID'] as int,
      vereinNr: json['VEREINNR'] as int,
      vereinName: json['VEREINNAME'] as String,
      eintrittVerein: (json['EINTRITTVEREIN'] == null ||
              (json['EINTRITTVEREIN'] is String &&
                  (json['EINTRITTVEREIN'] as String).isEmpty))
          ? null
          : DateTime.parse(json['EINTRITTVEREIN'] as String),

      // in case the EINTRITTVEREIN is null or empty we need a date object.
    );
  }
  ZweitmitgliedschaftData({
    required this.vereinId,
    required this.vereinNr,
    required this.vereinName,
    this.eintrittVerein,
  });

  final int vereinId;
  final int vereinNr;
  final String vereinName;
  final DateTime? eintrittVerein;

  Map<String, dynamic> toJson() {
    return {
      'VEREINID': vereinId,
      'VEREINNR': vereinNr,
      'VEREINNAME': vereinName,
      'EINTRITTVEREIN': eintrittVerein?.toIso8601String(),
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
