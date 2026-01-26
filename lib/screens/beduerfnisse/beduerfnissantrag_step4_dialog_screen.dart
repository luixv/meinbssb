import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/widgets/scaled_text.dart';

class AddWaffeBesitzDialog extends StatefulWidget {
  const AddWaffeBesitzDialog({
    super.key,
    required this.antragsnummer,
    this.onSaved,
  });
  final int antragsnummer;
  final VoidCallback? onSaved;

  @override
  State<AddWaffeBesitzDialog> createState() => _AddWaffeBesitzDialogState();
}

class _AddWaffeBesitzDialogState extends State<AddWaffeBesitzDialog> {
  final _formKey = GlobalKey<FormState>();
  final _wbkNrController = TextEditingController();
  final _lfdWbkController = TextEditingController();
  final _herstellerController = TextEditingController();
  final _lauflaengeController = TextEditingController();
  final _gewichtController = TextEditingController();
  final _bemerkungController = TextEditingController();
  bool _kompensator = false;
  int? _selectedWaffenartId;
  int? _selectedKaliberId;
  int? _selectedBeduerfnisgrundId;
  String? _selectedVerband;
  bool _isLoading = false;

  late Future<List<dynamic>> _waffenartenFuture;
  late Future<List<dynamic>> _kaliberFuture;
  late Future<List<dynamic>> _gruendeFuture;

  @override
  void initState() {
    super.initState();
    final apiService = Provider.of<ApiService>(context, listen: false);
    _waffenartenFuture = apiService.getBedAuswahlByTypId(1);
    _kaliberFuture = apiService.getBedAuswahlByTypId(6);
    _gruendeFuture = apiService.getBedAuswahlByTypId(5);
  }

  @override
  void dispose() {
    _wbkNrController.dispose();
    _lfdWbkController.dispose();
    _herstellerController.dispose();
    _lauflaengeController.dispose();
    _gewichtController.dispose();
    _bemerkungController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final apiService = Provider.of<ApiService>(context, listen: false);
        await apiService.createBedWaffeBesitz(
          antragsnummer: widget.antragsnummer,
          wbkNr: _wbkNrController.text,
          lfdWbk: _lfdWbkController.text,
          waffenartId: _selectedWaffenartId ?? 0,
          kaliberId: _selectedKaliberId ?? 0,
          kompensator: _kompensator,
          hersteller: _herstellerController.text,
          lauflaengeId: int.tryParse(_lauflaengeController.text),
          gewicht: _gewichtController.text,
          beduerfnisgrundId: _selectedBeduerfnisgrundId,
          verbandId:
              _selectedVerband == 'BSSB'
                  ? 1
                  : 2, // Assuming mapping or adjust as needed
          bemerkung: _bemerkungController.text,
        );
        if (mounted) {
          Navigator.of(context).pop();
          if (widget.onSaved != null) widget.onSaved!();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Fehler beim Speichern: $e')));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, child) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: UIConstants.spacingL,
            vertical: UIConstants.spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
          ),
          backgroundColor: UIConstants.backgroundColor,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: UIConstants.dialogMaxWidthWide,
            ),
            child: Semantics(
              container: true,
              liveRegion: true,
              label: 'Dialog - Waffenbesitz hinzufügen',
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(UIConstants.spacingL),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title
                                  Semantics(
                                    header: true,
                                    label: 'Waffenbesitz hinzufügen',
                                    child: ScaledText(
                                      'Waffenbesitz hinzufügen',
                                      style: UIStyles.titleStyle.copyWith(
                                        fontSize:
                                            UIStyles.titleStyle.fontSize! *
                                            fontSizeProvider.scaleFactor,
                                        color: UIConstants.defaultAppColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: UIConstants.spacingM),

                                  // WBK fields
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _wbkNrController,
                                          style: UIStyles.bodyTextStyle,
                                          decoration: InputDecoration(
                                            labelText: 'WBK-Nr *',
                                            filled: true,
                                            fillColor: UIConstants.whiteColor,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    UIConstants.cornerRadius,
                                                  ),
                                            ),
                                          ),
                                          validator:
                                              (v) =>
                                                  v == null || v.isEmpty
                                                      ? 'Pflichtfeld'
                                                      : null,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: UIConstants.spacingM,
                                      ),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _lfdWbkController,
                                          style: UIStyles.bodyTextStyle,
                                          decoration: InputDecoration(
                                            labelText: 'lfd WBK *',
                                            filled: true,
                                            fillColor: UIConstants.whiteColor,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    UIConstants.cornerRadius,
                                                  ),
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
                                        child: FutureBuilder<List<dynamic>>(
                                          future: _waffenartenFuture,
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            }
                                            final items =
                                                snapshot.data?.map<
                                                  DropdownMenuItem<int>
                                                >((wa) {
                                                  return DropdownMenuItem<int>(
                                                    value: wa.id,
                                                    child: Text(
                                                      wa.beschreibung ??
                                                          wa.toString(),
                                                      style:
                                                          UIStyles
                                                              .bodyTextStyle,
                                                    ),
                                                  );
                                                }).toList();
                                            return DropdownButtonFormField<int>(
                                              value: _selectedWaffenartId,
                                              hint: const Text('Waffenart'),
                                              items: items,
                                              onChanged:
                                                  (val) => setState(
                                                    () =>
                                                        _selectedWaffenartId =
                                                            val,
                                                  ),
                                              decoration: InputDecoration(
                                                labelText: 'Waffenart *',
                                                filled: true,
                                                fillColor:
                                                    UIConstants.whiteColor,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        UIConstants
                                                            .cornerRadius,
                                                      ),
                                                ),
                                              ),
                                              validator:
                                                  (v) =>
                                                      v == null
                                                          ? 'Pflichtfeld'
                                                          : null,
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        width: UIConstants.spacingM,
                                      ),
                                      Expanded(
                                        child: FutureBuilder<List<dynamic>>(
                                          future: _kaliberFuture,
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            }
                                            final items =
                                                snapshot.data?.map<
                                                  DropdownMenuItem<int>
                                                >((k) {
                                                  return DropdownMenuItem<int>(
                                                    value: k.id,
                                                    child: Text(
                                                      k.beschreibung ??
                                                          k.toString(),
                                                      style:
                                                          UIStyles
                                                              .bodyTextStyle,
                                                    ),
                                                  );
                                                }).toList();
                                            return DropdownButtonFormField<int>(
                                              value: _selectedKaliberId,
                                              hint: const Text('Kaliber'),
                                              items: items,
                                              onChanged:
                                                  (val) => setState(
                                                    () =>
                                                        _selectedKaliberId =
                                                            val,
                                                  ),
                                              decoration: InputDecoration(
                                                labelText: 'Kaliber *',
                                                filled: true,
                                                fillColor:
                                                    UIConstants.whiteColor,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        UIConstants
                                                            .cornerRadius,
                                                      ),
                                                ),
                                              ),
                                              validator:
                                                  (v) =>
                                                      v == null
                                                          ? 'Pflichtfeld'
                                                          : null,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: UIConstants.spacingM),

                                  // Hersteller und Modell
                                  TextFormField(
                                    controller: _herstellerController,
                                    decoration: InputDecoration(
                                      labelText: 'Hersteller und Modell *',
                                      filled: true,
                                      fillColor: UIConstants.whiteColor,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          UIConstants.cornerRadius,
                                        ),
                                      ),
                                    ),
                                    style: UIStyles.bodyTextStyle,
                                    validator:
                                        (v) =>
                                            v == null || v.isEmpty
                                                ? 'Pflichtfeld'
                                                : null,
                                  ),
                                  const SizedBox(height: UIConstants.spacingM),

                                  // Lauflänge und Gewicht
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _lauflaengeController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            labelText: 'Lauflänge (mm) *',
                                            filled: true,
                                            fillColor: UIConstants.whiteColor,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    UIConstants.cornerRadius,
                                                  ),
                                            ),
                                          ),
                                          style: UIStyles.bodyTextStyle,
                                          validator: (v) {
                                            if (v == null || v.isEmpty) {
                                              return 'Pflichtfeld';
                                            }
                                            if (num.tryParse(v) == null) {
                                              return 'Nur Zahlen';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        width: UIConstants.spacingM,
                                      ),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _gewichtController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            labelText: 'Gewicht (g) *',
                                            filled: true,
                                            fillColor: UIConstants.whiteColor,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    UIConstants.cornerRadius,
                                                  ),
                                            ),
                                          ),
                                          style: UIStyles.bodyTextStyle,
                                          validator: (v) {
                                            if (v == null || v.isEmpty) {
                                              return 'Pflichtfeld';
                                            }
                                            if (num.tryParse(v) == null) {
                                              return 'Nur Zahlen';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: UIConstants.spacingS),

                                  // Kompensator
                                  CheckboxListTile(
                                    title: const Text(
                                      'Kompensator',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    value: _kompensator,
                                    onChanged:
                                        (val) => setState(
                                          () => _kompensator = val ?? false,
                                        ),
                                    activeColor: UIConstants.defaultAppColor,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  const SizedBox(height: UIConstants.spacingS),

                                  // Bedürfnisgrund und Verband
                                  Row(
                                    children: [
                                      Expanded(
                                        child: FutureBuilder<List<dynamic>>(
                                          future: _gruendeFuture,
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            }
                                            final items =
                                                snapshot.data?.map<
                                                  DropdownMenuItem<int>
                                                >((g) {
                                                  return DropdownMenuItem<int>(
                                                    value: g.id,
                                                    child: Text(
                                                      g.beschreibung ??
                                                          g.toString(),
                                                      style:
                                                          UIStyles
                                                              .bodyTextStyle,
                                                    ),
                                                  );
                                                }).toList();
                                            return DropdownButtonFormField<int>(
                                              value: _selectedBeduerfnisgrundId,
                                              items: items,
                                              onChanged:
                                                  (val) => setState(
                                                    () =>
                                                        _selectedBeduerfnisgrundId =
                                                            val,
                                                  ),
                                              decoration: InputDecoration(
                                                labelText: 'Bedürfnisgrund *',
                                                filled: true,
                                                fillColor:
                                                    UIConstants.whiteColor,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        UIConstants
                                                            .cornerRadius,
                                                      ),
                                                ),
                                              ),
                                              validator:
                                                  (v) =>
                                                      v == null
                                                          ? 'Pflichtfeld'
                                                          : null,
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        width: UIConstants.spacingM,
                                      ),
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          value: _selectedVerband,
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
                                          onChanged:
                                              (val) => setState(
                                                () => _selectedVerband = val,
                                              ),
                                          decoration: InputDecoration(
                                            labelText: 'Verband *',
                                            filled: true,
                                            fillColor: UIConstants.whiteColor,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    UIConstants.cornerRadius,
                                                  ),
                                            ),
                                          ),
                                          validator:
                                              (v) =>
                                                  v == null
                                                      ? 'Pflichtfeld'
                                                      : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: UIConstants.spacingM),

                                  // Bemerkung
                                  TextFormField(
                                    controller: _bemerkungController,
                                    decoration: InputDecoration(
                                      labelText: 'Bemerkung',
                                      filled: true,
                                      fillColor: UIConstants.whiteColor,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          UIConstants.cornerRadius,
                                        ),
                                      ),
                                    ),
                                    style: UIStyles.bodyTextStyle,
                                    minLines: 2,
                                    maxLines: 2,
                                  ),
                                  const SizedBox(
                                    height: UIConstants.spacingXXL,
                                  ), // More space for FABs
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // FAB Cancel and Save buttons
                  Positioned(
                    bottom: UIConstants.dialogFabTightBottom,
                    right: UIConstants.dialogFabTightRight,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Semantics(
                          button: true,
                          label: 'Abbrechen',
                          child: FloatingActionButton(
                            heroTag: 'fab_cancel_waffe',
                            mini: true,
                            backgroundColor: UIConstants.submitButtonBackground,
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Icon(
                              Icons.close,
                              color: UIConstants.buttonTextColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: UIConstants.spacingM),
                        Semantics(
                          button: true,
                          label: 'Speichern',
                          child: FloatingActionButton(
                            heroTag: 'fab_save_waffe',
                            mini: true,
                            backgroundColor: UIConstants.submitButtonBackground,
                            onPressed: _isLoading ? null : _save,
                            child:
                                _isLoading
                                    ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Icon(
                                      Icons.check,
                                      color: UIConstants.buttonTextColor,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
