import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import 'package:meinbssb/models/beduerfnis_waffe_besitz_data.dart';

class AddWaffeBesitzDialog extends StatefulWidget {
  const AddWaffeBesitzDialog({
    super.key,
    required this.antragsnummer,
    this.onSaved,
    this.waffeBesitz,
  });
  final int antragsnummer;
  final VoidCallback? onSaved;
  final BeduerfnisWaffeBesitz? waffeBesitz;

  @override
  State<AddWaffeBesitzDialog> createState() => _AddWaffeBesitzDialogState();
}

class _AddWaffeBesitzDialogState extends State<AddWaffeBesitzDialog> {
  bool get _allRequiredFieldsFilled {
    return _wbkNrController.text.isNotEmpty &&
        _lfdWbkController.text.isNotEmpty &&
        _selectedWaffenartId != null &&
        _selectedKaliberId != null &&
        _herstellerController.text.isNotEmpty &&
        _selectedLauflaengeId != null &&
        _gewichtController.text.isNotEmpty &&
        num.tryParse(_gewichtController.text) != null &&
        _selectedBeduerfnisgrundId != null &&
        _selectedVerbandId != null;
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Add listeners to text controllers for compulsory fields
    _wbkNrController.removeListener(_onFieldChanged);
    _lfdWbkController.removeListener(_onFieldChanged);
    _herstellerController.removeListener(_onFieldChanged);
    _gewichtController.removeListener(_onFieldChanged);
    _wbkNrController.addListener(_onFieldChanged);
    _lfdWbkController.addListener(_onFieldChanged);
    _herstellerController.addListener(_onFieldChanged);
    _gewichtController.addListener(_onFieldChanged);
  }

  final _formKey = GlobalKey<FormState>();
  final _wbkNrController = TextEditingController();
  final _lfdWbkController = TextEditingController();
  final _herstellerController = TextEditingController();
  final _gewichtController = TextEditingController();
  final _bemerkungController = TextEditingController();
  bool _kompensator = false;
  int? _selectedWaffenartId;
  int? _selectedKaliberId;
  int? _selectedBeduerfnisgrundId;
  int? _selectedLauflaengeId;
  int? _selectedVerbandId;
  bool _isLoading = false;

  late Future<List<dynamic>> _waffenartenFuture;
  late Future<List<dynamic>> _kaliberFuture;
  late Future<List<dynamic>> _gruendeFuture;
  late Future<List<dynamic>> _lauflaengeFuture;
  late Future<List<dynamic>> _verbandFuture;

  @override
  void initState() {
    super.initState();
    final apiService = Provider.of<ApiService>(context, listen: false);
    _waffenartenFuture = apiService.getBedAuswahlByTypId(1);
    _kaliberFuture = apiService.getBedAuswahlByTypId(6);
    _gruendeFuture = apiService.getBedAuswahlByTypId(5);
    _lauflaengeFuture = apiService.getBedAuswahlByTypId(4);
    _verbandFuture = apiService.getBedAuswahlByTypId(3);

    if (widget.waffeBesitz != null) {
      final wb = widget.waffeBesitz!;
      _wbkNrController.text = wb.wbkNr;
      _lfdWbkController.text = wb.lfdWbk;
      _herstellerController.text = wb.hersteller ?? '';
      _gewichtController.text = wb.gewicht ?? '';
      _bemerkungController.text = wb.bemerkung ?? '';
      _kompensator = wb.kompensator;
      _selectedWaffenartId = wb.waffenartId;
      _selectedKaliberId = wb.kaliberId;
      _selectedBeduerfnisgrundId = wb.beduerfnisgrundId;
      _selectedLauflaengeId = wb.lauflaengeId;
      _selectedVerbandId = wb.verbandId;
    }
  }

  @override
  void dispose() {
    _wbkNrController.dispose();
    _lfdWbkController.dispose();
    _herstellerController.dispose();
    _gewichtController.dispose();
    _bemerkungController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final apiService = Provider.of<ApiService>(context, listen: false);
        if (widget.waffeBesitz != null) {
          final updatedWb = BeduerfnisWaffeBesitz(
            id: widget.waffeBesitz!.id,
            antragsnummer: widget.antragsnummer,
            wbkNr: _wbkNrController.text,
            lfdWbk: _lfdWbkController.text,
            waffenartId: _selectedWaffenartId ?? 0,
            kaliberId: _selectedKaliberId ?? 0,
            kompensator: _kompensator,
            hersteller: _herstellerController.text,
            lauflaengeId: _selectedLauflaengeId,
            gewicht: _gewichtController.text,
            beduerfnisgrundId: _selectedBeduerfnisgrundId,
            verbandId: _selectedVerbandId,
            bemerkung: _bemerkungController.text,
          );

          if (updatedWb.id == null) {
            throw Exception(
              'Fehler: Die ID des Eintrags konnte nicht ermittelt werden.',
            );
          }

          await apiService.updateBedWaffeBesitz(updatedWb);
        } else {
          await apiService.createBedWaffeBesitz(
            antragsnummer: widget.antragsnummer,
            wbkNr: _wbkNrController.text,
            lfdWbk: _lfdWbkController.text,
            waffenartId: _selectedWaffenartId ?? 0,
            kaliberId: _selectedKaliberId ?? 0,
            kompensator: _kompensator,
            hersteller: _herstellerController.text,
            lauflaengeId: _selectedLauflaengeId,
            gewicht: _gewichtController.text,
            beduerfnisgrundId: _selectedBeduerfnisgrundId,
            verbandId: _selectedVerbandId,
            bemerkung: _bemerkungController.text,
          );
        }
        if (mounted) {
          Navigator.of(context).pop();
          if (widget.onSaved != null) widget.onSaved!();
        }
      } catch (e) {
        if (mounted) {
          showDialog(
            context: context,
            builder:
                (ctx) => AlertDialog(
                  title: const Text('Fehler'),
                  content: Text('Fehler beim Speichern: $e'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
          );
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
        // The Dropdowns' onChanged will also call setState, so no extra listeners needed for them.
        // The FAB will be enabled only if all required fields are filled and not loading.
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
                                    label:
                                        widget.waffeBesitz != null
                                            ? 'Waffenbesitz bearbeiten'
                                            : 'Waffenbesitz hinzufügen',
                                    child: ScaledText(
                                      widget.waffeBesitz != null
                                          ? 'Waffenbesitz bearbeiten'
                                          : 'Waffenbesitz hinzufügen',
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
                                          maxLength: 3,
                                          decoration: InputDecoration(
                                            labelText: 'lfd WBK *',
                                            counterText: '',
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
                                              isExpanded: true,
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
                                              isExpanded: true,
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
                                        child: FutureBuilder<List<dynamic>>(
                                          future: _lauflaengeFuture,
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            }
                                            // Debugging output for lauflaenge API result
                                            if (snapshot.hasData) {
                                              debugPrint(
                                                'Lauflaenge API result:',
                                              );
                                              for (var item in snapshot.data!) {
                                                debugPrint('Item: $item');
                                              }
                                            } else if (snapshot.hasError) {
                                              debugPrint(
                                                'Lauflaenge API error: ${snapshot.error}',
                                              );
                                            }
                                            if (snapshot.data == null ||
                                                snapshot.data!.isEmpty) {
                                              // Show empty dropdown if no data
                                              return DropdownButtonFormField<
                                                int
                                              >(
                                                value: null,
                                                hint: const Text('Lauflänge'),
                                                items: const [],
                                                onChanged: null,
                                                decoration: InputDecoration(
                                                  labelText: 'Lauflänge *',
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
                                                        'Keine Werte verfügbar',
                                              );
                                            }
                                            final items =
                                                snapshot.data?.map<
                                                  DropdownMenuItem<int>
                                                >((k) {
                                                  if (k is Map &&
                                                      k.containsKey('id')) {
                                                    // Object with id and beschreibung
                                                    return DropdownMenuItem<
                                                      int
                                                    >(
                                                      value: k['id'] as int,
                                                      child: Text(
                                                        k['beschreibung']
                                                                ?.toString() ??
                                                            k['id'].toString(),
                                                        style:
                                                            UIStyles
                                                                .bodyTextStyle,
                                                      ),
                                                    );
                                                  } else if (k.id != null) {
                                                    // Object with id property
                                                    return DropdownMenuItem<
                                                      int
                                                    >(
                                                      value: k.id,
                                                      child: Text(
                                                        k.beschreibung
                                                                ?.toString() ??
                                                            k.id.toString(),
                                                        style:
                                                            UIStyles
                                                                .bodyTextStyle,
                                                      ),
                                                    );
                                                  } else if (k is String) {
                                                    // Plain string value
                                                    return DropdownMenuItem<
                                                      int
                                                    >(
                                                      value: snapshot.data!
                                                          .indexOf(k),
                                                      child: Text(
                                                        k,
                                                        style:
                                                            UIStyles
                                                                .bodyTextStyle,
                                                      ),
                                                    );
                                                  } else {
                                                    // Fallback: show toString
                                                    return DropdownMenuItem<
                                                      int
                                                    >(
                                                      value: snapshot.data!
                                                          .indexOf(k),
                                                      child: Text(
                                                        k.toString(),
                                                        style:
                                                            UIStyles
                                                                .bodyTextStyle,
                                                      ),
                                                    );
                                                  }
                                                }).toList();
                                            return DropdownButtonFormField<int>(
                                              isExpanded: true,
                                              value: _selectedLauflaengeId,
                                              hint: const Text('Lauflänge'),
                                              items: items,
                                              onChanged:
                                                  (val) => setState(
                                                    () =>
                                                        _selectedLauflaengeId =
                                                            val,
                                                  ),
                                              decoration: InputDecoration(
                                                labelText: 'Lauflänge *',
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
                                              isExpanded: true,
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
                                        child: FutureBuilder<List<dynamic>>(
                                          future: _verbandFuture,
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            }
                                            if (snapshot.data == null ||
                                                snapshot.data!.isEmpty) {
                                              return DropdownButtonFormField<
                                                int
                                              >(
                                                value: null,
                                                hint: const Text('Verband'),
                                                items: const [],
                                                onChanged: null,
                                                decoration: InputDecoration(
                                                  labelText: 'Verband *',
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
                                                        'Keine Werte verfügbar',
                                              );
                                            }
                                            final items =
                                                snapshot.data?.map<
                                                  DropdownMenuItem<int>
                                                >((v) {
                                                  return DropdownMenuItem<int>(
                                                    value: v.id,
                                                    child: Text(
                                                      v.beschreibung ??
                                                          v.toString(),
                                                      style:
                                                          UIStyles
                                                              .bodyTextStyle,
                                                    ),
                                                  );
                                                }).toList();
                                            return DropdownButtonFormField<int>(
                                              isExpanded: true,
                                              value: _selectedVerbandId,
                                              items: items,
                                              onChanged:
                                                  (val) => setState(
                                                    () =>
                                                        _selectedVerbandId =
                                                            val,
                                                  ),
                                              decoration: InputDecoration(
                                                labelText: 'Verband *',
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
                          child: AbsorbPointer(
                            absorbing: !_allRequiredFieldsFilled || _isLoading,
                            child: FloatingActionButton(
                              heroTag: 'fab_save_waffe',
                              mini: true,
                              backgroundColor:
                                  _allRequiredFieldsFilled && !_isLoading
                                      ? UIConstants.submitButtonBackground
                                      : UIConstants.disabledBackgroundColor,
                              onPressed:
                                  (_allRequiredFieldsFilled && !_isLoading)
                                      ? _save
                                      : null,
                              foregroundColor:
                                  _allRequiredFieldsFilled && !_isLoading
                                      ? UIConstants.buttonTextColor
                                      : Colors.white,
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
                                      : Icon(
                                        Icons.check,
                                        color:
                                            _allRequiredFieldsFilled &&
                                                    !_isLoading
                                                ? UIConstants.buttonTextColor
                                                : Colors.white,
                                      ),
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
