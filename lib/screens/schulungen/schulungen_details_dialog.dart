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
                    // Wrap dialog content in a Stack
                    AlertDialog(
                      backgroundColor: UIConstants.backgroundColor,
                      contentPadding: EdgeInsets.zero,
                      actions: null,
                      content: Stack(
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
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Header: white background, title, availability, and info table
                                  Container(
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
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: UIConstants.spacingL,
                                          ),
                                          child: Text(
                                            termin.bezeichnung.isNotEmpty
                                                ? termin.bezeichnung
                                                : originalSchulungsTermin
                                                    .bezeichnung,
                                            style: UIStyles.dialogTitleStyle,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: UIConstants.spacingM,
                                        ),
                                        Text(
                                          'Es sind noch ${termin.maxTeilnehmer - termin.angemeldeteTeilnehmer} von ${termin.maxTeilnehmer} Plätzen frei',
                                          style: UIStyles.bodyStyle.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(
                                          height: UIConstants.spacingM,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: UIConstants.spacingXL,
                                            vertical: UIConstants.spacingS,
                                          ),
                                          child: Row(
                                            children: [
                                              // First column: Date and Place
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.calendar_today,
                                                          size:
                                                              UIConstants
                                                                  .defaultIconSize,
                                                        ),
                                                        UIConstants
                                                            .horizontalSpacingS,
                                                        Flexible(
                                                          child: Text(
                                                            DateFormat(
                                                              'dd.MM.yyyy',
                                                              'de_DE',
                                                            ).format(
                                                              termin.datum,
                                                            ),
                                                            style:
                                                                UIStyles
                                                                    .bodyStyle,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height:
                                                          UIConstants.spacingXS,
                                                    ),
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.location_on,
                                                          size:
                                                              UIConstants
                                                                  .defaultIconSize,
                                                        ),
                                                        UIConstants
                                                            .horizontalSpacingS,
                                                        Flexible(
                                                          child: Text(
                                                            termin.ort,
                                                            style:
                                                                UIStyles
                                                                    .bodyStyle,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                width:
                                                    UIConstants.dialogColumnGap,
                                              ),
                                              // Second column: Group and Price
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.group,
                                                          size:
                                                              UIConstants
                                                                  .defaultIconSize,
                                                        ),
                                                        UIConstants
                                                            .horizontalSpacingS,
                                                        Flexible(
                                                          child: Text(
                                                            termin
                                                                .webGruppeLabel,
                                                            style:
                                                                UIStyles
                                                                    .bodyStyle,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height:
                                                          UIConstants.spacingXS,
                                                    ),
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.request_quote,
                                                          size:
                                                              UIConstants
                                                                  .defaultIconSize,
                                                        ),
                                                        UIConstants
                                                            .horizontalSpacingS,
                                                        Flexible(
                                                          child: Text(
                                                            '${termin.kosten.toStringAsFixed(2)} €',
                                                            style:
                                                                UIStyles
                                                                    .bodyStyle,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: UIConstants.spacingS,
                                        ),
                                        // "Lehrgangsleiter" section
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: UIConstants.spacingL,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Lehrgangsleiter:',
                                                style: UIStyles.bodyStyle
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              const SizedBox(
                                                height: UIConstants.spacingXS,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.email,
                                                    size:
                                                        UIConstants
                                                            .defaultIconSize,
                                                  ),
                                                  UIConstants
                                                      .horizontalSpacingS,
                                                  Flexible(
                                                    child: Text(
                                                      lehrgangsleiterMail,
                                                      style: UIStyles.bodyStyle,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: UIConstants.spacingXXS,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.phone,
                                                    size:
                                                        UIConstants
                                                            .defaultIconSize,
                                                  ),
                                                  UIConstants
                                                      .horizontalSpacingS,
                                                  Flexible(
                                                    child: Text(
                                                      lehrgangsleiterTel,
                                                      style: UIStyles.bodyStyle,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const Divider(
                                    height: UIConstants.defaultStrokeWidth,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(
                                      UIConstants.spacingM,
                                    ),
                                    child:
                                        termin.lehrgangsinhaltHtml.isNotEmpty
                                            ? Html(
                                              data: termin.lehrgangsinhaltHtml,
                                              style: {
                                                'body': Style(
                                                  fontSize: FontSize(
                                                    15.0,
                                                  ), // Increase font size as needed
                                                ),
                                              },
                                            )
                                            : termin.lehrgangsinhalt.isNotEmpty
                                            ? Text(termin.lehrgangsinhalt)
                                            : termin.bemerkung.isNotEmpty
                                            ? Text(termin.bemerkung)
                                            : const Text(
                                              'Keine Beschreibung verfügbar.',
                                            ),
                                  ),
                                  const SizedBox(height: UIConstants.spacingXL),
                                ],
                              ),
                            ),
                          ),
                          // FABs inside dialog, at bottom right
                          Positioned(
                            bottom: UIConstants.spacingM,
                            right: UIConstants.spacingM,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // "Schließen" FAB on top
                                FloatingActionButton(
                                  heroTag: 'dialogCloseFab',
                                  tooltip: 'Schließen',
                                  backgroundColor: UIConstants.defaultAppColor,
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Icon(
                                    Icons.close,
                                    color: UIConstants.whiteColor,
                                  ),
                                ),
                                const SizedBox(height: UIConstants.spacingM),
                                // "Buchen" FAB below
                                FloatingActionButton(
                                  heroTag: 'dialogBookFab',
                                  tooltip:
                                      cannotBook ? 'Nicht buchbar' : 'Buchen',
                                  backgroundColor:
                                      cannotBook
                                          ? UIConstants.cancelButtonBackground
                                          : UIConstants.defaultAppColor,
                                  onPressed:
                                      cannotBook
                                          ? null
                                          : () {
                                            Navigator.of(context).pop();
                                            if (onBookingPressed != null) {
                                              onBookingPressed();
                                            }
                                          },
                                  child: const Icon(
                                    Icons.event_available,
                                    color: UIConstants.whiteColor,
                                  ),
                                ),
                              ],
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
}
