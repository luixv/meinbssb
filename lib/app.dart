// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '/constants/ui_constants.dart';
import '/models/user_data.dart';

import 'screens/login_screen.dart';
import 'screens/start_screen.dart';
import 'screens/help_screen.dart';
import 'screens/impressum_screen.dart';
import 'screens/splash_screen.dart';
import 'utils/cookie_consent.dart';
import 'main.dart';

class MyAppWrapper extends StatelessWidget {
  const MyAppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        AppInitializer.configServiceProvider,
        AppInitializer.emailSenderProvider,
        AppInitializer.emailServiceProvider,
        AppInitializer.authServiceProvider,
        AppInitializer.apiServiceProvider,
        AppInitializer.networkServiceProvider,
        AppInitializer.cacheServiceProvider,
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  UserData? _userData;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final userDataString = prefs.getString('userData');
    UserData? userData;
    if (userDataString != null) {
      try {
        final jsonData = jsonDecode(userDataString) as Map<String, dynamic>;
        userData = UserData.fromJson(jsonData);
      } catch (e) {
        debugPrint('Error decoding user data: $e');
      }
    }
    setState(() {
      _isLoggedIn = isLoggedIn;
      _userData = userData;
    });
  }

  void _handleLogin(UserData userData) {
    setState(() {
      _isLoggedIn = true;
      _userData = userData;
    });
  }

  void _handleLogout() {
    setState(() {
      _isLoggedIn = false;
      _userData = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mein BSSB',
      theme: ThemeData(
        fontFamily: UIConstants.defaultFontFamily,
        primarySwatch: Colors.blue,
        textSelectionTheme: const TextSelectionThemeData(
          selectionColor: UIConstants.selectionColor,
          selectionHandleColor: UIConstants.selectionHandleColor,
          cursorColor: UIConstants.cursorColor,
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('de', 'DE'), Locale('en', 'US')],
      initialRoute: '/splash',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: const TextSelectionThemeData(
              selectionColor: UIConstants.selectionColor,
              cursorColor: UIConstants.cursorColor,
            ),
            highlightColor: UIConstants.highlightColor,
            splashColor: UIConstants.splashColor,
          ),
          child: CookieConsent(
            child: Material(
              type: MaterialType.transparency,
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
      routes: {
        '/splash': (context) => SplashScreen(
              onFinish: () {
                Navigator.of(context).pushReplacementNamed(
                  _isLoggedIn ? '/home' : '/login',
                );
              },
            ),
        '/login': (context) => LoginScreen(
              onLoginSuccess: _handleLogin,
            ),
        '/home': (context) => StartScreen(
              _userData,
              isLoggedIn: _isLoggedIn,
              onLogout: _handleLogout,
            ),
        '/help': (context) => HelpScreen(
              userData: _userData,
              isLoggedIn: _isLoggedIn,
              onLogout: _handleLogout,
            ),
        '/impressum': (context) => ImpressumScreen(
              userData: _userData,
              isLoggedIn: _isLoggedIn,
              onLogout: _handleLogout,
            ),
      },
    );
  }
}
