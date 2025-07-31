import 'package:flutter/material.dart';

class OktoberfestEintrittFestzelt extends StatelessWidget {
  const OktoberfestEintrittFestzelt({
    super.key,
    required this.date,
    required this.passnummer,
    required this.vorname,
    required this.nachname,
    required this.geburtsdatum,
  });
  final String date;
  final String passnummer;
  final String vorname;
  final String nachname;
  final String geburtsdatum;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eintritt Festzelt'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Datum: $date', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 10),
            Text(
              'Passnummer: $passnummer',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Vorname: $vorname',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Nachname: $nachname',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Geburtsdatum: $geburtsdatum',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
