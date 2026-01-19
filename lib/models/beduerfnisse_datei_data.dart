import 'package:flutter/foundation.dart';

/// Represents a file record (bed_datei) in the BSSB system.
@immutable
class BeduerfnisseDatei {
  /// Creates a [BeduerfnisseDatei] instance from a JSON map.
  factory BeduerfnisseDatei.fromJson(Map<String, dynamic> json) {
    // Helper to parse file_bytes which can be a hex string or list
    List<int> parseFileBytes(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0).toList();
      }
      if (value is String) {
        // Handle hex string format like '\x...'
        if (value.startsWith('\\x')) {
          final hexString = value.substring(2);
          final bytes = <int>[];
          for (int i = 0; i < hexString.length; i += 2) {
            final hex = hexString.substring(i, i + 2);
            bytes.add(int.parse(hex, radix: 16));
          }
          return bytes;
        }
      }
      return [];
    }

    return BeduerfnisseDatei(
      id: (json['ID'] ?? json['id']) as int?,
      createdAt:
          (json['CREATED_AT'] ?? json['created_at']) == null
              ? null
              : DateTime.parse((json['CREATED_AT'] ?? json['created_at']) as String),
      changedAt:
          (json['CHANGED_AT'] ?? json['changed_at']) == null
              ? null
              : DateTime.parse((json['CHANGED_AT'] ?? json['changed_at']) as String),
      deletedAt:
          (json['DELETED_AT'] ?? json['deleted_at']) == null
              ? null
              : DateTime.parse((json['DELETED_AT'] ?? json['deleted_at']) as String),
      antragsnummer: (json['ANTRAGSNUMMER'] ?? json['antragsnummer']) as int,
      dateiname: (json['DATEINAME'] ?? json['dateiname']) as String,
      fileBytes: parseFileBytes(json['FILE_BYTES'] ?? json['file_bytes']),
    );
  }

  /// Creates a new instance of [BeduerfnisseDatei].
  const BeduerfnisseDatei({
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
  final int antragsnummer;

  /// The file name.
  final String dateiname;

  /// The file bytes (binary data).
  final List<int> fileBytes;

  /// Converts the [BeduerfnisseDatei] instance to a JSON map.
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
