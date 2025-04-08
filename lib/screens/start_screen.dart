// Project: Mein BSSB
// Filename: start_screen.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/screens/app_menu.dart';
import 'package:meinbssb/services/localization_service.dart';
import 'package:meinbssb/screens/logo_widget.dart';
import 'package:meinbssb/constants/ui_constants.dart';

class StartScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final bool isLoggedIn;
  final Function() onLogout;

  const StartScreen(
    this.userData, {
    required this.isLoggedIn,
    required this.onLogout,
    super.key,
  });

  @override
  StartScreenState createState() => StartScreenState();
}

class StartScreenState extends State<StartScreen> {
  List<dynamic> schulungen = [];
  bool isLoading = true;
  Color _appColor = UIConstants.defaultAppColor;

  @override
  void initState() {
    super.initState();
    fetchSchulungen();
    _loadLocalization();
    debugPrint('StartScreen initialized with user: ${widget.userData}');
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

  Future<void> fetchSchulungen() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final personId = widget.userData['PERSONID'];

    if (personId == null) {
      debugPrint('PERSONID is null');
      if (mounted) setState(() => isLoading = false);
      return;
    }

    final today = DateTime.now();
    final abDatum =
        "${today.day.toString().padLeft(2, '0')}.${today.month.toString().padLeft(2, '0')}.${today.year}";

    try {
      debugPrint('Fetching schulungen for $personId on $abDatum');
      final result = await apiService.fetchAngemeldeteSchulungen(
        personId,
        abDatum,
      );

      if (mounted) {
        setState(() {
          schulungen = result;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching schulungen: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          schulungen = []; // Ensure empty state is clear
        });
      }
    }
  }

  void _handleLogout() {
    debugPrint('Logging out user: ${widget.userData['VORNAME']}');
    widget.onLogout(); // Update app state
    Navigator.of(context).pushReplacementNamed('/login'); // Force navigation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Angemeldete Schulungen', style: UIConstants.titleStyle),
        actions: [
          AppMenu(
            context: context,
            userData: widget.userData,
            isLoggedIn: widget.isLoggedIn,
            onLogout: _handleLogout,
          ),
        ],
      ),
      body: Padding(
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
            Text("Angemeldete Schulungen:", style: UIConstants.titleStyle),
            isLoading
                ? Center(
                  child: CircularProgressIndicator(
                    color: UIConstants.defaultAppColor,
                    strokeWidth: 2.0,
                  ),
                )
                : schulungen.isEmpty
                ? Text(
                  "Keine Schulungen gefunden.",
                  style: UIConstants.bodyStyle.copyWith(
                    color: UIConstants.grey,
                  ),
                )
                : Expanded(
                  child: ListView.builder(
                    itemCount: schulungen.length,
                    itemBuilder: (context, index) {
                      final schulung = schulungen[index];
                      final datum = DateTime.parse(schulung['DATUM']);
                      final formattedDatum =
                          "${datum.day.toString().padLeft(2, '0')}.${datum.month.toString().padLeft(2, '0')}.${datum.year}";
                      return Card(
                        margin: EdgeInsets.only(
                          bottom: UIConstants.smallSpacing,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: UIConstants.smallSpacing,
                            horizontal: UIConstants.smallSpacing,
                          ),
                          child: Row(
                            children: [
                              // Date
                              SizedBox(
                                width: 90, // Fixed width for date
                                child: Text(
                                  formattedDatum,
                                  style: UIConstants.bodyStyle.copyWith(
                                    fontSize: UIConstants.subtitleFontSize,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: UIConstants.smallSpacing,
                              ), // Small spacing
                              // Schulung name
                              Expanded(
                                child: Text(
                                  schulung['BEZEICHNUNG'] ?? 'N/A',
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
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
