import 'package:flutter/material.dart';

class BeduerfnissantragStep4Screen extends StatelessWidget {
  final dynamic userData;
  final bool isLoggedIn;
  final VoidCallback? onLogout;
  final dynamic antrag;

  const BeduerfnissantragStep4Screen({
    Key? key,
    this.userData,
    this.isLoggedIn = false,
    this.onLogout,
    this.antrag,
  }) : super(key: key);

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
