import 'package:flutter/foundation.dart';

/// States for Beduerfnis Antrag (Special Needs Application)
/// Maps to the finite state machine defined in the workflow matrix
enum BeduerfnisAntragStatus {
  entwurf, // Draft
  eingereichtAmVerein, // Submitted to Club
  zurueckgewiesenAnMitgliedVonVerein, // Rejected to Member by Club
  genehmightVonVerein, // Approved by Club
  zurueckgewiesenVonBSSBAnVerein, // Rejected by BSSB to Club
  zurueckgewiesenVonBSSBAnMitglied, // Rejected by BSSB to Member
  eingereichtAnBSSB, // Submitted to BSSB
  genehmight, // Approved
  abgelehnt, // Rejected
}

extension BeduerfnisAntragStatusExtension on BeduerfnisAntragStatus {
  /// Convert enum to database ID
  int toId() {
    switch (this) {
      case BeduerfnisAntragStatus.entwurf:
        return 1;
      case BeduerfnisAntragStatus.eingereichtAmVerein:
        return 2;
      case BeduerfnisAntragStatus.zurueckgewiesenAnMitgliedVonVerein:
        return 3;
      case BeduerfnisAntragStatus.genehmightVonVerein:
        return 4;
      case BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnVerein:
        return 5;
      case BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnMitglied:
        return 6;
      case BeduerfnisAntragStatus.eingereichtAnBSSB:
        return 7;
      case BeduerfnisAntragStatus.genehmight:
        return 8;
      case BeduerfnisAntragStatus.abgelehnt:
        return 9;
    }
  }

  /// Convert enum to German string representation for API/database
  String toGermanString() {
    switch (this) {
      case BeduerfnisAntragStatus.entwurf:
        return 'Entwurf';
      case BeduerfnisAntragStatus.eingereichtAmVerein:
        return 'Eingereicht am Verein';
      case BeduerfnisAntragStatus.zurueckgewiesenAnMitgliedVonVerein:
        return 'Zurückgewiesen an Mitglied von Verein';
      case BeduerfnisAntragStatus.genehmightVonVerein:
        return 'Genehmight von Verein';
      case BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnVerein:
        return 'Zurückgewiesen von BSSB an Verein';
      case BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnMitglied:
        return 'Zurückgewiesen von BSSB an Mitglied';
      case BeduerfnisAntragStatus.eingereichtAnBSSB:
        return 'Eingereicht an BSSB';
      case BeduerfnisAntragStatus.genehmight:
        return 'Genehmight';
      case BeduerfnisAntragStatus.abgelehnt:
        return 'Abgelehnt';
    }
  }

  /// Convert database ID to enum
  static BeduerfnisAntragStatus? fromId(int? id) {
    switch (id) {
      case 1:
        return BeduerfnisAntragStatus.entwurf;
      case 2:
        return BeduerfnisAntragStatus.eingereichtAmVerein;
      case 3:
        return BeduerfnisAntragStatus.zurueckgewiesenAnMitgliedVonVerein;
      case 4:
        return BeduerfnisAntragStatus.genehmightVonVerein;
      case 5:
        return BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnVerein;
      case 6:
        return BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnMitglied;
      case 7:
        return BeduerfnisAntragStatus.eingereichtAnBSSB;
      case 8:
        return BeduerfnisAntragStatus.genehmight;
      case 9:
        return BeduerfnisAntragStatus.abgelehnt;
      default:
        return null;
    }
  }

  /// Parse German string to enum
  static BeduerfnisAntragStatus? fromGermanString(String? value) {
    switch (value) {
      case 'Entwurf':
        return BeduerfnisAntragStatus.entwurf;
      case 'Eingereicht am Verein':
        return BeduerfnisAntragStatus.eingereichtAmVerein;
      case 'Zurückgewiesen an Mitglied von Verein':
        return BeduerfnisAntragStatus.zurueckgewiesenAnMitgliedVonVerein;
      case 'Genehmight von Verein':
        return BeduerfnisAntragStatus.genehmightVonVerein;
      case 'Zurückgewiesen von BSSB an Verein':
        return BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnVerein;
      case 'Zurückgewiesen von BSSB an Mitglied':
        return BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnMitglied;
      case 'Eingereicht an BSSB':
        return BeduerfnisAntragStatus.eingereichtAnBSSB;
      case 'Genehmight':
        return BeduerfnisAntragStatus.genehmight;
      case 'Abgelehnt':
        return BeduerfnisAntragStatus.abgelehnt;
      default:
        return null;
    }
  }

  /// Get German status text by status ID
  static String getStatusTextById(int? statusId) {
    switch (statusId) {
      case 1:
        return BeduerfnisAntragStatus.entwurf.toGermanString();
      case 2:
        return BeduerfnisAntragStatus.eingereichtAmVerein.toGermanString();
      case 3:
        return BeduerfnisAntragStatus.zurueckgewiesenAnMitgliedVonVerein
            .toGermanString();
      case 4:
        return BeduerfnisAntragStatus.genehmightVonVerein.toGermanString();
      case 5:
        return BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnVerein
            .toGermanString();
      case 6:
        return BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnMitglied
            .toGermanString();
      case 7:
        return BeduerfnisAntragStatus.eingereichtAnBSSB.toGermanString();
      case 8:
        return BeduerfnisAntragStatus.genehmight.toGermanString();
      case 9:
        return BeduerfnisAntragStatus.abgelehnt.toGermanString();
      default:
        return 'Unbekannt';
    }
  }
}

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
      deletedAt:
          json['DELETED_AT'] ?? json['deleted_at'] == null
              ? null
              : DateTime.parse(
                (json['DELETED_AT'] ?? json['deleted_at']) as String,
              ),
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
