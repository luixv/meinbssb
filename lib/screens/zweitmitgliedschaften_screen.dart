import 'package:flutter/material.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/screens/logo_widget.dart';
import 'package:meinbssb/screens/app_menu.dart';
import 'package:meinbssb/services/localization_service.dart';
import 'package:meinbssb/constants/ui_constants.dart';

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
    _loadLocalization();
  }

  Future<void> _loadLocalization() async {
    await LocalizationService.load('assets/strings.json');
    if (mounted) {
      setState(() {
        final colorString = LocalizationService.getString('appColor');
        if (colorString.isNotEmpty) {
          _appColor = Color(int.parse(colorString));
        }
      });
    }
  }

  void _loadData() {
    final apiService = Provider.of<ApiService>(context, listen: false);
    _zweitmitgliedschaftenFuture = apiService.fetchZweitmitgliedschaften(
      widget.personId,
    );
    _passdatenZVEFuture = apiService.fetchPassdatenZVE(
      widget.userData['PASSDATENID'],
      widget.personId,
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
            // First FutureBuilder for Zweitmitgliedschaften
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: UIConstants.red,
                        ),
                        SizedBox(height: UIConstants.defaultSpacing),
                        Text(
                          'Fehler beim Laden der Daten',
                          textAlign: TextAlign.center,
                          style: UIConstants.errorStyle,
                        ),
                      ],
                    ),
                  );
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
                        title: Text(
                          item['VEREINNAME'] ?? 'Unbekannter Verein',
                          style: UIConstants.bodyStyle.copyWith(
                            fontSize: UIConstants.subtitleFontSize,
                            fontWeight: FontWeight.bold,
                          ),
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
            // Second FutureBuilder for PassdatenZVE
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: UIConstants.red,
                        ),
                        SizedBox(height: UIConstants.defaultSpacing),
                        Text(
                          'Fehler beim Laden der Disziplinen',
                          textAlign: TextAlign.center,
                          style: UIConstants.errorStyle,
                        ),
                      ],
                    ),
                  );
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
                            // DISZIPLINNR
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
                            // DISZIPLIN
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
                            // VEREINNAME
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
