import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import 'agb_common.dart';

class AgbScreen extends StatelessWidget {
  const AgbScreen({super.key});

  static const String agbText = '''
Allgemeine Geschäftsbedingungen für die Neuausstellung von Mitgliedsausweisen (AGB-MA)
1. Geltungsbereich
1.1 Diese Allgemeinen Geschäftsbedingungen für die Neuausstellung von physischen Mitgliedsausweisen (nachfolgend „AGB-MA“) des Bayerischen Sportschützenbundes e.V. (nachfolgend „BSSB“) gelten für alle Leistungen im Zusammenhang mit der Beantragung, Ausstellung und Zusendung von Mitgliedsausweisen des BSSB.

1.2 Abweichende oder ergänzende Geschäftsbedingungen des Antragstellers finden keine Anwendung, es sei denn, ihrer Geltung wurde ausdrücklich zugestimmt.
________________________________________
2. Art und Umfang der Leistung
2.1 Der BSSB stellt auf Antrag neue physische Mitgliedsausweise für seine Mitglieder aus. Dies umfasst insbesondere:
•	die Erfassung und Überprüfung der Mitgliedsdaten,
•	die Herstellung des physischen Ausweises,
•	sowie den postalischen Versand an den Antragsteller oder den zuständigen Verein.
2.2 Der Mitgliedsausweis dient dem Nachweis der Mitgliedschaft im BSSB und ggf. in einem dem BSSB angeschlossenen Verein.
________________________________________
3. Vertragsschluss
3.1 Der Antrag auf Neuausstellung eines Mitgliedsausweises kann entweder über ZMI durch den Verein oder über das Webportal „MeinBSSB“ durch das Mitglied selbst gestellt werden.

3.2 Durch Absenden des Antrags über das Webportal gibt der Antragsteller ein verbindliches Angebot auf Abschluss eines Vertrags über die Neuausstellung des Mitgliedsausweises ab.

3.3 Der Vertrag kommt zustande, sobald der BSSB den Antrag durch elektronische Bestätigung annimmt.
________________________________________
4. Preise und Zahlungsbedingungen
4.1 Für erwachsene Mitglieder in der Beitragsklasse „Schützen“ wird für die Neuausstellung eines Mitgliedsausweises eine Gebühr von 10 € erhoben.

4.2 Für Mitglieder in den Beitragsklassen „Schüler“, „Jugend“ und „Junioren“ erfolgt die Neuausstellung kostenfrei.

4.3 Alle Preise verstehen sich als Bruttopreise inklusive der gesetzlichen Umsatzsteuer.

4.4 Der Rechnungsbetrag wird im SEPA-Lastschriftverfahren abgebucht. Der Betrag ist sofort fällig. 
Indem der Antragsteller dem BSSB seine Bankverbindung mitteilt, ermächtigt er den BSSB, Zahlungen von seinem Bankkonto mittels Lastschrift einzuziehen. Zugleich weist er sein Kreditinstitut an, die vom BSSB auf sein Konto gezogenen Lastschriften einzulösen. Im Rahmen der mit seinem Kreditinstitut vereinbarten Bedingungen kann der Antragsteller innerhalb von acht Wochen, beginnend mit dem Belastungsdatum, die Erstattung des belasteten Betrages verlangen. 
Zur Erleichterung des Zahlungsverkehrs beträgt die Frist für die Information vor Einzug einer fälligen Zahlung mindestens einen Tag vor Belastung. 
Wenn seine Bank die Lastschrift aus Gründen ablehnt, für die der Antragsteller verantwortlich ist (z.B. unzureichende Kontodeckung), können wir zusätzlich zu dem Recht, den geschuldeten Betrag einzuziehen, eine zusätzliche Gebühr von 10€ erheben. Dies hat keinen Einfluss auf sein Recht, das Lastschriftmandat kostenlos zu widerrufen, soweit wir keinen Anspruch auf den entsprechenden Betrag gegen ihn haben oder, wenn er nachweisen kann, dass der Schaden überhaupt nicht eingetreten ist oder deutlich unter 10€ liegt. 
Der Antragsteller kann sein SEPA-Lastschriftmandat in seinen Kundenstammdaten auf dem Webportal „MeinBSSB“ einsehen und ändern. 
Durch das Hinterlegen einer neuen Bankverbindung übermittelt er uns ein neues SEPA-Lastschriftmandat, das automatisch mit den von ihm eingegebenen Daten in seinen Kundenstammdaten hinterlegt wird. 
Der Antragsteller kann sein SEPA-Lastschriftmandat jederzeit im Webportal „MeinBSSB“ stornieren. Indem er seine Bankverbindung löscht, storniert er gleichzeitig sein SEPA-Lastschriftmandat. Das Löschen Ihrer Bankverbindung wirkt sich nicht auf offene Bestellungen aus, die eingeleitet wurden.
________________________________________
5. Widerrufsrecht
Da der Mitgliedsausweis eine eindeutig personalisierte Ware im Sinne von § 312g Abs. 2 Nr. 1 BGB darstellt, besteht kein Widerrufsrecht.
Mit der Beantragung der Neuausstellung erklärt der Antragsteller ausdrücklich sein Einverständnis, dass der BSSB unmittelbar nach Eingang des Antrags mit der Erstellung des Ausweises beginnt.
Ein Widerruf nach Beantragung ist daher nicht möglich.
________________________________________
6. Haftung und Verlust
6.1 Der BSSB haftet nicht für Verzögerungen, die auf unvollständige oder fehlerhafte Angaben des Antragstellers zurückzuführen sind.

6.2 Bei Verlust oder Beschädigung des Mitgliedsausweises kann über das Webportal „MeinBSSB“ jederzeit ein Ersatz beantragt werden. Es gelten die unter Ziffer 4 genannten Gebührenregelungen.
________________________________________
7. Anwendbares Recht und Gerichtsstand
7.1 Für sämtliche Rechtsbeziehungen gilt das Recht der Bundesrepublik Deutschland unter Ausschluss des UN-Kaufrechts.

7.2 Ist der Antragsteller Kaufmann, juristische Person des öffentlichen Rechts oder öffentlich-rechtliches Sondervermögen, ist Gerichtsstand der Sitz des BSSB.

7.3 Verbraucher mit Wohnsitz außerhalb Deutschlands behalten die ihnen nach dem Recht ihres Aufenthaltsstaates zustehenden zwingenden Rechte.
________________________________________
Stand: 21.10.2025


''';

  @override
  Widget build(BuildContext context) {
    final List<AgbSection> sections = parseAgbText(agbText);
    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('AGB', style: UIStyles.appBarTitleStyle),
        backgroundColor: UIConstants.backgroundColor,
        elevation: UIConstants.appBarElevation,
        iconTheme: const IconThemeData(color: UIConstants.textColor),
      ),
      body: Semantics(
        label:
            'Allgemeine Geschäftsbedingungen des Bayerischen Sportschützenbundes. Enthält alle relevanten Vertragsbedingungen, Widerrufsbelehrungen und Zahlungsinformationen für Seminare und Schulungen.',
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(
                vertical: UIConstants.spacingL,
                horizontal: UIConstants.spacingM,
              ),
              padding: UIConstants.defaultPadding,
              decoration: BoxDecoration(
                color: UIConstants.cardColor,
                borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
                boxShadow: UIStyles.cardDecoration.boxShadow,
              ),
              child: Builder(
                builder: (context) {
                  final List<AgbSection> mainSections = List.from(sections);
                  String? footer;
                  if (mainSections.isNotEmpty &&
                      mainSections.last.paragraphs.isNotEmpty) {
                    final lastParas = mainSections.last.paragraphs;
                    final lastLine = lastParas.last.trim();
                    if (lastLine.startsWith('Stand:')) {
                      footer = lastLine;
                      lastParas.removeLast();
                      if (lastParas.isEmpty) {
                        mainSections.removeLast();
                      }
                    }
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final section in mainSections) ...[
                        if (section.title != null) ...[
                          Text(
                            section.title!,
                            style: UIStyles.sectionTitleStyle,
                          ),
                          UIConstants.verticalSpacingS,
                        ],
                        for (final para in section.paragraphs) ...[
                          if (RegExp(r'^\d+(?:\.\d+)*\.\s*').hasMatch(para) &&
                              !para.startsWith('Stand:'))
                            buildNumberedParagraph(para)
                          else
                            Text(para, style: UIStyles.bodyStyle),
                          UIConstants.verticalSpacingXS,
                        ],
                        UIConstants.verticalSpacingM,
                      ],
                      if (footer != null)
                        Padding(
                          padding: const EdgeInsets.only(
                            top: UIConstants.spacingS,
                          ),
                          child: Text(
                            footer,
                            style: UIStyles.bodyStyle.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pop(),
        backgroundColor: UIConstants.defaultAppColor,
        child: const Icon(Icons.close, color: UIConstants.whiteColor),
      ),
    );
  }
}
