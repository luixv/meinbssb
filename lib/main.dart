import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/login_screen.dart';
import 'screens/start_screen.dart';
import 'services/localization_service.dart';
import 'package:meinbssb/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalizationService.load('assets/strings.json');

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  final ApiService apiService = ApiService();

  MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  Map<String, dynamic> _userData = {};

  void _setLoggedIn(bool isLoggedIn, Map<String, dynamic> userData) {
    setState(() {
      _isLoggedIn = isLoggedIn;
      _userData = userData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mein BSSB',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('de', 'DE'),
        Locale('en', 'US'),
      ],
     initialRoute: _isLoggedIn ? '/home' : '/login',
      routes: {
      '/login': (context) => LoginScreen(
        apiService: widget.apiService,
        onLoginSuccess: (userData) => _setLoggedIn(true, userData),
      ),
      '/home': (context) {
        final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        final userData = arguments?['userData'] as Map<String, dynamic>? ?? _userData;
        final isLoggedIn = arguments?['isLoggedIn'] as bool? ?? _isLoggedIn;

        return StartScreen(
          userData,
          apiService: widget.apiService,
          isLoggedIn: isLoggedIn, // Use the passed isLoggedIn value
          onLogout: () => _setLoggedIn(false, {}),
        );
},
    },

    );
  }
  
}