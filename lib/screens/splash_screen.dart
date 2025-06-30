import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
// Ensure LoggerService is correctly imported

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onFinish});
  final VoidCallback onFinish;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Removed LoggerService.logInfo from initState as per request context.

    _controller = AnimationController(
      duration:
          const Duration(seconds: 3), // Increased duration for a longer fade-in
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      // Changed to fade-in (0.0 to 1.0)
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn, // Using easeIn for a smoother fade-in
      ),
    );

    // Start the animation (fade-in). The onFinish callback is now called
    // immediately after the fade-in animation completes, without an additional delay.
    _controller.forward().then((_) {
      // Removed LoggerService.logInfo from here as per request context.
      widget.onFinish();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    // Removed LoggerService.logInfo from dispose as per request context.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Image.asset(
            'assets/images/BSSB_Wappen.png',
            width: UIConstants.logoSize * 2,
            height: UIConstants.logoSize * 2,
          ),
        ),
      ),
    );
  }
}
