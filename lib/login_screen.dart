import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'start_screen.dart'; 
import 'registration_screen.dart';
import 'help_page.dart';
import 'password_reset_screen.dart'; 
import 'logo_widget.dart'; 
import 'localization_service.dart'; 


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key}); // Key as a super parameter

  @override
  LoginScreenState createState() => LoginScreenState(); // Use the public class here
}

class LoginScreenState extends State<LoginScreen> { // Make this public
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String _errorMessage = '';
  Color _appColor = const Color(0xFF006400); // Default color

@override
  void initState() {
    super.initState();
    _loadLocalization();
  }

  Future<void> _loadLocalization() async {
    await LocalizationService.load('assets/strings.json'); // Adjust the path if needed
    setState(() {
      final colorString = LocalizationService.getString('appColor');
      if (colorString.isNotEmpty) {
        _appColor = Color(int.parse(colorString));
      }
    });
  }

Future<void> _handleLogin() async {
  setState(() {
    _isLoading = true;
    _errorMessage = '';
  });

  // First, perform the login
  final response = await ApiService.login(
    _emailController.text,
    _passwordController.text,
  );

  // Check if the widget is still mounted after the async call
  if (!mounted) return;

  if (response["ResultType"] == 1) {
    int personId = response["PersonID"];
    var passdaten = await ApiService.fetchPassdaten(personId);

    // Check if the widget is still mounted after the second async call
    if (!mounted) return;

    if (passdaten.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => StartScreen(passdaten),
        ),
      );
    } else {
      setState(() => _errorMessage = "Fehler beim Laden der Passdaten.");
    }
  } else {
    setState(() => _errorMessage = response["ResultMessage"]);
  }

  // Final mounted check before setting loading state to false
  if (mounted) {
    setState(() => _isLoading = false);
  }
}

void _navigateToRegistrationPage() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const RegistrationScreen(),
    ),
  );
}

  Future<void> _navigateToPasswordReset() async {
    String? personId;
    if(_emailController.text.isNotEmpty){
      final response = await ApiService.getPersonId(_emailController.text);
      if(response['ResultType'] == 1){
        personId = response['PersonID'].toString();
      }else{
        personId = null;
      }
    }else{
      personId = null;
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PasswordResetScreen(personId: personId ?? ""),//if personId is null, pass an empty string.
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView( // Wrap the entire body in SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LogoWidget(), 
              const SizedBox(height: 20),
               Text(
                "Hier anmelden",
                style: TextStyle(
                  color: _appColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                key: const Key('usernameField'), 
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: "E-mail"),
              ),
              TextField(
                key: const Key('passwordField'), 
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Passwort",
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
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
              const SizedBox(height: 45), // Increased space between the password and submit button
              if (_errorMessage.isNotEmpty)
                Text(_errorMessage, style: const TextStyle(color: Colors.red)),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading ? const CircularProgressIndicator() : const Text("Anmelden"),
                ),
              ),
              const SizedBox(height: 20), // Add spacing before the links
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    GestureDetector(
                            onTap: () {
                              _navigateToPasswordReset();
                            },
                            child: const Text(
                              "Passwort vergessen?",
                              style: TextStyle(
                                color: Color(0xFF006400),
                                decoration: TextDecoration.underline,
                                fontSize: 16,
                              ),
                            ),
                          ),

                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black, fontSize: 16),
                        children: [
                          const TextSpan(text: "Bestehen Fragen zum Account oder wird "),
                          TextSpan(
                          text: "Hilfe",
                          style: const TextStyle(
                            color: Color(0xFF006400), // Dark green color
                            decoration: TextDecoration.underline, // Underlined
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => HelpPage()), // Navigate to HelpPage
                            );
                          },
                        ),                          
                        const TextSpan(text: " benötigt?"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black, fontSize: 16),
                        children: [
                          const TextSpan(text: "Keinen Account? "),
                          TextSpan(
                            text: "Hier",
                            style: const TextStyle(color: Color(0xFF006400),
                            decoration: TextDecoration.underline), // Dark green color
                            recognizer: TapGestureRecognizer()..onTap = () {
                              _navigateToRegistrationPage(); // Future registration page
                            },
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



// Dummy page for demonstration purposes
class DummyPage extends StatelessWidget {
  const DummyPage({super.key}); // Use super.key directly

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dummy Page")),
      body: const Center(
        child: Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit."),
      ),
    );
  }
}