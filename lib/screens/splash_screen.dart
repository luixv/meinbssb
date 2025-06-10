import 'package:flutter/material.dart';
import '/services/core/logger_service.dart'; // Ensure LoggerService is correctly imported

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
    LoggerService.logInfo(
      'SplashScreen: initState called. Starting animation.',
    );

    _controller = AnimationController(
      duration: const Duration(
        seconds: 1,
      ),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    // Start the animation and then immediately call onFinish without extra delay.
    // This will make the splash screen transition quickly.
    _controller.forward().then((_) {
      LoggerService.logInfo(
        'SplashScreen: Animation forward complete. Calling onFinish.',
      );
      widget.onFinish();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    LoggerService.logInfo('SplashScreen: disposed.');
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
            width: 200,
            height: 200,
          ),
        ),
      ),
    );
  }
}
