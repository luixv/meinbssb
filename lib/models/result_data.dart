import 'package:flutter/foundation.dart';

@immutable
class Result {
  const Result({
    required this.wettbewerb,
    required this.platz,
    required this.gesamt,
    required this.postfix,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      wettbewerb: json['WETTBEWERB'] as String,
      platz: json['PLATZ'] as int,
      gesamt: json['GESAMT'] is int
          ? json['GESAMT'] as num
          : (json['GESAMT'] as num),
      postfix: json['POSTFIX'] as String,
    );
  }

  final String wettbewerb;
  final int platz;
  final num gesamt;
  final String postfix;

  Map<String, dynamic> toJson() {
    return {
      'WETTBEWERB': wettbewerb,
      'PLATZ': platz,
      'GESAMT': gesamt,
      'POSTFIX': postfix,
    };
  }
}
