import 'package:flutter/material.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/screens/logo_widget.dart';
import 'package:meinbssb/screens/app_menu.dart';
import 'package:meinbssb/services/localization_service.dart';

class ZweitmitgliedschaftenScreen extends StatefulWidget {
  final int personId;
  final Map<String, dynamic> userData;

  const ZweitmitgliedschaftenScreen({
    super.key,
    required this.personId,
    required this.userData,
  });

  @override
  State<ZweitmitgliedschaftenScreen> createState() =>
      _ZweitmitgliedschaftenScreenState();
}

class _ZweitmitgliedschaftenScreenState
    extends State<ZweitmitgliedschaftenScreen> {
  late Future<List<dynamic>> _zweitmitgliedschaftenFuture;
  Color _appColor = const Color(0xFF006400);

  @override
  void initState() {
    super.initState();
    _loadZweitmitgliedschaften();
    _loadLocalization();
  }

  Future<void> _loadLocalization() async {
    await LocalizationService.load('assets/strings.json');
    if (mounted) {
      setState(() {
        final colorString = LocalizationService.getString('appColor');
        if (colorString.isNotEmpty) {
          _appColor = Color(int.parse(colorString));
        }
      });
    }
  }

  void _loadZweitmitgliedschaften() {
    final apiService = Provider.of<ApiService>(context, listen: false);
    _zweitmitgliedschaftenFuture = apiService.fetchZweitmitgliedschaften(
      widget.personId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Zweitmitgliedschaften'),
        actions: [
          AppMenu(
            context: context,
            userData: widget.userData,
            isLoggedIn: true,
            onLogout: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LogoWidget(),
            const SizedBox(height: 20),
            Text(
              "Mein BSSB",
              style: TextStyle(
                color: _appColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "${widget.userData['VORNAME']} ${widget.userData['NAMEN']}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              widget.userData['PASSNUMMER'],
              style: const TextStyle(fontSize: 18),
            ),
            const Text(
              "Schützenpassnummer",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              widget.userData['VEREINNAME'],
              style: const TextStyle(fontSize: 18),
            ),
            const Text("Erstverein", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            const Text(
              "Zweitmitgliedschaften:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _zweitmitgliedschaftenFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Fehler beim Laden der Daten:\n${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _loadZweitmitgliedschaften();
                              });
                            },
                            child: const Text('Erneut versuchen'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'Keine Zweitmitgliedschaften gefunden.',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final item = snapshot.data![index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          title: Text(
                            item['VEREINNAME'] ?? 'Unbekannter Verein',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
