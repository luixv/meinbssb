import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/screens/logo_widget.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/models/user_data.dart';

class SchuetzenausweisScreen extends StatefulWidget {
  const SchuetzenausweisScreen({
    super.key,
    required this.personId,
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
  });

  final int personId;
  final UserData? userData;
  final bool isLoggedIn;
  final VoidCallback onLogout;
  @override
  State<SchuetzenausweisScreen> createState() => _SchuetzenausweisScreenState();
}

class _SchuetzenausweisScreenState extends State<SchuetzenausweisScreen> {
  late Future<Uint8List?> _schuetzenausweisFuture;

  @override
  void initState() {
    super.initState();
    final apiService = Provider.of<ApiService>(context, listen: false);
    _schuetzenausweisFuture = apiService.fetchSchuetzenausweis(widget.personId);
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: 'Schützenausweis',
      userData: widget.userData,
      isLoggedIn: widget.isLoggedIn,
      onLogout: widget.onLogout,
      body: Semantics(
        label:
            'Schützenausweis-Bereich. Hier sehen Sie Ihren digitalen Schützenausweis und die wichtigsten Informationen.',
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LogoWidget(),
              FutureBuilder<Uint8List?>(
                future: _schuetzenausweisFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || snapshot.data == null) {
                    return Center(
                      child: Semantics(
                        label:
                            'Fehlermeldung: Fehler beim Laden des Schützenausweises.',
                        child: Text(
                          'Fehler beim Laden des Schützenausweises.',
                          style: UIStyles.errorStyle,
                        ),
                      ),
                    );
                  }
                  return Semantics(
                    label: 'Schützenausweis Bild',
                    child: Card(
                      key: const ValueKey<String>('schuetzenausweis'),
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      color: UIConstants.backgroundColor,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: InteractiveViewer(
                            panEnabled: true,
                            minScale: 1,
                            maxScale: 5,
                            child: Image.memory(
                              snapshot.data!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: UIConstants.helpSpacing),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'schuetzenausweisFab',
        onPressed: () {
          Navigator.of(context).pushReplacementNamed(
            '/home',
            arguments: {'userData': widget.userData, 'isLoggedIn': true},
          );
        },
        backgroundColor: UIConstants.defaultAppColor,
        child: const Icon(Icons.home, color: UIConstants.whiteColor),
      ),
    );
  }
}

// ...existing code...
