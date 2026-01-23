import 'package:flutter/material.dart';

class BeduerfnissantragStep4Screen extends StatelessWidget {

  const BeduerfnissantragStep4Screen({
    super.key,
    this.userData,
    this.isLoggedIn = false,
    this.onLogout,
    this.antrag,
  });
  final dynamic userData;
  final bool isLoggedIn;
  final VoidCallback? onLogout;
  final dynamic antrag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bedürfnisantrag Schritt 4')),
      body: const Center(
        child: Text('Dies ist Schritt 4 des Bedürfnissantrags.'),
      ),
    );
  }
}
