import 'package:flutter/material.dart';
import 'api_service.dart';
import 'app_menu.dart'; // Import the reusable menu

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const HomeScreen(this.userData, {super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> schulungen = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSchulungen();
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
          AppMenu(context: context, userData: widget.userData), // Pass userData to AppMenu
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${widget.userData['VORNAME']} ${widget.userData['NAMEN']}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(widget.userData['PASSNUMMER'], style: const TextStyle(fontSize: 18)),
            const Text("Schützenpassnummer", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            Text(widget.userData['VEREINNAME'], style: const TextStyle(fontSize: 18)),
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