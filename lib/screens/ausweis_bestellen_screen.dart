import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/constants/messages.dart';
import '/constants/ui_styles.dart';
import '/screens/base_screen_layout.dart';
import '/screens/agb_screen.dart';
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
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: UIConstants.backgroundColor,
              contentPadding: UIConstants.dialogPadding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
              ),
              title: const Center(
                child: ScaledText(
                  'Bankdaten Erfassen',
                  style: UIStyles.dialogTitleStyle,
                ),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(UIConstants.spacingM),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            UIConstants.cornerRadius,
                          ),
                          border: Border.all(
                            color:
                                UIStyles
                                    .formInputDecoration
                                    .enabledBorder
                                    ?.borderSide
                                    .color ??
                                Colors.grey,
                            width:
                                UIStyles
                                    .formInputDecoration
                                    .enabledBorder
                                    ?.borderSide
                                    .width ??
                                1.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bankdaten',
                              style: UIStyles.subtitleStyle,
                            ),
                            const SizedBox(height: UIConstants.spacingM),
                            TextFormField(
                              controller: kontoinhaberController,
                              decoration: UIStyles.formInputDecoration.copyWith(
                                labelText: 'Kontoinhaber',
                              ),
                              style: UIStyles.bodyStyle,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Bitte Kontoinhaber angeben';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: UIConstants.spacingM),
                            TextFormField(
                              controller: ibanController,
                              decoration: UIStyles.formInputDecoration.copyWith(
                                labelText: 'IBAN',
                              ),
                              style: UIStyles.bodyStyle,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Bitte IBAN angeben';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: UIConstants.spacingM),
                            TextFormField(
                              controller: bicController,
                              decoration: UIStyles.formInputDecoration.copyWith(
                                labelText: 'BIC',
                              ),
                              style: UIStyles.bodyStyle,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Bitte BIC angeben';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingS),
                      ListTileTheme(
                        data: const ListTileThemeData(
                          horizontalTitleGap: UIConstants.spacingXS,
                          minLeadingWidth: 0,
                        ),
                        child: Column(
                          children: [
                            CheckboxListTile(
                              value: agbChecked,
                              onChanged: (val) {
                                setState(() => agbChecked = val ?? false);
                              },
                              title: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => const AgbScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'AGB',
                                      style: UIStyles.linkStyle.copyWith(
                                        color: UIConstants.linkColor,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: UIConstants.spacingS),
                                  const Text('akzeptieren'),
                                  const SizedBox(width: UIConstants.spacingS),
                                  const Tooltip(
                                    message:
                                        'Ich bin mit den AGB einverstanden.',
                                    triggerMode: TooltipTriggerMode.tap,
                                    child: Icon(
                                      Icons.info_outline,
                                      color: UIConstants.defaultAppColor,
                                      size: UIConstants.tooltipIconSize,
                                    ),
                                  ),
                                ],
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                            ),
                            CheckboxListTile(
                              value: lastschriftChecked,
                              onChanged: (val) {
                                setState(
                                  () => lastschriftChecked = val ?? false,
                                );
                              },
                              title: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(
                                    child: Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: UIConstants.spacingS,
                                      children: [
                                        Text(
                                          'Bestätigung des\nLastschrifteinzugs',
                                        ),
                                        Tooltip(
                                          message:
                                              'Ich ermächtige Sie widerruflich, die von mir zu entrichtenden Zahlungen bei Fälligkeit Durch Lastschrift von meinem im MeinBSSB angegebenen Konto einzuziehen. Zugleich weise ich mein Kreditinstitut an, die vom BSSB auf meinem Konto gezogenen Lastschriften einzulösen.',
                                          triggerMode: TooltipTriggerMode.tap,
                                          child: Icon(
                                            Icons.info_outline,
                                            color: UIConstants.defaultAppColor,
                                            size: UIConstants.tooltipIconSize,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                            ),
                            const SizedBox(height: UIConstants.spacingM),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                          Navigator.of(dialogContext).pop();
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
