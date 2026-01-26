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
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 32,
          ),
          elevation: 0,
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
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with icon and title
                        Row(
                          children: [
                            Icon(
                              Icons.security,
                              color: UIConstants.defaultAppColor,
                              size: 28,
                            ),
                            const SizedBox(width: UIConstants.spacingM),
                            Expanded(
                              child: Text(
                                'Waffenbesitz hinzufügen',
                                style: UIStyles.headerStyle.copyWith(
                                  color: UIConstants.defaultAppColor,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: UIConstants.spacingL),
                        // ...existing code...
                        // WBK fields
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
                        const SizedBox(height: UIConstants.spacingM),
                        // Waffenart and Kaliber
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
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
                                          kaliberList?.map<
                                            DropdownMenuItem<int>
                                          >((k) {
                                            return DropdownMenuItem<int>(
                                              value: k.id,
                                              child: Text(
                                                k.beschreibung ?? k.toString(),
                                                style: UIStyles.bodyTextStyle,
                                              ),
                                            );
                                          }).toList();
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
                                                v == null
                                                    ? 'Pflichtfeld'
                                                    : null,
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: UIConstants.spacingM),
                        // Hersteller und Modell
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Hersteller und Modell *',
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
                          style: UIStyles.bodyTextStyle,
                          validator:
                              (v) =>
                                  v == null || v.isEmpty ? 'Pflichtfeld' : null,
                        ),
                        const SizedBox(height: UIConstants.spacingM),
                        // Lauflänge und Gewicht
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Lauflänge (mm) *',
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
                                style: UIStyles.bodyTextStyle,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Pflichtfeld';
                                  }
                                  final n = num.tryParse(v);
                                  if (n == null || n <= 0) {
                                    return 'Nur positive Zahl';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Gewicht (g) *',
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
                                style: UIStyles.bodyTextStyle,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Pflichtfeld';
                                  }
                                  final n = num.tryParse(v);
                                  if (n == null || n <= 0) {
                                    return 'Nur positive Zahl';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: UIConstants.spacingSM),
                        // Kompensator
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
                        const SizedBox(height: UIConstants.spacingSM),
                        // Bedürfnisgrund und Verband (moved here)
                        Row(
                          children: [
                            // Bedürfnisgrund Dropdown
                            Expanded(
                              child: FutureBuilder<List<dynamic>>(
                                future: apiService.getBedAuswahlByTypId(5),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  if (snapshot.hasError) {
                                    return const Text(
                                      'Fehler beim Laden der Gründe',
                                    );
                                  }
                                  final items =
                                      snapshot.data?.map<DropdownMenuItem<int>>(
                                        (g) {
                                          return DropdownMenuItem<int>(
                                            value: g.id,
                                            child: Text(
                                              g.beschreibung ?? g.toString(),
                                              style: UIStyles.bodyTextStyle,
                                            ),
                                          );
                                        },
                                      ).toList();
                                  return DropdownButtonFormField<int>(
                                    items: items,
                                    onChanged: (val) {},
                                    decoration: InputDecoration(
                                      labelText: 'Bedürfnisgrund *',
                                      filled: true,
                                      fillColor: UIConstants.whiteColor,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
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
                            // Verband Dropdown
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                items: const [
                                  DropdownMenuItem(
                                    value: 'BSSB',
                                    child: Text('BSSB'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Sonstiges',
                                    child: Text('Sonstiges'),
                                  ),
                                ],
                                onChanged: (val) {},
                                decoration: InputDecoration(
                                  labelText: 'Verband *',
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
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: UIConstants.spacingL),
                        // Bemerkung (free text, two rows, full width)
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Bemerkung',
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
                          style: UIStyles.bodyTextStyle,
                          minLines: 2,
                          maxLines: 2,
                        ),
                        const SizedBox(height: UIConstants.spacingL),
                        const SizedBox(height: 24),
                        // Action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.close),
                              label: const Text('Abbrechen'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    UIConstants.cancelButtonBackground,
                                foregroundColor: UIConstants.cancelButtonText,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: UIConstants.buttonFontSize,
                                  fontWeight: FontWeight.w600,
                                  color: UIConstants.cancelButtonText,
                                ),
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            const SizedBox(width: UIConstants.spacingS),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.check),
                              label: const Text('Speichern'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    UIConstants.submitButtonBackground,
                                foregroundColor: UIConstants.submitButtonText,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: UIConstants.buttonFontSize,
                                  fontWeight: FontWeight.w600,
                                  color: UIConstants.submitButtonText,
                                ),
                              ),
                              onPressed: () async {
                                if (formKey.currentState?.validate() ?? false) {
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
                            ),
                          ],
                        ),
                      ],
                    ),
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
