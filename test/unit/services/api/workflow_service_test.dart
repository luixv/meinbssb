import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/beduerfnisse_antrag_status_data.dart';
import 'package:meinbssb/services/api/workflow_service.dart';

void main() {
  late WorkflowService workflowService;

  setUp(() {
    workflowService = WorkflowService();
  });

  group('WorkflowService.canTransition', () {
    group('Gültige Übergänge von Entwurf', () {
      test(
        'Erlaubt Mitglied, von Entwurf zu Eingereicht am Verein zu wechseln',
        () {
          final result = workflowService.canAntragChangeFromStateToState(
            currentState: BeduerfnisAntragStatus.entwurf,
            nextState: BeduerfnisAntragStatus.eingereichtAmVerein,
            userRole: WorkflowRole.mitglied,
          );
          expect(result, isTrue);
        },
      );

      test(
        'Verweigert Verein, von Entwurf zu Eingereicht am Verein zu wechseln',
        () {
          final result = workflowService.canAntragChangeFromStateToState(
            currentState: BeduerfnisAntragStatus.entwurf,
            nextState: BeduerfnisAntragStatus.eingereichtAmVerein,
            userRole: WorkflowRole.verein,
          );
          expect(result, isFalse);
        },
      );

      test(
        'Verweigert BSSB, von Entwurf zu Eingereicht am Verein zu wechseln',
        () {
          final result = workflowService.canAntragChangeFromStateToState(
            currentState: BeduerfnisAntragStatus.entwurf,
            nextState: BeduerfnisAntragStatus.eingereichtAmVerein,
            userRole: WorkflowRole.bssb,
          );
          expect(result, isFalse);
        },
      );
    });

    group('Gültige Übergänge von Eingereicht am Verein', () {
      test(
        'Erlaubt Verein, von Eingereicht am Verein zu Genehmight von Verein zu wechseln',
        () {
          final result = workflowService.canAntragChangeFromStateToState(
            currentState: BeduerfnisAntragStatus.eingereichtAmVerein,
            nextState: BeduerfnisAntragStatus.genehmightVonVerein,
            userRole: WorkflowRole.verein,
          );
          expect(result, isTrue);
        },
      );

      test(
        'Erlaubt Verein, von Eingereicht am Verein zu Zurückgewiesen an Mitglied zu wechseln',
        () {
          final result = workflowService.canAntragChangeFromStateToState(
            currentState: BeduerfnisAntragStatus.eingereichtAmVerein,
            nextState:
                BeduerfnisAntragStatus.zurueckgewiesenAnMitgliedVonVerein,
            userRole: WorkflowRole.verein,
          );
          expect(result, isTrue);
        },
      );

      test(
        'Erlaubt Verein, von Eingereicht am Verein zu Abgelehnt zu wechseln',
        () {
          final result = workflowService.canAntragChangeFromStateToState(
            currentState: BeduerfnisAntragStatus.eingereichtAmVerein,
            nextState: BeduerfnisAntragStatus.abgelehnt,
            userRole: WorkflowRole.verein,
          );
          expect(result, isTrue);
        },
      );

      test(
        'Verweigert BSSB, von Eingereicht am Verein zu Genehmight von Verein zu wechseln',
        () {
          final result = workflowService.canAntragChangeFromStateToState(
            currentState: BeduerfnisAntragStatus.eingereichtAmVerein,
            nextState: BeduerfnisAntragStatus.genehmightVonVerein,
            userRole: WorkflowRole.mitglied,
          );
          expect(result, isFalse);
        },
      );
    });

    group('Gültige Übergänge von Genehmight von Verein', () {
      test(
        'Erlaubt BSSB, von Genehmight von Verein zu Eingereicht an BSSB zu wechseln',
        () {
          final result = workflowService.canAntragChangeFromStateToState(
            currentState: BeduerfnisAntragStatus.genehmightVonVerein,
            nextState: BeduerfnisAntragStatus.eingereichtAnBSSB,
            userRole: WorkflowRole.bssb,
          );
          expect(result, isTrue);
        },
      );

      test(
        'Verweigert Verein, von Genehmight von Verein zu Eingereicht an BSSB zu wechseln',
        () {
          final result = workflowService.canAntragChangeFromStateToState(
            currentState: BeduerfnisAntragStatus.genehmightVonVerein,
            nextState: BeduerfnisAntragStatus.eingereichtAnBSSB,
            userRole: WorkflowRole.verein,
          );
          expect(result, isFalse);
        },
      );
    });

    group('Gültige Übergänge von Zurückgewiesen von BSSB an Verein', () {
      test('Erlaubt Verein, zu Genehmight zu wechseln', () {
        final result = workflowService.canAntragChangeFromStateToState(
          currentState: BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnVerein,
          nextState: BeduerfnisAntragStatus.genehmight,
          userRole: WorkflowRole.verein,
        );
        expect(result, isTrue);
      });

      test('Erlaubt BSSB, zu Abgelehnt zu wechseln', () {
        final result = workflowService.canAntragChangeFromStateToState(
          currentState: BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnVerein,
          nextState: BeduerfnisAntragStatus.abgelehnt,
          userRole: WorkflowRole.bssb,
        );
        expect(result, isTrue);
      });

      test('Verweigert Mitglied, zu Genehmight zu wechseln', () {
        final result = workflowService.canAntragChangeFromStateToState(
          currentState: BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnVerein,
          nextState: BeduerfnisAntragStatus.genehmight,
          userRole: WorkflowRole.mitglied,
        );
        expect(result, isFalse);
      });
    });

    group('Gültige Übergänge von Zurückgewiesen von BSSB an Mitglied', () {
      test('Erlaubt Mitglied, zu Genehmight zu wechseln', () {
        final result = workflowService.canAntragChangeFromStateToState(
          currentState: BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnMitglied,
          nextState: BeduerfnisAntragStatus.genehmight,
          userRole: WorkflowRole.mitglied,
        );
        expect(result, isTrue);
      });

      test('Erlaubt BSSB, zu Abgelehnt zu wechseln', () {
        final result = workflowService.canAntragChangeFromStateToState(
          currentState: BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnMitglied,
          nextState: BeduerfnisAntragStatus.abgelehnt,
          userRole: WorkflowRole.bssb,
        );
        expect(result, isTrue);
      });
    });

    group('Unerlaubte Übergänge (null in Matrix)', () {
      test(
        'Verweigert alle Rollen von Entwurf zu Zurückgewiesen an Mitglied',
        () {
          expect(
            workflowService.canAntragChangeFromStateToState(
              currentState: BeduerfnisAntragStatus.entwurf,
              nextState:
                  BeduerfnisAntragStatus.zurueckgewiesenAnMitgliedVonVerein,
              userRole: WorkflowRole.mitglied,
            ),
            isFalse,
          );
          expect(
            workflowService.canAntragChangeFromStateToState(
              currentState: BeduerfnisAntragStatus.entwurf,
              nextState:
                  BeduerfnisAntragStatus.zurueckgewiesenAnMitgliedVonVerein,
              userRole: WorkflowRole.verein,
            ),
            isFalse,
          );
          expect(
            workflowService.canAntragChangeFromStateToState(
              currentState: BeduerfnisAntragStatus.entwurf,
              nextState:
                  BeduerfnisAntragStatus.zurueckgewiesenAnMitgliedVonVerein,
              userRole: WorkflowRole.bssb,
            ),
            isFalse,
          );
        },
      );

      test(
        'Verweigert alle Rollen von Zurückgewiesen an Mitglied zu Genehmight von Verein',
        () {
          expect(
            workflowService.canAntragChangeFromStateToState(
              currentState:
                  BeduerfnisAntragStatus.zurueckgewiesenAnMitgliedVonVerein,
              nextState: BeduerfnisAntragStatus.genehmightVonVerein,
              userRole: WorkflowRole.mitglied,
            ),
            isFalse,
          );
          expect(
            workflowService.canAntragChangeFromStateToState(
              currentState:
                  BeduerfnisAntragStatus.zurueckgewiesenAnMitgliedVonVerein,
              nextState: BeduerfnisAntragStatus.genehmightVonVerein,
              userRole: WorkflowRole.verein,
            ),
            isFalse,
          );
        },
      );
    });

    group('Eingereicht an BSSB Übergänge', () {
      test(
        'Erlaubt BSSB, von Eingereicht an BSSB zu Abgelehnt zu wechseln',
        () {
          final result = workflowService.canAntragChangeFromStateToState(
            currentState: BeduerfnisAntragStatus.eingereichtAnBSSB,
            nextState: BeduerfnisAntragStatus.abgelehnt,
            userRole: WorkflowRole.bssb,
          );
          expect(result, isTrue);
        },
      );

      test(
        'Verweigert Verein, von Eingereicht an BSSB zu Abgelehnt zu wechseln',
        () {
          final result = workflowService.canAntragChangeFromStateToState(
            currentState: BeduerfnisAntragStatus.eingereichtAnBSSB,
            nextState: BeduerfnisAntragStatus.abgelehnt,
            userRole: WorkflowRole.verein,
          );
          expect(result, isFalse);
        },
      );

      test(
        'Verweigert alle Übergänge zu Genehmight von Eingereicht an BSSB',
        () {
          expect(
            workflowService.canAntragChangeFromStateToState(
              currentState: BeduerfnisAntragStatus.eingereichtAnBSSB,
              nextState: BeduerfnisAntragStatus.genehmight,
              userRole: WorkflowRole.bssb,
            ),
            isFalse,
          );
        },
      );
    });

    group('Zurückgewiesen an Mitglied Übergänge', () {
      test('Erlaubt Mitglied, zurück zu Eingereicht am Verein zu wechseln', () {
        final result = workflowService.canAntragChangeFromStateToState(
          currentState:
              BeduerfnisAntragStatus.zurueckgewiesenAnMitgliedVonVerein,
          nextState: BeduerfnisAntragStatus.eingereichtAmVerein,
          userRole: WorkflowRole.mitglied,
        );
        expect(result, isTrue);
      });

      test(
        'Verweigert Verein, zurück zu Eingereicht am Verein zu wechseln',
        () {
          final result = workflowService.canAntragChangeFromStateToState(
            currentState:
                BeduerfnisAntragStatus.zurueckgewiesenAnMitgliedVonVerein,
            nextState: BeduerfnisAntragStatus.eingereichtAmVerein,
            userRole: WorkflowRole.verein,
          );
          expect(result, isFalse);
        },
      );
    });

    group('Komplexe Workflow-Szenarien', () {
      test(
        'Mitglied kann Workflow starten: Entwurf -> Eingereicht am Verein',
        () {
          expect(
            workflowService.canAntragChangeFromStateToState(
              currentState: BeduerfnisAntragStatus.entwurf,
              nextState: BeduerfnisAntragStatus.eingereichtAmVerein,
              userRole: WorkflowRole.mitglied,
            ),
            isTrue,
          );
        },
      );

      test(
        'Verein kann genehmigen: Eingereicht am Verein -> Genehmight von Verein',
        () {
          expect(
            workflowService.canAntragChangeFromStateToState(
              currentState: BeduerfnisAntragStatus.eingereichtAmVerein,
              nextState: BeduerfnisAntragStatus.genehmightVonVerein,
              userRole: WorkflowRole.verein,
            ),
            isTrue,
          );
        },
      );

      test(
        'BSSB kann weiterleiten: Genehmight von Verein -> Eingereicht an BSSB',
        () {
          expect(
            workflowService.canAntragChangeFromStateToState(
              currentState: BeduerfnisAntragStatus.genehmightVonVerein,
              nextState: BeduerfnisAntragStatus.eingereichtAnBSSB,
              userRole: WorkflowRole.bssb,
            ),
            isTrue,
          );
        },
      );

      test(
        'Kompletter Ablehnungsfluss funktioniert: Eingereicht an BSSB -> Abgelehnt',
        () {
          expect(
            workflowService.canAntragChangeFromStateToState(
              currentState: BeduerfnisAntragStatus.eingereichtAnBSSB,
              nextState: BeduerfnisAntragStatus.abgelehnt,
              userRole: WorkflowRole.bssb,
            ),
            isTrue,
          );
        },
      );

      test(
        'Mitglied kann nach Ablehnung erneut einreichen: Zurückgewiesen an Mitglied -> Eingereicht am Verein',
        () {
          // First transition: BSSB rejects to Mitglied
          expect(
            workflowService.canAntragChangeFromStateToState(
              currentState: BeduerfnisAntragStatus.eingereichtAnBSSB,
              nextState:
                  BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnMitglied,

              userRole: WorkflowRole.bssb,
            ),
            isTrue,
          );

          // Mitglied can't transition directly from there to Genehmight
          expect(
            workflowService.canAntragChangeFromStateToState(
              currentState:
                  BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnMitglied,
              nextState: BeduerfnisAntragStatus.genehmight,
              userRole: WorkflowRole.bssb,
            ),
            isFalse,
          );

          // But BSSB can reject the application
          expect(
            workflowService.canAntragChangeFromStateToState(
              currentState:
                  BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnMitglied,
              nextState: BeduerfnisAntragStatus.abgelehnt,
              userRole: WorkflowRole.bssb,
            ),
            isTrue,
          );
        },
      );
    });
  });
}
