import 'dart:async';
import '/models/schulung.dart';
import '/services/core/cache_service.dart';
import '/services/core/http_client.dart';
import '/services/core/logger_service.dart';
import '/services/core/network_service.dart';

class TrainingService {
  TrainingService({
    required HttpClient httpClient,
    required CacheService cacheService,
    required NetworkService networkService,
  })  : _httpClient = httpClient,
        _cacheService = cacheService,
        _networkService = networkService;

  final HttpClient _httpClient;
  final CacheService _cacheService;
  final NetworkService _networkService;

  Future<List<Schulung>> fetchAngemeldeteSchulungen(
    int personId,
    String abDatum,
  ) async {
    final cacheKey = 'schulungen_$personId';
    final cacheDuration = _networkService.getCacheExpirationDuration();

    try {
      final result =
          await _cacheService.cacheAndRetrieveData<List<Map<String, dynamic>>>(
        cacheKey,
        cacheDuration,
        () async {
          final response = await _httpClient.get(
            'AngemeldeteSchulungen/$personId/$abDatum',
          );
          return _mapAngemeldeteSchulungenResponse(response)
              .map((s) => s.toJson())
              .toList();
        },
        (data) => data,
      );

      return result.map((json) => Schulung.fromJson(json)).toList();
    } catch (e) {
      LoggerService.logError('Error fetching schulungen: $e');
      return [];
    }
  }

  List<Schulung> _mapAngemeldeteSchulungenResponse(dynamic response) {
    if (response is! List) {
      LoggerService.logError('Expected List but got ${response.runtimeType}');
      return [];
    }

    return response
        .map((item) {
          if (item is! Map<String, dynamic>) {
            LoggerService.logError(
              'Expected Map<String, dynamic> but got ${item.runtimeType}',
            );
            return null;
          }

          try {
            // Convert all fields that might be integers to strings
            final datum = item['DATUM']?.toString() ?? '';
            final ausgestelltAm = item['AUSGESTELLTAM']?.toString() ?? '-';
            final uhrzeit = item['UHRZEIT']?.toString() ?? '';
            final dauer = item['DAUER']?.toString() ?? '';
            final preis = item['PREIS']?.toString() ?? '';
            final gueltigBis = item['GUELTIGBIS']?.toString() ?? '-';
            final bezeichnung = item['BEZEICHNUNG']?.toString() ?? '';
            final schulungsartBezeichnung =
                item['SCHULUNGSARTBEZEICHNUNG']?.toString() ?? '';
            final schulungsartKurzbezeichnung =
                item['SCHULUNGSARTKURZBEZEICHNUNG']?.toString() ?? '';
            final schulungsartBeschreibung =
                item['SCHULUNGSARTBESCHREIBUNG']?.toString() ?? '';
            final ort = item['ORT']?.toString() ?? '';
            final zielgruppe = item['ZIELGRUPPE']?.toString() ?? '';
            final voraussetzungen = item['VORAUSSETZUNGEN']?.toString() ?? '';
            final inhalt = item['INHALT']?.toString() ?? '';
            final abschluss = item['ABSCHLUSS']?.toString() ?? '';
            final anmerkungen = item['ANMERKUNGEN']?.toString() ?? '';
            final link = item['LINK']?.toString() ?? '';
            final status = item['STATUS']?.toString() ?? '';

            return Schulung(
              id: item['SCHULUNGID'] as int? ?? 0,
              bezeichnung: bezeichnung,
              datum: datum,
              ausgestelltAm: ausgestelltAm,
              teilnehmerId: item['SCHULUNGENTEILNEHMERID'] as int? ?? 0,
              schulungsartId: item['SCHULUNGSARTID'] as int? ?? 0,
              schulungsartBezeichnung: schulungsartBezeichnung,
              schulungsartKurzbezeichnung: schulungsartKurzbezeichnung,
              schulungsartBeschreibung: schulungsartBeschreibung,
              maxTeilnehmer: item['MAXTEILNEHMER'] as int? ?? 0,
              anzahlTeilnehmer: item['ANZAHLTEILNEHMER'] as int? ?? 0,
              ort: ort,
              uhrzeit: uhrzeit,
              dauer: dauer,
              preis: preis,
              zielgruppe: zielgruppe,
              voraussetzungen: voraussetzungen,
              inhalt: inhalt,
              abschluss: abschluss,
              anmerkungen: anmerkungen,
              isOnline: item['ISONLINE'] as bool? ?? false,
              link: link,
              status: status,
              gueltigBis: gueltigBis,
            );
          } catch (e, stackTrace) {
            LoggerService.logError(
              'Error mapping Schulung: $e\nStack trace: $stackTrace',
            );
            return null;
          }
        })
        .whereType<Schulung>()
        .toList();
  }

  Future<List<Schulung>> fetchAvailableSchulungen() async {
    try {
      final response = await _httpClient.get('AvailableSchulungen');
      return _mapAvailableSchulungenResponse(response);
    } catch (e) {
      LoggerService.logError('Error fetching available Schulungen: $e');
      return [];
    }
  }

  List<Schulung> _mapAvailableSchulungenResponse(dynamic response) {
    if (response is! List) {
      LoggerService.logError('Expected List but got ${response.runtimeType}');
      return [];
    }

    return response
        .map((item) {
          if (item is! Map<String, dynamic>) {
            LoggerService.logError(
              'Expected Map<String, dynamic> but got ${item.runtimeType}',
            );
            return null;
          }

          try {
            return Schulung(
              id: item['SCHULUNGID'] as int? ?? 0,
              bezeichnung: item['BEZEICHNUNG'] as String? ?? '',
              datum: item['DATUM']?.toString() ?? '',
              ausgestelltAm: item['AUSGESTELLTAM']?.toString() ?? '',
              teilnehmerId: item['SCHULUNGENTEILNEHMERID'] as int? ?? 0,
              schulungsartId: item['SCHULUNGSARTID'] as int? ?? 0,
              schulungsartBezeichnung:
                  item['SCHULUNGSARTBEZEICHNUNG'] as String? ?? '',
              schulungsartKurzbezeichnung:
                  item['SCHULUNGSARTKURZBEZEICHNUNG'] as String? ?? '',
              schulungsartBeschreibung:
                  item['SCHULUNGSARTBESCHREIBUNG'] as String? ?? '',
              maxTeilnehmer: item['MAXTEILNEHMER'] as int? ?? 0,
              anzahlTeilnehmer: item['ANZAHLTEILNEHMER'] as int? ?? 0,
              ort: item['ORT'] as String? ?? '',
              uhrzeit: item['UHRZEIT']?.toString() ?? '',
              dauer: item['DAUER']?.toString() ?? '',
              preis: item['PREIS']?.toString() ?? '',
              zielgruppe: item['ZIELGRUPPE'] as String? ?? '',
              voraussetzungen: item['VORAUSSETZUNGEN'] as String? ?? '',
              inhalt: item['INHALT'] as String? ?? '',
              abschluss: item['ABSCHLUSS'] as String? ?? '',
              anmerkungen: item['ANMERKUNGEN'] as String? ?? '',
              isOnline: item['ISONLINE'] as bool? ?? false,
              link: item['LINK'] as String? ?? '',
              status: item['STATUS'] as String? ?? '',
              gueltigBis: item['GUELTIGBIS']?.toString() ?? '',
            );
          } catch (e) {
            LoggerService.logError('Error mapping Schulung: $e');
            return null;
          }
        })
        .whereType<Schulung>()
        .toList();
  }

  Future<List<Schulung>> fetchSchulungsarten() async {
    try {
      final response = await _httpClient.get('Schulungsarten/false');
      return _mapSchulungsartenResponse(response);
    } catch (e) {
      LoggerService.logError('Error fetching Schulungsarten: $e');
      return [];
    }
  }

  List<Schulung> _mapSchulungsartenResponse(dynamic response) {
    if (response is! List) {
      LoggerService.logError('Expected List but got ${response.runtimeType}');
      return [];
    }

    return response
        .map((item) {
          if (item is! Map<String, dynamic>) {
            LoggerService.logError(
              'Expected Map<String, dynamic> but got ${item.runtimeType}',
            );
            return null;
          }

          try {
            return Schulung(
              id: item['SCHULUNGSARTID'] as int? ?? 0,
              bezeichnung: item['BEZEICHNUNG'] as String? ?? '',
              datum: '', // Not applicable for training types
              ausgestelltAm: '', // Not applicable for training types
              teilnehmerId: 0, // Not applicable for training types
              schulungsartId: item['SCHULUNGSARTID'] as int? ?? 0,
              schulungsartBezeichnung: item['BEZEICHNUNG'] as String? ?? '',
              schulungsartKurzbezeichnung:
                  item['KURZBEZEICHNUNG'] as String? ?? '',
              schulungsartBeschreibung: item['BESCHREIBUNG'] as String? ?? '',
              maxTeilnehmer: 0, // Not applicable for training types
              anzahlTeilnehmer: 0, // Not applicable for training types
              ort: '', // Not applicable for training types
              uhrzeit: '', // Not applicable for training types
              dauer: '', // Not applicable for training types
              preis: '', // Not applicable for training types
              zielgruppe: '', // Not applicable for training types
              voraussetzungen: '', // Not applicable for training types
              inhalt: '', // Not applicable for training types
              abschluss: '', // Not applicable for training types
              anmerkungen: '', // Not applicable for training types
              isOnline: false, // Not applicable for training types
              link: '', // Not applicable for training types
              status: '', // Not applicable for training types
              gueltigBis: '', // Not applicable for training types
            );
          } catch (e) {
            LoggerService.logError('Error mapping Schulung: $e');
            return null;
          }
        })
        .whereType<Schulung>()
        .toList();
  }

  Future<List<Schulung>> fetchAbsolvierteSchulungen(int personId) async {
    try {
      final response = await _httpClient.get('AbsolvierteSchulungen/$personId');
      return _mapAbsolvierteSchulungenResponse(response);
    } catch (e) {
      LoggerService.logError('Error fetching absolvierte Schulungen: $e');
      return [];
    }
  }

  List<Schulung> _mapAbsolvierteSchulungenResponse(dynamic response) {
    if (response is! List) {
      LoggerService.logError('Expected List but got ${response.runtimeType}');
      return [];
    }

    return response
        .map((item) {
          if (item is! Map<String, dynamic>) {
            LoggerService.logError(
              'Expected Map<String, dynamic> but got ${item.runtimeType}',
            );
            return null;
          }

          try {
            return Schulung(
              id: item['SCHULUNGID'] as int? ?? 0,
              bezeichnung: item['BEZEICHNUNG'] as String? ?? '',
              datum: item['DATUM']?.toString() ?? '',
              ausgestelltAm: item['AUSGESTELLTAM']?.toString() ?? '',
              teilnehmerId: item['SCHULUNGENTEILNEHMERID'] as int? ?? 0,
              schulungsartId: item['SCHULUNGSARTID'] as int? ?? 0,
              schulungsartBezeichnung:
                  item['SCHULUNGSARTBEZEICHNUNG'] as String? ?? '',
              schulungsartKurzbezeichnung:
                  item['SCHULUNGSARTKURZBEZEICHNUNG'] as String? ?? '',
              schulungsartBeschreibung:
                  item['SCHULUNGSARTBESCHREIBUNG'] as String? ?? '',
              maxTeilnehmer: item['MAXTEILNEHMER'] as int? ?? 0,
              anzahlTeilnehmer: item['ANZAHLTEILNEHMER'] as int? ?? 0,
              ort: item['ORT'] as String? ?? '',
              uhrzeit: item['UHRZEIT']?.toString() ?? '',
              dauer: item['DAUER']?.toString() ?? '',
              preis: item['PREIS']?.toString() ?? '',
              zielgruppe: item['ZIELGRUPPE'] as String? ?? '',
              voraussetzungen: item['VORAUSSETZUNGEN'] as String? ?? '',
              inhalt: item['INHALT'] as String? ?? '',
              abschluss: item['ABSCHLUSS'] as String? ?? '',
              anmerkungen: item['ANMERKUNGEN'] as String? ?? '',
              isOnline: item['ISONLINE'] as bool? ?? false,
              link: item['LINK'] as String? ?? '',
              status: item['STATUS'] as String? ?? '',
              gueltigBis: item['GUELTIGBIS']?.toString() ?? '',
            );
          } catch (e) {
            LoggerService.logError('Error mapping Schulung: $e');
            return null;
          }
        })
        .whereType<Schulung>()
        .toList();
  }

  Future<bool> registerForSchulung(int personId, int schulungId) async {
    try {
      final response = await _httpClient.post('RegisterForSchulung', {
        'personId': personId,
        'schulungId': schulungId,
      });
      return response['ResultType'] == 1;
    } catch (e) {
      LoggerService.logError('Error registering for Schulung: $e');
      return false;
    }
  }

  Future<bool> unregisterFromSchulung(int teilnehmerId) async {
    try {
      final response = await _httpClient.delete(
        'SchulungenTeilnehmer/$teilnehmerId',
        body: {},
      );
      return response['result'] == true;
    } catch (e) {
      LoggerService.logError('Error unregistering from Schulung: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchDisziplinen() async {
    try {
      final response = await _httpClient.get('Disziplinen');
      if (response is! List) {
        return [];
      }
      return response.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      LoggerService.logError('Error fetching Disziplinen: $e');
      return [];
    }
  }
}
