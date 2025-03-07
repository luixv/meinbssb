import 'package:flutter/material.dart';
import 'api_service.dart';
import 'start_screen.dart'; // Ensure this import is correct

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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

    final response = await ApiService.login(
      _emailController.text,
      _passwordController.text,
    );

    if (response["ResultType"] == 1) {
      int personId = response["PersonID"];
      var passdaten = await ApiService.fetchPassdaten(personId);

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

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 60, 16, 16), // Adjust top padding to 40 (1 cm lower)
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align children to the left
          mainAxisAlignment: MainAxisAlignment.start, // Align children to the top
          children: [
            // Add the logo image (aligned to the left)
            Image.asset(
              'assets/images/myBSSB-logo.png', // Path to the image
              height: 100, // Adjust the height as needed
              width: 100, // Adjust the width as needed
            ),
            const SizedBox(height: 20), // Add some spacing
            // Add the "Hier anmelden" message
            const Text(
              "Hier anmelden",
              style: TextStyle(
                color: Color(0xFF006400), // Dark green color (hex value)
                fontSize: 24, // Adjust the font size as needed
                fontWeight: FontWeight.bold, // Make it bold
              ),
            ),
            const SizedBox(height: 20), // Add some spacing
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
                // Trigger login when Enter is pressed
                _handleLogin();
              },
            ),
            const SizedBox(height: 20),
            if (_errorMessage.isNotEmpty)
              Text(_errorMessage, style: const TextStyle(color: Colors.red)),
            // Make the button full width and set color to light green
            SizedBox(
              width: double.infinity, // Make the button as wide as the form
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen, // Set background color to light green
                  padding: const EdgeInsets.symmetric(vertical: 16), // Add padding
                ),
                child: _isLoading ? const CircularProgressIndicator() : const Text("Anmelden"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}