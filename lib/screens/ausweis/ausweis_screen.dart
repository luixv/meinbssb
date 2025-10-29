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
  final Function() onLogout;

  @override
  State<SchuetzenausweisScreen> createState() => _SchuetzenausweisScreenState();
}

class _SchuetzenausweisScreenState extends State<SchuetzenausweisScreen> {
  late Future<Uint8List> _schuetzenausweisFuture;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
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
            'Schützenausweis anzeigen. Hier sehen Sie Ihren digitalen Schützenausweis und das Datum des letzten Updates. Bei Fehlern wird eine entsprechende Meldung angezeigt.',
        child: Padding(
          padding: UIConstants.defaultPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LogoWidget(),
              const SizedBox(height: UIConstants.spacingS),
              Expanded(
                child: FutureBuilder<Uint8List>(
                  future: _schuetzenausweisFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: UIConstants.defaultAppColor,
                          strokeWidth: UIConstants.defaultStrokeWidth,
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      String errorMessage = snapshot.error.toString();
                      if (errorMessage.startsWith('Exception: ')) {
                        errorMessage = errorMessage.substring(
                          'Exception: '.length,
                        );
                      }
                      return Center(
                        child: Text(
                          'Error beim Laden des Schützenausweises: $errorMessage',
                          style: UIStyles.errorStyle,
                        ),
                      );
                    }
                    if (snapshot.hasData && snapshot.data != null) {
                      return InteractiveViewer(
                        panEnabled: true,
                        minScale: 1,
                        maxScale: 5,
                        child: Center(
                          child: Image.memory(
                            snapshot.data!,
                            fit: BoxFit.contain,
                            key: const ValueKey<String>('schuetzenausweis'),
                          ),
                        ),
                      );
                    }
                    return const Center(
                      child: Text(
                        'Kein Schützenausweis verfügbar',
                        style: UIStyles.bodyStyle,
                      ),
                    );
                  },
                ),
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
