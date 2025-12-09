import 'package:flutter/foundation.dart';

/// Represents a file record (bed_datei) in the BSSB system.
@immutable
class Datei {
  /// Creates a [Datei] instance from a JSON map.
  factory Datei.fromJson(Map<String, dynamic> json) {
    return Datei(
      id: json['ID'] as int?,
      createdAt:
          json['CREATED_AT'] == null
              ? null
              : DateTime.parse(json['CREATED_AT'] as String),
      changedAt:
          json['CHANGED_AT'] == null
              ? null
              : DateTime.parse(json['CHANGED_AT'] as String),
      deletedAt:
          json['DELETED_AT'] == null
              ? null
              : DateTime.parse(json['DELETED_AT'] as String),
      antragsnummer: json['ANTRAGSNUMMER'] as String,
      dateiname: json['DATEINAME'] as String,
      fileBytes:
          (json['FILE_BYTES'] as List<dynamic>).map((e) => e as int).toList(),
    );
  }

  /// Creates a new instance of [Datei].
  const Datei({
    this.id,
    this.createdAt,
    this.changedAt,
    this.deletedAt,
    required this.antragsnummer,
    required this.dateiname,
    required this.fileBytes,
  });

  /// The unique identifier for the file record.
  final int? id;

  /// The creation timestamp.
  final DateTime? createdAt;

  /// The last changed timestamp.
  final DateTime? changedAt;

  /// The deletion timestamp (nullable).
  final DateTime? deletedAt;

  /// The application number.
  final String antragsnummer;

  /// The file name.
  final String dateiname;

  /// The file bytes (binary data).
  final List<int> fileBytes;

  /// Converts the [Datei] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'CREATED_AT': createdAt?.toIso8601String(),
      'CHANGED_AT': changedAt?.toIso8601String(),
      'DELETED_AT': deletedAt?.toIso8601String(),
      'ANTRAGSNUMMER': antragsnummer,
      'DATEINAME': dateiname,
      'FILE_BYTES': fileBytes,
    };
  }
}
