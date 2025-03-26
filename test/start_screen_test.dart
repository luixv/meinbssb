import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/screens/start_screen.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:mockito/annotations.dart';
import 'start_screen_test.mocks.dart';

// Use the generated file annotation, with customMocks to avoid name conflict
@GenerateMocks([ApiService], customMocks: [MockSpec<ApiService>(as: #CustomMockApiService)])

void main() {
  // Now, we can use CustomMockApiService without conflicts
  testWidgets('StartScreen displays loading spinner while fetching data', (WidgetTester tester) async {
    // Arrange
    final mockApiService = CustomMockApiService();
    final userData = {
      'PERSONID': 123,
      'VORNAME': 'John',
      'NAMEN': 'Doe',
      'PASSNUMMER': 'ABC123',
      'VEREINNAME': 'My Vereinsname'
    };

    // Stub for the fetchAngemeldeteSchulungen method to simulate a loading state
    when(mockApiService.fetchAngemeldeteSchulungen(any, any))
        .thenAnswer((_) async => Future.delayed(Duration(seconds: 1), () => []));

    // Act
    await tester.pumpWidget(MaterialApp(
        home: StartScreen(userData, isLoggedIn: true, onLogout: () {})));

    // Initially, the loading indicator should be visible
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for the fetch to complete
    await tester.pumpAndSettle();

    // After loading, the loading indicator should be gone
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('StartScreen displays no Schulungen found message when no data', (WidgetTester tester) async {
    // Arrange
    final mockApiService = CustomMockApiService();
    final userData = {
      'PERSONID': 123,
      'VORNAME': 'John',
      'NAMEN': 'Doe',
      'PASSNUMMER': 'ABC123',
      'VEREINNAME': 'My Vereinsname'
    };

    // Stub for the fetchAngemeldeteSchulungen method to return an empty list
    when(mockApiService.fetchAngemeldeteSchulungen(any, any)).thenAnswer((_) async => []);

    // Act
    await tester.pumpWidget(MaterialApp(
        home: StartScreen(userData,isLoggedIn: true, onLogout: () {})));

    // Wait for the fetch to complete
    await tester.pumpAndSettle();

    // Verify that no schulung found message is shown
    expect(find.text("Keine Schulungen gefunden."), findsOneWidget);
  });

  testWidgets('StartScreen displays Schulungen list when data is returned', (WidgetTester tester) async {
    // Arrange
    final mockApiService = CustomMockApiService();
    final userData = {
      'PERSONID': 123,
      'VORNAME': 'Jane',
      'NAMEN': 'Doe',
      'PASSNUMMER': 'XYZ456',
      'VEREINNAME': 'Vereinsname XYZ'
    };

    // Sample data to return
    final schulungList = [
      {'BEZEICHNUNG': 'Schulung 1', 'DATUM': '2023-01-01'},
      {'BEZEICHNUNG': 'Schulung 2', 'DATUM': '2023-01-15'},
    ];

    // Stub for the fetchAngemeldeteSchulungen method to return sample data
    when(mockApiService.fetchAngemeldeteSchulungen(any, any))
        .thenAnswer((_) async => schulungList);

    // Act
    await tester.pumpWidget(MaterialApp(
        home: StartScreen(userData, isLoggedIn: true, onLogout: () {})));

    // Wait for the fetch to complete
    await tester.pumpAndSettle();

    // Verify that the list of Schulungen is displayed
    expect(find.text('Schulung 1'), findsOneWidget);
    expect(find.text('Schulung 2'), findsOneWidget);
  });
}