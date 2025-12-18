import 'package:meinbssb/main.dart';

class WorkflowService {
  WorkflowService();

  /// Transition matrix for Beduerfnis Antrag workflow
  /// Maps [fromState][toState] -> required role for transition
  /// null/empty = transition not allowed
  static const Map<
    BeduerfnisAntragStatus,
    Map<BeduerfnisAntragStatus, WorkflowRole?>
  >
  _transitionMatrix = {
    // From: Entwurf
    BeduerfnisAntragStatus.entwurf: {
      BeduerfnisAntragStatus.entwurf: null, // stay same
      BeduerfnisAntragStatus.eingereichtAmVerein: WorkflowRole.mitglied,
      BeduerfnisAntragStatus.zurueckgewiesenAnMitgliedVonVerein: null,
      BeduerfnisAntragStatus.genehmightVonVerein: null,
      BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnVerein: null,
      BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnMitglied: null,
      BeduerfnisAntragStatus.eingereichtAnBSSB: null,
      BeduerfnisAntragStatus.genehmight: null,
      BeduerfnisAntragStatus.abgelehnt: null,
    },
    // From: Eingereicht am Verein
    BeduerfnisAntragStatus.eingereichtAmVerein: {
      BeduerfnisAntragStatus.entwurf: null,
      BeduerfnisAntragStatus.eingereichtAmVerein: null, // stay same
      BeduerfnisAntragStatus.zurueckgewiesenAnMitgliedVonVerein:
          WorkflowRole.verein,
      BeduerfnisAntragStatus.genehmightVonVerein: WorkflowRole.verein,
      BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnVerein: null,
      BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnMitglied: null,
      BeduerfnisAntragStatus.eingereichtAnBSSB: null,
      BeduerfnisAntragStatus.genehmight: null,
      BeduerfnisAntragStatus.abgelehnt: WorkflowRole.verein,
    },
    // From: Zurückgewiesen an Mitglied von Verein
    BeduerfnisAntragStatus.zurueckgewiesenAnMitgliedVonVerein: {
      BeduerfnisAntragStatus.entwurf: null,
      BeduerfnisAntragStatus.eingereichtAmVerein: WorkflowRole.mitglied,
      BeduerfnisAntragStatus.zurueckgewiesenAnMitgliedVonVerein:
          null, // stay same
      BeduerfnisAntragStatus.genehmightVonVerein: null,
      BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnVerein: null,
      BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnMitglied: null,
      BeduerfnisAntragStatus.eingereichtAnBSSB: null,
      BeduerfnisAntragStatus.genehmight: null,
      BeduerfnisAntragStatus.abgelehnt: null,
    },
    // From: Genehmight von Verein
    BeduerfnisAntragStatus.genehmightVonVerein: {
      BeduerfnisAntragStatus.entwurf: null,
      BeduerfnisAntragStatus.eingereichtAmVerein: null,
      BeduerfnisAntragStatus.zurueckgewiesenAnMitgliedVonVerein: null,
      BeduerfnisAntragStatus.genehmightVonVerein: null, // stay same
      BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnVerein: null,
      BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnMitglied: null,
      BeduerfnisAntragStatus.eingereichtAnBSSB: WorkflowRole.bssb,
      BeduerfnisAntragStatus.genehmight: null,
      BeduerfnisAntragStatus.abgelehnt: null,
    },
    // From: Zurückgewiesen von BSSB an Verein
    BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnVerein: {
      BeduerfnisAntragStatus.entwurf: null,
      BeduerfnisAntragStatus.eingereichtAmVerein: null,
      BeduerfnisAntragStatus.zurueckgewiesenAnMitgliedVonVerein: null,
      BeduerfnisAntragStatus.genehmightVonVerein: null,
      BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnVerein: null, // stay same
      BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnMitglied: null,
      BeduerfnisAntragStatus.eingereichtAnBSSB: null,
      BeduerfnisAntragStatus.genehmight: WorkflowRole.verein,
      BeduerfnisAntragStatus.abgelehnt: WorkflowRole.bssb,
    },
    // From: Zurückgewiesen von BSSB an Mitglied
    BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnMitglied: {
      BeduerfnisAntragStatus.entwurf: null,
      BeduerfnisAntragStatus.eingereichtAmVerein: null,
      BeduerfnisAntragStatus.zurueckgewiesenAnMitgliedVonVerein: null,
      BeduerfnisAntragStatus.genehmightVonVerein: null,
      BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnVerein: null,
      BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnMitglied:
          null, // stay same
      BeduerfnisAntragStatus.eingereichtAnBSSB: null,
      BeduerfnisAntragStatus.genehmight: WorkflowRole.mitglied,
      BeduerfnisAntragStatus.abgelehnt: WorkflowRole.bssb,
    },
    // From: Eingereicht an BSSB
    BeduerfnisAntragStatus.eingereichtAnBSSB: {
      BeduerfnisAntragStatus.entwurf: null,
      BeduerfnisAntragStatus.eingereichtAmVerein: null,
      BeduerfnisAntragStatus.zurueckgewiesenAnMitgliedVonVerein: null,
      BeduerfnisAntragStatus.genehmightVonVerein: null,
      BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnVerein: null,
      BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnMitglied:
          WorkflowRole.bssb,
      BeduerfnisAntragStatus.eingereichtAnBSSB: null, // stay same
      BeduerfnisAntragStatus.genehmight: null,
      BeduerfnisAntragStatus.abgelehnt: WorkflowRole.bssb,
    },
  };

  /// Validates if a state transition is allowed for a user with the given role
  ///
  /// Returns true if:
  /// - The transition from [currentState] to [nextState] is allowed for [userRole]
  ///
  /// Returns false if:
  /// - The transition is not defined in the matrix (no row or column exists)
  /// - The cell is null (transition not permitted)
  /// - The user's role does not match the required role for the transition
  bool canTransition({
    required BeduerfnisAntragStatus currentState,
    required BeduerfnisAntragStatus nextState,
    required WorkflowRole userRole,
  }) {
    // Get the row for current state
    final transitionsFromCurrentState = _transitionMatrix[currentState];
    if (transitionsFromCurrentState == null) {
      return false; // Current state not in matrix
    }

    // Get the required role for this specific transition
    final requiredRole = transitionsFromCurrentState[nextState];
    if (requiredRole == null) {
      return false; // Transition not allowed
    }

    // Check if user role matches required role
    return userRole == requiredRole;
  }

  /// Gets all possible next states from the current state for a given user role
  ///
  /// Returns a list of states that the user can transition to
  List<BeduerfnisAntragStatus> getAvailableTransitions({
    required BeduerfnisAntragStatus currentState,
    required WorkflowRole userRole,
  }) {
    final transitionsFromCurrentState = _transitionMatrix[currentState];
    if (transitionsFromCurrentState == null) {
      return [];
    }

    final availableTransitions = <BeduerfnisAntragStatus>[];
    transitionsFromCurrentState.forEach((nextState, requiredRole) {
      if (requiredRole == userRole) {
        availableTransitions.add(nextState);
      }
    });

    return availableTransitions;
  }

  /// Gets the role required to transition from one state to another
  ///
  /// Returns the required role, or null if the transition is not allowed
  WorkflowRole? getRequiredRoleForTransition({
    required BeduerfnisAntragStatus fromState,
    required BeduerfnisAntragStatus toState,
  }) {
    final transitionsFromState = _transitionMatrix[fromState];
    if (transitionsFromState == null) {
      return null;
    }

    return transitionsFromState[toState];
  }
}
