import 'package:flutter/foundation.dart';

@immutable
class Bezirk {
  const Bezirk({
    required this.bezirkId,
    required this.bezirkNr,
    required this.bezirkName,
    this.strasse,
    this.plz,
    this.ort,
    this.telefon,
    this.email,
    this.homepage,
    this.oeffnungszeiten,
    this.namen,
    this.vorname,
    this.pStrasse,
    this.pPlz,
    this.pOrt,
    this.pEmail,
    this.lat,
    this.lon,
    this.facebook,
    this.instagram,
    this.xTwitter,
    this.tiktok,
    this.twitch,
    this.anzahlMitglieder,
    this.geocodeQuelle,
  });

  factory Bezirk.fromJson(Map<String, dynamic> json) {
    return Bezirk(
      bezirkId: json['BEZIRKID'] as int,
      bezirkNr: json['BEZIRKNR'] as int,
      bezirkName: json['BEZIRKNAME'] as String,
      strasse: json['STRASSE'] as String?,
      plz: json['PLZ'] as String?,
      ort: json['ORT'] as String?,
      telefon: json['TELEFON'] as String?,
      email: json['EMAIL'] as String?,
      homepage: json['HOMEPAGE'] as String?,
      oeffnungszeiten: json['OEFFNUNGSZEITEN'] as String?,
      namen: json['NAMEN'] as String?,
      vorname: json['VORNAME'] as String?,
      pStrasse: json['P_STRASSE'] as String?,
      pPlz: json['P_PLZ'] as String?,
      pOrt: json['P_ORT'] as String?,
      pEmail: json['P_EMAIL'] as String?,
      lat: (json['LAT'] as num?)?.toDouble(),
      lon: (json['LON'] as num?)?.toDouble(),
      facebook: json['FACEBOOK'] as String?,
      instagram: json['INSTAGRAM'] as String?,
      xTwitter: json['XTWITTER'] as String?,
      tiktok: json['TIKTOK'] as String?,
      twitch: json['TWITCH'] as String?,
      anzahlMitglieder: json['ANZAHLMITGLIEDER'] as int?,
      geocodeQuelle: json['GEOCODEQUELLE'] as int?,
    );
  }

  final int bezirkId;
  final int bezirkNr;
  final String bezirkName;
  final String? strasse;
  final String? plz;
  final String? ort;
  final String? telefon;
  final String? email;
  final String? homepage;
  final String? oeffnungszeiten;
  final String? namen;
  final String? vorname;
  final String? pStrasse;
  final String? pPlz;
  final String? pOrt;
  final String? pEmail;
  final double? lat;
  final double? lon;
  final String? facebook;
  final String? instagram;
  final String? xTwitter;
  final String? tiktok;
  final String? twitch;
  final int? anzahlMitglieder;
  final int? geocodeQuelle;

  Map<String, dynamic> toJson() {
    return {
      'BEZIRKID': bezirkId,
      'BEZIRKNR': bezirkNr,
      'BEZIRKNAME': bezirkName,
      'STRASSE': strasse,
      'PLZ': plz,
      'ORT': ort,
      'TELEFON': telefon,
      'EMAIL': email,
      'HOMEPAGE': homepage,
      'OEFFNUNGSZEITEN': oeffnungszeiten,
      'NAMEN': namen,
      'VORNAME': vorname,
      'P_STRASSE': pStrasse,
      'P_PLZ': pPlz,
      'P_ORT': pOrt,
      'P_EMAIL': pEmail,
      'LAT': lat,
      'LON': lon,
      'FACEBOOK': facebook,
      'INSTAGRAM': instagram,
      'XTWITTER': xTwitter,
      'TIKTOK': tiktok,
      'TWITCH': twitch,
      'ANZAHLMITGLIEDER': anzahlMitglieder,
      'GEOCODEQUELLE': geocodeQuelle,
    };
  }
}
