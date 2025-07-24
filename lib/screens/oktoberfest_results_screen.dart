import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/services/api_service.dart';
import '/services/core/config_service.dart';
import '/models/result.dart';
import '/models/user_data.dart';

import '/constants/ui_styles.dart';
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
            return ListView.separated(
              padding: const EdgeInsets.all(UIConstants.spacingL),
              itemCount: results.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final result = results[index];
                return Card(
                  elevation: UIConstants.appBarElevation,
                  margin: const EdgeInsets.symmetric(
                    vertical: UIConstants.spacingS,
                    horizontal: UIConstants.spacingL,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: UIConstants.spacingM,
                      horizontal: UIConstants.spacingL,
                    ),
                    title: Text(
                      result.wettbewerb,
                      style: UIStyles.listItemTitleStyle,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Platz: ${result.platz}',
                          style: UIStyles.listItemSubtitleStyle,
                        ),
                        Text(
                          'Gesamt: ${result.gesamt}',
                          style: UIStyles.listItemSubtitleStyle,
                        ),
                        // Add more details if needed
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: SizedBox(
          height: UIConstants.fabSize,
          width: UIConstants.fabSize,
          child: Stack(
            children: [
              // Refresh (Year pick / fetch results) FAB
              Visibility(
                visible: true,
                maintainState: true,
                child: FloatingActionButton(
                  heroTag: 'fetchResults',
                  onPressed: () async {
                    setState(() {
                      _resultsFuture =
                          Provider.of<ApiService>(context, listen: false)
                              .fetchResults(
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
            ],
          ),
        ),
      ),
    );
  }
}
