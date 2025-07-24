import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/services/api_service.dart';
import '/services/core/config_service.dart';
import '/models/result.dart';
import '/models/user_data.dart';

import '/constants/ui_constants.dart';
import 'base_screen_layout.dart';

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
    final apiService = Provider.of<ApiService>(context, listen: false);
    _resultsFuture =
        apiService.fetchResults(widget.passnummer, widget.configService);
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
            return Column(
              children: [
                // Fixed header
                Container(
                  color: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.all(UIConstants.spacingS),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text('Wettbewerb',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,),),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text('Rang',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,),),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('Ergebnis',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,),),
                      ),
                    ],
                  ),
                ),
                // Scrollable table with "dummy" column headers
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columnSpacing: UIConstants.spacingM,
                      columns: const [
                        DataColumn(label: SizedBox()), // Empty headers
                        DataColumn(label: SizedBox()),
                        DataColumn(label: SizedBox()),
                      ],
                      rows: results
                          .map(
                            (result) => DataRow(
                              cells: [
                                DataCell(Text(result.wettbewerb)),
                                DataCell(Text('${result.platz}')),
                                DataCell(Text('${result.gesamt}')),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: SizedBox(
          height: UIConstants.fabSize,
          width: UIConstants.fabSize,
          child: FloatingActionButton(
            heroTag: 'refreshResults',
            onPressed: () {
              setState(() {
                final apiService =
                    Provider.of<ApiService>(context, listen: false);
                _resultsFuture = apiService.fetchResults(
                  widget.passnummer,
                  widget.configService,
                );
              });
            },
            tooltip: 'Ergebnisse aktualisieren',
            backgroundColor: UIConstants.defaultAppColor,
            child: const Icon(Icons.refresh, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
