import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:meinbssb/screens/password_reset_screen.dart';
import 'package:meinbssb/services/api/auth_service.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:meinbssb/services/core/font_size_provider.dart';
import 'package:meinbssb/services/core/config_service.dart';

import 'password_reset_screen_test.mocks.dart';

@GenerateMocks([AuthService, NetworkService, FontSizeProvider, ConfigService])
void main() {
  late MockAuthService mockAuthService;
  late MockNetworkService mockNetworkService;
  late MockFontSizeProvider mockFontSizeProvider;
  late MockConfigService mockConfigService;

  setUp(() {
    mockAuthService = MockAuthService();
    mockNetworkService = MockNetworkService();
    mockFontSizeProvider = MockFontSizeProvider();
    mockConfigService = MockConfigService();
    when(mockNetworkService.hasInternet()).thenAnswer((_) async => true);
    when(mockFontSizeProvider.scaleFactor).thenReturn(1.0);
    when(mockConfigService.getString('logoName', 'appTheme'))
        .thenReturn('assets/images/myBSSB-logo.png');
  });

  Future<void> pumpPasswordResetScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthService>.value(value: mockAuthService),
          Provider<NetworkService>.value(value: mockNetworkService),
          ChangeNotifierProvider<FontSizeProvider>.value(
              value: mockFontSizeProvider,),
          Provider<ConfigService>.value(value: mockConfigService),
        ],
        child: MaterialApp(
          home: PasswordResetScreen(
            authService: mockAuthService,
            userData: null,
            isLoggedIn: false,
            onLogout: () {},
          ),
        ),
      ),
    );
  }

  testWidgets('shows form fields when online', (WidgetTester tester) async {
    await pumpPasswordResetScreen(tester);
    await tester.pumpAndSettle();
    expect(find.text('Passwort zurücksetzen'), findsWidgets);
    expect(find.text('Schützenausweisnummer'), findsOneWidget);
    expect(find.byKey(const Key('forgotPasswordButton')), findsOneWidget);
  });

  testWidgets('shows offline message when offline',
      (WidgetTester tester) async {
    when(mockNetworkService.hasInternet()).thenAnswer((_) async => false);
    await pumpPasswordResetScreen(tester);
    await tester.pumpAndSettle();
    expect(
      find.text('Passwort zurücksetzen ist offline nicht verfügbar'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Bitte stellen Sie sicher, dass Sie mit dem Internet verbunden sind, um Ihr Passwort zurückzusetzen.',
      ),
      findsOneWidget,
    );
  });
}
