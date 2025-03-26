import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:meinbssb/services/api_service.dart';
import 'start_screen.dart';
import 'help_page.dart'; 

class LoginScreen extends StatefulWidget {
  final ApiService apiService;
  const LoginScreen({required this.apiService, super.key}); 
  
  @override
  LoginScreenState createState() => LoginScreenState(); // Use the public class here
}

class LoginScreenState extends State<LoginScreen> { // Make this public
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _handleLogin() async {
  setState(() {
    _isLoading = true;
    _errorMessage = '';
  });

  final response = await ApiService().login(
    _emailController.text,
    _passwordController.text,
  );

  if (!mounted) return;

  if (response["ResultType"] == 1) {
    int personId = response["PersonID"];
    var passdaten = await ApiService().fetchPassdaten(personId);

    if (passdaten.isNotEmpty) {
      // Another mounted check before navigation
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => StartScreen(
            passdaten,
            apiService: widget.apiService,
            isLoggedIn: true, 
            onLogout: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ),
      );
    } else {
      // One more mounted check before this state change
      if (!mounted) return;

      setState(() => _errorMessage = "Fehler beim Laden der Passdaten.");
    }
  } else {
    // Again, check if the widget is still mounted
    if (!mounted) return;

    setState(() => _errorMessage = response["ResultMessage"]);
  }

  // Final mounted check before changing loading state
  if (mounted) {
    setState(() => _isLoading = false);
  }
}

  void _navigateToDummyPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DummyPage(), // To be replaced with the actual page later
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
              Image.asset(
                'assets/images/myBSSB-logo.png',
                height: 100,
                width: 100,
              ),
              const SizedBox(height: 20),
              const Text(
                "Hier anmelden",
                style: TextStyle(
                  color: Color(0xFF006400),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: "E-mail"),
              ),
              TextField(
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
              const SizedBox(height: 30), // Increased space between the password and submit button
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
                        _navigateToDummyPage(); // Future page for password recovery
                      },
                      child: const Text(
                        "Passwort vergessen?",
                        style: TextStyle(color: Color(0xFF006400), 
                        decoration: TextDecoration.underline, fontSize: 16), // Dark green color
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
                              _navigateToDummyPage(); // Future registration page
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