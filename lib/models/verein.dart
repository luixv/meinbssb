import 'package:flutter/foundation.dart';

/// Represents a Verein (club/association) in the BSSB system.
/// This model is used to store and manage club information such as
/// name, location, contact details, and administrative data.
@immutable
class Verein {
  /// Creates a [Verein] instance from a JSON map.
  factory Verein.fromJson(Map<String, dynamic> json) {
    return Verein(
      id: json['VEREINID'] as int,
      vereinsNr: json['VEREINNR'] as String,
      name: json['VEREINNAME'] as String,
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
      gauId: json['GAUID'] as int?,
      gauNr: json['GAUNR'] as String?,
      gauName: json['GAUNAME'] as String?,
      bezirkId: json['BEZIRKID'] as int?,
      bezirkNr: json['BEZIRKNR'] as String?,
      bezirkName: json['BEZIRKNAME'] as String?,
      lat: json['LAT'] as double?,
      lon: json['LON'] as double?,
      geocodeQuelle: json['GEOCODEQUELLE'] as String?,
      facebook: json['FACEBOOK'] as String?,
      instagram: json['INSTAGRAM'] as String?,
      xTwitter: json['XTWITTER'] as String?,
      tiktok: json['TIKTOK'] as String?,
      twitch: json['TWITCH'] as String?,
      anzahlMitglieder: json['ANZAHLMITGLIEDER'] as int?,
    );
  }

  /// Creates a new instance of [Verein].
  const Verein({
    required this.id,
    required this.vereinsNr,
    required this.name,
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
    this.gauId,
    this.gauNr,
    this.gauName,
    this.bezirkId,
    this.bezirkNr,
    this.bezirkName,
    this.lat,
    this.lon,
    this.geocodeQuelle,
    this.facebook,
    this.instagram,
    this.xTwitter,
    this.tiktok,
    this.twitch,
    this.anzahlMitglieder,
  });

  /// The unique identifier for the Verein.
  final int id;

  /// The Verein's registration number.
  final String vereinsNr;

  /// The name of the Verein.
  final String name;

  /// The street address of the Verein.
  final String? strasse;

  /// The postal code of the Verein's location.
  final String? plz;

  /// The city/town of the Verein's location.
  final String? ort;

  /// The Verein's phone number.
  final String? telefon;

  /// The Verein's email address.
  final String? email;

  /// The Verein's website URL.
  final String? homepage;

  /// The Verein's opening hours.
  final String? oeffnungszeiten;

  /// The last name of the contact person.
  final String? namen;

  /// The first name of the contact person.
  final String? vorname;

  /// The postal address street of the contact person.
  final String? pStrasse;

  /// The postal address postal code of the contact person.
  final String? pPlz;

  /// The postal address city of the contact person.
  final String? pOrt;

  /// The email address of the contact person.
  final String? pEmail;

  /// The ID of the Gau (district) the Verein belongs to.
  final int? gauId;

  /// The number of the Gau the Verein belongs to.
  final String? gauNr;

  /// The name of the Gau the Verein belongs to.
  final String? gauName;

  /// The ID of the Bezirk (region) the Verein belongs to.
  final int? bezirkId;

  /// The number of the Bezirk the Verein belongs to.
  final String? bezirkNr;

  /// The name of the Bezirk the Verein belongs to.
  final String? bezirkName;

  /// The latitude coordinate of the Verein's location.
  final double? lat;

  /// The longitude coordinate of the Verein's location.
  final double? lon;

  /// The source of the geocoding data.
  final String? geocodeQuelle;

  /// The Verein's Facebook page URL.
  final String? facebook;

  /// The Verein's Instagram profile URL.
  final String? instagram;

  /// The Verein's X (Twitter) profile URL.
  final String? xTwitter;

  /// The Verein's TikTok profile URL.
  final String? tiktok;

  /// The Verein's Twitch channel URL.
  final String? twitch;

  /// The number of members in the Verein.
  final int? anzahlMitglieder;

  /// Converts the [Verein] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'VEREINID': id,
      'VEREINNR': vereinsNr,
      'VEREINNAME': name,
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
      'GAUID': gauId,
      'GAUNR': gauNr,
      'GAUNAME': gauName,
      'BEZIRKID': bezirkId,
      'BEZIRKNR': bezirkNr,
      'BEZIRKNAME': bezirkName,
      'LAT': lat,
      'LON': lon,
      'GEOCODEQUELLE': geocodeQuelle,
      'FACEBOOK': facebook,
      'INSTAGRAM': instagram,
      'XTWITTER': xTwitter,
      'TIKTOK': tiktok,
      'TWITCH': twitch,
      'ANZAHLMITGLIEDER': anzahlMitglieder,
    };
  }
}
