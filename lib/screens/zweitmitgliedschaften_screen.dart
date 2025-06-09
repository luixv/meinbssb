// ignore_for_file: require_trailing_commas, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/screens/logo_widget.dart';
import '/screens/app_menu.dart';
import '/services/api_service.dart';
import '../services/core/config_service.dart';
import '../services/core/logger_service.dart';

class ZweitmitgliedschaftenScreen extends StatefulWidget {
  const ZweitmitgliedschaftenScreen({
    super.key,
    required this.personId,
    required this.userData,
    this.logoWidget,
  });
  final int personId;
  final Map<String, dynamic> userData;
  final Widget? logoWidget;

  @override
  State<ZweitmitgliedschaftenScreen> createState() =>
      _ZweitmitgliedschaftenScreenState();
}

class _ZweitmitgliedschaftenScreenState
    extends State<ZweitmitgliedschaftenScreen> {
  late Future<List<dynamic>> _zweitmitgliedschaftenFuture;
  late Future<List<dynamic>> _passdatenZVEFuture;
  Color _appColor = UIConstants.defaultAppColor;
  // Add the _userData variable
  Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    // Assign the user data.
    _userData = widget.userData['data'] ?? {};
    _loadData();
    _loadAppColor();
  }

  Future<void> _loadAppColor() async {
    final configService = Provider.of<ConfigService>(context, listen: false);
    final colorString = configService.getString('appColor', 'theme');
    if (mounted && colorString != null && colorString.isNotEmpty) {
      setState(() {
        _appColor = Color(int.parse(colorString));
      });
    }
  }

  void _loadData() {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final passDataId = _userData['PASSDATENID']; // Use _userData

      _zweitmitgliedschaftenFuture = apiService.fetchZweitmitgliedschaften(
        widget.personId,
      );

      _passdatenZVEFuture = passDataId != null
          ? apiService.fetchPassdatenZVE(passDataId, widget.personId)
          : Future.value([]);
    } catch (e) {
      LoggerService.logError('Error loading data: $e');
      _zweitmitgliedschaftenFuture = Future.value([]);
      _passdatenZVEFuture = Future.value([]);
    }
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline,
              size: UIConstants.defaultIconSize, color: UIConstants.errorColor),
          const SizedBox(height: UIConstants.spacingS),
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
    final Widget displayedLogo = widget.logoWidget ?? const LogoWidget();

    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: UIConstants.backgroundColor,
        title: const Text(
          'Zweitmitgliedschaften',
          style: UIConstants.appBarTitleStyle,
        ),
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
        padding: UIConstants.defaultPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            displayedLogo, // Use the potentially mocked logo
            const SizedBox(height: UIConstants.spacingS),
            Text(
              'Mein BSSB',
              style: UIConstants.titleStyle.copyWith(color: _appColor),
            ),
            const SizedBox(height: UIConstants.spacingS),
            Text(
              "${_userData['VORNAME']} ${_userData['NAMEN']}",
              style: UIConstants.titleStyle,
            ),
            const SizedBox(height: UIConstants.spacingS),
            Text(
              _userData['PASSNUMMER'],
              style: UIConstants.bodyStyle.copyWith(
                fontSize: UIConstants.subtitleFontSize,
              ),
            ),
            Text(
              'Schützenpassnummer',
              style: UIConstants.bodyStyle
                  .copyWith(color: UIConstants.greySubtitleTextColor),
            ),
            const SizedBox(height: UIConstants.spacingS),
            Text(
              _userData['VEREINNAME'],
              style: UIConstants.bodyStyle.copyWith(
                fontSize: UIConstants.subtitleFontSize,
              ),
            ),
            Text(
              'Erstverein',
              style: UIConstants.bodyStyle
                  .copyWith(color: UIConstants.greySubtitleTextColor),
            ),
            const SizedBox(height: UIConstants.spacingS),
            const Text('Zweitmitgliedschaften:', style: UIConstants.titleStyle),
            const SizedBox(height: UIConstants.spacingS),
            FutureBuilder<List<dynamic>>(
              future: _zweitmitgliedschaftenFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: UIConstants.defaultAppColor,
                      strokeWidth: UIConstants.defaultStrokeWidth,
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
                      margin: const EdgeInsets.only(
                        bottom: UIConstants.spacingS,
                      ),
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
            const SizedBox(height: UIConstants.spacingS),
            const Text('Disziplinen:', style: UIConstants.titleStyle),
            const SizedBox(height: UIConstants.spacingS),
            FutureBuilder<List<dynamic>>(
              future: _passdatenZVEFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: UIConstants.defaultAppColor,
                      strokeWidth: UIConstants.defaultStrokeWidth,
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
                      margin: const EdgeInsets.only(
                        bottom: UIConstants.spacingS,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: UIConstants.spacingS,
                          horizontal: UIConstants.spacingS,
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
                            const SizedBox(width: UIConstants.spacingS),
                            SizedBox(
                              width: 120,
                              child: Text(
                                item['DISZIPLIN'] ?? 'N/A',
                                style: UIConstants.bodyStyle.copyWith(
                                  fontSize: UIConstants.subtitleFontSize,
                                ),
                              ),
                            ),
                            const SizedBox(width: UIConstants.spacingS),
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
