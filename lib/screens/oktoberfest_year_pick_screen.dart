import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api/oktoberfest_service.dart';
import '../services/core/config_service.dart';
import '../models/gewinn.dart';
import '../constants/ui_styles.dart';
import 'base_screen_layout.dart';
import '../models/user_data.dart';

class OktoberfestYearPickScreen extends StatefulWidget {
  const OktoberfestYearPickScreen({
    super.key,
    required this.passnummer,
    required this.configService,
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
  });
  final String passnummer;
  final ConfigService configService;
  final UserData? userData;
  final bool isLoggedIn;
  final VoidCallback onLogout;

  @override
  State<OktoberfestYearPickScreen> createState() =>
      _OktoberfestYearPickScreenState();
}

class _OktoberfestYearPickScreenState extends State<OktoberfestYearPickScreen> {
  int _selectedYear = DateTime.now().year < 2024 ? 2024 : DateTime.now().year;
  bool _loading = false;
  List<Gewinn> _gewinne = [];

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    return BaseScreenLayout(
      title: 'Oktoberfest Landesschiessen',
      userData: widget.userData,
      isLoggedIn: widget.isLoggedIn,
      onLogout: widget.onLogout,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Bitte Jahr wählen:', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 24),
              DropdownButton<int>(
                value: _selectedYear,
                items: List.generate(
                  (currentYear < 2024 ? 1 : currentYear - 2024 + 1),
                  (index) => 2024 + index,
                )
                    .map(
                      (year) => DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedYear = value;
                    });
                  }
                },
              ),
              if (_loading) ...[
                const SizedBox(height: 32),
                const CircularProgressIndicator(),
              ],
              if (_gewinne.isNotEmpty) ...[
                const SizedBox(height: 32),
                const Text(
                  'Gefundene Gewinne:',
                  style: TextStyle(fontSize: 18),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _gewinne.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final gewinn = _gewinne[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 16,
                      ),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        title: Text(
                          gewinn.wettbewerb,
                          style: UIStyles.listItemTitleStyle,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Platz: ${gewinn.platz}',
                              style: UIStyles.listItemSubtitleStyle,
                            ),
                            Text(
                              'Geldpreis: ${gewinn.geldpreis}',
                              style: UIStyles.listItemSubtitleStyle,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final bankData = await showDialog<_BankDataResult>(
                      context: context,
                      builder: (context) => const BankDataDialog(),
                    );
                    if (!mounted) return;
                    if (bankData != null) {
                      final oktoberfestService =
                          Provider.of<OktoberfestService>(context,
                              listen: false,);
                      setState(() {
                        _loading = true;
                      });
                      final result = await oktoberfestService.gewinneAbrufen(
                        gewinnIDs: _gewinne.map((g) => g.gewinnId).toList(),
                        iban: bankData.iban,
                        passnummer: widget.passnummer,
                        configService: widget.configService,
                      );
                      setState(() {
                        _loading = false;
                      });
                      if (!mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OktoberfestAbrufResultScreen(success: result),
                        ),
                      );
                    }
                  },
                  child: const Text('Gewinne abrufen'),
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loading
            ? null
            : () async {
                setState(() {
                  _loading = true;
                });
                try {
                  debugPrint(
                    'Calling fetchGewinne with jahr=2024, passnummer=40100709',
                  );
                  final oktoberfestService =
                      Provider.of<OktoberfestService>(context, listen: false);
                  final List<Gewinn> gewinne =
                      await oktoberfestService.fetchGewinne(
                    jahr: 2024, // hardcoded for debugging
                    passnummer: '40100709', // hardcoded for debugging
                    configService: widget.configService,
                  );
                  debugPrint(
                    'fetchGewinne returned: \\${gewinne.length} gewinne',
                  );
                  setState(() {
                    _gewinne = gewinne;
                  });
                } catch (e) {
                  debugPrint('Fehler beim Abrufen der Gewinne: $e');
                } finally {
                  setState(() {
                    _loading = false;
                  });
                }
              },
        child: const Icon(Icons.check),
      ),
    );
  }
}

class _BankDataResult {
  _BankDataResult({
    required this.kontoinhaber,
    required this.iban,
    required this.bic,
  });
  final String kontoinhaber;
  final String iban;
  final String bic;
}

class BankDataDialog extends StatefulWidget {
  const BankDataDialog({super.key});

  @override
  State<BankDataDialog> createState() => _BankDataDialogState();
}

class _BankDataDialogState extends State<BankDataDialog> {
  final _formKey = GlobalKey<FormState>();
  final _kontoinhaberController = TextEditingController();
  final _ibanController = TextEditingController();
  final _bicController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bankdaten bearbeiten'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _kontoinhaberController,
              decoration: const InputDecoration(labelText: 'Kontoinhaber'),
              validator: (v) => v == null || v.isEmpty ? 'Pflichtfeld' : null,
            ),
            TextFormField(
              controller: _ibanController,
              decoration: const InputDecoration(labelText: 'IBAN'),
              validator: (v) => v == null || v.isEmpty ? 'Pflichtfeld' : null,
            ),
            TextFormField(
              controller: _bicController,
              decoration: const InputDecoration(labelText: 'BIC'),
              validator: (v) => v == null || v.isEmpty ? 'Pflichtfeld' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.of(context).pop(
                _BankDataResult(
                  kontoinhaber: _kontoinhaberController.text,
                  iban: _ibanController.text,
                  bic: _bicController.text,
                ),
              );
            }
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class OktoberfestAbrufResultScreen extends StatelessWidget {
  const OktoberfestAbrufResultScreen({super.key, required this.success});
  final bool success;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Abruf Ergebnis')),
      body: Center(
        child: success
            ? const Text(
                'Gewinne erfolgreich abgerufen!',
                style: TextStyle(fontSize: 20, color: Colors.green),
              )
            : const Text(
                'Fehler beim Abrufen der Gewinne.',
                style: TextStyle(fontSize: 20, color: Colors.red),
              ),
      ),
    );
  }
}
