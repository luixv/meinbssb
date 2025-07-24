import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/services/api_service.dart';
import '/services/core/config_service.dart';
import '/models/result.dart';
import '/models/user_data.dart';

import '/constants/ui_constants.dart';
import 'base_screen_layout.dart';
import '/widgets/scaled_text.dart'; // Assuming ScaledText is available
import '/services/core/font_size_provider.dart'; // Import FontSizeProvider

class OktoberfestResultsScreen extends StatefulWidget {
  const OktoberfestResultsScreen({
    super.key,
    required this.passnummer,
    required this.configService,
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
  });
  final String passnummer;
  final ConfigService configService;
  final UserData? userData;
  final bool isLoggedIn;
  final VoidCallback onLogout;

  @override
  _OktoberfestResultsScreenState createState() =>
      _OktoberfestResultsScreenState();
}

class _OktoberfestResultsScreenState extends State<OktoberfestResultsScreen> {
  late Future<List<Result>> _resultsFuture;

  @override
  void initState() {
    super.initState();
    _fetchResults();
  }

  // Method to fetch results, allowing it to be called on refresh
  void _fetchResults() {
    final apiService = Provider.of<ApiService>(context, listen: false);
    setState(() {
      _resultsFuture =
          apiService.fetchResults(widget.passnummer, widget.configService);
    });
  }

  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return BaseScreenLayout(
      title: 'Oktoberfest Ergebnisse',
      userData: widget.userData,
      isLoggedIn: widget.isLoggedIn,
      onLogout: widget.onLogout,
      body: FutureBuilder<List<Result>>(
        future: _resultsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Keine Ergebnisse gefunden.'));
          } else {
            // Filter out results where platz is 0
            final results =
                snapshot.data!.where((result) => result.platz != 0).toList();

            if (results.isEmpty) {
              return const Center(
                child: Text('Keine Ergebnisse gefunden nach Filterung.'),
              );
            }

            // Define column widths using FractionColumnWidth for responsiveness
            const Map<int, TableColumnWidth> columnWidths = {
              0: FractionColumnWidth(0.7), // Wettbewerb (70%)
              1: FractionColumnWidth(0.15), // Rang (approx 15%)
              2: FractionColumnWidth(0.15), // Ergebnis (approx 15%)
            };

            return Column(
              // Center the entire column horizontally
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Fixed header using a Table
                Table(
                  columnWidths: columnWidths,
                  border: const TableBorder(
                    bottom: BorderSide(
                      color: Colors.white,
                      width: 1.0,
                    ), // Add a subtle border below header
                  ),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(UIConstants.spacingS),
                          child: ScaledText(
                            'Wettbewerb',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .fontSize! *
                                      fontSizeProvider.scaleFactor,
                                ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(UIConstants.spacingS),
                          child: ScaledText(
                            'Rang',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .fontSize! *
                                      fontSizeProvider.scaleFactor,
                                ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(UIConstants.spacingS),
                          child: ScaledText(
                            'Ergebnis',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .fontSize! *
                                      fontSizeProvider.scaleFactor,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Scrollable table content using a ListView of TableRows
                Expanded(
                  child: SingleChildScrollView(
                    child: Table(
                      columnWidths:
                          columnWidths, // Apply the same column widths
                      border: TableBorder.all(
                        color: Colors.grey.shade300,
                      ), // Border for data table
                      children: results.map((result) {
                        return TableRow(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.all(UIConstants.spacingS),
                              child: ScaledText(
                                result.wettbewerb,
                                style: TextStyle(
                                  fontSize: (Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.fontSize ??
                                          14.0) *
                                      fontSizeProvider.scaleFactor,
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.all(UIConstants.spacingS),
                              child: ScaledText(
                                '${result.platz}',
                                style: TextStyle(
                                  fontSize: (Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.fontSize ??
                                          14.0) *
                                      fontSizeProvider.scaleFactor,
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.all(UIConstants.spacingS),
                              child: ScaledText(
                                '${result.gesamt}',
                                style: TextStyle(
                                  fontSize: (Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.fontSize ??
                                          14.0) *
                                      fontSizeProvider.scaleFactor,
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
