import 'dart:async';
import '/models/schulung.dart';
import '/models/disziplin.dart';
import '/models/schulungsart.dart';
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
          return _mapAngemeldeteSchulungenResponse(
            response,
          ).map((s) => s.toJson()).toList();
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
              lehrgangsinhaltHtml: '',
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

  Future<List<Schulung>> fetchSchulungstermine(String abDatum) async {
    try {
      final response = await _httpClient.get('Schulungstermine/$abDatum/false');
      final mappedSchulungen = _mapSchulungstermineResponse(response);
      return mappedSchulungen;
    } catch (e) {
      LoggerService.logError('Error fetching available Schulungen: $e');
      return [];
    }
  }

  List<Schulung> _mapSchulungstermineResponse(dynamic response) {
    if (response is! List) {
      LoggerService.logError('Expected List but got ${response.runtimeType}');
      return [];
    }

    return response
        .map((item) {
          if (item is! Map) {
            LoggerService.logError(
              'Expected Map but got ${item.runtimeType}',
            );
            return null;
          }
          final map = Map<String, dynamic>.from(item);
          try {
            return Schulung(
              id: map['SCHULUNGENTERMINID'] as int? ?? 0,
              bezeichnung: map['BEZEICHNUNG'] as String? ?? '',
              datum: map['DATUM']?.toString() ?? '',
              ausgestelltAm: '', // not in response
              teilnehmerId: 0, // not in response
              schulungsartId: map['SCHULUNGSARTID'] as int? ?? 0,
              schulungsartBezeichnung: '', // not in response
              schulungsartKurzbezeichnung: '', // not in response
              schulungsartBeschreibung: '', // not in response
              maxTeilnehmer: map['MAXTEILNEHMER'] as int? ?? 0,
              anzahlTeilnehmer: map['ANGEMELDETETEILNEHMER'] as int? ?? 0,
              ort: map['ORT'] as String? ?? '',
              uhrzeit: '', // not in response
              dauer: '', // not in response
              preis: map['KOSTEN']?.toString() ?? '',
              zielgruppe: '', // not in response
              voraussetzungen: '', // not in response
              inhalt: map['LEHRGANGSINHALT'] as String? ?? '',
              lehrgangsinhaltHtml: map['LEHRGANGSINHALTHTML'] as String? ?? '',
              abschluss: '', // not in response
              anmerkungen: map['BEMERKUNG'] as String? ?? '',
              isOnline: false, // not in response
              link: '', // not in response
              status: map['STATUS']?.toString() ?? '',
              gueltigBis: map['DATUMBIS']?.toString() ?? '',
            );
          } catch (e) {
            LoggerService.logError('Error mapping Schulung: $e');
            return null;
          }
        })
        .whereType<Schulung>()
        .toList();
  }

  Future<List<Schulungsart>> fetchSchulungsarten() async {
    try {
      final response = await _httpClient.get('Schulungsarten/false');
      return _mapSchulungsartenResponse(response);
    } catch (e) {
      LoggerService.logError('Error fetching Schulungsarten: $e');
      return [];
    }
  }

  List<Schulungsart> _mapSchulungsartenResponse(dynamic response) {
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
            return Schulungsart(
              schulungsartId: item['SCHULUNGSARTID'] as int? ?? 0,
              bezeichnung: item['BEZEICHNUNG'] as String? ?? '',
              typ: item['TYP'] as int? ?? 0,
              kosten: (item['KOSTEN'] as num?)?.toDouble() ?? 0.0,
              ue: item['UE'] as int? ?? 0,
              omKategorieId: item['OMKATEGORIEID'] as int? ?? 0,
              rechnungAn: item['RECHNUNGAN'] as int? ?? 0,
              verpflegungskosten:
                  (item['VERPFLEGUNGSKOSTEN'] as num?)?.toDouble() ?? 0.0,
              uebernachtungskosten:
                  (item['UEBERNACHTUNGSKOSTEN'] as num?)?.toDouble() ?? 0.0,
              lehrmaterialkosten:
                  (item['LEHRMATERIALKOSTEN'] as num?)?.toDouble() ?? 0.0,
              lehrgangsinhalt: item['LEHRGANGSINHALT'] as String? ?? '',
              lehrgangsinhaltHtml: item['LEHRGANGSINHALTHTML'] as String? ?? '',
              webGruppe: item['WEBGRUPPE'] as int? ?? 0,
              fuerVerlaengerungen:
                  item['FUERVERLAENGERUNGEN'] as bool? ?? false,
            );
          } catch (e) {
            LoggerService.logError('Error mapping Schulungsart: $e');
            return null;
          }
        })
        .whereType<Schulungsart>()
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
              lehrgangsinhaltHtml: '',
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

  Future<List<Disziplin>> fetchDisziplinen() async {
    try {
      final response = await _httpClient.get('Disziplinen');
      if (response is! List) {
        return [];
      }
      return response
          .map((item) {
            try {
              if (item is Map<String, dynamic>) {
                return Disziplin.fromJson(item);
              }

              return null;
            } catch (e) {
              LoggerService.logError('Error mapping Disziplin: $e');
              return null;
            }
          })
          .whereType<Disziplin>()
          .toList();
    } catch (e) {
      LoggerService.logError('Error fetching Disziplinen: $e');
      return [];
    }
  }
}
