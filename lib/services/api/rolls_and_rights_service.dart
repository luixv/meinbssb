import 'package:meinbssb/services/core/http_client.dart';
import 'package:meinbssb/services/api/workflow_service.dart';

class RollsAndRights {
  RollsAndRights({required HttpClient httpClient});

  /// Gets the workflow role for a given person ID.
  /// For now, always returns [WorkflowRole.mitglied].
  Future<WorkflowRole> getRoles(int personId) async {
    // TODO: Implement actual role retrieval logic from backend
    return WorkflowRole.mitglied;
  }
}
