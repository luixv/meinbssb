import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/services/api_service.dart';

class AddWaffeBesitzDialog extends StatelessWidget {
  const AddWaffeBesitzDialog({
    super.key,
    required this.antragsnummer,
    this.onSaved,
  });
  final int antragsnummer;
  final VoidCallback? onSaved;

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final wbkNrController = TextEditingController();
    final lfdWbkController = TextEditingController();
    final kaliberIdController = TextEditingController();
    final kompensator = ValueNotifier<bool>(false);
    int? selectedWaffenartId;

    return FutureBuilder<List<dynamic>>(
      // dynamic for BeduerfnisseAuswahl
      future: Provider.of<ApiService>(
        context,
        listen: false,
      ).getBedAuswahlByTypId(1),
      builder: (context, snapshot) {
        final waffenarten = snapshot.data;
        return Dialog(
          insetPadding: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          child: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Waffenbesitz hinzufügen',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(color: Theme.of(context).primaryColor),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: wbkNrController,
                        decoration: const InputDecoration(
                          labelText: 'WBK-Nr *',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (v) =>
                                v == null || v.isEmpty ? 'Pflichtfeld' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: lfdWbkController,
                        decoration: const InputDecoration(
                          labelText: 'lfd WBK *',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (v) =>
                                v == null || v.isEmpty ? 'Pflichtfeld' : null,
                      ),
                      const SizedBox(height: 16),
                      // Waffenart Dropdown with look and feel from step 2
                      Builder(
                        builder: (context) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError) {
                            return const Text(
                              'Fehler beim Laden der Waffenarten',
                            );
                          }
                          final items =
                              waffenarten?.map<DropdownMenuItem<int>>((wa) {
                                return DropdownMenuItem<int>(
                                  value: wa.id,
                                  child: Text(wa.beschreibung ?? wa.toString()),
                                );
                              }).toList();
                          return DropdownButtonFormField<int>(
                            value: selectedWaffenartId,
                            hint: const Text('Waffenart wählen'),
                            isExpanded: true,
                            items: items,
                            onChanged: (val) {
                              selectedWaffenartId = val;
                            },
                            decoration: const InputDecoration(
                              labelText: 'Waffenart *',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => v == null ? 'Pflichtfeld' : null,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: kaliberIdController,
                        decoration: const InputDecoration(
                          labelText: 'Kaliber ID *',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator:
                            (v) =>
                                v == null || v.isEmpty ? 'Pflichtfeld' : null,
                      ),
                      const SizedBox(height: 16),
                      ValueListenableBuilder<bool>(
                        valueListenable: kompensator,
                        builder:
                            (context, value, _) => CheckboxListTile(
                              title: const Text('Kompensator'),
                              value: value,
                              onChanged:
                                  (val) => kompensator.value = val ?? false,
                            ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Abbrechen'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState?.validate() ?? false) {
                                final apiService = Provider.of<ApiService>(
                                  context,
                                  listen: false,
                                );
                                await apiService.createBedWaffeBesitz(
                                  antragsnummer: antragsnummer,
                                  wbkNr: wbkNrController.text,
                                  lfdWbk: lfdWbkController.text,
                                  waffenartId: selectedWaffenartId ?? 0,
                                  kaliberId:
                                      int.tryParse(kaliberIdController.text) ??
                                      0,
                                  kompensator: kompensator.value,
                                  hersteller: null,
                                  lauflaengeId: null,
                                  gewicht: null,
                                  beduerfnisgrundId: null,
                                  verbandId: null,
                                  bemerkung: null,
                                );
                                Navigator.of(context).pop();
                                if (onSaved != null) onSaved!();
                              }
                            },
                            child: const Text('Speichern'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
