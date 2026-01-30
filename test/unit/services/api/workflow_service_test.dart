import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/beduerfnis_antrag_status_data.dart';
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

  group('WorkflowService.getAvailableTransitions', () {
    test('Returns available transitions for Mitglied from Entwurf', () {
      final result = workflowService.getAvailableTransitions(
        currentState: BeduerfnisAntragStatus.entwurf,
        userRole: WorkflowRole.mitglied,
      );
      expect(result, contains(BeduerfnisAntragStatus.eingereichtAmVerein));
      expect(result, hasLength(1));
    });

    test(
      'Returns available transitions for Verein from Eingereicht am Verein',
      () {
        final result = workflowService.getAvailableTransitions(
          currentState: BeduerfnisAntragStatus.eingereichtAmVerein,
          userRole: WorkflowRole.verein,
        );
        expect(result, contains(BeduerfnisAntragStatus.genehmightVonVerein));
        expect(
          result,
          contains(BeduerfnisAntragStatus.zurueckgewiesenAnMitgliedVonVerein),
        );
        expect(result, contains(BeduerfnisAntragStatus.abgelehnt));
        expect(result, hasLength(3));
      },
    );

    test(
      'Returns available transitions for BSSB from Genehmight von Verein',
      () {
        final result = workflowService.getAvailableTransitions(
          currentState: BeduerfnisAntragStatus.genehmightVonVerein,
          userRole: WorkflowRole.bssb,
        );
        expect(result, contains(BeduerfnisAntragStatus.eingereichtAnBSSB));
        expect(result, hasLength(1));
      },
    );

    test('Returns available transitions for BSSB from Eingereicht an BSSB', () {
      final result = workflowService.getAvailableTransitions(
        currentState: BeduerfnisAntragStatus.eingereichtAnBSSB,
        userRole: WorkflowRole.bssb,
      );
      expect(
        result,
        contains(BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnMitglied),
      );
      expect(result, contains(BeduerfnisAntragStatus.abgelehnt));
      expect(result, hasLength(2));
    });

    test(
      'Returns available transitions for Mitglied from Zurückgewiesen an Mitglied von Verein',
      () {
        final result = workflowService.getAvailableTransitions(
          currentState:
              BeduerfnisAntragStatus.zurueckgewiesenAnMitgliedVonVerein,
          userRole: WorkflowRole.mitglied,
        );
        expect(result, contains(BeduerfnisAntragStatus.eingereichtAmVerein));
        expect(result, hasLength(1));
      },
    );

    test(
      'Returns available transitions for Verein from Zurückgewiesen von BSSB an Verein',
      () {
        final result = workflowService.getAvailableTransitions(
          currentState: BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnVerein,
          userRole: WorkflowRole.verein,
        );
        expect(result, contains(BeduerfnisAntragStatus.genehmight));
        expect(result, hasLength(1));
      },
    );

    test(
      'Returns available transitions for BSSB from Zurückgewiesen von BSSB an Verein',
      () {
        final result = workflowService.getAvailableTransitions(
          currentState: BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnVerein,
          userRole: WorkflowRole.bssb,
        );
        expect(result, contains(BeduerfnisAntragStatus.abgelehnt));
        expect(result, hasLength(1));
      },
    );

    test(
      'Returns available transitions for Mitglied from Zurückgewiesen von BSSB an Mitglied',
      () {
        final result = workflowService.getAvailableTransitions(
          currentState: BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnMitglied,
          userRole: WorkflowRole.mitglied,
        );
        expect(result, contains(BeduerfnisAntragStatus.genehmight));
        expect(result, hasLength(1));
      },
    );

    test(
      'Returns available transitions for BSSB from Zurückgewiesen von BSSB an Mitglied',
      () {
        final result = workflowService.getAvailableTransitions(
          currentState: BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnMitglied,
          userRole: WorkflowRole.bssb,
        );
        expect(result, contains(BeduerfnisAntragStatus.abgelehnt));
        expect(result, hasLength(1));
      },
    );

    test('Returns empty list for Mitglied from Genehmight von Verein', () {
      final result = workflowService.getAvailableTransitions(
        currentState: BeduerfnisAntragStatus.genehmightVonVerein,
        userRole: WorkflowRole.mitglied,
      );
      expect(result, isEmpty);
    });

    test('Returns empty list for Verein from Entwurf', () {
      final result = workflowService.getAvailableTransitions(
        currentState: BeduerfnisAntragStatus.entwurf,
        userRole: WorkflowRole.verein,
      );
      expect(result, isEmpty);
    });

    test('Returns empty list for BSSB from Entwurf', () {
      final result = workflowService.getAvailableTransitions(
        currentState: BeduerfnisAntragStatus.entwurf,
        userRole: WorkflowRole.bssb,
      );
      expect(result, isEmpty);
    });

    test('Returns empty list for terminal state Genehmight', () {
      final result = workflowService.getAvailableTransitions(
        currentState: BeduerfnisAntragStatus.genehmight,
        userRole: WorkflowRole.mitglied,
      );
      expect(result, isEmpty);
    });

    test('Returns empty list for terminal state Abgelehnt', () {
      final result = workflowService.getAvailableTransitions(
        currentState: BeduerfnisAntragStatus.abgelehnt,
        userRole: WorkflowRole.mitglied,
      );
      expect(result, isEmpty);
    });
  });

  group('WorkflowService.getRequiredRoleForTransition', () {
    test('Returns Mitglied for Entwurf -> Eingereicht am Verein', () {
      final result = workflowService.getRequiredRoleForTransition(
        fromState: BeduerfnisAntragStatus.entwurf,
        toState: BeduerfnisAntragStatus.eingereichtAmVerein,
      );
      expect(result, WorkflowRole.mitglied);
    });

    test(
      'Returns Verein for Eingereicht am Verein -> Genehmight von Verein',
      () {
        final result = workflowService.getRequiredRoleForTransition(
          fromState: BeduerfnisAntragStatus.eingereichtAmVerein,
          toState: BeduerfnisAntragStatus.genehmightVonVerein,
        );
        expect(result, WorkflowRole.verein);
      },
    );

    test(
      'Returns Verein for Eingereicht am Verein -> Zurückgewiesen an Mitglied von Verein',
      () {
        final result = workflowService.getRequiredRoleForTransition(
          fromState: BeduerfnisAntragStatus.eingereichtAmVerein,
          toState: BeduerfnisAntragStatus.zurueckgewiesenAnMitgliedVonVerein,
        );
        expect(result, WorkflowRole.verein);
      },
    );

    test('Returns Verein for Eingereicht am Verein -> Abgelehnt', () {
      final result = workflowService.getRequiredRoleForTransition(
        fromState: BeduerfnisAntragStatus.eingereichtAmVerein,
        toState: BeduerfnisAntragStatus.abgelehnt,
      );
      expect(result, WorkflowRole.verein);
    });

    test('Returns BSSB for Genehmight von Verein -> Eingereicht an BSSB', () {
      final result = workflowService.getRequiredRoleForTransition(
        fromState: BeduerfnisAntragStatus.genehmightVonVerein,
        toState: BeduerfnisAntragStatus.eingereichtAnBSSB,
      );
      expect(result, WorkflowRole.bssb);
    });

    test(
      'Returns BSSB for Eingereicht an BSSB -> Zurückgewiesen von BSSB an Mitglied',
      () {
        final result = workflowService.getRequiredRoleForTransition(
          fromState: BeduerfnisAntragStatus.eingereichtAnBSSB,
          toState: BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnMitglied,
        );
        expect(result, WorkflowRole.bssb);
      },
    );

    test('Returns BSSB for Eingereicht an BSSB -> Abgelehnt', () {
      final result = workflowService.getRequiredRoleForTransition(
        fromState: BeduerfnisAntragStatus.eingereichtAnBSSB,
        toState: BeduerfnisAntragStatus.abgelehnt,
      );
      expect(result, WorkflowRole.bssb);
    });

    test(
      'Returns Mitglied for Zurückgewiesen an Mitglied von Verein -> Eingereicht am Verein',
      () {
        final result = workflowService.getRequiredRoleForTransition(
          fromState: BeduerfnisAntragStatus.zurueckgewiesenAnMitgliedVonVerein,
          toState: BeduerfnisAntragStatus.eingereichtAmVerein,
        );
        expect(result, WorkflowRole.mitglied);
      },
    );

    test(
      'Returns Verein for Zurückgewiesen von BSSB an Verein -> Genehmight',
      () {
        final result = workflowService.getRequiredRoleForTransition(
          fromState: BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnVerein,
          toState: BeduerfnisAntragStatus.genehmight,
        );
        expect(result, WorkflowRole.verein);
      },
    );

    test('Returns BSSB for Zurückgewiesen von BSSB an Verein -> Abgelehnt', () {
      final result = workflowService.getRequiredRoleForTransition(
        fromState: BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnVerein,
        toState: BeduerfnisAntragStatus.abgelehnt,
      );
      expect(result, WorkflowRole.bssb);
    });

    test(
      'Returns Mitglied for Zurückgewiesen von BSSB an Mitglied -> Genehmight',
      () {
        final result = workflowService.getRequiredRoleForTransition(
          fromState: BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnMitglied,
          toState: BeduerfnisAntragStatus.genehmight,
        );
        expect(result, WorkflowRole.mitglied);
      },
    );

    test(
      'Returns BSSB for Zurückgewiesen von BSSB an Mitglied -> Abgelehnt',
      () {
        final result = workflowService.getRequiredRoleForTransition(
          fromState: BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnMitglied,
          toState: BeduerfnisAntragStatus.abgelehnt,
        );
        expect(result, WorkflowRole.bssb);
      },
    );

    test('Returns null for invalid transition: Entwurf -> Genehmight', () {
      final result = workflowService.getRequiredRoleForTransition(
        fromState: BeduerfnisAntragStatus.entwurf,
        toState: BeduerfnisAntragStatus.genehmight,
      );
      expect(result, isNull);
    });

    test(
      'Returns null for invalid transition: Entwurf -> Zurückgewiesen an Mitglied von Verein',
      () {
        final result = workflowService.getRequiredRoleForTransition(
          fromState: BeduerfnisAntragStatus.entwurf,
          toState: BeduerfnisAntragStatus.zurueckgewiesenAnMitgliedVonVerein,
        );
        expect(result, isNull);
      },
    );

    test(
      'Returns null for invalid transition: Genehmight von Verein -> Abgelehnt',
      () {
        final result = workflowService.getRequiredRoleForTransition(
          fromState: BeduerfnisAntragStatus.genehmightVonVerein,
          toState: BeduerfnisAntragStatus.abgelehnt,
        );
        expect(result, isNull);
      },
    );

    test('Returns null for staying in same state: Entwurf -> Entwurf', () {
      final result = workflowService.getRequiredRoleForTransition(
        fromState: BeduerfnisAntragStatus.entwurf,
        toState: BeduerfnisAntragStatus.entwurf,
      );
      expect(result, isNull);
    });

    test(
      'Returns null for staying in same state: Eingereicht am Verein -> Eingereicht am Verein',
      () {
        final result = workflowService.getRequiredRoleForTransition(
          fromState: BeduerfnisAntragStatus.eingereichtAmVerein,
          toState: BeduerfnisAntragStatus.eingereichtAmVerein,
        );
        expect(result, isNull);
      },
    );

    test('Returns null for transition from terminal state Genehmight', () {
      final result = workflowService.getRequiredRoleForTransition(
        fromState: BeduerfnisAntragStatus.genehmight,
        toState: BeduerfnisAntragStatus.entwurf,
      );
      expect(result, isNull);
    });

    test('Returns null for transition from terminal state Abgelehnt', () {
      final result = workflowService.getRequiredRoleForTransition(
        fromState: BeduerfnisAntragStatus.abgelehnt,
        toState: BeduerfnisAntragStatus.entwurf,
      );
      expect(result, isNull);
    });
  });
}
