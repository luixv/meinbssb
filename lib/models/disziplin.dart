class Disziplin {
  factory Disziplin.fromJson(Map<String, dynamic> json) {
    return Disziplin(
      disziplinId: json['DISZIPLINID'] as int,
      disziplinNr: json['DISZIPLINNR'] as String? ?? '',
      disziplin: json['DISZIPLIN'] as String,
    );
  }
  Disziplin({
    required this.disziplinId,
    required this.disziplinNr,
    required this.disziplin,
  });

  final int disziplinId;
  final String disziplinNr;
  final String disziplin;

  Map<String, dynamic> toJson() {
    return {
      'DISZIPLINID': disziplinId,
      'DISZIPLINNR': disziplinNr,
      'DISZIPLIN': disziplin,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Disziplin &&
        other.disziplinId == disziplinId &&
        other.disziplinNr == disziplinNr &&
        other.disziplin == disziplin;
  }

  @override
  int get hashCode => Object.hash(disziplinId, disziplinNr, disziplin);

  @override
  String toString() {
    return 'Disziplin(disziplinId: $disziplinId, disziplinNr: $disziplinNr, disziplin: $disziplin)';
  }
}
