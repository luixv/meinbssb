import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/constants/ui_constants.dart';

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
    final apiService = Provider.of<ApiService>(context, listen: false);

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
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: wbkNrController,
                              decoration: const InputDecoration(
                                labelText: 'WBK-Nr *',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(),
                              ),
                              validator:
                                  (v) =>
                                      v == null || v.isEmpty
                                          ? 'Pflichtfeld'
                                          : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: lfdWbkController,
                              decoration: const InputDecoration(
                                labelText: 'lfd WBK *',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(),
                              ),
                              validator:
                                  (v) =>
                                      v == null || v.isEmpty
                                          ? 'Pflichtfeld'
                                          : null,
                            ),
                          ),
                        ],
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
                          Semantics(
                            button: true,
                            label: 'Abbrechen',
                            hint: 'Dialog schließen ohne zu speichern',
                            child: FloatingActionButton(
                              heroTag: 'cancelWaffeBesitzFab',
                              mini: true,
                              backgroundColor:
                                  UIConstants.cancelButtonBackground,
                              foregroundColor: UIConstants.cancelButtonText,
                              tooltip: 'Abbrechen',
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Icon(Icons.close),
                            ),
                          ),
                          const SizedBox(height: UIConstants.spacingS),
                          Semantics(
                            button: true,
                            label: 'Speichern',
                            hint: 'Eingaben speichern',
                            child: FloatingActionButton(
                              heroTag: 'saveWaffeBesitzFab',
                              mini: true,
                              backgroundColor:
                                  UIConstants.submitButtonBackground,
                              foregroundColor: UIConstants.submitButtonText,
                              tooltip: 'Speichern',
                              onPressed: () async {
                                if (formKey.currentState?.validate() ?? false) {
                                  await apiService.createBedWaffeBesitz(
                                    antragsnummer: antragsnummer,
                                    wbkNr: wbkNrController.text,
                                    lfdWbk: lfdWbkController.text,
                                    waffenartId: selectedWaffenartId ?? 0,
                                    kaliberId:
                                        int.tryParse(
                                          kaliberIdController.text,
                                        ) ??
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
                              child: const Icon(Icons.check),
                            ),
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
