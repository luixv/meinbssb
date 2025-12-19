import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import 'package:meinbssb/widgets/dialog_fabs.dart';
import 'package:meinbssb/models/beduerfnisse_auswahl_typ_data.dart';
import 'package:meinbssb/models/beduerfnisse_auswahl_data.dart';

class BeduerfnissantragStep2DialogScreen extends StatefulWidget {
  const BeduerfnissantragStep2DialogScreen({
    required this.antragsnummer,
    required this.onSaved,
    super.key,
  });

  final String antragsnummer;
  final Function(Map<String, dynamic>) onSaved;

  @override
  State<BeduerfnissantragStep2DialogScreen> createState() =>
      _BeduerfnissantragStep2DialogScreenState();
}

class _BeduerfnissantragStep2DialogScreenState
    extends State<BeduerfnissantragStep2DialogScreen> {
  final TextEditingController _datumController = TextEditingController();
  final TextEditingController _disziplinController = TextEditingController();
  final TextEditingController _wettkampfergebnisController =
      TextEditingController();
  bool _training = false;
  bool _isLoading = false;
  int? _selectedWaffenartId;
  late Future<List<BeduerfnisseAuswahlTyp>> _waffenartFuture;
  late Future<List<BeduerfnisseAuswahl>> _auswahlFuture;
  int? _selectedWettkampfartId;

  @override
  void initState() {
    super.initState();
    final apiService = Provider.of<ApiService>(context, listen: false);
    _waffenartFuture = apiService.getBedAuswahlTypen();
    _auswahlFuture = apiService.getBedAuswahlList();
  }

  @override
  void dispose() {
    _datumController.dispose();
    _disziplinController.dispose();
    _wettkampfergebnisController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      _datumController.text =
          '${pickedDate.day.toString().padLeft(2, '0')}.${pickedDate.month.toString().padLeft(2, '0')}.${pickedDate.year}';
    }
  }

  Future<void> _saveBedSport() async {
    if (_datumController.text.isEmpty ||
        _selectedWaffenartId == null ||
        _disziplinController.text.isEmpty) {
      if (mounted) {
        Navigator.of(
          context,
        ).pop({'error': 'Bitte füllen Sie alle erforderlichen Felder aus'});
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);

      // Convert DD.MM.YYYY format to YYYY-MM-DD for database
      final dateParts = _datumController.text.split('.');
      final schiessdatumForDb =
          '${dateParts[2]}-${dateParts[1]}-${dateParts[0]}';

      await apiService.createBedSport(
        antragsnummer: widget.antragsnummer,
        schiessdatum: schiessdatumForDb,
        waffenartId: _selectedWaffenartId!,
        disziplinId: int.parse(_disziplinController.text),
        training: _training,
        wettkampfartId: _selectedWettkampfartId,
        wettkampfergebnis:
            _wettkampfergebnisController.text.isNotEmpty
                ? double.parse(_wettkampfergebnisController.text)
                : null,
      );

      if (mounted) {
        widget.onSaved({
          'schiessdatum': _datumController.text,
          'waffenartId': _selectedWaffenartId!,
          'disziplinId': int.parse(_disziplinController.text),
          'training': _training,
          'wettkampfartId': _selectedWettkampfartId,
          'wettkampfergebnis':
              _wettkampfergebnisController.text.isNotEmpty
                  ? double.parse(_wettkampfergebnisController.text)
                  : null,
        });
        Navigator.of(context).pop({'success': true});
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop({'error': 'Fehler beim Speichern: $e'});
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, child) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
          ),
          backgroundColor: UIConstants.backgroundColor,
          child: Semantics(
            container: true,
            label: 'Dialog - Schießaktivität hinzufügen',
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(UIConstants.spacingL),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Semantics(
                          header: true,
                          label: 'Schießaktivität hinzufügen',
                          child: ScaledText(
                            'Schießaktivität hinzufügen',
                            style: UIStyles.titleStyle.copyWith(
                              fontSize:
                                  UIStyles.titleStyle.fontSize! *
                                  fontSizeProvider.scaleFactor,
                              color: UIConstants.defaultAppColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: UIConstants.spacingL),

                        // Datum
                        TextField(
                          controller: _datumController,
                          readOnly: true,
                          onTap: _selectDate,
                          style: UIStyles.bodyTextStyle.copyWith(
                            fontSize:
                                UIStyles.bodyTextStyle.fontSize! *
                                fontSizeProvider.scaleFactor,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Datum *',
                            hintText: 'Wählen Sie ein Datum',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                UIConstants.cornerRadius,
                              ),
                              borderSide: const BorderSide(
                                color: UIConstants.defaultAppColor,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                UIConstants.cornerRadius,
                              ),
                              borderSide: const BorderSide(
                                color: UIConstants.defaultAppColor,
                                width: 2,
                              ),
                            ),
                            suffixIcon: const Icon(
                              Icons.calendar_today,
                              color: UIConstants.defaultAppColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: UIConstants.spacingL),

                        // Waffenart Dropdown
                        FutureBuilder<List<BeduerfnisseAuswahlTyp>>(
                          future: _waffenartFuture,
                          builder: (context, snapshot) {
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

                            final waffenarten = snapshot.data ?? [];

                            return DropdownButtonFormField<int>(
                              value: _selectedWaffenartId,
                              hint: const Text('Wählen Sie eine Waffenart'),
                              isExpanded: true,
                              items:
                                  waffenarten.map((waffenart) {
                                    return DropdownMenuItem<int>(
                                      value: waffenart.id,
                                      child: ScaledText(
                                        '${waffenart.id} - ${waffenart.beschreibung}',
                                        style: UIStyles.bodyTextStyle.copyWith(
                                          fontSize:
                                              UIStyles.bodyTextStyle.fontSize! *
                                              fontSizeProvider.scaleFactor,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedWaffenartId = value;
                                  // Reset Wettkampfart when Waffenart changes
                                  _selectedWettkampfartId = null;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Waffenart *',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    UIConstants.cornerRadius,
                                  ),
                                  borderSide: const BorderSide(
                                    color: UIConstants.defaultAppColor,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    UIConstants.cornerRadius,
                                  ),
                                  borderSide: const BorderSide(
                                    color: UIConstants.defaultAppColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: UIConstants.spacingL),

                        // Disziplinnummer lt. SPO
                        TextField(
                          controller: _disziplinController,
                          keyboardType: TextInputType.number,
                          style: UIStyles.bodyTextStyle.copyWith(
                            fontSize:
                                UIStyles.bodyTextStyle.fontSize! *
                                fontSizeProvider.scaleFactor,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Disziplinnummer lt. SPO *',
                            hintText: 'z.B. 1',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                UIConstants.cornerRadius,
                              ),
                              borderSide: const BorderSide(
                                color: UIConstants.defaultAppColor,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                UIConstants.cornerRadius,
                              ),
                              borderSide: const BorderSide(
                                color: UIConstants.defaultAppColor,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: UIConstants.spacingL),

                        // Training Checkbox
                        Semantics(
                          checked: _training,
                          enabled: true,
                          label: 'Training',
                          onTap: () {
                            setState(() {
                              _training = !_training;
                            });
                          },
                          child: Row(
                            children: [
                              Checkbox(
                                value: _training,
                                activeColor: UIConstants.defaultAppColor,
                                onChanged: (value) {
                                  setState(() {
                                    _training = value ?? false;
                                  });
                                },
                              ),
                              ScaledText(
                                'Training',
                                style: UIStyles.bodyTextStyle.copyWith(
                                  fontSize:
                                      UIStyles.bodyTextStyle.fontSize! *
                                      fontSizeProvider.scaleFactor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: UIConstants.spacingL),

                        // Wettkampfart Dropdown (dependent on Waffenart)
                        FutureBuilder<List<BeduerfnisseAuswahl>>(
                          future: _auswahlFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasError) {
                              return const Text(
                                'Fehler beim Laden der Wettkampfarten',
                              );
                            }

                            final allWettkampfarten = snapshot.data ?? [];

                            // Filter Wettkampfarten by selected Waffenart
                            final filteredWettkampfarten =
                                _selectedWaffenartId != null
                                    ? allWettkampfarten
                                        .where(
                                          (w) =>
                                              w.typId == _selectedWaffenartId,
                                        )
                                        .toList()
                                    : [];

                            return DropdownButtonFormField<int>(
                              value: _selectedWettkampfartId,
                              hint: const Text('Wählen Sie eine Wettkampfart'),
                              items:
                                  filteredWettkampfarten.map((wettkampfart) {
                                    return DropdownMenuItem<int>(
                                      value: wettkampfart.id,
                                      child: ScaledText(
                                        wettkampfart.beschreibung,
                                        style: UIStyles.bodyTextStyle.copyWith(
                                          fontSize:
                                              UIStyles.bodyTextStyle.fontSize! *
                                              fontSizeProvider.scaleFactor,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedWettkampfartId = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Wettkampfart (optional)',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    UIConstants.cornerRadius,
                                  ),
                                  borderSide: const BorderSide(
                                    color: UIConstants.defaultAppColor,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    UIConstants.cornerRadius,
                                  ),
                                  borderSide: const BorderSide(
                                    color: UIConstants.defaultAppColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                              disabledHint: const Text(
                                'Wählen Sie zuerst eine Waffenart',
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: UIConstants.spacingL),

                        // Wettkampfergebnis (optional)
                        TextField(
                          controller: _wettkampfergebnisController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: UIStyles.bodyTextStyle.copyWith(
                            fontSize:
                                UIStyles.bodyTextStyle.fontSize! *
                                fontSizeProvider.scaleFactor,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Wettkampfergebnis (optional)',
                            hintText: 'z.B. 95.5',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                UIConstants.cornerRadius,
                              ),
                              borderSide: const BorderSide(
                                color: UIConstants.defaultAppColor,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                UIConstants.cornerRadius,
                              ),
                              borderSide: const BorderSide(
                                color: UIConstants.defaultAppColor,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: UIConstants.spacingL),
                      ],
                    ),
                  ),
                ),
                // FABs positioned at bottom-right
                Positioned(
                  bottom: UIConstants.dialogFabTightBottom,
                  right: UIConstants.dialogFabTightRight,
                  child: DialogFABs(
                    children: [
                      FloatingActionButton(
                        heroTag: 'cancelBedSportFab',
                        mini: true,
                        tooltip: 'Abbrechen',
                        backgroundColor: UIConstants.defaultAppColor,
                        onPressed:
                            _isLoading
                                ? null
                                : () => Navigator.of(context).pop(),
                        child: const Icon(
                          Icons.close,
                          color: UIConstants.whiteColor,
                        ),
                      ),
                      FloatingActionButton(
                        key: const ValueKey('saveBedSportFab'),
                        heroTag: 'saveBedSportFab',
                        mini: true,
                        tooltip: 'Speichern',
                        backgroundColor: UIConstants.defaultAppColor,
                        onPressed: _isLoading ? null : _saveBedSport,
                        child:
                            _isLoading
                                ? const SizedBox(
                                  width: UIConstants.loadingIndicatorSize,
                                  height: UIConstants.loadingIndicatorSize,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      UIConstants.whiteColor,
                                    ),
                                  ),
                                )
                                : const Icon(
                                  Icons.check,
                                  color: UIConstants.whiteColor,
                                ),
                      ),
                    ],
                  ),
                ),
                // Loading overlay
                if (_isLoading)
                  Positioned.fill(
                    child: AbsorbPointer(
                      absorbing: true,
                      child: Container(
                        color: UIConstants.overlayColor,
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              UIConstants.circularProgressIndicator,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
