import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:meinbssb/screens/change_password_screen.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:meinbssb/services/core/font_size_provider.dart';
import 'package:meinbssb/services/core/config_service.dart';

import 'change_password_screen_test.mocks.dart';

@GenerateMocks([NetworkService, FontSizeProvider, ConfigService])
void main() {
  late MockNetworkService mockNetworkService;
  late MockFontSizeProvider mockFontSizeProvider;
  late MockConfigService mockConfigService;

  setUp(() {
    mockNetworkService = MockNetworkService();
    mockFontSizeProvider = MockFontSizeProvider();
    mockConfigService = MockConfigService();
    when(mockNetworkService.hasInternet()).thenAnswer((_) async => true);
    when(mockFontSizeProvider.scaleFactor).thenReturn(1.0);
    when(mockConfigService.getString('logoName', 'appTheme'))
        .thenReturn('assets/images/myBSSB-logo.png');
  });

  Future<void> pumpChangePasswordScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<NetworkService>.value(value: mockNetworkService),
          ChangeNotifierProvider<FontSizeProvider>.value(
              value: mockFontSizeProvider,),
          Provider<ConfigService>.value(value: mockConfigService),
        ],
        child: MaterialApp(
          home: ChangePasswordScreen(
            userData: null,
            isLoggedIn: false,
            onLogout: () {},
          ),
        ),
      ),
    );
  }

  testWidgets('shows form fields when online', (WidgetTester tester) async {
    await pumpChangePasswordScreen(tester);
    await tester.pumpAndSettle();
    expect(find.text('Neues Passwort erstellen'), findsWidgets);
    expect(find.text('Aktuelles Passwort'), findsOneWidget);
    expect(find.text('Neues Passwort'), findsOneWidget);
    expect(find.text('Neues Passwort wiederholen'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('shows offline message when offline',
      (WidgetTester tester) async {
    when(mockNetworkService.hasInternet()).thenAnswer((_) async => false);
    await pumpChangePasswordScreen(tester);
    await tester.pumpAndSettle();
    expect(find.text('Passwort ändern ist offline nicht verfügbar'),
        findsOneWidget,);
    expect(
        find.text(
            'Bitte stellen Sie sicher, dass Sie mit dem Internet verbunden sind, um Ihr Passwort zu ändern.',),
        findsOneWidget,);
    expect(find.byType(FloatingActionButton), findsNothing);
  });
}
