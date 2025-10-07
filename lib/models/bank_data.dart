// ...existing imports (leave them)...

// Add safe helpers (outside or at top of file, BEFORE the class). They must NOT include 'factory'.
DateTime? _safeParseDate(String? value) {
  if (value == null || value.isEmpty) return null;
  try {
    return DateTime.parse(value);
  } catch (_) {
    return null;
  }
}

int _parseMandatSeq(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

// Ensure the BankData class starts cleanly (remove any accidental 'factory BankData...' top‑level code)
class BankData {
  factory BankData.fromJson(Map<String, dynamic> json) {
    final rawDate = json['LETZTENUTZUNG'];
    final parsedDate = rawDate is String ? _safeParseDate(rawDate) : null;

    return BankData(
      id: json['BANKDATENWEBID'] as int,
      webloginId: json['WEBLOGINID'] as int,
      kontoinhaber: (json['KONTOINHABER'] as String?) ?? '',
      iban: (json['IBAN'] as String?) ?? '',
      bic: (json['BIC'] as String?) ?? '',
      bankName: (json['BANKNAME'] as String?) ?? '',
      mandatNr: (json['MANDATNR'] as String?) ?? '',
      mandatName: (json['MANDATNAME'] as String?) ?? '',
      mandatSeq: _parseMandatSeq(json['MANDATSEQ']),
      letzteNutzung: parsedDate,
      ungueltig: (json['UNGUELTIG'] as bool?) ?? false,
    );
  }

  const BankData({
    required this.id,
    required this.webloginId,
    required this.kontoinhaber,
    required this.iban,
    required this.bic,
    this.bankName = '',
    this.mandatNr = '',
    this.mandatName = '',
    this.mandatSeq = 0,
    this.letzteNutzung,
    this.ungueltig = false,
  });
  final int id;
  final int webloginId;
  final String kontoinhaber;
  final String iban;
  final String bic;
  final String bankName;
  final String mandatNr;
  final String mandatName;
  final int mandatSeq;
  final DateTime? letzteNutzung;
  final bool ungueltig;

  Map<String, dynamic> toJson() => {
    'WebloginID': webloginId,
    'Kontoinhaber': kontoinhaber,
    'IBAN': iban,
    'BIC': bic,
    'Bankname': bankName,
    'MandatNr': mandatNr,
    'MandatName': mandatName,
    'MandatSeq': mandatSeq,
    if (letzteNutzung != null)
      'LetzteNutzung': letzteNutzung!.toIso8601String(),
    'Ungueltig': ungueltig,
  };

  BankData copyWith({
    String? kontoinhaber,
    String? iban,
    String? bic,
    String? bankName,
    String? mandatNr,
    String? mandatName,
    int? mandatSeq,
    DateTime? letzteNutzung,
    bool? ungueltig,
  }) {
    return BankData(
      id: id,
      webloginId: webloginId,
      kontoinhaber: kontoinhaber ?? this.kontoinhaber,
      iban: iban ?? this.iban,
      bic: bic ?? this.bic,
      bankName: bankName ?? this.bankName,
      mandatNr: mandatNr ?? this.mandatNr,
      mandatName: mandatName ?? this.mandatName,
      mandatSeq: mandatSeq ?? this.mandatSeq,
      letzteNutzung: letzteNutzung ?? this.letzteNutzung,
      ungueltig: ungueltig ?? this.ungueltig,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BankData &&
          id == other.id &&
          webloginId == other.webloginId &&
          kontoinhaber == other.kontoinhaber &&
          iban == other.iban &&
          bic == other.bic &&
          bankName == other.bankName &&
          mandatNr == other.mandatNr &&
          mandatName == other.mandatName &&
          mandatSeq == other.mandatSeq &&
          letzteNutzung == other.letzteNutzung &&
          ungueltig == other.ungueltig;

  @override
  int get hashCode =>
      id ^
      webloginId ^
      kontoinhaber.hashCode ^
      iban.hashCode ^
      bic.hashCode ^
      bankName.hashCode ^
      mandatNr.hashCode ^
      mandatName.hashCode ^
      mandatSeq.hashCode ^
      (letzteNutzung?.hashCode ?? 0) ^
      ungueltig.hashCode;

  @override
  String toString() =>
      'BankData(id: $id, webloginId: $webloginId, kontoinhaber: $kontoinhaber, '
      'iban: $iban, bic: $bic, bankName: $bankName, mandatNr: $mandatNr, '
      'mandatName: $mandatName, mandatSeq: $mandatSeq, letzteNutzung: $letzteNutzung, '
      'ungueltig: $ungueltig)';
}
