import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/models/schulungstermin_data.dart';

import '/services/api_service.dart';

class SchulungenDetailsDialog {
  static Future<bool> canNotBeBooked(
    Schulungstermin termin,
    int personId,
    BuildContext context,
  ) async {
    if (termin.anmeldungenGesperrt) {
      return true;
    }

    if (personId > 0) {
      final apiService = Provider.of<ApiService>(context, listen: false);
      try {
        final isAlreadyRegistered = await apiService.isRegisterForThisSchulung(
          personId,
          termin.schulungsterminId,
        );
        return isAlreadyRegistered;
      } catch (e) {
        // In case of error, allow booking (don't block)
        return false;
      }
    }

    return false;
  }

  static Future<void> show(
    BuildContext context,
    Schulungstermin termin,
    Schulungstermin originalSchulungsTermin, {
    required String lehrgangsleiterMail,
    required String lehrgangsleiterTel,
    required VoidCallback? onBookingPressed,
    required bool isUserLoggedIn,
    int? personId,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return FutureBuilder<bool>(
              future: canNotBeBooked(termin, personId ?? 0, context),
              builder: (context, snapshot) {
                final cannotBook =
                    snapshot.data ?? true; // Default to disabled while loading
                return Stack(
                  children: [
                    // Accessible dialog with proper semantic structure
                    AlertDialog(
                      backgroundColor: UIConstants.backgroundColor,
                      contentPadding: EdgeInsets.zero,
                      actions: null,
                      semanticLabel: 'Schulungsdetails Dialog',
                      content: Semantics(
                        container: true,
                        label: 'Detailinformationen zur Schulung',
                        child: Stack(
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: UIConstants.dialogMaxWidthWide,
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.8,
                                minWidth: UIConstants.dialogMinWidth,
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Header with semantic structure
                                    Semantics(
                                      container: true,
                                      header: true,
                                      label: 'Schulungsinformationen Übersicht',
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: UIConstants.spacingL,
                                          horizontal: UIConstants.spacingXS,
                                        ),
                                        decoration: BoxDecoration(
                                          color: UIConstants.whiteColor,
                                          borderRadius: BorderRadius.circular(
                                            UIConstants.cornerRadius,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal:
                                                    UIConstants.spacingL,
                                              ),
                                              child: Semantics(
                                                header: true,
                                                child: Text(
                                                  termin.bezeichnung.isNotEmpty
                                                      ? termin.bezeichnung
                                                      : originalSchulungsTermin
                                                          .bezeichnung,
                                                  style:
                                                      UIStyles.dialogTitleStyle,
                                                  textAlign: TextAlign.center,
                                                  semanticsLabel:
                                                      'Schulungstitel: ${termin.bezeichnung.isNotEmpty ? termin.bezeichnung : originalSchulungsTermin.bezeichnung}',
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: UIConstants.spacingM,
                                            ),
                                            Semantics(
                                              liveRegion: true,
                                              child: Text(
                                                'Es sind noch ${termin.maxTeilnehmer - termin.angemeldeteTeilnehmer} von ${termin.maxTeilnehmer} Plätzen frei',
                                                style:
                                                    UIStyles.bodyStyle.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                                semanticsLabel:
                                                    'Verfügbarkeit: Es sind noch ${termin.maxTeilnehmer - termin.angemeldeteTeilnehmer} von ${termin.maxTeilnehmer} Plätzen frei',
                                              ),
                                            ),
                                            const SizedBox(
                                              height: UIConstants.spacingM,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal:
                                                    UIConstants.spacingXL,
                                                vertical: UIConstants.spacingS,
                                              ),
                                              child: Semantics(
                                                container: true,
                                                label: 'Schulungsdetails',
                                                child: Row(
                                                  children: [
                                                    // First column: Date and Place
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Semantics(
                                                            container: true,
                                                            label:
                                                                'Datum: ${DateFormat('dd.MM.yyyy', 'de_DE').format(termin.datum)}',
                                                            child: Row(
                                                              children: [
                                                                Semantics(
                                                                  excludeSemantics:
                                                                      true,
                                                                  child:
                                                                      const Icon(
                                                                    Icons
                                                                        .calendar_today,
                                                                    size: UIConstants
                                                                        .defaultIconSize,
                                                                  ),
                                                                ),
                                                                UIConstants
                                                                    .horizontalSpacingS,
                                                                Flexible(
                                                                  child: Text(
                                                                    DateFormat(
                                                                      'dd.MM.yyyy',
                                                                      'de_DE',
                                                                    ).format(
                                                                      termin
                                                                          .datum,
                                                                    ),
                                                                    style: UIStyles
                                                                        .bodyStyle,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    maxLines: 1,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: UIConstants
                                                                .spacingXS,
                                                          ),
                                                          Semantics(
                                                            container: true,
                                                            label:
                                                                'Ort: ${termin.ort}',
                                                            child: Row(
                                                              children: [
                                                                Semantics(
                                                                  excludeSemantics:
                                                                      true,
                                                                  child:
                                                                      const Icon(
                                                                    Icons
                                                                        .location_on,
                                                                    size: UIConstants
                                                                        .defaultIconSize,
                                                                  ),
                                                                ),
                                                                UIConstants
                                                                    .horizontalSpacingS,
                                                                Flexible(
                                                                  child: Text(
                                                                    termin.ort,
                                                                    style: UIStyles
                                                                        .bodyStyle,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    maxLines: 1,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: UIConstants
                                                          .dialogColumnGap,
                                                    ),
                                                    // Second column: Group and Price
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Semantics(
                                                            container: true,
                                                            label:
                                                                'Gruppe: ${termin.webGruppeLabel}',
                                                            child: Row(
                                                              children: [
                                                                Semantics(
                                                                  excludeSemantics:
                                                                      true,
                                                                  child:
                                                                      const Icon(
                                                                    Icons.group,
                                                                    size: UIConstants
                                                                        .defaultIconSize,
                                                                  ),
                                                                ),
                                                                UIConstants
                                                                    .horizontalSpacingS,
                                                                Flexible(
                                                                  child: Text(
                                                                    termin
                                                                        .webGruppeLabel,
                                                                    style: UIStyles
                                                                        .bodyStyle,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    maxLines: 1,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: UIConstants
                                                                .spacingXS,
                                                          ),
                                                          Semantics(
                                                            container: true,
                                                            label:
                                                                'Kosten: ${termin.kosten.toStringAsFixed(2)} Euro',
                                                            child: Row(
                                                              children: [
                                                                Semantics(
                                                                  excludeSemantics:
                                                                      true,
                                                                  child:
                                                                      const Icon(
                                                                    Icons
                                                                        .request_quote,
                                                                    size: UIConstants
                                                                        .defaultIconSize,
                                                                  ),
                                                                ),
                                                                UIConstants
                                                                    .horizontalSpacingS,
                                                                Flexible(
                                                                  child: Text(
                                                                    '${termin.kosten.toStringAsFixed(2)} €',
                                                                    style: UIStyles
                                                                        .bodyStyle,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    maxLines: 1,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: UIConstants.spacingS,
                                            ),
                                            // Accessible contact information
                                            Semantics(
                                              container: true,
                                              label:
                                                  'Kontaktinformationen Lehrgangsleiter',
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal:
                                                      UIConstants.spacingL,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Semantics(
                                                      header: true,
                                                      child: Text(
                                                        'Lehrgangsleiter:',
                                                        style: UIStyles
                                                            .bodyStyle
                                                            .copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height:
                                                          UIConstants.spacingXS,
                                                    ),
                                                    Semantics(
                                                      container: true,
                                                      label:
                                                          'E-Mail: $lehrgangsleiterMail',
                                                      hint:
                                                          'E-Mail-Adresse des Lehrgangsleiter',
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Semantics(
                                                            excludeSemantics:
                                                                true,
                                                            child: const Icon(
                                                              Icons.email,
                                                              size: UIConstants
                                                                  .defaultIconSize,
                                                            ),
                                                          ),
                                                          UIConstants
                                                              .horizontalSpacingS,
                                                          Flexible(
                                                            child: Text(
                                                              lehrgangsleiterMail,
                                                              style: UIStyles
                                                                  .bodyStyle,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: UIConstants
                                                          .spacingXXS,
                                                    ),
                                                    Semantics(
                                                      container: true,
                                                      label:
                                                          'Telefon: $lehrgangsleiterTel',
                                                      hint:
                                                          'Telefonnummer des Lehrgangsleiter',
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Semantics(
                                                            excludeSemantics:
                                                                true,
                                                            child: const Icon(
                                                              Icons.phone,
                                                              size: UIConstants
                                                                  .defaultIconSize,
                                                            ),
                                                          ),
                                                          UIConstants
                                                              .horizontalSpacingS,
                                                          Flexible(
                                                            child: Text(
                                                              lehrgangsleiterTel,
                                                              style: UIStyles
                                                                  .bodyStyle,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    const Divider(
                                      height: UIConstants.defaultStrokeWidth,
                                    ),
                                    // Accessible content section
                                    Semantics(
                                      container: true,
                                      label: 'Schulungsinhalt und Beschreibung',
                                      child: Padding(
                                        padding: const EdgeInsets.all(
                                          UIConstants.spacingM,
                                        ),
                                        child: termin
                                                .lehrgangsinhaltHtml.isNotEmpty
                                            ? Semantics(
                                                container: true,
                                                label:
                                                    'Lehrgangsinhalte im HTML-Format',
                                                child: Html(
                                                  data: termin
                                                      .lehrgangsinhaltHtml,
                                                ),
                                              )
                                            : termin.lehrgangsinhalt.isNotEmpty
                                                ? Semantics(
                                                    container: true,
                                                    label:
                                                        'Lehrgangsinhalt: ${termin.lehrgangsinhalt}',
                                                    child: Text(
                                                      termin.lehrgangsinhalt,
                                                    ),
                                                  )
                                                : termin.bemerkung.isNotEmpty
                                                    ? Semantics(
                                                        container: true,
                                                        label:
                                                            'Bemerkungen: ${termin.bemerkung}',
                                                        child: Text(
                                                          termin.bemerkung,
                                                        ),
                                                      )
                                                    : Semantics(
                                                        container: true,
                                                        label:
                                                            'Keine Beschreibung verfügbar',
                                                        child: const Text(
                                                          'Keine Beschreibung verfügbar.',
                                                        ),
                                                      ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: UIConstants.spacingXL,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Accessible action buttons
                            Positioned(
                              bottom: UIConstants.spacingM,
                              right: UIConstants.spacingM,
                              child: Semantics(
                                container: true,
                                label: 'Dialog Aktionen',
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // Close button with accessibility
                                    Semantics(
                                      container: true,
                                      button: true,
                                      label: 'Dialog schließen',
                                      hint:
                                          'Schließt das Schulungsdetails-Fenster',
                                      child: FloatingActionButton(
                                        heroTag: 'dialogCloseFab',
                                        tooltip: 'Dialog schließen',
                                        backgroundColor:
                                            UIConstants.defaultAppColor,
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: Semantics(
                                          excludeSemantics: true,
                                          child: const Icon(
                                            Icons.close,
                                            color: UIConstants.whiteColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: UIConstants.spacingM,
                                    ),
                                    // Booking button with accessibility
                                    Semantics(
                                      container: true,
                                      button: true,
                                      enabled: !cannotBook,
                                      label: cannotBook
                                          ? 'Schulung kann nicht gebucht werden'
                                          : 'Schulung buchen',
                                      hint: cannotBook
                                          ? 'Diese Schulung ist nicht buchbar, da sie bereits ausgebucht ist oder Sie bereits angemeldet sind'
                                          : 'Meldet Sie für diese Schulung an',
                                      child: FloatingActionButton(
                                        heroTag: 'dialogBookFab',
                                        tooltip: cannotBook
                                            ? 'Nicht buchbar'
                                            : 'Schulung buchen',
                                        backgroundColor: cannotBook
                                            ? UIConstants.cancelButtonBackground
                                            : UIConstants.defaultAppColor,
                                        onPressed: cannotBook
                                            ? null
                                            : () {
                                                Navigator.of(context).pop();
                                                if (onBookingPressed != null) {
                                                  onBookingPressed();
                                                }
                                              },
                                        child: Semantics(
                                          excludeSemantics: true,
                                          child: const Icon(
                                            Icons.event_available,
                                            color: UIConstants.whiteColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
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
}
