import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/constants/messages.dart';
import '/constants/ui_styles.dart';
import '/screens/base_screen_layout_accessible.dart';
import '/models/user_data.dart';
import '../providers/font_size_provider.dart';
import '/widgets/scaled_text.dart';
import 'package:meinbssb/services/api_service.dart';
import 'ausweis_bestellen_success_screen_accessible.dart';

/// BITV 2.0 konforme Version des Ausweis-Bestellbildschirms
///
/// Erfüllt deutsche Barrierefreiheitsstandards (BITV 2.0/WCAG 2.1 Level AA):
/// - Vollständige Semantik-Unterstützung für Screen Reader
/// - Deutsche Sprachanpassung für Accessibility
/// - Live-Region-Ankündigungen für Statusänderungen
/// - Erweiterte Tastaturnavigation
/// - Kontextuelle Schaltflächen-Labels
/// - Fokus-Management für Ladezustände
class AusweisBestellenScreenAccessible extends StatefulWidget {
  const AusweisBestellenScreenAccessible({
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
    super.key,
  });

  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  State<AusweisBestellenScreenAccessible> createState() =>
      _AusweisBestellenScreenAccessibleState();
}

class _AusweisBestellenScreenAccessibleState
    extends State<AusweisBestellenScreenAccessible> {
  bool isLoading = false;
  String? errorMessage;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  Future<void> _onSave() async {
    // Live-Region-Ankündigung für Bestellvorgang
    SemanticsService.announce(
      'Schützenausweis-Bestellung wird verarbeitet. Bitte warten.',
      TextDirection.ltr,
    );

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    const antragsTyp = 5;
    final int? passdatenId = widget.userData?.passdatenId;
    final int? personId = widget.userData?.personId;
    final int? erstVereinId = widget.userData?.erstVereinId;
    int digitalerPass = 1; // 1 for yes, 0 for no

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final bool success = await apiService.bssbAppPassantrag(
        <int, Map<String, int?>>{}, // secondColumns
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
          // Erfolgs-Ankündigung für Screen Reader
          SemanticsService.announce(
            'Schützenausweis-Bestellung erfolgreich übermittelt. Sie werden zur Bestätigungsseite weitergeleitet.',
            TextDirection.ltr,
          );

          // Navigate to the accessible success screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AusweisBestellendSuccessScreenAccessible(
                userData: widget.userData,
                isLoggedIn: widget.isLoggedIn,
                onLogout: widget.onLogout,
              ),
            ),
          );
        } else {
          setState(() {
            errorMessage =
                'Antrag konnte nicht gesendet werden. Bitte versuchen Sie es erneut.';
          });

          // Fehler-Ankündigung für Screen Reader
          SemanticsService.announce(
            'Fehler: Schützenausweis-Antrag konnte nicht gesendet werden. Bitte versuchen Sie es erneut.',
            TextDirection.ltr,
          );

          // Zusätzlich SnackBar für visuelle Nutzer
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Semantics(
                liveRegion: true,
                child: const Text(
                  'Antrag konnte nicht gesendet werden. Bitte versuchen Sie es erneut.',
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
              duration: const Duration(seconds: 6),
              action: SnackBarAction(
                label: 'Schließen',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage =
              'Ein unerwarteter Fehler ist aufgetreten. Bitte versuchen Sie es später erneut.';
        });

        // Fehler-Ankündigung für Screen Reader
        SemanticsService.announce(
          'Fehler: Ein unerwarteter Fehler ist aufgetreten bei der Schützenausweis-Bestellung. Bitte versuchen Sie es später erneut.',
          TextDirection.ltr,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Schützenausweis bestellen - Hauptbereich',
      child: BaseScreenLayoutAccessible(
        key: _scaffoldMessengerKey,
        title: Messages.ausweisBestellenTitle,
        userData: widget.userData,
        isLoggedIn: widget.isLoggedIn,
        onLogout: widget.onLogout,
        automaticallyImplyLeading: true,
        semanticScreenLabel: 'Schützenausweis-Bestellung',
        screenDescription:
            'Seite zur Bestellung des digitalen Schützenausweises',
        body: Consumer<FontSizeProvider>(
          builder: (context, fontSizeProvider, child) {
            return Semantics(
              container: true,
              child: Padding(
                padding: UIConstants.screenPadding,
                child: Column(
                  crossAxisAlignment: UIConstants.startCrossAlignment,
                  children: [
                    // Hauptinhalt-Container
                    Semantics(
                      container: true,
                      label: 'Schützenausweis-Bestellinformationen',
                      child: Column(
                        crossAxisAlignment: UIConstants.startCrossAlignment,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                          ),
                          UIConstants.verticalSpacingS,

                          // Beschreibungstext mit verbesserter Semantik
                          Semantics(
                            header: false,
                            readOnly: true,
                            label:
                                'Informationen zur Schützenausweis-Bestellung',
                            child: const ScaledText(
                              Messages.ausweisBestellenDescription,
                              style: UIStyles.bodyStyle,
                            ),
                          ),

                          const SizedBox(height: UIConstants.spacingM),
                        ],
                      ),
                    ),

                    // Fehlerbereich
                    if (errorMessage != null)
                      Semantics(
                        liveRegion: true,
                        container: true,
                        label: 'Fehlermeldung',
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          margin: const EdgeInsets.only(bottom: 16.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.error,
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Semantics(
                                label: 'Fehler-Symbol',
                                child: Icon(
                                  Icons.error_outline,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: Semantics(
                                  label: 'Fehlermeldung: $errorMessage',
                                  child: Text(
                                    errorMessage!,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onErrorContainer,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Lade-Indikator oder Bestell-Button
                    if (isLoading)
                      Semantics(
                        liveRegion: true,
                        label:
                            'Schützenausweis-Bestellung wird verarbeitet, bitte warten',
                        child: const Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(
                                semanticsLabel: 'Bestellung wird verarbeitet',
                              ),
                              SizedBox(height: 16.0),
                              Text(
                                'Ihre Bestellung wird verarbeitet...',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Center(
                        child: Semantics(
                          button: true,
                          enabled: !isLoading,
                          label:
                              'Schützenausweis kostenpflichtig bestellen. Schaltfläche. '
                              'Startet den Bestellvorgang für Ihren digitalen Schützenausweis.',
                          hint:
                              'Doppeltippen zum Bestellen. Nach Bestätigung wird Ihr Antrag übermittelt.',
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _onSave,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                                vertical: 16.0,
                              ),
                              minimumSize: const Size(200, 56),
                            ),
                            child: const Text(
                              'Schützenausweis kostenpflichtig bestellen',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Zusätzliche Informationen für Barrierefreiheit
                    const SizedBox(height: UIConstants.spacingL),
                    Semantics(
                      readOnly: true,
                      label: 'Hilfe-Information',
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Semantics(
                                  label: 'Informations-Symbol',
                                  child: Icon(
                                    Icons.info_outline,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: Text(
                                    'Wichtige Hinweise zur Bestellung:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              '• Der Schützenausweis wird digital ausgestellt\n'
                              '• Die Bestellung ist kostenpflichtig\n'
                              '• Sie erhalten eine Bestätigung nach erfolgreicher Übermittlung\n'
                              '• Bei Problemen wenden Sie sich an den Support',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
