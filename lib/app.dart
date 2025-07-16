// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/services/core/font_size_provider.dart';
import 'providers/theme_provider.dart';
import 'package:meinbssb/services/core/http_client.dart';
import 'package:meinbssb/services/api/auth_service.dart';

import 'screens/login_screen.dart';
import 'screens/start_screen.dart';
import 'screens/help_screen.dart';
import 'screens/impressum_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/set_password_screen.dart';
import 'utils/cookie_consent.dart';
import 'main.dart';
import 'screens/schulungen_search_screen.dart';

class MyAppWrapper extends StatelessWidget {
  const MyAppWrapper({super.key, this.initialScreen});

  final Widget? initialScreen;

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
        AppInitializer.userServiceProvider,
        AppInitializer.trainingServiceProvider,
        AppInitializer.fontSizeProvider,
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider<HttpClient>(create: (_) => AppInitializer.httpClient),
      ],
      child: initialScreen != null
          ? Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) => MaterialApp(
                home: initialScreen,
                theme: themeProvider.getTheme(false),
                darkTheme: themeProvider.getTheme(true),
                themeMode: ThemeMode.system,
              ),
            )
          : const MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static bool _bypassDone = false;
  bool _isLoggedIn = false;
  UserData? _userData;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late final AuthService _authService;
  bool _loading = true;
  bool _splashDone = false;
  bool _authCheckDone = false;

  @override
  void initState() {
    super.initState();
    _authService = Provider.of<AuthService>(context, listen: false);
    _startSplashAndAuthCheck();
  }

  void _startSplashAndAuthCheck() {
    // Start both splash and auth check in parallel
    _checkLoginStatus();
    Future.delayed(const Duration(seconds: 3)).then((_) {
      _splashDone = true;
      _maybeFinishLoading();
    });
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

    bool valid = false;
    if (isLoggedIn) {
      try {
        valid = await _authService.isTokenValid();
      } catch (e) {
        valid = false;
      }
    }

    if (!mounted) return;

    setState(() {
      _isLoggedIn = isLoggedIn && valid;
      _userData = isLoggedIn && valid ? userData : null;
    });
    _authCheckDone = true;
    _maybeFinishLoading();
    // After setState, force navigation if needed
    if (!_isLoggedIn && _navigatorKey.currentState != null) {
      try {
        final currentRoute =
            ModalRoute.of(_navigatorKey.currentContext!)?.settings.name;
        if (currentRoute == '/home') {
          _navigatorKey.currentState!.pushReplacementNamed('/login');
        }
      } catch (e) {
        // ignore
      }
    }
  }

  void _maybeFinishLoading() {
    if (_splashDone && _authCheckDone && mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _handleLogin(UserData userData) {
    setState(() {
      _isLoggedIn = true;
      _userData = userData;
    });
  }

  void _handleLogout() async {
    try {
      // Get AuthService before async operations to avoid BuildContext issues
      final authService = Provider.of<AuthService>(context, listen: false);

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('userData');

      // Call AuthService logout to clear cached data
      await authService.logout();

      // Update local state
      setState(() {
        _isLoggedIn = false;
        _userData = null;
      });

      // Navigate to login screen using the navigator key
      if (mounted && _navigatorKey.currentState != null) {
        _navigatorKey.currentState!.pushReplacementNamed('/login');
      }
    } catch (e) {
      debugPrint('Error during logout: $e');
      // Even if there's an error, still update state and navigate
      setState(() {
        _isLoggedIn = false;
        _userData = null;
      });
      if (mounted && _navigatorKey.currentState != null) {
        _navigatorKey.currentState!.pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fragment = Uri.base.fragment;
    final path = Uri.base.path;
    final bool isDirectSchulungenSearch = fragment == '/schulungen_search' ||
        fragment == 'schulungen_search' ||
        path == '/schulungen_search' ||
        path == 'schulungen_search';
    if (isDirectSchulungenSearch && !_bypassDone) {
      _bypassDone = true;
      return MaterialApp(
        home: SchulungenSearchScreen(
          null,
          isLoggedIn: false,
          onLogout: () {},
          showMenu: false,
          showConnectivityIcon: false,
        ),
      );
    }
    final String initialRoute =
        (fragment == '/schulungen_search' || fragment == 'schulungen_search')
            ? '/schulungen_search'
            : '/splash';
    if (_loading) {
      // Show the animated SplashScreen for at least 3 seconds
      return MaterialApp(
        home: SplashScreen(
          onFinish: () {}, // No-op, we control timing in _MyAppState
        ),
      );
    }
    // Only now build the MaterialApp with all routes
    return Consumer2<FontSizeProvider, ThemeProvider>(
      builder: (context, fontSizeProvider, themeProvider, child) {
        return MaterialApp(
          navigatorKey: _navigatorKey,
          title: 'Mein BSSB',
          theme: themeProvider.getTheme(false),
          darkTheme: themeProvider.getTheme(true),
          themeMode: ThemeMode.system,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('de', 'DE'), Locale('en', 'US')],
          initialRoute: initialRoute,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                textTheme: Theme.of(context).textTheme.apply(
                      fontSizeFactor: fontSizeProvider.scaleFactor,
                    ),
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
          // Only use onGenerateRoute, no static routes map
          onGenerateRoute: (settings) {
            if (_loading) {
              return MaterialPageRoute(
                builder: (_) => const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
                settings: settings,
              );
            }
            if (settings.name != null &&
                settings.name!.startsWith('/set-password')) {
              final uri = Uri.parse(settings.name!);
              final token = uri.queryParameters['token'] ?? '';
              return MaterialPageRoute(
                builder: (context) => SetPasswordScreen(
                    token: token,
                    authService:
                        Provider.of<AuthService>(context, listen: false),),
                settings: settings,
              );
            }
            // Allow anonymous access to SchulungenSearchScreen
            if (settings.name == '/schulungen_search') {
              return MaterialPageRoute(
                builder: (_) => SchulungenSearchScreen(
                  _userData,
                  isLoggedIn: _isLoggedIn,
                  onLogout: _handleLogout,
                  showMenu: false,
                ),
                settings: settings,
              );
            }
            if (!_isLoggedIn || _userData == null) {
              // Always redirect to login if not logged in
              return MaterialPageRoute(
                builder: (_) => LoginScreen(onLoginSuccess: _handleLogin),
                settings: settings,
              );
            }
            // Now handle the actual routes
            switch (settings.name) {
              case '/home':
                return MaterialPageRoute(
                  builder: (_) => SafeStartScreen(
                    userData: _userData,
                    isLoggedIn: _isLoggedIn,
                    onLogout: _handleLogout,
                  ),
                  settings: settings,
                );
              case '/help':
                return MaterialPageRoute(
                  builder: (_) => HelpScreen(
                    userData: _userData,
                    isLoggedIn: _isLoggedIn,
                    onLogout: _handleLogout,
                  ),
                  settings: settings,
                );
              case '/impressum':
                return MaterialPageRoute(
                  builder: (_) => ImpressumScreen(
                    userData: _userData,
                    isLoggedIn: _isLoggedIn,
                    onLogout: _handleLogout,
                  ),
                  settings: settings,
                );
              case '/settings':
                return MaterialPageRoute(
                  builder: (_) => SettingsScreen(
                    userData: _userData,
                    isLoggedIn: _isLoggedIn,
                    onLogout: _handleLogout,
                  ),
                  settings: settings,
                );
              case '/profile':
                return MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                    userData: _userData,
                    isLoggedIn: _isLoggedIn,
                    onLogout: _handleLogout,
                  ),
                  settings: settings,
                );
              case '/splash':
              default:
                return MaterialPageRoute(
                  builder: (_) => SplashScreen(
                    onFinish: () {
                      _navigatorKey.currentState!.pushReplacementNamed(
                        _isLoggedIn ? '/home' : '/login',
                      );
                    },
                  ),
                  settings: settings,
                );
            }
          },
        );
      },
    );
  }
}

class AuthGuard extends StatelessWidget {
  const AuthGuard({
    required this.isLoggedIn,
    required this.userData,
    required this.child,
    super.key,
  });
  final bool isLoggedIn;
  final UserData? userData;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn || userData == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return const SizedBox.shrink();
    }
    return child;
  }
}

// Defensive wrapper for StartScreen to avoid crash if userData is null
class SafeStartScreen extends StatelessWidget {
  const SafeStartScreen({
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
    super.key,
  });
  final UserData? userData;
  final bool isLoggedIn;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return const SizedBox.shrink();
    }
    return StartScreen(
      userData,
      isLoggedIn: isLoggedIn,
      onLogout: onLogout,
    );
  }
}
