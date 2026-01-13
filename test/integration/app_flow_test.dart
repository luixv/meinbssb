import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:meinbssb/main.dart';
import 'package:meinbssb/services/api_service.dart' hide NetworkException;
import 'package:shared_preferences/shared_preferences.dart';

// Generate mocks for services that will be overridden
class MockNetworkService extends Mock implements NetworkService {}

class MockApiService extends Mock implements ApiService {} // Mock ApiService

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Flow Integration Tests', () {
    // These late initializations will now get their values from AppInitializer
    // Declare networkService

    setUpAll(() async {
      // Initialize mock for SharedPreferences to avoid MissingPluginException
      SharedPreferences.setMockInitialValues({});

      // Initialize the app's service providers.
      // This will set the static variables in AppInitializer.
      final prefs = await SharedPreferences.getInstance();
      await AppInitializer.init(prefs: prefs);
      // Assign the initialized services from AppInitializer's static getters
    });

    setUp(() {});
  });
}
