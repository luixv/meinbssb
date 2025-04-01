import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/screens/app_menu.dart';
import 'package:meinbssb/services/localization_service.dart';
import 'package:meinbssb/screens/logo_widget.dart';

class StartScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final bool isLoggedIn;
  final Function() onLogout;

  const StartScreen(
    this.userData, {
    required this.isLoggedIn,
    required this.onLogout,
    super.key,
  });

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
    _loadLocalization();
    debugPrint('StartScreen initialized with user: ${widget.userData}');
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

  Future<void> fetchSchulungen() async {
  final apiService = Provider.of<ApiService>(context, listen: false);
  final personId = widget.userData['PERSONID'];
  
  if (personId == null) {
    debugPrint('PERSONID is null');
    if (mounted) setState(() => isLoading = false);
    return;
  }

  final today = DateTime.now();
  final abDatum = "${today.day.toString().padLeft(2, '0')}.${today.month.toString().padLeft(2, '0')}.${today.year}";
  
  try {
    debugPrint('Fetching schulungen for $personId on $abDatum');
    final result = await apiService.fetchAngemeldeteSchulungen(personId, abDatum);
    
    if (mounted) {
      setState(() {
        schulungen = result;
        isLoading = false;
      });
    }
  } catch (e) {
    debugPrint('Error fetching schulungen: $e');
    if (mounted) {
      setState(() {
        isLoading = false;
        schulungen = []; // Ensure empty state is clear
      });
    }
  }
}


  void _handleLogout() {
    debugPrint('Logging out user: ${widget.userData['VORNAME']}');
    widget.onLogout(); // Update app state
    Navigator.of(context).pushReplacementNamed('/login'); // Force navigation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Angemeldete Schulungen'),
        actions: [
          AppMenu(
            context: context,
            userData: widget.userData,
            isLoggedIn: widget.isLoggedIn,
            onLogout: _handleLogout,
          )
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
            const Text(
              "Erstverein",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const Text(
              "Angemeldete Schulungen:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : schulungen.isEmpty
                    ? const Text(
                        "Keine Schulungen gefunden.",
                        style: TextStyle(color: Colors.grey),
                      )
                    : Expanded(
                        child: ListView(
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
                      ),
          ],
        ),
      ),
    );
  }
}