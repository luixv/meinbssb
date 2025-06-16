class FremdeVerband {

  FremdeVerband({
    required this.vereinId,
    required this.vereinNr,
    required this.vereinName,
  });

  factory FremdeVerband.fromJson(Map<String, dynamic> json) {
    try {
      if (!json.containsKey('VEREINID')) {
        throw const FormatException('Missing required field: VEREINID');
      }
      if (!json.containsKey('VEREINNR')) {
        throw const FormatException('Missing required field: VEREINNR');
      }
      if (!json.containsKey('VEREINNAME')) {
        throw const FormatException('Missing required field: VEREINNAME');
      }

      final vereinId = json['VEREINID'];
      final vereinNr = json['VEREINNR'];
      final vereinName = json['VEREINNAME'];

      if (vereinId is! int) {
        throw FormatException('VEREINID must be an integer, got ${vereinId.runtimeType}');
      }
      if (vereinNr is! int) {
        throw FormatException('VEREINNR must be an integer, got ${vereinNr.runtimeType}');
      }
      if (vereinName is! String) {
        throw FormatException('VEREINNAME must be a string, got ${vereinName.runtimeType}');
      }

      return FremdeVerband(
        vereinId: vereinId,
        vereinNr: vereinNr,
        vereinName: vereinName,
      );
    } catch (e) {
      if (e is FormatException) {
        rethrow;
      }
      throw FormatException('Failed to parse FremdeVerband: $e');
    }
  }
  final int vereinId;
  final int vereinNr;
  final String vereinName;

  Map<String, dynamic> toJson() {
    return {
      'VEREINID': vereinId,
      'VEREINNR': vereinNr,
      'VEREINNAME': vereinName,
    };
  }

  @override
  String toString() {
    return 'FremdeVerband(vereinId: $vereinId, vereinNr: $vereinNr, vereinName: $vereinName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FremdeVerband &&
        other.vereinId == vereinId &&
        other.vereinNr == vereinNr &&
        other.vereinName == vereinName;
  }

  @override
  int get hashCode => vereinId.hashCode ^ vereinNr.hashCode ^ vereinName.hashCode;
} 