class RegisterSchulungenTeilnehmerResponse {
  RegisterSchulungenTeilnehmerResponse({
    required this.msg,
    required this.platz,
    required this.maxPlaetze,
  });

  factory RegisterSchulungenTeilnehmerResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return RegisterSchulungenTeilnehmerResponse(
      msg: json['msg'] ?? '',
      platz: json['Platz'] ?? 0,
      maxPlaetze: json['MaxPlaetze'] ?? 0,
    );
  }
  final String msg;
  final int platz;
  final int maxPlaetze;
}
