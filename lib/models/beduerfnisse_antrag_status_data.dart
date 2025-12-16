import 'package:flutter/foundation.dart';

/// Represents an application status (bed_antrag_status) in the BSSB system.
@immutable
class BeduerfnisseAntragStatus {
  /// Creates a [BeduerfnisseAntragStatus] instance from a JSON map.
  /// Supports both snake_case (PostgREST) and uppercase formats.
  factory BeduerfnisseAntragStatus.fromJson(Map<String, dynamic> json) {
    return BeduerfnisseAntragStatus(
      id: (json['ID'] ?? json['id']) as int?,
      status: (json['STATUS'] ?? json['status']) as String,
      beschreibung: (json['BESCHREIBUNG'] ?? json['beschreibung']) as String?,
      deletedAt: json['DELETED_AT'] ?? json['deleted_at'] == null
          ? null
          : DateTime.parse((json['DELETED_AT'] ?? json['deleted_at']) as String),
    );
  }

  /// Creates a new instance of [BeduerfnisseAntragStatus].
  const BeduerfnisseAntragStatus({
    this.id,
    required this.status,
    this.beschreibung,
    this.deletedAt,
  });

  /// The unique identifier for the application status.
  final int? id;

  /// The status value (unique).
  final String status;

  /// The description of the status.
  final String? beschreibung;

  /// The deletion timestamp (nullable).
  final DateTime? deletedAt;

  /// Converts the [BeduerfnisseAntragStatus] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'STATUS': status,
      'BESCHREIBUNG': beschreibung,
      'DELETED_AT': deletedAt?.toIso8601String(),
    };
  }
}
