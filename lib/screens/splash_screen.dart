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
    _controller = AnimationController(
      duration: const Duration(seconds: 2), // Total duration: 2 seconds
      vsync: this,
    );

    // Fade-in for first second, fade-out for second second
    _animation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 1,
      ),
    ]).animate(_controller);

    _controller.forward().then((_) {
      widget.onFinish();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
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
