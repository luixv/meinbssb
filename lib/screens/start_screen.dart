import 'package:flutter/material.dart';
import 'package:meinbssb/services/api_service.dart'; // moved
import 'app_menu.dart';
import 'package:meinbssb/services/localization_service.dart'; // moved
import 'logo_widget.dart'; 

class StartScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final ApiService apiService;

  const StartScreen(this.userData, {required this.apiService, super.key}); 

  @override
  StartScreenState createState() => StartScreenState();
}

class StartScreenState extends State<StartScreen> {
  List<dynamic> schulungen = [];
  bool isLoading = true;
  Color _appColor = const Color(0xFF006400); 

  @override
  void initState() {
    super.initState();
    fetchSchulungen();
    _loadLocalization(); // Load localization
  }

  Future<void> _loadLocalization() async {
    await LocalizationService.load('assets/strings.json');
    setState(() {
      final colorString = LocalizationService.getString('appColor');
      if (colorString.isNotEmpty) {
        _appColor = Color(int.parse(colorString));
      }
    });
  }

  Future<void> fetchSchulungen() async {
    final personId = widget.userData['PERSONID'];
    if (personId == null) {
      debugPrint("PERSONID is null");
      setState(() {
        isLoading = false;
      });
      return;
    }

    final today = DateTime.now();
    final abDatum =
        "${today.day.toString().padLeft(2, '0')}.${today.month.toString().padLeft(2, '0')}.${today.year}";
    final result = await widget.apiService.fetchAngemeldeteSchulungen(personId, abDatum); // Use the injected apiService
    setState(() {
      schulungen = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Angemeldete Schulungen'),
        actions: [
          AppMenu(context: context, userData: widget.userData),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header UI (similar to login screen)
            const LogoWidget(), // Use LogoWidget here
            const SizedBox(height: 20),
            Text(
              "Mein BSSB", // Header title
              style: TextStyle(
                color: _appColor, // Use parameterized color
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Rest of the content
            Text(
                "${widget.userData['VORNAME']} ${widget.userData['NAMEN']}",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(widget.userData['PASSNUMMER'],
                style: const TextStyle(fontSize: 18)),
            const Text("Schützenpassnummer",
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            Text(widget.userData['VEREINNAME'],
                style: const TextStyle(fontSize: 18)),
            const Text("Erstverein", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            const Text("Angemeldete Schulungen:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            isLoading
                ? const CircularProgressIndicator()
                : schulungen.isEmpty
                    ? const Text("Keine Schulungen gefunden.",
                        style: TextStyle(color: Colors.grey))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: schulungen.map((schulung) {
                          final datum = DateTime.parse(schulung['DATUM']);
                          final formattedDatum =
                              "${datum.day.toString().padLeft(2, '0')}.${datum.month.toString().padLeft(2, '0')}.${datum.year}";
                          return ListTile(
                            title: Text(schulung['BEZEICHNUNG']),
                            subtitle: Text(formattedDatum),
                          );
                        }).toList(),
                      ),
          ],
        ),
      ),
    );
  }
}