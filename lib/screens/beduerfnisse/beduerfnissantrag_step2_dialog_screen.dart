import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/core/document_scanner_service.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import 'package:meinbssb/widgets/dialog_fabs.dart';
import 'package:meinbssb/models/beduerfnisse_auswahl_data.dart';
import 'package:meinbssb/models/disziplin_data.dart';

class BeduerfnissantragStep2DialogScreen extends StatefulWidget {
  const BeduerfnissantragStep2DialogScreen({
    required this.antragsnummer,
    required this.onSaved,
    super.key,
  });

  final int? antragsnummer;
  final Function(Map<String, dynamic>) onSaved;

  @override
  State<BeduerfnissantragStep2DialogScreen> createState() =>
      _BeduerfnissantragStep2DialogScreenState();
}

class _BeduerfnissantragStep2DialogScreenState
    extends State<BeduerfnissantragStep2DialogScreen> {
  final TextEditingController _datumController = TextEditingController();
  final TextEditingController _wettkampfergebnisController =
      TextEditingController();
  bool _training = false;
  bool _isLoading = false;
  bool _documentUploaded = false;
  bool _isUploadingDocument = false;
  int?
  _uploadedDateiId; // Stores the datei_id from uploadBedDatei (before mapping to sport)
  int? _selectedWaffenartId;
  int? _selectedDisziplinId;
  late Future<List<BeduerfnisseAuswahl>> _waffenartFuture;
  late Future<List<BeduerfnisseAuswahl>> _auswahlFuture;
  late Future<List<Disziplin>> _disziplinenFuture;
  int? _selectedWettkampfartId;

  @override
  void initState() {
    super.initState();

    // Set default date to today
    final now = DateTime.now();
    _datumController.text =
        '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}';

    final apiService = Provider.of<ApiService>(context, listen: false);
    _waffenartFuture = apiService.getBedAuswahlByTypId(1);
    _auswahlFuture = apiService.getBedAuswahlByTypId(2);
    _disziplinenFuture = apiService.fetchDisziplinen();

    // Add listeners to update UI when fields change
    _datumController.addListener(() {
      setState(() {});
    });
    _wettkampfergebnisController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _datumController.dispose();
    _wettkampfergebnisController.dispose();
    super.dispose();
  }

  bool _areAllCompulsoryFieldsFilled() {
    // Wettkampfart and Wettkampfergebnis are required only if training is NOT checked
    final wettkampfartRequired = !_training && _selectedWettkampfartId == null;
    final wettkampfergebnisRequired =
        !_training && _wettkampfergebnisController.text.isEmpty;

    return _datumController.text.isNotEmpty &&
        _selectedWaffenartId != null &&
        _selectedDisziplinId != null &&
        !wettkampfartRequired &&
        !wettkampfergebnisRequired;
  }

  // Scan a single document with edge detection
  Future<void> _scanDocument(BuildContext buttonContext) async {
    if (widget.antragsnummer == null) {
      ScaffoldMessenger.of(buttonContext).showSnackBar(
        const SnackBar(content: Text('Fehler: Antragsnummer fehlt')),
      );
      return;
    }

    setState(() {
      _isUploadingDocument = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final scanResult = await apiService.scanDocument();

      if (scanResult == null) {
        // User cancelled scanning
        setState(() {
          _isUploadingDocument = false;
        });
        return;
      }

      final dateiId = await apiService.uploadBedDatei(
        antragsnummer: widget.antragsnummer!,
        dateiname: scanResult.fileName,
        fileBytes: scanResult.bytes,
      );

      if (mounted) {
        if (dateiId != null) {
          setState(() {
            _uploadedDateiId = dateiId;
            _documentUploaded = true;
            _isUploadingDocument = false;
          });
          ScaffoldMessenger.of(buttonContext).showSnackBar(
            const SnackBar(
              content: Text('Dokument erfolgreich gescannt und hochgeladen'),
            ),
          );
        } else {
          setState(() {
            _isUploadingDocument = false;
          });
          ScaffoldMessenger.of(buttonContext).showSnackBar(
            const SnackBar(
              content: Text('Fehler beim Hochladen des Dokuments'),
            ),
          );
        }
      }
    } on UnsupportedPlatformException catch (e) {
      setState(() {
        _isUploadingDocument = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(buttonContext).showSnackBar(
          SnackBar(
            content: Text(e.message),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } on ScanException catch (e) {
      setState(() {
        _isUploadingDocument = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          buttonContext,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      setState(() {
        _isUploadingDocument = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          buttonContext,
        ).showSnackBar(SnackBar(content: Text('Fehler beim Scannen: $e')));
      }
    }
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) => _buildCustomCalendarDialog(),
    );

    if (pickedDate != null) {
      setState(() {
        _datumController.text =
            '${pickedDate.day.toString().padLeft(2, '0')}.${pickedDate.month.toString().padLeft(2, '0')}.${pickedDate.year}';
      });
    }
  }

  Widget _buildCustomCalendarDialog() {
    DateTime selectedDate = DateTime.now();
    DateTime displayMonth = DateTime.now();

    return StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: UIConstants.backgroundColor,
              borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(UIConstants.spacingL),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with month/year and navigation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            color: UIConstants.defaultAppColor,
                            onPressed: () {
                              setState(() {
                                displayMonth = DateTime(
                                  displayMonth.year,
                                  displayMonth.month - 1,
                                );
                              });
                            },
                          ),
                          Text(
                            '${_getMonthName(displayMonth.month)} ${displayMonth.year}',
                            style: UIStyles.titleStyle.copyWith(
                              color: UIConstants.defaultAppColor,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            color: UIConstants.defaultAppColor,
                            onPressed: () {
                              setState(() {
                                displayMonth = DateTime(
                                  displayMonth.year,
                                  displayMonth.month + 1,
                                );
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: UIConstants.spacingM),

                      // Weekday headers
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _getWeekdayHeaders(),
                      ),
                      const SizedBox(height: UIConstants.spacingS),

                      // Calendar grid
                      _buildCalendarGrid(displayMonth, selectedDate, (date) {
                        setState(() {
                          selectedDate = date;
                        });
                      }),
                      const SizedBox(height: UIConstants.spacingL),

                      // Selected date display
                      Container(
                        padding: const EdgeInsets.all(UIConstants.spacingM),
                        decoration: BoxDecoration(
                          color: UIConstants.cardColor,
                          border: Border.all(
                            color: UIConstants.defaultAppColor,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(
                            UIConstants.cornerRadius,
                          ),
                        ),
                        child: Text(
                          'Gewähltes Datum: ${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}',
                          style: UIStyles.bodyTextStyle.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingL),
                    ],
                  ),
                ),
                // FAB Cancel and OK buttons positioned at bottom-right
                Positioned(
                  bottom: UIConstants.dialogFabTightBottom,
                  right: UIConstants.dialogFabTightRight,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton(
                        heroTag: 'fab_cancel_calendar',
                        mini: true,
                        backgroundColor: UIConstants.submitButtonBackground,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Icon(
                          Icons.close,
                          color: UIConstants.buttonTextColor,
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingM),
                      FloatingActionButton(
                        heroTag: 'fab_ok_calendar',
                        mini: true,
                        backgroundColor: UIConstants.submitButtonBackground,
                        onPressed: () {
                          Navigator.of(context).pop(selectedDate);
                        },
                        child: const Icon(
                          Icons.check,
                          color: UIConstants.buttonTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _getWeekdayHeaders() {
    final weekdays = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    return weekdays
        .map(
          (day) => SizedBox(
            width: 40,
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: UIStyles.bodyTextStyle.copyWith(
                fontWeight: FontWeight.bold,
                color: UIConstants.defaultAppColor,
              ),
            ),
          ),
        )
        .toList();
  }

  Widget _buildCalendarGrid(
    DateTime displayMonth,
    DateTime selectedDate,
    Function(DateTime) onDateSelected,
  ) {
    final firstDay = DateTime(displayMonth.year, displayMonth.month, 1);
    final lastDay = DateTime(displayMonth.year, displayMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    final firstWeekday = firstDay.weekday; // 1=Monday, 7=Sunday

    final days = <Widget>[];

    // Empty cells for days before month starts
    for (int i = 1; i < firstWeekday; i++) {
      days.add(SizedBox(width: 40, height: 40, child: Container()));
    }

    // Days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(displayMonth.year, displayMonth.month, day);
      final isSelected =
          selectedDate.year == date.year &&
          selectedDate.month == date.month &&
          selectedDate.day == date.day;
      final isToday =
          DateTime.now().year == date.year &&
          DateTime.now().month == date.month &&
          DateTime.now().day == date.day;
      final isFuture = date.isAfter(DateTime.now());

      days.add(
        GestureDetector(
          onTap: isFuture ? null : () => onDateSelected(date),
          onDoubleTap: isFuture ? null : () => Navigator.of(context).pop(date),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  isFuture
                      ? Colors.grey.withOpacity(0.3)
                      : isSelected
                      ? UIConstants.defaultAppColor
                      : isToday
                      ? UIConstants.backgroundColor
                      : Colors.transparent,
              border:
                  isToday
                      ? Border.all(color: UIConstants.defaultAppColor, width: 2)
                      : null,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: UIStyles.bodyTextStyle.copyWith(
                  color:
                      isFuture
                          ? Colors.grey
                          : isSelected
                          ? Colors.white
                          : Colors.black,
                  fontWeight:
                      isSelected || isToday
                          ? FontWeight.bold
                          : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Fill remaining cells in last week
    while (days.length % 7 != 0) {
      days.add(SizedBox(width: 40, height: 40, child: Container()));
    }

    // Build rows of 7 days
    final rows = <Widget>[];
    for (int i = 0; i < days.length; i += 7) {
      final rowDays = days.sublist(i, i + 7);
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: rowDays,
        ),
      );
      if (i + 7 < days.length) {
        rows.add(const SizedBox(height: UIConstants.spacingS));
      }
    }

    return Column(children: rows);
  }

  String _getMonthName(int month) {
    const monthNames = [
      'Januar',
      'Februar',
      'März',
      'April',
      'Mai',
      'Juni',
      'Juli',
      'August',
      'September',
      'Oktober',
      'November',
      'Dezember',
    ];
    return monthNames[month - 1];
  }

  Future<void> _saveBedSport() async {
    if (_datumController.text.isEmpty ||
        _selectedWaffenartId == null ||
        _selectedDisziplinId == null) {
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

      if (widget.antragsnummer == null) {
        Navigator.of(context).pop({'error': 'Fehler: Antragsnummer fehlt'});
        return;
      }

      final response = await apiService.createBedSport(
        antragsnummer: widget.antragsnummer!,
        schiessdatum: schiessdatumForDb,
        waffenartId: _selectedWaffenartId!,
        disziplinId: _selectedDisziplinId!,
        training: _training,
        wettkampfartId: _selectedWettkampfartId,
        wettkampfergebnis:
            _wettkampfergebnisController.text.isNotEmpty
                ? double.parse(_wettkampfergebnisController.text)
                : null,
      );

      // Store the created bedSport ID
      final createdBedSportId = response['id'] as int?;
      if (createdBedSportId != null) {
        setState(() {});

        // Map uploaded document to the newly created sport
        if (_uploadedDateiId != null) {
          final mapped = await apiService.mapBedDateiToSport(
            antragsnummer: widget.antragsnummer!,
            dateiId: _uploadedDateiId!,
            bedSportId: createdBedSportId,
          );

          if (!mapped) {
            // Mapping failed, but sport was created
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Warnung: Dokument konnte nicht verknüpft werden',
                  ),
                ),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dokument erfolgreich verknüpft')),
              );
            }
          }
        } else {}
      }

      if (mounted) {
        widget.onSaved({
          'schiessdatum': _datumController.text,
          'waffenartId': _selectedWaffenartId!,
          'disziplinId': _selectedDisziplinId!,
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
          child: Scaffold(
            backgroundColor: UIConstants.backgroundColor,
            body: Semantics(
              container: true,
              label: 'Dialog - Schießaktivität hinzufügen',
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(UIConstants.spacingL),
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
                                FutureBuilder<List<BeduerfnisseAuswahl>>(
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
                                      hint: const Text(
                                        'Wählen Sie eine Waffenart',
                                      ),
                                      isExpanded: true,
                                      items:
                                          waffenarten.map((waffenart) {
                                            return DropdownMenuItem<int>(
                                              value: waffenart.id,
                                              child: ScaledText(
                                                '${waffenart.id} - ${waffenart.beschreibung}',
                                                style: UIStyles.bodyTextStyle
                                                    .copyWith(
                                                      fontSize:
                                                          UIStyles
                                                              .bodyTextStyle
                                                              .fontSize! *
                                                          fontSizeProvider
                                                              .scaleFactor,
                                                    ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedWaffenartId = value;
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
                                FutureBuilder<List<Disziplin>>(
                                  future: _disziplinenFuture,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    if (snapshot.hasError) {
                                      return const Text(
                                        'Fehler beim Laden der Disziplinen',
                                      );
                                    }

                                    final disziplinen = snapshot.data ?? [];

                                    return DropdownButtonFormField<int>(
                                      value: _selectedDisziplinId,
                                      hint: const Text(
                                        'Wählen Sie eine Disziplin',
                                      ),
                                      isExpanded: true,
                                      items:
                                          disziplinen.map((disziplin) {
                                            return DropdownMenuItem<int>(
                                              value: disziplin.disziplinId,
                                              child: ScaledText(
                                                '${disziplin.disziplinNr} - ${disziplin.disziplin}',
                                                style: UIStyles.bodyTextStyle
                                                    .copyWith(
                                                      fontSize:
                                                          UIStyles
                                                              .bodyTextStyle
                                                              .fontSize! *
                                                          fontSizeProvider
                                                              .scaleFactor,
                                                    ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedDisziplinId = value;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Disziplinnummer lt. SPO *',
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
                                        activeColor:
                                            UIConstants.defaultAppColor,
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

                                // Wettkampfart Dropdown (independent of Waffenart)
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

                                    final wettkampfarten = snapshot.data ?? [];

                                    return DropdownButtonFormField<int>(
                                      value: _selectedWettkampfartId,
                                      hint: const Text(
                                        'Wählen Sie eine Wettkampfart',
                                      ),
                                      items:
                                          wettkampfarten.map((wettkampfart) {
                                            return DropdownMenuItem<int>(
                                              value: wettkampfart.id,
                                              child: ScaledText(
                                                wettkampfart.beschreibung,
                                                style: UIStyles.bodyTextStyle
                                                    .copyWith(
                                                      fontSize:
                                                          UIStyles
                                                              .bodyTextStyle
                                                              .fontSize! *
                                                          fontSizeProvider
                                                              .scaleFactor,
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
                                        labelText:
                                            _training
                                                ? 'Wettkampfart (optional)'
                                                : 'Wettkampfart *',
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

                                // Wettkampfergebnis (required if not training)
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller:
                                            _wettkampfergebnisController,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                            RegExp(r'^\d*\.?\d*$'),
                                          ),
                                        ],
                                        style: UIStyles.bodyTextStyle.copyWith(
                                          fontSize:
                                              UIStyles.bodyTextStyle.fontSize! *
                                              fontSizeProvider.scaleFactor,
                                        ),
                                        decoration: InputDecoration(
                                          labelText:
                                              _training
                                                  ? 'Wettkampfergebnis (optional)'
                                                  : 'Wettkampfergebnis *',
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              UIConstants.cornerRadius,
                                            ),
                                            borderSide: const BorderSide(
                                              color:
                                                  UIConstants.defaultAppColor,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              UIConstants.cornerRadius,
                                            ),
                                            borderSide: const BorderSide(
                                              color:
                                                  UIConstants.defaultAppColor,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: UIConstants.spacingL),

                                // Dokument label
                                ScaledText(
                                  'Dokument hochladen oder scannen',
                                  style: UIStyles.bodyTextStyle.copyWith(
                                    fontSize:
                                        UIStyles.bodyTextStyle.fontSize! *
                                        fontSizeProvider.scaleFactor,
                                  ),
                                ),
                                const SizedBox(height: UIConstants.spacingS),

                                // Dokument hochladen and scannen buttons - always visible
                                Row(
                                  children: [
                                    Expanded(
                                      child: Builder(
                                        builder:
                                            (buttonContext) => ElevatedButton(
                                              onPressed:
                                                  _documentUploaded
                                                      ? null
                                                      : () async {
                                                        if (widget
                                                                .antragsnummer ==
                                                            null) {
                                                          ScaffoldMessenger.of(
                                                            buttonContext,
                                                          ).showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                'Fehler: Antragsnummer fehlt',
                                                              ),
                                                            ),
                                                          );
                                                          return;
                                                        }

                                                        setState(() {
                                                          _isUploadingDocument =
                                                              true;
                                                        });

                                                        try {
                                                          final ImagePicker
                                                          picker =
                                                              ImagePicker();
                                                          final XFile?
                                                          file = await picker
                                                              .pickImage(
                                                                source:
                                                                    ImageSource
                                                                        .gallery,
                                                              );

                                                          if (file == null) {
                                                            setState(() {
                                                              _isUploadingDocument =
                                                                  false;
                                                            });
                                                            return;
                                                          }

                                                          final bytes =
                                                              await file
                                                                  .readAsBytes();
                                                          final fileName =
                                                              file.name;

                                                          if (bytes.isEmpty) {
                                                            setState(() {
                                                              _isUploadingDocument =
                                                                  false;
                                                            });
                                                            if (mounted) {
                                                              ScaffoldMessenger.of(
                                                                buttonContext,
                                                              ).showSnackBar(
                                                                const SnackBar(
                                                                  content: Text(
                                                                    'Fehler: Datei konnte nicht gelesen werden',
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                            return;
                                                          }

                                                          final apiService =
                                                              Provider.of<
                                                                ApiService
                                                              >(
                                                                context,
                                                                listen: false,
                                                              );

                                                          final dateiId =
                                                              await apiService
                                                                  .uploadBedDatei(
                                                                    antragsnummer:
                                                                        widget
                                                                            .antragsnummer!,
                                                                    dateiname:
                                                                        fileName,
                                                                    fileBytes:
                                                                        bytes,
                                                                  );

                                                          if (mounted) {
                                                            if (dateiId !=
                                                                null) {
                                                              setState(() {
                                                                _uploadedDateiId =
                                                                    dateiId;
                                                                _documentUploaded =
                                                                    true;
                                                                _isUploadingDocument =
                                                                    false;
                                                              });
                                                              ScaffoldMessenger.of(
                                                                buttonContext,
                                                              ).showSnackBar(
                                                                const SnackBar(
                                                                  content: Text(
                                                                    'Dokument erfolgreich hochgeladen',
                                                                  ),
                                                                ),
                                                              );
                                                            } else {
                                                              setState(() {
                                                                _isUploadingDocument =
                                                                    false;
                                                              });
                                                              ScaffoldMessenger.of(
                                                                buttonContext,
                                                              ).showSnackBar(
                                                                const SnackBar(
                                                                  content: Text(
                                                                    'Fehler beim Hochladen des Dokuments',
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                          }
                                                        } catch (e) {
                                                          setState(() {
                                                            _isUploadingDocument =
                                                                false;
                                                          });
                                                          if (mounted) {
                                                            ScaffoldMessenger.of(
                                                              buttonContext,
                                                            ).showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                  'Dokument erfolgreich hochgeladen',
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                        }
                                                      },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    _documentUploaded
                                                        ? Colors.lightGreen
                                                        : UIConstants
                                                            .defaultAppColor,
                                                disabledBackgroundColor:
                                                    Colors.lightGreen,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical:
                                                          UIConstants.spacingM,
                                                      horizontal:
                                                          UIConstants.spacingL,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        UIConstants
                                                            .cornerRadius,
                                                      ),
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.upload_file,
                                                color:
                                                    UIConstants.buttonTextColor,
                                              ),
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: UIConstants.spacingM),
                                    Expanded(
                                      child: Builder(
                                        builder:
                                            (buttonContext) => ElevatedButton(
                                              onPressed:
                                                  _documentUploaded
                                                      ? null
                                                      : () => _scanDocument(
                                                        buttonContext,
                                                      ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    _documentUploaded
                                                        ? Colors.lightGreen
                                                        : UIConstants
                                                            .defaultAppColor,
                                                disabledBackgroundColor:
                                                    Colors.lightGreen,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical:
                                                          UIConstants.spacingM,
                                                      horizontal:
                                                          UIConstants.spacingL,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        UIConstants
                                                            .cornerRadius,
                                                      ),
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.document_scanner,
                                                color:
                                                    UIConstants.buttonTextColor,
                                              ),
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (!_training)
                                  const SizedBox(height: UIConstants.spacingL),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // FABs at bottom
                      Container(
                        padding: const EdgeInsets.all(UIConstants.spacingM),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            DialogFABs(
                              children: [
                                FloatingActionButton(
                                  heroTag: 'cancelBedSportFab',
                                  mini: true,
                                  tooltip: 'Abbrechen',
                                  backgroundColor: UIConstants.defaultAppColor,
                                  onPressed:
                                      _isLoading
                                          ? null
                                          : () async {
                                            // Clean up uploaded document if not mapped
                                            if (_uploadedDateiId != null) {
                                              final apiService =
                                                  Provider.of<ApiService>(
                                                    context,
                                                    listen: false,
                                                  );
                                              await apiService
                                                  .deleteBedDateiById(
                                                    _uploadedDateiId!,
                                                  );
                                            }
                                            if (mounted) {
                                              Navigator.of(context).pop();
                                            }
                                          },
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
                                  backgroundColor:
                                      _isLoading ||
                                              !_areAllCompulsoryFieldsFilled() ||
                                              _isUploadingDocument
                                          ? UIConstants.disabledBackgroundColor
                                          : UIConstants.defaultAppColor,
                                  onPressed:
                                      _isLoading || _isUploadingDocument
                                          ? null
                                          : (_areAllCompulsoryFieldsFilled()
                                              ? _saveBedSport
                                              : null),
                                  child:
                                      _isLoading
                                          ? const SizedBox(
                                            width:
                                                UIConstants
                                                    .loadingIndicatorSize,
                                            height:
                                                UIConstants
                                                    .loadingIndicatorSize,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
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
                          ],
                        ),
                      ),
                    ],
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
                  // Document upload loading overlay
                  if (_isUploadingDocument)
                    Positioned.fill(
                      child: AbsorbPointer(
                        absorbing: true,
                        child: Container(
                          color: UIConstants.overlayColor,
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    UIConstants.circularProgressIndicator,
                                  ),
                                ),
                                SizedBox(height: UIConstants.spacingM),
                                Text(
                                  'Dokument wird hochgeladen...',
                                  style: TextStyle(
                                    color: UIConstants.whiteColor,
                                    fontSize: UIConstants.bodyFontSize,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
