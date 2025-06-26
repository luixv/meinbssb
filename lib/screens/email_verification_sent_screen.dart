import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/services/api/auth_service.dart';
import '/screens/base_screen_layout.dart';
import '/screens/set_password_screen.dart';
import '/widgets/scaled_text.dart';

class EmailVerificationSentScreen extends StatefulWidget {
  const EmailVerificationSentScreen({
    required this.email,
    required this.token,
    required this.authService,
    super.key,
  });

  final String email;
  final String token;
  final AuthService authService;

  @override
  EmailVerificationSentScreenState createState() => EmailVerificationSentScreenState();
}

class EmailVerificationSentScreenState extends State<EmailVerificationSentScreen> {
  @override
  void initState() {
    super.initState();
    _verifyEmailAndNavigate();
  }

  Future<void> _verifyEmailAndNavigate() async {
    // Add a small delay to ensure the screen is built
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (!mounted) return;

    // Navigate to set password screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SetPasswordScreen(
          email: widget.email,
          token: widget.token,
          authService: widget.authService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: 'Email Verification',
      userData: null,
      isLoggedIn: false,
      onLogout: () {},
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(UIConstants.primaryColor),
            ),
            SizedBox(height: UIConstants.spacingM),
            ScaledText(
              'Verifying your email...',
              style: UIStyles.bodyStyle,
            ),
          ],
        ),
      ),
    );
  }
}
