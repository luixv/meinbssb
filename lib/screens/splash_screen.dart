import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/services/api_service.dart';
import '/constants/ui_constants.dart';

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

    preFetchCache();

    _controller = AnimationController(
      duration: const Duration(seconds: 3), // Fade-in duration: 3 seconds
      vsync: this,
    );

    // Fade-in only
    _animation = Tween<double>(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: Curves.easeIn))
        .animate(_controller);

    _controller.forward().then((_) {
      widget.onFinish();
    });
  }

  Future<void> preFetchCache() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    apiService.fetchBezirkeforSearch();
    apiService.fetchDisziplinen();
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
