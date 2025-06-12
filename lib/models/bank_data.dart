import 'package:flutter/foundation.dart';

/// Represents bank account data for a user.
/// This model is used to store and manage bank account information
/// such as account holder, IBAN, BIC, and mandate details.
@immutable
class BankData {
  /// Creates a [BankData] instance from a JSON map.
  factory BankData.fromJson(Map<String, dynamic> json) {
    return BankData(
      id: json['BANKDATENWEBID'] as int,
      webloginId: json['WEBLOGINID'] as int,
      kontoinhaber: json['KONTOINHABER'] as String,
      iban: json['IBAN'] as String,
      bic: json['BIC'] as String,
      bankName: json['BANKNAME'] as String? ?? '',
      mandatNr: json['MANDATNR'] as String? ?? '',
      mandatName: json['MANDATNAME'] as String? ?? '',
      mandatSeq: json['MANDATSEQ'] as int? ?? 0,
      letzteNutzung: json['LETZTENUTZUNG'] != null
          ? DateTime.parse(json['LETZTENUTZUNG'] as String)
          : null,
      ungueltig: json['UNGUELTIG'] as bool? ?? false,
    );
  }

  /// Creates a new instance of [BankData].
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

  /// The unique identifier for the bank data record.
  final int id;

  /// The web login ID associated with this bank data.
  final int webloginId;

  /// The account holder's name.
  final String kontoinhaber;

  /// The International Bank Account Number.
  final String iban;

  /// The Bank Identifier Code.
  final String bic;

  /// The name of the bank.
  final String bankName;

  /// The mandate number for SEPA direct debits.
  final String mandatNr;

  /// The name associated with the mandate.
  final String mandatName;

  /// The sequence number of the mandate.
  final int mandatSeq;

  /// The date of the last usage of this bank data.
  final DateTime? letzteNutzung;

  /// Whether this bank data is invalid.
  final bool ungueltig;

  /// Converts this [BankData] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'WebloginID': webloginId,
      'Kontoinhaber': kontoinhaber,
      'IBAN': iban,
      'BIC': bic,
      'Bankname': bankName,
      'MandatNr': mandatNr,
      'MandatSeq': mandatSeq,
    };
  }

  /// Creates a copy of this [BankData] with the given fields replaced with new values.
  BankData copyWith({
    int? id,
    int? webloginId,
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
      id: id ?? this.id,
      webloginId: webloginId ?? this.webloginId,
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
  String toString() {
    return 'BankData(id: $id, webloginId: $webloginId, kontoinhaber: $kontoinhaber, '
        'iban: $iban, bic: $bic, bankName: $bankName, mandatNr: $mandatNr, '
        'mandatName: $mandatName, mandatSeq: $mandatSeq, '
        'letzteNutzung: $letzteNutzung, ungueltig: $ungueltig)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BankData &&
        other.id == id &&
        other.webloginId == webloginId &&
        other.kontoinhaber == kontoinhaber &&
        other.iban == iban &&
        other.bic == bic &&
        other.bankName == bankName &&
        other.mandatNr == mandatNr &&
        other.mandatName == mandatName &&
        other.mandatSeq == mandatSeq &&
        other.letzteNutzung == letzteNutzung &&
        other.ungueltig == ungueltig;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      webloginId,
      kontoinhaber,
      iban,
      bic,
      bankName,
      mandatNr,
      mandatName,
      mandatSeq,
      letzteNutzung,
      ungueltig,
    );
  }
}
