import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/services/api_service.dart';
import '../models/result_data.dart';
import '/models/user_data.dart';

import '/constants/ui_constants.dart';
import 'base_screen_layout.dart';
import '/widgets/scaled_text.dart'; // Assuming ScaledText is available
import '../providers/font_size_provider.dart'; // Import FontSizeProvider

class OktoberfestResultsScreen extends StatefulWidget {
  const OktoberfestResultsScreen({
    super.key,
    required this.passnummer,
    required this.apiService,
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
  });
  final String passnummer;
  final ApiService apiService;
  final UserData? userData;
  final bool isLoggedIn;
  final VoidCallback onLogout;

  @override
  OktoberfestResultsScreenState createState() =>
      OktoberfestResultsScreenState();
}

class OktoberfestResultsScreenState extends State<OktoberfestResultsScreen> {
  late Future<List<Result>> _resultsFuture;

  @override
  void initState() {
    super.initState();
    _fetchResults();
  }

  // Method to fetch results, allowing it to be called on refresh
  void _fetchResults() {
    setState(() {
      _resultsFuture = widget.apiService.fetchResults(widget.passnummer);
    });
  }

  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return BaseScreenLayout(
      title: 'Meine Ergebnisse',
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
              0: FractionColumnWidth(0.05), // Empty column (5%)
              1: FractionColumnWidth(0.65), // Wettbewerb (70%)
              2: FractionColumnWidth(0.15), // Rang (15%)
              3: FractionColumnWidth(0.15), // Ergebnis (15%)
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
                        const SizedBox(), // Empty header cell
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
                            const SizedBox(), // Empty cell
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
                                          UIConstants.spacingM) *
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
