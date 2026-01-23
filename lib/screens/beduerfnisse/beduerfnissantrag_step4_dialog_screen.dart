import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';

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
    final kompensator = ValueNotifier<bool>(false);
    int? selectedWaffenartId;
    int? selectedKaliberId;
    final apiService = Provider.of<ApiService>(context, listen: false);

    return FutureBuilder<List<dynamic>>(
      future: Provider.of<ApiService>(
        context,
        listen: false,
      ).getBedAuswahlByTypId(1),
      builder: (context, snapshot) {
        final waffenarten = snapshot.data;
        return Dialog(
          backgroundColor: UIConstants.backgroundColor,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: UIConstants.spacingL,
            vertical: UIConstants.spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
          ),
          child: Center(
            child: Container(
              width: 440,
              decoration: BoxDecoration(
                color: UIConstants.whiteColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 32,
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Waffenbesitz hinzufügen',
                        style: UIStyles.headerStyle,
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: wbkNrController,
                              style: UIStyles.bodyTextStyle,
                              decoration: InputDecoration(
                                labelText: 'WBK-Nr *',
                                filled: true,
                                fillColor: UIConstants.whiteColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
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
                              style: UIStyles.bodyTextStyle,
                              decoration: InputDecoration(
                                labelText: 'lfd WBK *',
                                filled: true,
                                fillColor: UIConstants.whiteColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
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
                      Row(
                        children: [
                          Expanded(
                            child: Builder(
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
                                    waffenarten?.map<DropdownMenuItem<int>>((
                                      wa,
                                    ) {
                                      return DropdownMenuItem<int>(
                                        value: wa.id,
                                        child: Text(
                                          wa.beschreibung ?? wa.toString(),
                                          style: UIStyles.bodyTextStyle,
                                        ),
                                      );
                                    }).toList();
                                return DropdownButtonFormField<int>(
                                  value: selectedWaffenartId,
                                  hint: const Text('Waffenart'),
                                  isExpanded: true,
                                  items: items,
                                  onChanged: (val) {
                                    selectedWaffenartId = val;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Waffenart *',
                                    filled: true,
                                    fillColor: UIConstants.whiteColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                  ),
                                  validator:
                                      (v) => v == null ? 'Pflichtfeld' : null,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: StatefulBuilder(
                              builder: (context, setState) {
                                return FutureBuilder<List<dynamic>>(
                                  future: apiService.getBedAuswahlByTypId(6),
                                  builder: (context, kaliberSnapshot) {
                                    if (kaliberSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    if (kaliberSnapshot.hasError) {
                                      return const Text(
                                        'Fehler beim Laden der Kaliber',
                                      );
                                    }
                                    final kaliberList = kaliberSnapshot.data;
                                    final items =
                                        kaliberList?.map<DropdownMenuItem<int>>(
                                          (k) {
                                            return DropdownMenuItem<int>(
                                              value: k.id,
                                              child: Text(
                                                k.beschreibung ?? k.toString(),
                                                style: UIStyles.bodyTextStyle,
                                              ),
                                            );
                                          },
                                        ).toList();
                                    return DropdownButtonFormField<int>(
                                      value: selectedKaliberId,
                                      hint: const Text('Kaliber'),
                                      isExpanded: true,
                                      items: items,
                                      onChanged: (val) {
                                        setState(() {
                                          selectedKaliberId = val;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Kaliber *',
                                        filled: true,
                                        fillColor: UIConstants.whiteColor,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 12,
                                            ),
                                      ),
                                      validator:
                                          (v) =>
                                              v == null ? 'Pflichtfeld' : null,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ValueListenableBuilder<bool>(
                          valueListenable: kompensator,
                          builder:
                              (context, value, _) => CheckboxListTile(
                                title: const Text(
                                  'Kompensator',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                value: value,
                                onChanged:
                                    (val) => kompensator.value = val ?? false,
                                activeColor: UIConstants.primaryColor,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                              ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
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
                            const SizedBox(width: UIConstants.spacingS),
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
                                  if (formKey.currentState?.validate() ??
                                      false) {
                                    await apiService.createBedWaffeBesitz(
                                      antragsnummer: antragsnummer,
                                      wbkNr: wbkNrController.text,
                                      lfdWbk: lfdWbkController.text,
                                      waffenartId: selectedWaffenartId ?? 0,
                                      kaliberId: selectedKaliberId ?? 0,
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
