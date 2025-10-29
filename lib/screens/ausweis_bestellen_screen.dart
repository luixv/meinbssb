import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/constants/messages.dart';
import '/constants/ui_styles.dart';
import '/screens/base_screen_layout.dart';
import '/models/user_data.dart';
import '/models/bank_data.dart';
import '/providers/font_size_provider.dart';
import '/widgets/scaled_text.dart';
import 'package:meinbssb/services/api_service.dart';

void _onSave() {
  // TODO: Implement save logic for bank data dialog
}

class AusweisBestellenScreen extends StatefulWidget {
  const AusweisBestellenScreen({
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
    super.key,
  });

  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  State<AusweisBestellenScreen> createState() => _AusweisBestellenScreenState();
}

class _AusweisBestellenScreenState extends State<AusweisBestellenScreen> {
  bool isLoading = false;

  Future<void> _showBankDataDialog() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final user = widget.userData;
    if (user == null) return;

    // Show loading indicator while fetching bank data
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              UIConstants.defaultAppColor,
            ),
          ),
        );
      },
    );

    final List<BankData> bankDataList = await apiService.fetchBankdatenMyBSSB(
      user.webLoginId,
    );
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    final bankData = bankDataList.isNotEmpty ? bankDataList.first : null;

    bool agbChecked = false;
    bool lastschriftChecked = false;
    final formKey = GlobalKey<FormState>();

    final kontoinhaberController = TextEditingController(
      text: bankData?.kontoinhaber ?? '',
    );
    final ibanController = TextEditingController(text: bankData?.iban ?? '');
    final bicController = TextEditingController(text: bankData?.bic ?? '');

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: UIConstants.dialogMaxWidth,
                    maxHeight: UIConstants.dialogMaxHeight,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        color: UIConstants.backgroundColor,
                        borderRadius: BorderRadius.circular(
                          UIConstants.cornerRadius,
                        ),
                        boxShadow: UIStyles.cardDecoration.boxShadow,
                      ),
                      padding: UIConstants.dialogPadding,
                      child: SingleChildScrollView(
                        child: Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Center(
                                child: ScaledText(
                                  'Bankdaten für Bestellung',
                                  style: UIStyles.dialogTitleStyle,
                                ),
                              ),
                              const SizedBox(height: UIConstants.spacingM),
                              TextFormField(
                                controller: kontoinhaberController,
                                decoration: const InputDecoration(
                                  labelText: 'Kontoinhaber',
                                  border: OutlineInputBorder(),
                                ),
                                style: UIStyles.bodyStyle,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Bitte Kontoinhaber angeben';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: UIConstants.spacingS),
                              TextFormField(
                                controller: ibanController,
                                decoration: const InputDecoration(
                                  labelText: 'IBAN',
                                  border: OutlineInputBorder(),
                                ),
                                style: UIStyles.bodyStyle,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Bitte IBAN angeben';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: UIConstants.spacingS),
                              TextFormField(
                                controller: bicController,
                                decoration: const InputDecoration(
                                  labelText: 'BIC',
                                  border: OutlineInputBorder(),
                                ),
                                style: UIStyles.bodyStyle,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Bitte BIC angeben';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: UIConstants.spacingM),
                              Semantics(
                                label:
                                    'Bitte bestätigen Sie die Allgemeinen Geschäftsbedingungen (AGB).',
                                child: CheckboxListTile(
                                  title: const ScaledText(
                                    'Ich habe die Allgemeinen Geschäftsbedingungen (AGB) gelesen und akzeptiere sie.',
                                    style: UIStyles.bodyStyle,
                                  ),
                                  value: agbChecked,
                                  onChanged: (value) {
                                    setState(() {
                                      agbChecked = value ?? false;
                                    });
                                  },
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                ),
                              ),
                              Semantics(
                                label:
                                    'Bitte bestätigen Sie das SEPA-Lastschriftverfahren.',
                                child: CheckboxListTile(
                                  title: const ScaledText(
                                    'Ich ermächtige den Bayerischen Sportschützenbund e.V., den Betrag per SEPA-Lastschrift einzuziehen.',
                                    style: UIStyles.bodyStyle,
                                  ),
                                  value: lastschriftChecked,
                                  onChanged: (value) {
                                    setState(() {
                                      lastschriftChecked = value ?? false;
                                    });
                                  },
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                ),
                              ),
                              const SizedBox(height: UIConstants.spacingM),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Semantics(
                                      label:
                                          'Button zum Abbrechen der Bestellung des Schützenausweises.',
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.close),
                                        label: const ScaledText(
                                          'Abbrechen',
                                          style: UIStyles.dialogButtonTextStyle,
                                        ),
                                        style: UIStyles.dialogCancelButtonStyle,
                                        onPressed: () {
                                          Navigator.of(dialogContext).pop();
                                        },
                                      ),
                                    ),
                                  ),
                                  UIConstants.horizontalSpacingM,
                                  Expanded(
                                    child: Semantics(
                                      label:
                                          'Button zum kostenpflichtigen Bestellen des Schützenausweises. Aktiviert, wenn AGB und SEPA-Lastschrift bestätigt sind.',
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.check),
                                        label: const ScaledText(
                                          'Bestellen',
                                          style: UIStyles.dialogButtonTextStyle,
                                        ),
                                        style: UIStyles.dialogAcceptButtonStyle,
                                        onPressed:
                                            (agbChecked && lastschriftChecked)
                                                ? () {
                                                  Navigator.of(
                                                    dialogContext,
                                                  ).pop();
                                                  _onSave();
                                                }
                                                : null,
                                      ),
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
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: Messages.ausweisBestellenTitle,
      userData: widget.userData,
      isLoggedIn: widget.isLoggedIn,
      onLogout: widget.onLogout,
      automaticallyImplyLeading: true,
      body: Semantics(
        label:
            'Schützenausweis bestellen. Hier können Sie einen neuen Schützenausweis beantragen und die Beschreibung sowie den Bestellbutton sehen.',
        child: Consumer<FontSizeProvider>(
          builder: (context, fontSizeProvider, child) {
            return Padding(
              padding: UIConstants.screenPadding,
              child: Column(
                crossAxisAlignment: UIConstants.startCrossAlignment,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    Messages.ausweisBestellenDescription,
                    style: UIStyles.bodyStyle,
                  ),
                  const SizedBox(height: UIConstants.spacingM),
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Center(
                      child: ElevatedButton(
                        onPressed: _showBankDataDialog,
                        child: const Text(
                          'Schützenausweis kostenpflichtig  bestellen',
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
