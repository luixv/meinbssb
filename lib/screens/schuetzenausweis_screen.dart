import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/screens/app_menu.dart';
import '/screens/connectivity_icon.dart';
import '/screens/logo_widget.dart';
import '/services/api_service.dart';

class SchuetzenausweisScreen extends StatefulWidget {
  const SchuetzenausweisScreen({
    super.key,
    required this.personId,
    required this.userData,
  });
  final int personId;
  final Map<String, dynamic> userData;

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
    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: UIConstants.backgroundColor,
        title: const Text(
          'Schützenausweis',
          style: UIConstants.appBarTitleStyle,
        ),
        actions: [
          // --- Added ConnectivityIcon here ---
          const Padding(
            padding: UIConstants.defaultHorizontalPadding,
            child: ConnectivityIcon(),
          ),
          // --- End ConnectivityIcon addition ---
          AppMenu(
            context: context,
            userData: widget.userData,
            isLoggedIn: true,
            onLogout: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: UIConstants.defaultPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LogoWidget(), // Display the logo at the top
            const SizedBox(height: UIConstants.spacingS),
            FutureBuilder<Uint8List>(
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
                    errorMessage = errorMessage.substring('Exception: '.length);
                  }
                  return Center(
                    child: Text(
                      'Error beim Laden des Schützenausweises: $errorMessage',
                      style: UIConstants.errorStyle,
                    ),
                  );
                }
                if (snapshot.hasData && snapshot.data != null) {
                  return Center(
                    child: SizedBox(
                      key: const ValueKey<String>('schuetzenausweis'),
                      child: Image.memory(snapshot.data!),
                    ),
                  );
                }
                return const Center(
                  child: Text(
                    'Kein Schützenausweis verfügbar',
                    style: UIConstants.bodyStyle,
                  ),
                );
              },
            ),
            const SizedBox(height: UIConstants.spacingS),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'personalDataResultFab',
        onPressed: () {
          Navigator.of(context).pushReplacementNamed(
            '/home',
            arguments: {'isLoggedIn': true},
          );
        },
        backgroundColor: UIConstants.defaultAppColor,
        child: const Icon(
          Icons.home,
          color: UIConstants.whiteColor,
        ),
      ),
    );
  }
}
