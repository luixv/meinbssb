// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:meinbssb/screens/password/reset_password_screen.dart';
import 'package:meinbssb/screens/email/email_verification_screen.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/core/logger_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'providers/theme_provider.dart';
import 'package:meinbssb/services/core/http_client.dart';

import 'screens/login_screen.dart';
import 'screens/start_screen.dart';
import 'screens/help_screen.dart';
import 'screens/impressum_screen.dart';
import 'screens/datenschutz_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/menu/profile_menu.dart';
import 'screens/password/set_password_screen.dart';
import 'screens/cookie_consent_screen.dart';
import 'main.dart';
import 'screens/schulungen/schulungen_search_screen.dart';
import 'package:flutter/foundation.dart';
import 'web_storage_stub.dart' if (dart.library.html) 'web_storage_web.dart';
import 'dart:html' as html show window;

final GlobalKey<NavigatorState> globalNavigatorKey =
    GlobalKey<NavigatorState>();

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
        AppInitializer.calendarServiceProvider,
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider<HttpClient>(create: (_) => AppInitializer.httpClient),
      ],
      child:
          initialScreen != null
              ? Consumer<ThemeProvider>(
                builder:
                    (context, themeProvider, _) => MaterialApp(
                      initialRoute: '/schulungen_search',
                      onGenerateRoute: (settings) {
                        if (settings.name == '/login') {
                          return MaterialPageRoute(
                            builder:
                                (context) => LoginScreen(
                                  onLoginSuccess: (userData) {
                                    // Login success is handled by LoginScreen's navigation
                                    // No need to do anything here
                                  },
                                ),
                            settings: settings,
                          );
                        }
                        if (settings.name == '/home') {
                          // Redirect to root URL to load the full app
                          if (kIsWeb) {
                            html.window.location.href = '/';
                          }
                          // Return a loading screen while redirecting
                          return MaterialPageRoute(
                            builder:
                                (_) => const Scaffold(
                                  body: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                            settings: settings,
                          );
                        }
                        // Default to schulungen_search screen
                        return MaterialPageRoute(
                          builder: (_) => initialScreen!,
                          settings: settings,
                        );
                      },
                      theme: themeProvider.getTheme(false),
                      darkTheme: themeProvider.getTheme(false),
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
  bool _isLoggedIn = false;
  UserData? _userData;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late final ApiService _apiService;
  bool _loading = true;
  bool _splashDone = false;
  bool _authCheckDone = false;

  @override
  void initState() {
    super.initState();
    _apiService = Provider.of<ApiService>(context, listen: false);
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
        valid = await _apiService.authService.isTokenValid();
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
      // Get ApiService before async operations to avoid BuildContext issues
      final apiService = Provider.of<ApiService>(context, listen: false);

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');

      // Call AuthService logout to clear cached data
      await apiService.authService.logout();

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
      // debugPrint('Error during logout: $e');
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
    final path = Uri.base.path;

    // Determine initial route based on path and remembered route
    String initialRoute;
    if (kIsWeb) {
      // Robust logic for web: handle Schulungen-only and login systems
      bool isSchulungenUrl = path.startsWith('/schulungen_search');
      bool isSetPasswordUrl = path.startsWith('/set-password');
      bool isResetPasswordUrl = path.startsWith('/reset-password');
      bool isVerifyEmailUrl = path.startsWith('/verify-email');
      String? rememberedRoute = WebStorage.getItem('intendedRoute');

      // Get the full URI with query parameters
      final uri = Uri.base;
      final queryString = uri.query.isNotEmpty ? '?${uri.query}' : '';

      if (isSetPasswordUrl) {
        // If on set-password URL, route directly to set-password with query params
        initialRoute = '/set-password$queryString';
      } else if (isResetPasswordUrl) {
        // If on reset-password URL, route directly to reset-password with query params
        initialRoute = '/reset-password$queryString';
      } else if (isVerifyEmailUrl) {
        // If on verify-email URL, route directly to verify-email with query params
        initialRoute = '/verify-email$queryString';
      } else if (isSchulungenUrl) {
        // If on Schulungen-only URL, clear any login-related remembered route
        if (rememberedRoute != null &&
            !rememberedRoute.startsWith('/schulungen_search')) {
          WebStorage.removeItem('intendedRoute');
        }
        initialRoute = '/schulungen_search';
      } else if (path == '/' || path.isEmpty) {
        // Root URL case - check if user is logged in
        if (_isLoggedIn && _userData != null) {
          // If logged in, go to home
          initialRoute = '/home';
        } else {
          // If not logged in, check remembered route or default to login
          if (rememberedRoute != null &&
              rememberedRoute.startsWith('/schulungen_search')) {
            initialRoute = '/schulungen_search';
          } else {
            initialRoute = '/login';
          }
        }
      } else if (rememberedRoute != null) {
        // If we have a remembered route, use it
        if (rememberedRoute.startsWith('/schulungen_search')) {
          initialRoute = '/schulungen_search';
        } else {
          initialRoute = rememberedRoute;
        }
      } else {
        // Any other route - use normal login system
        initialRoute = '/splash';
      }
      // Store the current route for future reloads
      if (path.isNotEmpty && path != '/') {
        WebStorage.setItem('intendedRoute', path);
      }
    } else {
      // Non-web platforms: always start with splash
      initialRoute = '/splash';
    }
    // Skip splash if accessing anonymous routes directly
    final skipSplashRoutes = [
      '/schulungen_search',
      '/set-password',
      '/reset-password',
      '/verify-email',
    ];
    // Check if initialRoute starts with any of the skip routes (to handle query parameters)
    final shouldSkipSplash = skipSplashRoutes.any(
      (route) => initialRoute.startsWith(route),
    );
    if (_loading && !shouldSkipSplash) {
      // Show the animated SplashScreen for at least 3 seconds
      return MaterialApp(
        home: SplashScreen(
          onFinish: () {}, // No-op, we control timing in _MyAppState
        ),
        theme: ThemeProvider().getTheme(false),
        darkTheme: ThemeProvider().getTheme(false),
        themeMode: ThemeMode.system,
      );
    }
    // Only now build the MaterialApp with all routes
    return Consumer2<FontSizeProvider, ThemeProvider>(
      builder: (context, fontSizeProvider, themeProvider, child) {
        return MaterialApp(
          navigatorKey: _navigatorKey,
          title: 'Mein BSSB',
          theme: themeProvider.getTheme(false),
          darkTheme: themeProvider.getTheme(false),
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
                textTheme: Theme.of(
                  context,
                ).textTheme.apply(fontSizeFactor: fontSizeProvider.scaleFactor),
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
                builder:
                    (_) => const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    ),
                settings: settings,
              );
            }
            // Allow anonymous access to /set-password
            if (settings.name!.startsWith('/set-password')) {
              final uri = Uri.base;
              final token = uri.queryParameters['token'] ?? '';
              // Construct the full path with query parameters for the URL
              final fullPath =
                  uri.query.isNotEmpty
                      ? '/set-password?${uri.query}'
                      : '/set-password';
              return MaterialPageRoute(
                builder:
                    (context) => SetPasswordScreen(
                      token: token,
                      authService:
                          Provider.of<ApiService>(
                            context,
                            listen: false,
                          ).authService,
                    ),
                settings: RouteSettings(name: fullPath),
              );
            }
            if (settings.name!.startsWith('/reset-password')) {
              final uri = Uri.base;
              final token = uri.queryParameters['token'] ?? '';
              final personId = uri.queryParameters['personId'] ?? '';
              // Construct the full path with query parameters for the URL
              final fullPath =
                  uri.query.isNotEmpty
                      ? '/reset-password?${uri.query}'
                      : '/reset-password';
              return MaterialPageRoute(
                builder:
                    (context) => ResetPasswordScreen(
                      token: token,
                      personId: personId,
                      apiService: Provider.of<ApiService>(
                        context,
                        listen: false,
                      ),
                    ),
                settings: RouteSettings(name: fullPath),
              );
            }
            if (settings.name!.startsWith('/verify-email')) {
              LoggerService.logInfo('Verifying email for settings: $settings');
              final uri = Uri.base;
              final token = uri.queryParameters['token'] ?? '';
              final personId = uri.queryParameters['personId'] ?? '';
              LoggerService.logInfo('Token: $token, PersonId: $personId');
              // Construct the full path with query parameters for the URL
              final fullPath =
                  uri.query.isNotEmpty
                      ? '/verify-email?${uri.query}'
                      : '/verify-email';
              return MaterialPageRoute(
                builder:
                    (context) => EmailVerificationScreen(
                      verificationToken: token,
                      personId: personId,
                    ),
                settings: RouteSettings(name: fullPath),
              );
            }
            // Allow anonymous access to SchulungenSearchScreen and all its subroutes
            if (settings.name != null &&
                settings.name!.startsWith('/schulungen_search')) {
              return MaterialPageRoute(
                builder:
                    (_) => SchulungenSearchScreen(
                      userData: _userData,
                      isLoggedIn: _isLoggedIn,
                      onLogout: _handleLogout,
                      showMenu: false,
                      showConnectivityIcon:
                          false, // Hide connectivity icon for Schulungen-only system
                    ),
                settings: settings,
              );
            }
            // Handle login route specifically
            if (settings.name == '/login') {
              return MaterialPageRoute(
                builder: (_) => LoginScreen(onLoginSuccess: _handleLogin),
                settings: settings,
              );
            }
            // Allow anonymous access to /help
            if (!_isLoggedIn || _userData == null) {
              if (settings.name == '/help') {
                return MaterialPageRoute(
                  builder:
                      (_) => HelpScreen(
                        userData: _userData,
                        isLoggedIn: _isLoggedIn,
                        onLogout: _handleLogout,
                      ),
                  settings: settings,
                );
              }
              return MaterialPageRoute(
                builder: (_) => LoginScreen(onLoginSuccess: _handleLogin),
                settings: settings,
              );
            }
            // Now handle the actual routes
            switch (settings.name) {
              case '/home':
                return MaterialPageRoute(
                  builder:
                      (_) => SafeStartScreen(
                        userData: _userData,
                        isLoggedIn: _isLoggedIn,
                        onLogout: _handleLogout,
                      ),
                  settings: settings,
                );
              case '/help':
                return MaterialPageRoute(
                  builder:
                      (_) => HelpScreen(
                        userData: _userData,
                        isLoggedIn: _isLoggedIn,
                        onLogout: _handleLogout,
                      ),
                  settings: settings,
                );
              case '/impressum':
                return MaterialPageRoute(
                  builder:
                      (_) => ImpressumScreen(
                        userData: _userData,
                        isLoggedIn: _isLoggedIn,
                        onLogout: _handleLogout,
                      ),
                  settings: settings,
                );
              case '/datenschutz':
                return MaterialPageRoute(
                  builder:
                      (_) => DatenschutzScreen(
                        userData: _userData,
                        isLoggedIn: _isLoggedIn,
                        onLogout: _handleLogout,
                      ),
                  settings: settings,
                );
              case '/settings':
                return MaterialPageRoute(
                  builder:
                      (_) => SettingsScreen(
                        userData: _userData,
                        isLoggedIn: _isLoggedIn,
                        onLogout: _handleLogout,
                      ),
                  settings: settings,
                );
              case '/profile':
                return MaterialPageRoute(
                  builder:
                      (_) => ProfileScreen(
                        userData: _userData,
                        isLoggedIn: _isLoggedIn,
                        onLogout: _handleLogout,
                      ),
                  settings: settings,
                );
              case '/splash':
              default:
                return MaterialPageRoute(
                  builder:
                      (_) => SplashScreen(
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
    return StartScreen(userData, isLoggedIn: isLoggedIn, onLogout: onLogout);
  }
}
