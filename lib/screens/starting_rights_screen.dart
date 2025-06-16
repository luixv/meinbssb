import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/screens/base_screen_layout.dart';
import '/models/user_data.dart';
import '/services/api_service.dart';

import '/models/pass_data_zve.dart';
import '/services/core/logger_service.dart';
import '/services/api/training_service.dart';
import '/models/disziplin.dart';
import '/widgets/scaled_text.dart';
import '/providers/font_size_provider.dart';

class StartingRightsScreen extends StatefulWidget {
  const StartingRightsScreen({
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
    super.key,
  });

  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  State<StartingRightsScreen> createState() => _StartingRightsScreenState();
}

class _StartingRightsScreenState extends State<StartingRightsScreen> {
  UserData? _passData;
  List<PassDataZVE> _zveData = [];
  List<Disziplin> _disciplines = [];
  bool _isLoading = false;
  String? _errorMessage;
  late TextEditingController _autocompleteTextController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _autocompleteTextController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  @override
  void dispose() {
    _autocompleteTextController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    final int? personId = widget.userData?.personId;
    final int? passdatenId = widget.userData?.passdatenId;

    if (personId == null || passdatenId == null) {
      LoggerService.logError(
        'Person ID or Passdaten ID is null. Cannot fetch starting rights data.',
      );
      if (mounted) {
        setState(() {
          _errorMessage =
              'Benutzerdaten nicht verfügbar. Bitte erneut anmelden.';
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);

      final fetchedPassData = await apiService.fetchPassdaten(personId);
      final fetchedZveData = await apiService.fetchPassdatenZVE(
        passdatenId,
        personId,
      );
      final fetchedDisciplines = await apiService.fetchDisziplinen();

      if (mounted) {
        setState(() {
          _passData = fetchedPassData;
          _zveData = fetchedZveData;
          _disciplines = fetchedDisciplines;
        });
      }
    } catch (e) {
      LoggerService.logError('Error fetching starting rights data: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Fehler beim Laden der Startrechte: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: 'Startrechte Ändern',
      userData: widget.userData,
      isLoggedIn: widget.isLoggedIn,
      onLogout: widget.onLogout,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: ScaledText(
                    _errorMessage!,
                    style: UIStyles.bodyStyle.copyWith(color: Colors.red),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(UIConstants.spacingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ScaledText(
                        'Erstverein',
                        style: UIStyles.headerStyle.copyWith(
                          color: UIConstants.defaultAppColor,
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingS),
                      if (_passData != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: UIStyles.bodyStyle,
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: _passData!.passnummer,
                                          style: UIStyles.bodyStyle.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const TextSpan(text: ' - '),
                                        TextSpan(
                                          text: _passData!.vereinName,
                                          style: UIStyles.bodyStyle.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      else
                        const ScaledText(
                          'Keine Erstvereinsdaten verfügbar.',
                          style: UIStyles.bodyStyle,
                        ),
                      const SizedBox(height: UIConstants.spacingM),
                      ScaledText(
                        'Zweitvereine',
                        style: UIStyles.headerStyle.copyWith(
                          color: UIConstants.defaultAppColor,
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingS),
                      if (_zveData.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _zveData.length,
                          itemBuilder: (context, index) {
                            final zve = _zveData[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: UIConstants.spacingS,
                              ),
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                    UIConstants.spacingS,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: RichText(
                                              text: TextSpan(
                                                style: UIStyles.bodyStyle,
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text: zve.vVereinNr
                                                        .toString(),
                                                    style: UIStyles.bodyStyle
                                                        .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const TextSpan(text: ' - '),
                                                  TextSpan(
                                                    text: zve.vereinName,
                                                    style: UIStyles.bodyStyle
                                                        .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      else
                        const ScaledText(
                          'Keine Zweitvereine verfügbar.',
                          style: UIStyles.bodyStyle,
                        ),
                    ],
                  ),
                ),
    );
  }
}
