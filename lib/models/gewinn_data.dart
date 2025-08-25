import 'package:flutter/foundation.dart';

@immutable
class Gewinn {

  const Gewinn({
    required this.gewinnId,
    required this.jahr,
    required this.tradition,
    required this.isSachpreis,
    required this.geldpreis,
    required this.sachpreis,
    required this.wettbewerb,
    required this.abgerufenAm,
    required this.platz,
  });

  factory Gewinn.fromJson(Map<String, dynamic> json) {
    return Gewinn(
      gewinnId: json['GEWINNID'] as int,
      jahr: json['JAHR'] as int,
      tradition: json['TRADITION'] as bool,
      isSachpreis: json['ISSACHPREIS'] as bool,
      geldpreis: json['GELDPREIS'] is int
          ? json['GELDPREIS'] as int
          : (json['GELDPREIS'] as num),
      sachpreis: json['SACHPREIS'] as String,
      wettbewerb: json['WETTBEWERB'] as String,
      abgerufenAm: json['ABGERUFENAM'] as String,
      platz: json['PLATZ'] as int,
    );
  }
  final int gewinnId;
  final int jahr;
  final bool tradition;
  final bool isSachpreis;
  final num geldpreis;
  final String sachpreis;
  final String wettbewerb;
  final String abgerufenAm;
  final int platz;

  Map<String, dynamic> toJson() {
    return {
      'GEWINNID': gewinnId,
      'JAHR': jahr,
      'TRADITION': tradition,
      'ISSACHPREIS': isSachpreis,
      'GELDPREIS': geldpreis,
      'SACHPREIS': sachpreis,
      'WETTBEWERB': wettbewerb,
      'ABGERUFENAM': abgerufenAm,
      'PLATZ': platz,
    };
  }
}
