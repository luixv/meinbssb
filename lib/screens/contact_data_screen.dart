// Project: Mein BSSB
// Filename: contact_data_screen.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/models/contact.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/core/logger_service.dart';
import 'package:meinbssb/services/core/font_size_provider.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:meinbssb/widgets/scaled_text.dart';

class ContactDataScreen extends StatefulWidget {
  const ContactDataScreen(
    this.userData, {
    required this.isLoggedIn,
    required this.onLogout,
    super.key,
  });

  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  ContactDataScreenState createState() => ContactDataScreenState();
}

class ContactDataScreenState extends State<ContactDataScreen> {
  late Future<List<Map<String, dynamic>>> _contactDataFuture;
  bool _isAdding = false;
  final ScrollController _scrollController = ScrollController();

  final Map<int, String> _contactTypeLabels = {
    for (var type in [1, 2, 3, 4, 5, 6, 7, 8])
      type: Contact(id: 0, personId: 0, type: type, value: '').typeLabel,
  };

  int? _selectedKontaktTyp;
  final TextEditingController _kontaktController = TextEditingController();
  final RegExp _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  final RegExp _phoneFaxMobileRegex = RegExp(r'^[0-9\s\-\+\(\)]+$');

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    final int personId = widget.userData?.personId ?? 0;
    setState(() {
      _contactDataFuture = Future.value([]);
    });
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      _contactDataFuture = apiService.fetchKontakte(personId).then((data) {
        LoggerService.logInfo('Contact data structure: $data');
        return data;
      });
      LoggerService.logInfo(
        'ContactDataScreen: Initiating contact data fetch.',
      );
    } catch (e) {
      LoggerService.logError('Error setting up contact data fetch: $e');
      _contactDataFuture = Future.value([]);
    }
  }

  Future<void> _onDeleteContact(
    int kontaktId,
    int kontaktTyp,
    String contactValue,
    String contactLabel,
  ) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: UIConstants.backgroundColor,
          title: const Center(
            child: Text(
              UIConstants.contactDataDeleteTitle,
              style: UIStyles.dialogTitleStyle,
            ),
          ),
          content: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: UIStyles.dialogContentStyle,
              children: <TextSpan>[
                const TextSpan(text: UIConstants.contactDataDeleteQuestion),
                TextSpan(
                  text: '$contactLabel: $contactValue',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: ' löschen möchten?'),
              ],
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.spacingM,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      style: UIStyles.dialogCancelButtonStyle,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.close, color: UIConstants.closeIcon),
                          UIConstants.horizontalSpacingS,
                          const Text('Abbrechen'),
                        ],
                      ),
                    ),
                  ),
                  UIConstants.horizontalSpacingM,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      style: UIStyles.dialogAcceptButtonStyle,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check, color: UIConstants.checkIcon),
                          UIConstants.horizontalSpacingS,
                          const Text('Löschen'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmDelete != true) return;

    // Store the navigator context
    final navigator = Navigator.of(context);

    // Show loading dialog and store its reference
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          backgroundColor: UIConstants.backgroundColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  UIConstants.circularProgressIndicator,
                ),
              ),
              SizedBox(height: UIConstants.spacingM),
              Text(
                'Kontakt wird gelöscht...',
                style: UIStyles.dialogContentStyle,
              ),
            ],
          ),
        );
      },
    );

    try {
      // Check network status
      final networkService =
          Provider.of<NetworkService>(context, listen: false);
      final isOffline = !(await networkService.hasInternet());
      if (!mounted) return;
      if (isOffline) {
        navigator.pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kontaktdaten können offline nicht gelöscht werden'),
            duration: UIConstants.snackbarDuration,
            backgroundColor: UIConstants.errorColor,
          ),
        );
        return;
      }

      // Perform deletion
      final apiService = Provider.of<ApiService>(context, listen: false);
      final contact = Contact(
        id: kontaktId,
        personId: widget.userData?.personId ?? 0,
        type: kontaktTyp,
        value: '',
      );
      final bool success = await apiService.deleteKontakt(contact);

      if (!mounted) return;
      navigator.pop(); // Close loading dialog

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kontaktdaten erfolgreich gelöscht.'),
            duration: UIConstants.snackbarDuration,
          ),
        );
        _fetchContacts();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fehler beim Löschen der Kontaktdaten.'),
            duration: UIConstants.snackbarDuration,
            backgroundColor: UIConstants.errorColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        navigator.pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ein Fehler ist aufgetreten: $e'),
            duration: UIConstants.snackbarDuration,
            backgroundColor: UIConstants.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _onAddContact(BuildContext dialogContext) async {
    final String kontaktValue = _kontaktController.text.trim();

    if (_selectedKontaktTyp == null || kontaktValue.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bitte Kontakttyp und Kontaktwert eingeben.'),
            duration: UIConstants.snackbarDuration,
            backgroundColor: UIConstants.errorColor,
          ),
        );
      }
      return;
    }

    final networkService = Provider.of<NetworkService>(context, listen: false);
    final isOffline = !(await networkService.hasInternet());
    if (!mounted) return;
    if (isOffline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kontaktdaten können offline nicht hinzugefügt werden'),
          duration: UIConstants.snackbarDuration,
          backgroundColor: UIConstants.errorColor,
        ),
      );
      return;
    }

    final contact = Contact(
      id: 0,
      personId: widget.userData?.personId ?? 0,
      type: _selectedKontaktTyp!,
      value: kontaktValue,
    );

    String? validationErrorMessage;
    if (contact.isEmail) {
      if (!_emailRegex.hasMatch(kontaktValue)) {
        validationErrorMessage =
            'Bitte geben Sie eine gültige E-Mail-Adresse ein.';
      }
    } else if (contact.isPhone || contact.isFax) {
      if (!_phoneFaxMobileRegex.hasMatch(kontaktValue)) {
        validationErrorMessage =
            'Bitte geben Sie eine gültige Telefon-/Faxnummer ein (nur Ziffern, +, -, (, ) erlaubt).';
      }
    }

    if (validationErrorMessage != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validationErrorMessage),
            duration: UIConstants.snackbarDuration,
            backgroundColor: UIConstants.errorColor,
          ),
        );
      }
      return;
    }

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final bool success = await apiService.addKontakt(contact);

      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kontaktdaten erfolgreich gespeichert.'),
            duration: UIConstants.snackbarDuration,
          ),
        );
        _kontaktController.clear();
        _selectedKontaktTyp = null;
        _fetchContacts();
        Navigator.of(dialogContext).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fehler beim Speichern der Kontaktdaten.'),
            duration: UIConstants.snackbarDuration,
            backgroundColor: UIConstants.errorColor,
          ),
        );
      }
    } catch (e) {
      LoggerService.logError('Exception during contact addition: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ein Fehler ist aufgetreten: $e'),
            duration: UIConstants.snackbarDuration,
            backgroundColor: UIConstants.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAdding = false;
        });
      }
    }
  }

  void _showAddContactForm() {
    _selectedKontaktTyp = null;
    _kontaktController.clear();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Consumer<FontSizeProvider>(
              builder: (context, fontSizeProvider, child) {
                return AlertDialog(
                  backgroundColor: UIConstants.backgroundColor,
                  title: Center(
                    child: ScaledText(
                      'Neuen Kontakt hinzufügen',
                      style: UIStyles.dialogTitleStyle.copyWith(
                        fontSize: UIStyles.dialogTitleStyle.fontSize! *
                            fontSizeProvider.scaleFactor,
                      ),
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        DropdownButtonFormField<int>(
                          decoration: UIStyles.formInputDecoration.copyWith(
                            labelText: 'Kontakttyp',
                            labelStyle: UIStyles.formInputDecoration.labelStyle
                                ?.copyWith(
                              fontSize: UIStyles.formInputDecoration.labelStyle!
                                      .fontSize! *
                                  fontSizeProvider.scaleFactor,
                            ),
                            floatingLabelStyle: UIStyles
                                .formInputDecoration.floatingLabelStyle
                                ?.copyWith(
                              fontSize: UIStyles.formInputDecoration
                                      .floatingLabelStyle!.fontSize! *
                                  fontSizeProvider.scaleFactor,
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                          ),
                          value: _selectedKontaktTyp,
                          items: _contactTypeLabels.entries.map((entry) {
                            return DropdownMenuItem<int>(
                              value: entry.key,
                              child: ScaledText(
                                entry.value,
                                style: TextStyle(
                                  fontSize: UIConstants.subtitleFontSize *
                                      fontSizeProvider.scaleFactor,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (int? newValue) {
                            setState(() {
                              _selectedKontaktTyp = newValue;
                            });
                          },
                        ),
                        const SizedBox(height: UIConstants.spacingM),
                        TextFormField(
                          controller: _kontaktController,
                          decoration: UIStyles.formInputDecoration.copyWith(
                            labelText: 'Kontakt',
                            labelStyle: UIStyles.formInputDecoration.labelStyle
                                ?.copyWith(
                              fontSize: UIStyles.formInputDecoration.labelStyle!
                                      .fontSize! *
                                  fontSizeProvider.scaleFactor,
                            ),
                            floatingLabelStyle: UIStyles
                                .formInputDecoration.floatingLabelStyle
                                ?.copyWith(
                              fontSize: UIStyles.formInputDecoration
                                      .floatingLabelStyle!.fontSize! *
                                  fontSizeProvider.scaleFactor,
                            ),
                            hintText: 'z.B. email@beispiel.de oder 0123 456789',
                            hintStyle: UIStyles.formInputDecoration.hintStyle
                                ?.copyWith(
                              fontSize: UIStyles.formInputDecoration.hintStyle!
                                      .fontSize! *
                                  fontSizeProvider.scaleFactor,
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                          ),
                          style: TextStyle(
                            fontSize: UIConstants.subtitleFontSize *
                                fontSizeProvider.scaleFactor,
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: UIConstants.spacingM,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Cancel Button
                          Expanded(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                minHeight:
                                    40, // Match your delete dialog button height
                              ),
                              child: ElevatedButton(
                                onPressed: _isAdding
                                    ? null
                                    : () => Navigator.of(dialogContext).pop(),
                                style:
                                    UIStyles.dialogCancelButtonStyle.copyWith(
                                  padding: MaterialStateProperty.all(
                                    const EdgeInsets.symmetric(
                                      horizontal: UIConstants.spacingM,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.close,
                                      color: UIConstants.closeIcon,
                                      size: UIConstants.defaultIconSize,
                                    ),
                                    const SizedBox(width: UIConstants.spacingS),
                                    Text(
                                      'Abbrechen',
                                      style: UIStyles.dialogButtonTextStyle
                                          .copyWith(
                                        color: UIConstants.cancelButtonText,
                                        fontSize: UIConstants.buttonFontSize,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: UIConstants.spacingM),
                          // Add Button
                          Expanded(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                minHeight: UIConstants
                                    .defaultButtonHeight, // Same as cancel button
                              ),
                              child: ElevatedButton(
                                onPressed: _isAdding
                                    ? null
                                    : () async {
                                        setStateDialog(() => _isAdding = true);
                                        await _onAddContact(dialogContext);
                                      },
                                style:
                                    UIStyles.dialogAcceptButtonStyle.copyWith(
                                  padding: MaterialStateProperty.all(
                                    const EdgeInsets.symmetric(
                                      vertical: UIConstants.spacingS,
                                    ),
                                  ),
                                ),
                                child: _isAdding
                                    ? const SizedBox(
                                        width: UIConstants.defaultIconSize,
                                        height: UIConstants.defaultIconSize,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            UIConstants
                                                .circularProgressIndicator,
                                          ),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.check,
                                            color: UIConstants.checkIcon,
                                            size:
                                                20, // Same as cancel button icon
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Hinzufügen',
                                            style: UIStyles
                                                .dialogButtonTextStyle
                                                .copyWith(
                                              color:
                                                  UIConstants.submitButtonText,
                                              fontSize:
                                                  14, // Same as cancel button
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _handleLogout() {
    LoggerService.logInfo('Logging out user from ContactdataScreen');
    widget.onLogout();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _kontaktController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: 'Kontaktdaten',
      userData: widget.userData,
      isLoggedIn: widget.isLoggedIn,
      onLogout: _handleLogout,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _contactDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            LoggerService.logError(
              'Error loading contact data in FutureBuilder:  [${snapshot.error}',
            );
            return Center(
              child: ScaledText(
                'Fehler beim Laden der Kontaktdaten:  [${snapshot.error}',
                style: UIStyles.errorStyle,
              ),
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            final List<Map<String, dynamic>> categorizedContactData =
                snapshot.data!;
            return _buildContactDataList(
              categorizedContactData,
              widget.userData?.personId ?? 0,
              _onDeleteContact,
              false,
            );
          } else {
            return const Center(
              child: ScaledText('Keine Kontaktdaten gefunden.'),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'contactDataFab',
        onPressed: _showAddContactForm,
        backgroundColor: UIConstants.defaultAppColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildContactTile({
    required int kontaktId,
    required int rawKontaktTyp,
    required String displayValue,
    required String displayLabel,
    required Function(int kontaktId, int kontaktTyp, String value, String label)
        onDelete,
  }) {
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, child) {
        return Padding(
          padding: const EdgeInsets.only(bottom: UIConstants.spacingS),
          child: TextFormField(
            initialValue: displayValue.isNotEmpty ? displayValue : '-',
            readOnly: true,
            style: UIStyles.formValueBoldStyle.copyWith(
              fontSize: UIStyles.formValueBoldStyle.fontSize! *
                  fontSizeProvider.scaleFactor,
            ),
            decoration: UIStyles.formInputDecoration.copyWith(
              labelText: displayLabel.isNotEmpty ? displayLabel : 'Unbekannt',
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  size: UIConstants.iconSizeL * fontSizeProvider.scaleFactor,
                ),
                color: UIConstants.deleteIcon,
                onPressed: () => onDelete(
                  kontaktId,
                  rawKontaktTyp,
                  displayValue,
                  displayLabel,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactDataList(
    List<Map<String, dynamic>> contactData,
    int personId,
    Function(int kontaktId, int kontaktTyp, String value, String label)
        onDelete,
    bool isDeleting,
  ) {
    return Padding(
      padding: UIConstants.defaultPadding,
      child: Column(
        children: [
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              thickness: UIConstants.dividerThick,
              radius: const Radius.circular(UIConstants.cornerRadius),
              child: ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: contactData.length,
                itemBuilder: (context, index) {
                  final category = contactData[index];
                  final contacts = category['contacts'] as List<dynamic>;
                  final categoryName = category['category'] as String;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: UIConstants.spacingS,
                        ),
                        child: Consumer<FontSizeProvider>(
                          builder: (context, fontSizeProvider, child) {
                            return ScaledText(
                              categoryName,
                              style: UIStyles.subtitleStyle.copyWith(
                                color: UIConstants.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: UIConstants.titleFontSize *
                                    fontSizeProvider.scaleFactor,
                              ),
                            );
                          },
                        ),
                      ),
                      ...contacts.map((contact) {
                        final kontaktId = contact['kontaktId'] as int;
                        final rawKontaktTyp = contact['rawKontaktTyp'] as int;
                        final displayValue = contact['value'] as String;
                        final displayLabel = contact['type'] as String;

                        return _buildContactTile(
                          kontaktId: kontaktId,
                          rawKontaktTyp: rawKontaktTyp,
                          displayValue: displayValue,
                          displayLabel: displayLabel,
                          onDelete: onDelete,
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: UIConstants.spacingXXXL),
        ],
      ),
    );
  }
}
