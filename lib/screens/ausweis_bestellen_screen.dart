import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/constants/messages.dart';
import '/constants/ui_styles.dart';
import '/screens/base_screen_layout.dart';
import '/models/user_data.dart';
import '/models/passdaten_akzept_or_aktiv_data.dart';
import '/providers/font_size_provider.dart';
import '/widgets/scaled_text.dart';
import 'package:meinbssb/services/api_service.dart';
import 'ausweis_bestellen_success_screen.dart';

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

  Future<void> _onSave() async {
    setState(() {
      isLoading = true;
    });

    const antragsTyp = 5; // 5=Verlust
    final int? passdatenId = widget.userData?.passdatenId;
    final int? personId = widget.userData?.personId;
    final int? erstVereinId = widget.userData?.erstVereinId;
    int digitalerPass = 0; // 1 for yes, 0 for no

    final apiService = Provider.of<ApiService>(context, listen: false);

    final PassdatenAkzeptOrAktiv?
    fetchedPassdatenAkzeptierterOderAktiverPassData = await apiService
        .fetchPassdatenAkzeptierterOderAktiverPass(personId);

    /* create a list "ZVEs": [
        {
            "VEREINID": 2420,
            "DISZIPLINID": 94
        },
        ...
    ]
*/
    List<Map<String, dynamic>> zves = [];
    if (fetchedPassdatenAkzeptierterOderAktiverPassData != null) {
      for (final zve in fetchedPassdatenAkzeptierterOderAktiverPassData.zves) {
        final vereinId = zve.vereinId;
        final disziplinId = zve.disziplinId;

        zves.add({'VEREINID': vereinId, 'DISZIPLINID': disziplinId});
      }
    }

    final bool success = await apiService.bssbAppPassantrag(
      zves,
      passdatenId,
      personId,
      erstVereinId,
      digitalerPass,
      antragsTyp,
    );

    if (mounted) {
      setState(() {
        isLoading = false;
      });

      if (success) {
        // Navigate to the success screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => AusweisBestellendSuccessScreen(
                  userData: widget.userData,
                  isLoggedIn: widget.isLoggedIn,
                  onLogout: widget.onLogout,
                ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Antrag konnte nicht gesendet werden.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: Messages.ausweisBestellenTitle,
      userData: widget.userData,
      isLoggedIn: widget.isLoggedIn,
      onLogout: widget.onLogout,
      automaticallyImplyLeading: true,
      body: Consumer<FontSizeProvider>(
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
                      onPressed: _onSave,
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
    );
  }
}
