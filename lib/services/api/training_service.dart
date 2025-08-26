import 'dart:async';
import '../../models/schulung_data.dart';
import '../../models/disziplin_data.dart';
import '../../models/schulungsart_data.dart';
import '/services/core/cache_service.dart';
import '/services/core/http_client.dart';
import '/services/core/logger_service.dart';
import '/services/core/network_service.dart';
import '/services/core/config_service.dart';

import '../../models/schulungstermin_data.dart';
import '../../models/register_schulungen_teilnehmer_response_data.dart';
import '/models/user_data.dart';
import '/models/bank_data.dart';

class TrainingService {
  TrainingService({
    required HttpClient httpClient,
    required CacheService cacheService,
    required NetworkService networkService,
    required ConfigService configService,
  })  : _httpClient = httpClient,
        _cacheService = cacheService,
        _networkService = networkService,
        _configService = configService;

  final HttpClient _httpClient;
  final CacheService _cacheService;
  final NetworkService _networkService;
  final ConfigService _configService;

  Future<List<Schulungstermin>> fetchAngemeldeteSchulungen(
    int personId,
    String abDatum,
  ) async {
    final cacheKey = 'schulungen_$personId';
    final cacheDuration = _networkService.getCacheExpirationDuration();

    try {
      final endpoint = 'AngemeldeteSchulungen/$personId/$abDatum';
      final result = await _cacheService.cacheAndRetrieveData<List<dynamic>>(
        cacheKey,
        cacheDuration,
        () async {
          final response = await _httpClient.get(
            endpoint,
          );
          final mapped = _mapAngemeldeteSchulungenResponse(response);
          // Only cache minimal fields
          return mapped
              .map(
                (s) => {
                  'SCHULUNGENTERMINID': s.schulungsterminId,
                  'SCHULUNGENTEILNEHMERID': s.schulungsTeilnehmerId,
                  'DATUM': s.datum.toIso8601String(),
                  'KOSTEN': s.kosten,
                  'ORT': s.ort,
                  'MAXTEILNEHMER': s.maxTeilnehmer,
                  'ANGEMELDETETEILNEHMER': s.angemeldeteTeilnehmer,
                  'STATUS': s.status,
                  'BEZEICHNUNG': s.bezeichnung,
                  'WEBGRUPPE': s.webGruppe,
                },
              )
              .toList();
        },
        (data) {
          // Ensure the cached data is properly typed
          if (data is List) {
            return data.map((item) {
              if (item is Map<String, dynamic>) {
                return item;
              } else if (item is Map) {
                return Map<String, dynamic>.from(item);
              } else {
                LoggerService.logWarning(
                  'Unexpected item type in cached schulungen: \\${item.runtimeType}',
                );
                return <String, dynamic>{};
              }
            }).toList();
          }
          return <dynamic>[];
        },
      );

      return result
          .whereType<Map<String, dynamic>>()
          .map((json) => Schulungstermin.fromJson(json))
          .toList();
    } catch (e) {
      LoggerService.logError('Error fetching schulungen: $e');
      return [];
    }
  }

  List<Schulungstermin> _mapAngemeldeteSchulungenResponse(dynamic response) {
    if (response is! List) {
      LoggerService.logError('Expected List but got \\${response.runtimeType}');
      return [];
    }

    return response
        .map((item) {
          if (item is! Map<String, dynamic>) {
            LoggerService.logError(
              'Expected Map<String, dynamic> but got \\${item.runtimeType}',
            );
            return null;
          }
          try {
            return Schulungstermin.fromJson(item);
          } catch (e) {
            LoggerService.logError('Error mapping Schulungstermin: $e');
            return null;
          }
        })
        .whereType<Schulungstermin>()
        .toList();
  }

/* 
/Schulungstermine/{AbDatum}/{Ort}/{Webgruppe}/{Veranstaltungsbezirk}/{FuerVerlaengerung}/{Bezeichnung}
*/
  Future<List<Schulungstermin>> fetchSchulungstermine(
    String abDatum,
    String webGruppe,
    String bezirk,
    String fuerVerlaengerung,
  ) async {
    try {
      String endpoint =
          'Schulungstermine/$abDatum/*/$webGruppe/$bezirk/$fuerVerlaengerung/*';

      LoggerService.logInfo(
        'endpoint $endpoint',
      );

      final baseUrl =
          ConfigService.buildBaseUrlForServer(_configService, name: 'api1Base');

      final response =
          await _httpClient.get(endpoint, overrideBaseUrl: baseUrl);

      final mappedTermine = _mapSchulungstermineResponseToTermine(response);
      LoggerService.logInfo(
        'Mapped ${mappedTermine.length} termine from response',
      );

      final termine = mappedTermine.where((t) {
        // Status darf NICHT 2 sein!
        if (t.status == 2) {
          return false;
        }
        // webVeroeffentlichenAm ist leer ODER jetzt > Veröffentlichungsdatum (stundengenau)
        if (t.webVeroeffentlichenAm.isEmpty) {
          return true;
        }
        try {
          final veroeff = DateTime.parse(t.webVeroeffentlichenAm);
          final shouldInclude = DateTime.now().isAfter(veroeff);
          return shouldInclude;
        } catch (e) {
          return false;
        }
      }).toList();

      LoggerService.logInfo(
        'After filtering: ${termine.length} termine remaining',
      );
      termine.sort((a, b) => a.datum.compareTo(b.datum));
      return termine;
    } catch (e) {
      LoggerService.logError('Error fetching available Schulungstermine: $e');
      return [];
    }
  }

  List<Schulungstermin> _mapSchulungstermineResponseToTermine(
    dynamic response,
  ) {
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
            return Schulungstermin.fromJson(item);
          } catch (e) {
            LoggerService.logError('Error mapping Schulungstermine: $e');
            return null;
          }
        })
        .whereType<Schulungstermin>()
        .toList();
  }

  Future<List<Schulungsart>> fetchSchulungsarten() async {
    const endpoint = 'Schulungsarten/false';
    try {
      final response = await _httpClient.get(endpoint);
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
      final endpoint = 'AbsolvierteSchulungen/$personId';
      final response = await _httpClient.get(endpoint);
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
      const endpoint = 'RegisterForSchulung';
      final response = await _httpClient.post(endpoint, {
        'personId': personId,
        'schulungId': schulungId,
      });
      final success = response['ResultType'] == 1;
      if (success) {
        // Clear the schulungen cache after successful registration
        await clearSchulungenCache(personId);
      }
      return success;
    } catch (e) {
      LoggerService.logError('Error registering for Schulung: $e');
      return false;
    }
  }

  Future<bool> unregisterFromSchulung(int schulungenTeilnehmerId) async {
    try {
      final endpoint = 'SchulungenTeilnehmer/$schulungenTeilnehmerId';

      final response = await _httpClient.delete(
        endpoint,
        body: {},
      );
      final success = response['result'] == true;
      if (success) {
        // Clear the schulungen cache after successful unregistration
        // We need to get the personId from the response or pass it as parameter
        // For now, we'll clear all schulungen caches
        await clearAllSchulungenCache();
      }
      return success;
    } catch (e) {
      LoggerService.logError('Error unregistering from Schulung: $e');
      return false;
    }
  }

  /// Clears the cache for a specific person's schulungen
  Future<void> clearSchulungenCache(int personId) async {
    try {
      final cacheKey = 'schulungen_$personId';
      await _cacheService.remove(cacheKey);
      LoggerService.logInfo('Cleared schulungen cache for personId: $personId');
    } catch (e) {
      LoggerService.logError('Error clearing schulungen cache: $e');
    }
  }

  /// Clears all schulungen caches (used when we don't have the specific personId)
  Future<void> clearAllSchulungenCache() async {
    try {
      await _cacheService.clearPattern('schulungen_');
      LoggerService.logInfo('Cleared all schulungen cache entries');
    } catch (e) {
      LoggerService.logError('Error clearing all schulungen cache: $e');
    }
  }

  Future<List<Disziplin>> fetchDisziplinen() async {
    const cacheKey = 'disziplinen';
    final cacheDuration = _networkService.getCacheExpirationDuration();

    try {
      const endpoint = 'Disziplinen';
      final result = await _cacheService.cacheAndRetrieveData<List<dynamic>>(
        cacheKey,
        cacheDuration,
        () async {
          final response = await _httpClient.get(endpoint);
          if (response is! List) {
            return [];
          }
          return response
              .map((item) {
                try {
                  if (item is Map<String, dynamic>) {
                    return Disziplin.fromJson(item).toJson();
                  }
                  return null;
                } catch (e) {
                  LoggerService.logError('Error mapping Disziplin: $e');
                  return null;
                }
              })
              .whereType<Map<String, dynamic>>()
              .toList();
        },
        (data) {
          // Ensure the cached data is properly typed
          if (data is List) {
            return data.map((item) {
              if (item is Map<String, dynamic>) {
                return item;
              } else if (item is Map) {
                return Map<String, dynamic>.from(item);
              } else {
                LoggerService.logWarning(
                  'Unexpected item type in cached disziplinen: ${item.runtimeType}',
                );
                return <String, dynamic>{};
              }
            }).toList();
          }
          return <dynamic>[];
        },
      );

      return result
          .whereType<Map<String, dynamic>>()
          .map((json) => Disziplin.fromJson(json))
          .toList();
    } catch (e) {
      LoggerService.logError('Error fetching Disziplinen: $e');
      return [];
    }
  }

  /// Clears the disziplinen cache
  Future<void> clearDisziplinenCache() async {
    try {
      const cacheKey = 'disziplinen';
      await _cacheService.remove(cacheKey);
      LoggerService.logInfo('Cleared disziplinen cache');
    } catch (e) {
      LoggerService.logError('Error clearing disziplinen cache: $e');
    }
  }

  /// Registers a participant for a training event (Schulungstermin).
  Future<RegisterSchulungenTeilnehmerResponse> registerSchulungenTeilnehmer({
    required int schulungTerminId,
    required UserData user,
    required String email,
    required String telefon,
    required BankData bankData,
    required List<Map<String, dynamic>> felderArray,
  }) async {
    final body = {
      'SchulungTerminID': schulungTerminId,
      'PersonID': user.personId,
      'Namen': user.namen,
      'Vorname': user.vorname,
      'Titel': user.titel ?? '',
      'Passnummer': user.passnummer,
      'Nummer': '',
      'Email': email,
      'Geschlecht': user.geschlecht ?? 0,
      'RechnungAn': 0,
      'Strasse': user.strasse ?? '',
      'PLZ': user.plz ?? '',
      'ORT': user.ort ?? '',
      'Kosten': 0,
      'Verpflegung': 0,
      'Uebernachtung': 0,
      'Lehrmaterial': 0,
      'AngemeldetUeber ': '',
      'Bemerkung': '',
      'Bankdaten': {
        'Kontoinhaber': bankData.kontoinhaber,
        'Bankname': bankData.bankName,
        'IBAN': bankData.iban,
        'BIC': bankData.bic,
        'MandatNr': bankData.mandatNr,
        'Mandatname': bankData.mandatName,
        'MandatSeq': bankData.mandatSeq,
      },
      'AngemeldetUeberEmail': '',
      'AngemeldetUeberTelefon': '',
      'Telefon': telefon,
      'VereinID': user.vereinNr,
      'FelderArray': felderArray,
    };

    const endpoint = 'SchulungenTeilnehmer';

    try {
      final response = await _httpClient.post(
        endpoint,
        body,
      );
      final result = RegisterSchulungenTeilnehmerResponse.fromJson(response);

      // Clear the schulungen cache after successful registration
      // Check if the response indicates success (platz > 0 means successful registration)
      if (result.platz > 0) {
        await clearSchulungenCache(user.personId);
      }

      return result;
    } catch (e) {
      LoggerService.logError('Error registering Schulungen Teilnehmer: $e');
      rethrow;
    }
  }

  /// Fetch a single Schulungstermin by its ID.
  Future<Schulungstermin?> fetchSchulungstermin(
    String schulungenTerminID,
  ) async {
    try {
      final baseUrl =
          ConfigService.buildBaseUrlForServer(_configService, name: 'api1Base');

      final endpoint = 'Schulungstermin/$schulungenTerminID';
      final response =
          await _httpClient.get(endpoint, overrideBaseUrl: baseUrl);

      Map<String, dynamic>? data;
      if (response is Map<String, dynamic>) {
        data = response;
      } else if (response is List &&
          response.isNotEmpty &&
          response.first is Map<String, dynamic>) {
        data = response.first as Map<String, dynamic>;
      }
      if (data != null) {
        return Schulungstermin.fromJson(data);
      } else {
        LoggerService.logError(
          'Unexpected response type for fetchSchulungstermin: \\${response.runtimeType}',
        );
        return null;
      }
    } catch (e) {
      LoggerService.logError(
        'Error fetching Schulungstermin: \\${e.toString()}',
      );
      return null;
    }
  }
}
