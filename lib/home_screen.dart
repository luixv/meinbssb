import 'package:flutter/material.dart';
import 'api_service.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const HomeScreen(this.userData, {super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> schulungen = [];
  bool isLoading = true;

  // Constants for key names
  static const String personIdKey = 'PERSONID';
  static const String vornameKey = 'VORNAME';
  static const String namenKey = 'NAMEN';
  static const String passnummerKey = 'PASSNUMMER';
  static const String vereinnameKey = 'VEREINNAME';

  @override
  void initState() {
    super.initState();
    fetchSchulungen();
  }

  Future<void> fetchSchulungen() async {
    final personId = widget.userData[personIdKey];
    if (personId == null) {
      debugPrint("PERSONID is null");
      setState(() {
        isLoading = false;
      });
      return;
    }

    final today = DateTime.now();
    final abDatum = "${today.day.toString().padLeft(2, '0')}.${today.month.toString().padLeft(2, '0')}.${today.year}";

    final result = await ApiService.fetchAngemeldeteSchulungen(personId, abDatum);
    setState(() {
      schulungen = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mein BSSB'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                Navigator.pop(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Abmelden'),
              ),
            ],
            icon: const Icon(Icons.menu),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${widget.userData[vornameKey]} ${widget.userData[namenKey]}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(widget.userData[passnummerKey], style: const TextStyle(fontSize: 18)),
            const Text("Schützenpassnummer", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            Text(widget.userData[vereinnameKey], style: const TextStyle(fontSize: 18)),
            const Text("Erstverein", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            const Text("Angemeldete Schulungen:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            isLoading
                ? const CircularProgressIndicator()
                : schulungen.isEmpty
                    ? const Text("Keine Schulungen gefunden.", style: TextStyle(color: Colors.grey))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: schulungen.map((schulung) {
                          final datum = DateTime.parse(schulung['DATUM']);
                          final formattedDatum = "${datum.day.toString().padLeft(2, '0')}.${datum.month.toString().padLeft(2, '0')}.${datum.year}";
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