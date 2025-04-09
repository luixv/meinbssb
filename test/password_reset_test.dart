import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/screens/password_reset_screen.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/http_client.dart';
import 'package:meinbssb/services/image_service.dart';
import 'package:meinbssb/services/cache_service.dart';
import 'package:mockito/mockito.dart';

class MockHttpClient extends Mock implements HttpClient {}

class MockDatabaseService extends Mock implements ImageService {}

class MockCacheService extends Mock implements CacheService {}

// Updated MockApiService to use super parameters and mocks
class MockApiService extends ApiService {
  MockApiService({
    required super.httpClient,
    required super.databaseService,
    required super.cacheService,
    required super.baseIp,
    required super.port,
    required super.serverTimeout,
  });

  @override
  Future<Map<String, dynamic>> resetPassword(String passNumber) async {
    return {'ResultType': 1, 'ResultMessage': 'Success'};
  }
}

void main() {
  testWidgets('Displays password reset form', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PasswordResetScreen(
            apiService: MockApiService(
              httpClient: MockHttpClient(),
              databaseService: MockDatabaseService(),
              cacheService: MockCacheService(),
              baseIp: 'test',
              port: '1234',
              serverTimeout: 10,
            ),
          ),
          appBar: AppBar(title: const Text('Test')),
        ),
      ),
    );

    // Find the main heading by style (size 24 and bold)
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data == 'Passwort zurücksetzen' &&
            widget.style?.fontSize == 24 &&
            widget.style?.fontWeight == FontWeight.bold,
      ),
      findsOneWidget,
    );

    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('Validates pass number input', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PasswordResetScreen(
            apiService: MockApiService(
              httpClient: MockHttpClient(),
              databaseService: MockDatabaseService(),
              cacheService: MockCacheService(),
              baseIp: 'test',
              port: '1234',
              serverTimeout: 10,
            ),
          ),
        ),
      ),
    );

    // Test invalid input
    await tester.enterText(find.byType(TextField), '1234');
    await tester.pump();

    final errorText =
        tester.widget<TextField>(find.byType(TextField)).decoration?.errorText;
    expect(errorText, contains('Passnummer muss 8 Ziffern enthalten'));

    // Test valid input
    await tester.enterText(find.byType(TextField), '12345678');
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField)).decoration?.errorText,
      isNull,
    );
  });
}
