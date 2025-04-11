// Project: Mein BSSB
// Filename: zweitmitgliedschaften_screen.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/screens/logo_widget.dart';
import '/screens/app_menu.dart';
import '/constants/ui_constants.dart';
import '/services/config_service.dart';
import '/services/api_service.dart';

class ZweitmitgliedschaftenScreen extends StatefulWidget {
  final int personId;
  final Map<String, dynamic> userData;

  const ZweitmitgliedschaftenScreen({
    super.key,
    required this.personId,
    required this.userData,
  });

  @override
  State<ZweitmitgliedschaftenScreen> createState() =>
      _ZweitmitgliedschaftenScreenState();
}

class _ZweitmitgliedschaftenScreenState
    extends State<ZweitmitgliedschaftenScreen> {
  late Future<List<dynamic>> _zweitmitgliedschaftenFuture;
  late Future<List<dynamic>> _passdatenZVEFuture;
  Color _appColor = UIConstants.defaultAppColor;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadAppColor();
  }

  Future<void> _loadAppColor() async {
    final colorString = ConfigService.getString('appColor', 'theme');
    if (mounted && colorString != null && colorString.isNotEmpty) {
      setState(() {
        _appColor = Color(int.parse(colorString));
      });
    }
  }

  void _loadData() {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final passDataId = widget.userData['PASSDATENID'];

      _zweitmitgliedschaftenFuture = apiService.fetchZweitmitgliedschaften(
        widget.personId,
      );

      _passdatenZVEFuture =
          passDataId != null
              ? apiService.fetchPassdatenZVE(passDataId, widget.personId)
              : Future.value([]);
    } catch (e) {
      debugPrint('Error loading data: $e');
      _zweitmitgliedschaftenFuture = Future.value([]);
      _passdatenZVEFuture = Future.value([]);
    }
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: UIConstants.red),
          SizedBox(height: UIConstants.defaultSpacing),
          Text(
            message,
            textAlign: TextAlign.center,
            style: UIConstants.errorStyle,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Zweitmitgliedschaften', style: UIConstants.titleStyle),
        actions: [
          AppMenu(
            context: context,
            userData: widget.userData,
            isLoggedIn: true,
            onLogout: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(UIConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LogoWidget(),
            SizedBox(height: UIConstants.defaultSpacing),
            Text(
              "Mein BSSB",
              style: UIConstants.headerStyle.copyWith(color: _appColor),
            ),
            SizedBox(height: UIConstants.defaultSpacing),
            Text(
              "${widget.userData['VORNAME']} ${widget.userData['NAMEN']}",
              style: UIConstants.titleStyle,
            ),
            SizedBox(height: UIConstants.smallSpacing),
            Text(
              widget.userData['PASSNUMMER'],
              style: UIConstants.bodyStyle.copyWith(
                fontSize: UIConstants.subtitleFontSize,
              ),
            ),
            Text(
              "Schützenpassnummer",
              style: UIConstants.bodyStyle.copyWith(color: UIConstants.grey),
            ),
            SizedBox(height: UIConstants.smallSpacing),
            Text(
              widget.userData['VEREINNAME'],
              style: UIConstants.bodyStyle.copyWith(
                fontSize: UIConstants.subtitleFontSize,
              ),
            ),
            Text(
              "Erstverein",
              style: UIConstants.bodyStyle.copyWith(color: UIConstants.grey),
            ),
            SizedBox(height: UIConstants.defaultSpacing),
            Text("Zweitmitgliedschaften:", style: UIConstants.titleStyle),
            SizedBox(height: UIConstants.smallSpacing),
            FutureBuilder<List<dynamic>>(
              future: _zweitmitgliedschaftenFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: UIConstants.defaultAppColor,
                      strokeWidth: 2.0,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return _buildErrorWidget('Fehler beim Laden der Daten');
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'Keine Zweitmitgliedschaften gefunden.',
                      style: UIConstants.bodyStyle.copyWith(
                        fontSize: UIConstants.subtitleFontSize,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final item = snapshot.data![index];
                    return Card(
                      margin: EdgeInsets.only(bottom: UIConstants.smallSpacing),
                      child: ListTile(
                        title: Row(
                          children: [
                            SizedBox(
                              width: 60,
                              child: Text(
                                '${item['VEREINID'] ?? 'N/A'}',
                                style: UIConstants.bodyStyle.copyWith(
                                  fontSize: UIConstants.subtitleFontSize,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                item['VEREINNAME'] ?? 'Unbekannter Verein',
                                style: UIConstants.bodyStyle.copyWith(
                                  fontSize: UIConstants.subtitleFontSize,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            SizedBox(height: UIConstants.defaultSpacing),
            Text("Disziplinen:", style: UIConstants.titleStyle),
            SizedBox(height: UIConstants.smallSpacing),
            FutureBuilder<List<dynamic>>(
              future: _passdatenZVEFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: UIConstants.defaultAppColor,
                      strokeWidth: 2.0,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return _buildErrorWidget('Fehler beim Laden der Disziplinen');
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'Keine Disziplinen gefunden.',
                      style: UIConstants.bodyStyle.copyWith(
                        fontSize: UIConstants.subtitleFontSize,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final item = snapshot.data![index];
                    return Card(
                      margin: EdgeInsets.only(bottom: UIConstants.smallSpacing),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: UIConstants.smallSpacing,
                          horizontal: UIConstants.smallSpacing,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 60,
                              child: Text(
                                item['DISZIPLINNR'] ?? 'N/A',
                                style: UIConstants.bodyStyle.copyWith(
                                  fontSize: UIConstants.subtitleFontSize,
                                ),
                              ),
                            ),
                            SizedBox(width: UIConstants.smallSpacing),
                            SizedBox(
                              width: 120,
                              child: Text(
                                item['DISZIPLIN'] ?? 'N/A',
                                style: UIConstants.bodyStyle.copyWith(
                                  fontSize: UIConstants.subtitleFontSize,
                                ),
                              ),
                            ),
                            SizedBox(width: UIConstants.smallSpacing),
                            Expanded(
                              child: Text(
                                item['VEREINNAME'] ?? 'N/A',
                                style: UIConstants.bodyStyle.copyWith(
                                  fontSize: UIConstants.subtitleFontSize,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
