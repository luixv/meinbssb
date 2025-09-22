class SchulungstermineZusatzfelder {
  factory SchulungstermineZusatzfelder.fromJson(Map<String, dynamic> json) {
    return SchulungstermineZusatzfelder(
      schulungstermineFeldId: json['SCHULUNGENTERMINEFELDID'] as int,
      schulungsterminId: json['SCHULUNGENTERMINID'] as int,
      feldbezeichnung: json['FELDBEZEICHNUNG'] as String,
    );
  }

  const SchulungstermineZusatzfelder({
    required this.schulungstermineFeldId,
    required this.schulungsterminId,
    required this.feldbezeichnung,
  });
  final int schulungstermineFeldId;
  final int schulungsterminId;
  final String feldbezeichnung;

  Map<String, dynamic> toJson() {
    return {
      'SCHULUNGENTERMINEFELDID': schulungstermineFeldId,
      'SCHULUNGENTERMINID': schulungsterminId,
      'FELDBEZEICHNUNG': feldbezeichnung,
    };
  }
}
