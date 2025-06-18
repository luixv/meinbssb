import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/screens/base_screen_layout.dart';
import '/models/user_data.dart';
import '/services/api_service.dart';

import '/models/pass_data_zve.dart';
import '/services/core/logger_service.dart';
import '/models/disziplin.dart';
import '/widgets/scaled_text.dart';
import '/services/core/font_size_provider.dart';

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
    _searchController.dispose();
    _autocompleteTextController.dispose();
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
                                  child: Consumer<FontSizeProvider>(
                                    builder:
                                        (context, fontSizeProvider, child) {
                                      return RichText(
                                        text: TextSpan(
                                          style: UIStyles.bodyStyle.copyWith(
                                            fontSize: UIStyles
                                                    .bodyStyle.fontSize! *
                                                fontSizeProvider.scaleFactor,
                                          ),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: _passData!.passnummer,
                                              style:
                                                  UIStyles.bodyStyle.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: UIStyles
                                                        .bodyStyle.fontSize! *
                                                    fontSizeProvider
                                                        .scaleFactor,
                                              ),
                                            ),
                                            TextSpan(
                                              text: ' - ',
                                              style:
                                                  UIStyles.bodyStyle.copyWith(
                                                fontSize: UIStyles
                                                        .bodyStyle.fontSize! *
                                                    fontSizeProvider
                                                        .scaleFactor,
                                              ),
                                            ),
                                            TextSpan(
                                              text: _passData!.vereinName,
                                              style:
                                                  UIStyles.bodyStyle.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: UIStyles
                                                        .bodyStyle.fontSize! *
                                                    fontSizeProvider
                                                        .scaleFactor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      else
                        Consumer<FontSizeProvider>(
                          builder: (context, fontSizeProvider, child) {
                            return ScaledText(
                              'Keine Erstvereinsdaten verfügbar.',
                              style: UIStyles.bodyStyle.copyWith(
                                fontSize: UIStyles.bodyStyle.fontSize! *
                                    fontSizeProvider.scaleFactor,
                              ),
                            );
                          },
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Consumer<FontSizeProvider>(
                                          builder: (context, fontSizeProvider,
                                              child,) {
                                            return RichText(
                                              text: TextSpan(
                                                style:
                                                    UIStyles.bodyStyle.copyWith(
                                                  fontSize: UIStyles
                                                          .bodyStyle.fontSize! *
                                                      fontSizeProvider
                                                          .scaleFactor,
                                                ),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text: zve.vVereinNr
                                                        .toString(),
                                                    style: UIStyles.bodyStyle
                                                        .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: UIStyles
                                                              .bodyStyle
                                                              .fontSize! *
                                                          fontSizeProvider
                                                              .scaleFactor,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: ' - ',
                                                    style: UIStyles.bodyStyle
                                                        .copyWith(
                                                      fontSize: UIStyles
                                                              .bodyStyle
                                                              .fontSize! *
                                                          fontSizeProvider
                                                              .scaleFactor,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: zve.vereinName,
                                                    style: UIStyles.bodyStyle
                                                        .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: UIStyles
                                                              .bodyStyle
                                                              .fontSize! *
                                                          fontSizeProvider
                                                              .scaleFactor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (zve.disziplin.isNotEmpty) ...[
                                    const SizedBox(
                                        height: UIConstants.spacingS,),
                                    ...zve.disziplin.map((selectedDisziplin) {
                                      return Consumer<FontSizeProvider>(
                                        builder:
                                            (context, fontSizeProvider, child) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: UIConstants.spacingXS,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ScaledText(
                                                  '• ',
                                                  style: UIStyles.bodyStyle
                                                      .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: UIStyles.bodyStyle
                                                            .fontSize! *
                                                        fontSizeProvider
                                                            .scaleFactor,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: ScaledText(
                                                    '${selectedDisziplin.disziplinNr ?? 'N/A'} - ${selectedDisziplin.disziplin ?? 'N/A'}',
                                                    style: UIStyles.bodyStyle
                                                        .copyWith(
                                                      fontSize: UIStyles
                                                              .bodyStyle
                                                              .fontSize! *
                                                          fontSizeProvider
                                                              .scaleFactor,
                                                    ),
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons
                                                        .delete_outline_outlined,
                                                    color: UIConstants
                                                        .defaultAppColor,
                                                    size: 24 *
                                                        fontSizeProvider
                                                            .scaleFactor,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      final updatedZveData =
                                                          List<PassDataZVE>.from(
                                                              _zveData,);
                                                      final index =
                                                          updatedZveData
                                                              .indexOf(zve);
                                                      if (index != -1) {
                                                        final currentDisciplines =
                                                            List<Disziplin>.from(
                                                                zve.disziplin,);
                                                        currentDisciplines.remove(
                                                            selectedDisziplin,);
                                                        updatedZveData[index] =
                                                            zve.copyWith(
                                                          disziplin:
                                                              currentDisciplines,
                                                        );
                                                        _zveData =
                                                            updatedZveData;
                                                      }
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    }),
                                  ],
                                ],
                              ),
                            );
                          },
                        )
                      else
                        Consumer<FontSizeProvider>(
                          builder: (context, fontSizeProvider, child) {
                            return ScaledText(
                              'Keine Zweitvereine verfügbar.',
                              style: UIStyles.bodyStyle.copyWith(
                                fontSize: UIStyles.bodyStyle.fontSize! *
                                    fontSizeProvider.scaleFactor,
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: UIConstants.spacingM),
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: UIConstants.spacingM),
                        child: Consumer<FontSizeProvider>(
                          builder: (context, fontSizeProvider, child) {
                            return Autocomplete<Disziplin>(
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                if (textEditingValue.text.isEmpty) {
                                  return const Iterable<Disziplin>.empty();
                                }
                                return _disciplines.where((Disziplin option) {
                                  return (option.disziplin?.toLowerCase() ?? '')
                                          .contains(
                                        textEditingValue.text.toLowerCase(),
                                      ) ||
                                      (option.disziplinNr?.toLowerCase() ?? '')
                                          .contains(
                                        textEditingValue.text.toLowerCase(),
                                      );
                                }).take(UIConstants.maxFilteredDisziplinen);
                              },
                              displayStringForOption: (Disziplin option) =>
                                  '${option.disziplinNr ?? 'N/A'} - ${option.disziplin ?? 'N/A'}',
                              fieldViewBuilder: (
                                BuildContext context,
                                TextEditingController textEditingController,
                                FocusNode focusNode,
                                VoidCallback onFieldSubmitted,
                              ) {
                                _autocompleteTextController =
                                    textEditingController;
                                return TextField(
                                  controller: textEditingController,
                                  focusNode: focusNode,
                                  style: UIStyles.bodyStyle.copyWith(
                                    fontSize: UIStyles.bodyStyle.fontSize! *
                                        fontSizeProvider.scaleFactor,
                                  ),
                                  decoration:
                                      UIStyles.formInputDecoration.copyWith(
                                    labelText: 'Disziplin hinzufügen',
                                    labelStyle:
                                        UIStyles.formLabelStyle.copyWith(
                                      fontSize:
                                          UIStyles.formLabelStyle.fontSize! *
                                              fontSizeProvider.scaleFactor,
                                    ),
                                    floatingLabelStyle:
                                        UIStyles.formLabelStyle.copyWith(
                                      fontSize:
                                          UIStyles.formLabelStyle.fontSize! *
                                              fontSizeProvider.scaleFactor,
                                    ),
                                    hintStyle: UIStyles.formLabelStyle.copyWith(
                                      fontSize:
                                          UIStyles.formLabelStyle.fontSize! *
                                              fontSizeProvider.scaleFactor,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      size: 24 * fontSizeProvider.scaleFactor,
                                    ),
                                  ),
                                );
                              },
                              onSelected: (Disziplin selection) {
                                setState(() {
                                  if (_zveData.isNotEmpty) {
                                    final updatedZveData =
                                        List<PassDataZVE>.from(_zveData);
                                    final firstZve = updatedZveData[0];
                                    final currentDisciplines =
                                        List<Disziplin>.from(
                                            firstZve.disziplin,);
                                    if (!currentDisciplines
                                        .contains(selection)) {
                                      currentDisciplines.add(selection);
                                      updatedZveData[0] = firstZve.copyWith(
                                        disziplin: currentDisciplines,
                                      );
                                      _zveData = updatedZveData;
                                    }
                                  }
                                });
                                _autocompleteTextController.clear();
                              },
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
