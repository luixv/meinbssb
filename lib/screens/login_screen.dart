import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/email_service.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'registration_screen.dart';
import 'help_page.dart';
import 'password_reset_screen.dart';
import 'logo_widget.dart';
import 'package:meinbssb/services/localization_service.dart';

class LoginScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onLoginSuccess;

  const LoginScreen({required this.onLoginSuccess, super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String _errorMessage = '';
  Color _appColor = UIConstants.defaultAppColor;

  @override
  void initState() {
    super.initState();
    _loadLocalization();
  }

  Future<void> _loadLocalization() async {
    await LocalizationService.load('assets/strings.json');
    setState(() {
      final colorString = LocalizationService.getString('appColor');
      if (colorString.isNotEmpty) {
        _appColor = Color(int.parse(colorString));
      }
    });
  }

  Future<void> _handleLogin() async {
    final apiService = Provider.of<ApiService>(context, listen: false);

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await apiService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      debugPrint('Login response: $response');

      if (response["ResultType"] == 1) {
        int personId = response["PersonID"];

        debugPrint('Retrieving passdaten');
        var passdaten = await apiService.fetchPassdaten(personId);
        debugPrint('User data: $passdaten');

        if (!mounted) return;

        if (passdaten.isNotEmpty) {
          // Combine all user data
          final completeUserData = {...passdaten, 'PERSONID': personId};

          // Trigger both state update and direct navigation
          widget.onLoginSuccess(completeUserData);

          // Fetch and cache Schuetzenausweis
          await apiService.fetchSchuetzenausweis(personId);

          // Immediate navigation as fallback
          if (mounted) {
            Navigator.of(context).pushReplacementNamed(
              '/home',
              arguments: {'userData': completeUserData, 'isLoggedIn': true},
            );
          }
        } else {
          setState(() => _errorMessage = "Fehler beim Laden der Passdaten.");
        }
      } else {
        setState(() => _errorMessage = response["ResultMessage"]);
      }
    } catch (e) {
      setState(() => _errorMessage = "Error: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToRegistrationPage() {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final emailService = Provider.of<EmailService>(context, listen: false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => RegistrationScreen(
              apiService: apiService,
              emailService: emailService,
            ),
      ),
    );
  }

  Future<void> _navigateToPasswordReset() async {
    if (!mounted) return;
    final apiService = Provider.of<ApiService>(context, listen: false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PasswordResetScreen(apiService: apiService),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: UIConstants.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LogoWidget(),
              SizedBox(height: UIConstants.defaultSpacing),
              Text(
                "Hier anmelden",
                style: UIConstants.headerStyle.copyWith(color: _appColor),
              ),
              SizedBox(height: UIConstants.defaultSpacing),
              TextField(
                key: const Key('usernameField'),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: UIConstants.defaultInputDecoration.copyWith(
                  labelText: "E-mail",
                ),
              ),
              SizedBox(height: UIConstants.smallSpacing),
              TextField(
                key: const Key('passwordField'),
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: UIConstants.defaultInputDecoration.copyWith(
                  labelText: "Passwort",
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                onSubmitted: (value) {
                  _handleLogin();
                },
              ),
              SizedBox(height: UIConstants.defaultSpacing * 2),
              if (_errorMessage.isNotEmpty)
                Text(_errorMessage, style: UIConstants.errorStyle),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UIConstants.lightGreen,
                    padding: UIConstants.buttonPadding,
                  ),
                  child:
                      _isLoading
                          ? CircularProgressIndicator(
                            color: UIConstants.white,
                            strokeWidth: 2.0,
                          )
                          : Text(
                            "Anmelden",
                            style: UIConstants.bodyStyle.copyWith(
                              color: UIConstants.white,
                            ),
                          ),
                ),
              ),
              SizedBox(height: UIConstants.defaultSpacing),
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _navigateToPasswordReset,
                      child: Text(
                        "Passwort vergessen?",
                        style: UIConstants.linkStyle.copyWith(
                          color: UIConstants.defaultAppColor,
                        ),
                      ),
                    ),
                    SizedBox(height: UIConstants.smallSpacing),
                    RichText(
                      text: TextSpan(
                        style: UIConstants.bodyStyle,
                        children: [
                          const TextSpan(
                            text: "Bestehen Fragen zum Account oder wird ",
                          ),
                          TextSpan(
                            text: "Hilfe",
                            style: UIConstants.linkStyle.copyWith(
                              color: UIConstants.defaultAppColor,
                            ),
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const HelpPage(),
                                      ),
                                    );
                                  },
                          ),
                          const TextSpan(text: " benötigt?"),
                        ],
                      ),
                    ),
                    SizedBox(height: UIConstants.smallSpacing),
                    RichText(
                      text: TextSpan(
                        style: UIConstants.bodyStyle,
                        children: [
                          const TextSpan(text: "Keinen Account? "),
                          TextSpan(
                            text: "Hier",
                            style: UIConstants.linkStyle.copyWith(
                              color: UIConstants.defaultAppColor,
                            ),
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap = _navigateToRegistrationPage,
                          ),
                          const TextSpan(text: " Registrieren."),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
