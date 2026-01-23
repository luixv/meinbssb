import 'package:flutter/material.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import '/widgets/keyboard_focus_fab.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/services/api_service.dart';

class BeduerfnissantragStep4Screen extends StatefulWidget {
  const BeduerfnissantragStep4Screen({
    super.key,
    this.userData,
    this.isLoggedIn = false,
    this.onLogout,
    this.antrag,
  });

  final dynamic userData;
  final bool isLoggedIn;
  final VoidCallback? onLogout;
  final dynamic antrag;

  @override
  State<BeduerfnissantragStep4Screen> createState() =>
      _BeduerfnissantragStep4ScreenState();
}

class _BeduerfnissantragStep4ScreenState
    extends State<BeduerfnissantragStep4Screen> {
  late Future<List<dynamic>> _waffeBesitzFuture;

  @override
  void initState() {
    super.initState();
    _refreshWaffeBesitz();
  }

  void _refreshWaffeBesitz() {
    setState(() {
      _waffeBesitzFuture = _fetchWaffeBesitz(context);
    });
  }

  Future<List<dynamic>> _fetchWaffeBesitz(BuildContext context) async {
    if (widget.antrag == null || widget.antrag.antragsnummer == null) return [];
    final apiService = Provider.of<ApiService>(context, listen: false);
    return await apiService.getBedWaffeBesitzByAntragsnummer(
      widget.antrag.antragsnummer,
    );
  }

  Future<void> _showAddWaffeBesitzDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    // Example fields for BeduerfnisseWaffeBesitz
    final wbkNrController = TextEditingController();
    final lfdWbkController = TextEditingController();
    final waffenartIdController = TextEditingController();
    final kaliberIdController = TextEditingController();
    final kompensator = ValueNotifier<bool>(false);

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Waffenbesitz hinzufügen'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: wbkNrController,
                    decoration: const InputDecoration(labelText: 'WBK-Nr'),
                    validator:
                        (v) => v == null || v.isEmpty ? 'Pflichtfeld' : null,
                  ),
                  TextFormField(
                    controller: lfdWbkController,
                    decoration: const InputDecoration(labelText: 'lfd WBK'),
                    validator:
                        (v) => v == null || v.isEmpty ? 'Pflichtfeld' : null,
                  ),
                  TextFormField(
                    controller: waffenartIdController,
                    decoration: const InputDecoration(
                      labelText: 'Waffenart ID',
                    ),
                    keyboardType: TextInputType.number,
                    validator:
                        (v) => v == null || v.isEmpty ? 'Pflichtfeld' : null,
                  ),
                  TextFormField(
                    controller: kaliberIdController,
                    decoration: const InputDecoration(labelText: 'Kaliber ID'),
                    keyboardType: TextInputType.number,
                    validator:
                        (v) => v == null || v.isEmpty ? 'Pflichtfeld' : null,
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: kompensator,
                    builder:
                        (context, value, _) => CheckboxListTile(
                          title: const Text('Kompensator'),
                          value: value,
                          onChanged: (val) => kompensator.value = val ?? false,
                        ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  final apiService = Provider.of<ApiService>(
                    context,
                    listen: false,
                  );
                  await apiService.createBedWaffeBesitz(
                    antragsnummer: widget.antrag.antragsnummer,
                    wbkNr: wbkNrController.text,
                    lfdWbk: lfdWbkController.text,
                    waffenartId: int.tryParse(waffenartIdController.text) ?? 0,
                    kaliberId: int.tryParse(kaliberIdController.text) ?? 0,
                    kompensator: kompensator.value,
                    hersteller: null,
                    lauflaengeId: null,
                    gewicht: null,
                    beduerfnisgrundId: null,
                    verbandId: null,
                    bemerkung: null,
                  );
                  Navigator.of(ctx).pop();
                  _refreshWaffeBesitz();
                }
              },
              child: const Text('Speichern'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: 'Bedürfnisbescheinigung',
      userData: widget.userData,
      isLoggedIn: widget.isLoggedIn,
      onLogout: widget.onLogout ?? () {},
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width - 32,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                KeyboardFocusFAB(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icons.arrow_back,
                  heroTag: 'fab_back_step4',
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                KeyboardFocusFAB(
                  heroTag: 'addWaffeBesitzFab',
                  tooltip: 'Waffenbesitz hinzufügen',
                  semanticLabel: 'Waffenbesitz hinzufügen',
                  semanticHint: 'Neuen Waffenbesitz-Eintrag hinzufügen',
                  onPressed: () {
                    _showAddWaffeBesitzDialog(context);
                  },
                  icon: Icons.add,
                ),
                const SizedBox(height: 12),
                KeyboardFocusFAB(
                  heroTag: 'nextFromStep4Fab',
                  tooltip: 'Weiter',
                  semanticLabel: 'Weiter Button',
                  semanticHint: 'Weiter zum nächsten Schritt',
                  onPressed: () {
                    // TODO: Implement navigation to step 5 or finish
                  },
                  icon: Icons.arrow_forward,
                ),
              ],
            ),
          ],
        ),
      ),
      body: Semantics(
        label: 'Bedürfnisbescheinigung Schritt 4',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(UIConstants.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                label: 'Bedürfnisbescheinigung',
                child: ScaledText(
                  'Bedürfnisbescheinigung',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color.fromRGBO(11, 75, 16, 1),
                  ),
                ),
              ),
              const SizedBox(height: UIConstants.spacingM),
              const ScaledText(
                'Erfassen der Lang- bzw. Kurzwaffen',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: UIConstants.spacingM),

              // Show BedWaffeBesitz results
              FutureBuilder<List<dynamic>>(
                future: _waffeBesitzFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text('Fehler: \\${snapshot.error}');
                  }
                  final waffen = snapshot.data ?? [];
                  if (waffen.isEmpty) {
                    return const ScaledText(
                      'Keine Waffenbesitz-Einträge gefunden.',
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ScaledText(
                        'Waffenbesitz-Einträge:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingM),
                      ...waffen.map(
                        (w) => Card(
                          margin: const EdgeInsets.only(
                            bottom: UIConstants.spacingS,
                          ),
                          child: ListTile(title: Text(w.toString())),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: UIConstants.spacingXXXL),
            ],
          ),
        ),
      ),
    );
  }
}
