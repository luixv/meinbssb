import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/services/api_service.dart';
import '/services/core/config_service.dart';
import '/models/result.dart';
import '/models/user_data.dart';

import '/constants/ui_constants.dart';
import 'base_screen_layout.dart';
import '/widgets/scaled_text.dart'; // Assuming ScaledText is available

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
    return BaseScreenLayout(
      title: 'Oktoberfest Results',
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
            final results = snapshot.data!;

            // Define column widths using FractionColumnWidth for responsiveness
            const Map<int, TableColumnWidth> columnWidths = {
              0: FractionColumnWidth(0.5), // Wettbewerb (50%)
              1: FractionColumnWidth(0.16), // Rang (approx 16%)
              2: FractionColumnWidth(0.34), // Ergebnis (approx 34%)
            };

            return Column(
              children: [
                // Fixed header using a Table
                Table(
                  columnWidths: columnWidths,
                  border: TableBorder.all(
                      color: Colors.transparent,), // No border for header table
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
                          color: Colors.grey.shade300,), // Border for data table
                      children: results.map((result) {
                        return TableRow(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.all(UIConstants.spacingS),
                              child: ScaledText(result.wettbewerb),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.all(UIConstants.spacingS),
                              child: ScaledText('${result.platz}'),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.all(UIConstants.spacingS),
                              child: ScaledText('${result.gesamt}'),
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
      floatingActionButton: FloatingActionButton(
        heroTag: 'refreshResults',
        onPressed: _fetchResults, // Call the new _fetchResults method
        tooltip: 'Ergebnisse aktualisieren',
        backgroundColor: UIConstants.defaultAppColor,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
