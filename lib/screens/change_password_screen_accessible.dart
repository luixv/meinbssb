import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/messages.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/screens/base_screen_layout_accessible.dart';
import 'package:meinbssb/screens/change_password_success_screen.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/core/cache_service.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/widgets/scaled_text.dart';

/// BITV 2.0 konforme Version des Passwort-Änderungsbildschirms
///
/// Erfüllt deutsche Barrierefreiheitsstandards (BITV 2.0/WCAG 2.1 Level AA):
/// - Vollständige Semantik-Unterstützung für Screen Reader
/// - Deutsche Sprachanpassung für Accessibility
/// - Live-Region-Ankündigungen für Validierung
/// - Autocomplete-Unterstützung für Passwort-Manager
/// - Strukturelle Kennzeichnung von Formularelementen
/// - Zugängliche Passwort-Sichtbarkeits-Kontrollen
/// - Accessible Passwort-Stärke-Anzeige
class ChangePasswordScreenAccessible extends StatefulWidget {
  const ChangePasswordScreenAccessible({
    super.key,
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
  });

  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  State<ChangePasswordScreenAccessible> createState() =>
      _ChangePasswordScreenAccessibleState();
}

class _ChangePasswordScreenAccessibleState
    extends State<ChangePasswordScreenAccessible> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Focus Nodes für bessere Accessibility
  final _currentPasswordFocusNode = FocusNode();
  final _newPasswordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _saveButtonFocusNode = FocusNode();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  double _strength = 0;

  // Passwort-Anforderungen Tracking für Accessibility
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();

    // Announce screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SemanticsService.announce(
        'Passwort ändern Bildschirm geladen. Geben Sie Ihr aktuelles Passwort ein und erstellen Sie ein neues sicheres Passwort.',
        TextDirection.ltr,
      );
    });
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _currentPasswordFocusNode.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _saveButtonFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    // Announce save attempt
    SemanticsService.announce(
      'Passwort-Änderung wird verarbeitet. Bitte warten.',
      TextDirection.ltr,
    );

    if (!_formKey.currentState!.validate()) {
      SemanticsService.announce(
        'Formular-Validierung fehlgeschlagen. Bitte überprüfen Sie Ihre Eingaben.',
        TextDirection.ltr,
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final personId = widget.userData?.personId;
      final apiService = Provider.of<ApiService>(context, listen: false);
      final cacheService = Provider.of<CacheService>(context, listen: false);

      if (personId == null) {
        throw Exception(Messages.personIdMissing);
      }

      // Get username from cache
      final username = await cacheService.getString('username');
      if (username == null) {
        throw Exception(Messages.usernameNotFound);
      }

      // First, validate the current password
      final loginResponse = await apiService.login(
        username,
        _currentPasswordController.text,
      );

      if (loginResponse['ResultType'] != 1) {
        if (!mounted) return;
        _showPasswordIncorrectSnackbar();
        return;
      }

      // If current password is valid, proceed with password change
      final result = await apiService.changePassword(
        personId,
        _newPasswordController.text,
      );

      if (!mounted) return;
      _navigateToResultScreen(result['result'] == true);
    } catch (e) {
      if (!mounted) return;
      _navigateToResultScreen(false);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showPasswordIncorrectSnackbar() {
    // Announce error to screen readers
    SemanticsService.announce(
      'Fehler: Das aktuelle Passwort ist nicht korrekt. Bitte versuchen Sie es erneut.',
      TextDirection.ltr,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Semantics(
          liveRegion: true,
          label: 'Fehlermeldung: Aktuelles Passwort ist nicht korrekt',
          child: const Text(Messages.currentPasswordIncorrect),
        ),
        backgroundColor: UIConstants.errorColor,
        action: SnackBarAction(
          label: 'Schließen',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _navigateToResultScreen(bool success) {
    final message = success
        ? 'Passwort erfolgreich geändert. Sie werden zur Bestätigungsseite weitergeleitet.'
        : 'Passwort-Änderung fehlgeschlagen. Sie werden zur Ergebnisseite weitergeleitet.';

    SemanticsService.announce(message, TextDirection.ltr);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ChangePasswordSuccessScreen(
          success: success,
          userData: widget.userData,
          isLoggedIn: widget.isLoggedIn,
          onLogout: widget.onLogout,
        ),
      ),
    );
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      const error = 'Bitte Passwort eingeben';
      _announceValidationError(error);
      return error;
    }
    if (value.length < 8) {
      const error = 'Mindestens 8 Zeichen erforderlich';
      _announceValidationError(error);
      return error;
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      const error = 'Mindestens 1 Großbuchstabe erforderlich';
      _announceValidationError(error);
      return error;
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      const error = 'Mindestens 1 Kleinbuchstabe erforderlich';
      _announceValidationError(error);
      return error;
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      const error = 'Mindestens 1 Zahl erforderlich';
      _announceValidationError(error);
      return error;
    }
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
      const error = 'Mindestens 1 Sonderzeichen erforderlich';
      _announceValidationError(error);
      return error;
    }
    return null;
  }

  void _announceValidationError(String error) {
    Future.microtask(() {
      if (mounted) {
        SemanticsService.announce(
          'Passwort-Validierungsfehler: $error',
          TextDirection.ltr,
        );
      }
    });
  }

  void _checkStrength(String value) {
    double strength = 0;
    _hasMinLength = value.length >= 8;
    _hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
    _hasLowercase = RegExp(r'[a-z]').hasMatch(value);
    _hasNumber = RegExp(r'[0-9]').hasMatch(value);
    _hasSpecialChar = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value);

    if (_hasMinLength) strength += 0.25;
    if (_hasUppercase) strength += 0.25;
    if (_hasLowercase) strength += 0.15;
    if (_hasNumber) strength += 0.15;
    if (_hasSpecialChar) strength += 0.2;

    final oldStrength = _strength;
    setState(() => _strength = strength);

    // Announce strength changes
    if (_strength != oldStrength) {
      final strengthLabel = _strengthLabel(_strength);
      Future.microtask(() {
        if (mounted) {
          SemanticsService.announce(
            'Passwort-Stärke geändert zu: $strengthLabel',
            TextDirection.ltr,
          );
        }
      });
    }
  }

  String _strengthLabel(double value) {
    if (value < 0.4) return 'Schwach';
    if (value < 0.7) return 'Mittel';
    return 'Stark';
  }

  Color _strengthColor(double value) {
    if (value < 0.4) return UIConstants.errorColor;
    if (value < 0.7) return UIConstants.warningColor;
    return UIConstants.successColor;
  }

  IconData _strengthIcon(double value) {
    if (value < 0.4) return Icons.warning;
    if (value < 0.7) return Icons.info;
    return Icons.check_circle;
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayoutAccessible(
      title: 'Neues Passwort erstellen',
      userData: widget.userData,
      isLoggedIn: widget.isLoggedIn,
      onLogout: widget.onLogout,
      automaticallyImplyLeading: true,
      semanticScreenLabel: 'Passwort ändern',
      screenDescription:
          'Bildschirm zum Ändern des Benutzerpassworts mit Sicherheitsanforderungen',
      body: Consumer<FontSizeProvider>(
        builder: (context, fontSizeProvider, child) {
          return SingleChildScrollView(
            padding: UIConstants.defaultPadding,
            child: Semantics(
              container: true,
              label: 'Passwort ändern Formular',
              hint:
                  'Eingabebereich für aktuelles und neues Passwort mit Sicherheitsanforderungen',
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Error message with live region
                    if (_errorMessage != null)
                      Semantics(
                        liveRegion: true,
                        label: 'Fehlermeldung',
                        child: Padding(
                          padding: const EdgeInsets.only(
                            bottom: UIConstants.spacingM,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: UIConstants.errorColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: UIConstants.errorColor),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: UIConstants.errorColor,
                                  semanticLabel: 'Fehler-Symbol',
                                ),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: ScaledText(
                                    _errorMessage!,
                                    style: UIStyles.errorStyle.copyWith(
                                      fontSize: UIStyles.errorStyle.fontSize! *
                                          fontSizeProvider.scaleFactor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Current password field
                    _buildAccessiblePasswordField(
                      controller: _currentPasswordController,
                      focusNode: _currentPasswordFocusNode,
                      label: 'Aktuelles Passwort',
                      isVisible: _isCurrentPasswordVisible,
                      onToggleVisibility: () {
                        setState(() {
                          _isCurrentPasswordVisible =
                              !_isCurrentPasswordVisible;
                        });
                        SemanticsService.announce(
                          _isCurrentPasswordVisible
                              ? 'Aktuelles Passwort ist jetzt sichtbar'
                              : 'Aktuelles Passwort ist jetzt verborgen',
                          TextDirection.ltr,
                        );
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          const error =
                              'Bitte geben Sie Ihr aktuelles Passwort ein';
                          _announceValidationError(error);
                          return error;
                        }
                        return null;
                      },
                      fontSizeProvider: fontSizeProvider,
                      autocompleteHints: const [AutofillHints.password],
                      nextFocusNode: _newPasswordFocusNode,
                    ),

                    const SizedBox(height: UIConstants.spacingM),

                    // New password field
                    _buildAccessiblePasswordField(
                      controller: _newPasswordController,
                      focusNode: _newPasswordFocusNode,
                      label: 'Neues Passwort',
                      isVisible: _isNewPasswordVisible,
                      onToggleVisibility: () {
                        setState(() {
                          _isNewPasswordVisible = !_isNewPasswordVisible;
                        });
                        SemanticsService.announce(
                          _isNewPasswordVisible
                              ? 'Neues Passwort ist jetzt sichtbar'
                              : 'Neues Passwort ist jetzt verborgen',
                          TextDirection.ltr,
                        );
                      },
                      validator: _validatePassword,
                      fontSizeProvider: fontSizeProvider,
                      autocompleteHints: const [AutofillHints.newPassword],
                      onChanged: _checkStrength,
                      nextFocusNode: _confirmPasswordFocusNode,
                    ),

                    const SizedBox(height: UIConstants.spacingS),

                    // Password requirements
                    _buildPasswordRequirements(fontSizeProvider),

                    const SizedBox(height: UIConstants.spacingS),

                    // Password strength indicator
                    _buildPasswordStrengthIndicator(fontSizeProvider),

                    const SizedBox(height: UIConstants.spacingM),

                    // Confirm password field
                    _buildAccessiblePasswordField(
                      controller: _confirmPasswordController,
                      focusNode: _confirmPasswordFocusNode,
                      label: 'Neues Passwort wiederholen',
                      isVisible: _isConfirmPasswordVisible,
                      onToggleVisibility: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                        SemanticsService.announce(
                          _isConfirmPasswordVisible
                              ? 'Passwort-Wiederholung ist jetzt sichtbar'
                              : 'Passwort-Wiederholung ist jetzt verborgen',
                          TextDirection.ltr,
                        );
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          const error =
                              'Bitte wiederholen Sie das neue Passwort';
                          _announceValidationError(error);
                          return error;
                        }
                        if (value != _newPasswordController.text) {
                          const error = 'Die Passwörter stimmen nicht überein';
                          _announceValidationError(error);
                          return error;
                        }
                        return null;
                      },
                      fontSizeProvider: fontSizeProvider,
                      autocompleteHints: const [AutofillHints.newPassword],
                      nextFocusNode: _saveButtonFocusNode,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: _buildAccessibleSaveButton(),
    );
  }

  Widget _buildAccessiblePasswordField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    required FontSizeProvider fontSizeProvider,
    String? Function(String?)? validator,
    List<String>? autocompleteHints,
    void Function(String)? onChanged,
    FocusNode? nextFocusNode,
  }) {
    return Semantics(
      textField: true,
      label: 'Passwort-Eingabefeld: $label',
      hint:
          'Eingabe des Passworts. Verwenden Sie die Schaltfläche rechts um die Sichtbarkeit umzuschalten.',
      obscured: !isVisible,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: !isVisible,
        autofillHints: autocompleteHints,
        textInputAction:
            nextFocusNode != null ? TextInputAction.next : TextInputAction.done,
        onFieldSubmitted: (_) {
          if (nextFocusNode != null) {
            nextFocusNode.requestFocus();
          } else {
            _handleSave();
          }
        },
        style: UIStyles.formValueStyle.copyWith(
          fontSize:
              UIStyles.formValueStyle.fontSize! * fontSizeProvider.scaleFactor,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: UIStyles.formInputDecoration.labelStyle?.copyWith(
            fontSize: UIStyles.formInputDecoration.labelStyle!.fontSize! *
                fontSizeProvider.scaleFactor,
          ),
          floatingLabelStyle:
              UIStyles.formInputDecoration.floatingLabelStyle?.copyWith(
            fontSize:
                UIStyles.formInputDecoration.floatingLabelStyle!.fontSize! *
                    fontSizeProvider.scaleFactor,
          ),
          errorStyle: UIStyles.errorStyle.copyWith(
            fontSize:
                UIStyles.errorStyle.fontSize! * fontSizeProvider.scaleFactor,
          ),
          border: const OutlineInputBorder(),
          suffixIcon: Semantics(
            button: true,
            label:
                '${isVisible ? "Passwort verbergen" : "Passwort anzeigen"} für $label',
            hint: 'Schaltet die Sichtbarkeit des Passworts um',
            child: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility_off : Icons.visibility,
                color: UIConstants.textColor,
                semanticLabel:
                    isVisible ? 'Passwort verbergen' : 'Passwort anzeigen',
              ),
              onPressed: onToggleVisibility,
              tooltip: isVisible ? 'Passwort verbergen' : 'Passwort anzeigen',
            ),
          ),
        ),
        validator: validator,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildPasswordRequirements(FontSizeProvider fontSizeProvider) {
    return Semantics(
      readOnly: true,
      label: 'Passwort-Anforderungen',
      hint: 'Liste der Kriterien die das neue Passwort erfüllen muss',
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue.shade700,
                  size: 20,
                  semanticLabel: 'Informations-Symbol',
                ),
                const SizedBox(width: 8),
                Text(
                  'Passwort-Anforderungen:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade800,
                    fontSize: 16.0 * fontSizeProvider.scaleFactor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildRequirement(
                'Mindestens 8 Zeichen', _hasMinLength, fontSizeProvider,),
            _buildRequirement(
                '1 Großbuchstabe', _hasUppercase, fontSizeProvider,),
            _buildRequirement(
                '1 Kleinbuchstabe', _hasLowercase, fontSizeProvider,),
            _buildRequirement('1 Zahl', _hasNumber, fontSizeProvider),
            _buildRequirement(
                '1 Sonderzeichen', _hasSpecialChar, fontSizeProvider,),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirement(
      String text, bool fulfilled, FontSizeProvider fontSizeProvider,) {
    return Semantics(
      label: '$text: ${fulfilled ? "erfüllt" : "nicht erfüllt"}',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          children: [
            Icon(
              fulfilled ? Icons.check_circle : Icons.radio_button_unchecked,
              color: fulfilled
                  ? UIConstants.successColor
                  : UIConstants.greySubtitleTextColor,
              size: 16,
              semanticLabel: fulfilled ? 'Erfüllt' : 'Nicht erfüllt',
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: fulfilled
                    ? UIConstants.successColor
                    : UIConstants.greySubtitleTextColor,
                fontSize: 14.0 * fontSizeProvider.scaleFactor,
                fontWeight: fulfilled ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator(FontSizeProvider fontSizeProvider) {
    return Semantics(
      liveRegion: true,
      label: 'Passwort-Stärke-Anzeige',
      value: 'Aktuelle Stärke: ${_strengthLabel(_strength)}',
      hint: 'Zeigt die Sicherheitsstärke des neuen Passworts an',
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: _strengthColor(_strength).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: _strengthColor(_strength).withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _strengthIcon(_strength),
                  color: _strengthColor(_strength),
                  size: 20,
                  semanticLabel: 'Passwort-Stärke-Symbol',
                ),
                const SizedBox(width: 8),
                Text(
                  'Passwort-Stärke:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.0 * fontSizeProvider.scaleFactor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: _strength,
                    minHeight: 8,
                    backgroundColor:
                        UIConstants.greySubtitleTextColor.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                        _strengthColor(_strength),),
                    semanticsLabel: 'Passwort-Stärke Fortschrittsbalken',
                  ),
                ),
                const SizedBox(width: UIConstants.spacingS),
                Icon(
                  _strengthIcon(_strength),
                  color: _strengthColor(_strength),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _strengthLabel(_strength),
                  style: TextStyle(
                    color: _strengthColor(_strength),
                    fontWeight: FontWeight.w600,
                    fontSize: 14.0 * fontSizeProvider.scaleFactor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessibleSaveButton() {
    return Semantics(
      button: true,
      enabled: !_isLoading,
      label: _isLoading
          ? 'Passwort wird gespeichert, bitte warten'
          : 'Passwort speichern',
      hint: _isLoading
          ? 'Vorgang läuft, bitte warten Sie auf die Bestätigung'
          : 'Speichert das neue Passwort nach erfolgreicher Validierung aller Felder',
      child: FloatingActionButton(
        heroTag: 'save_password_accessible',
        focusNode: _saveButtonFocusNode,
        onPressed: _isLoading ? null : _handleSave,
        backgroundColor: _isLoading
            ? UIConstants.greySubtitleTextColor
            : UIConstants.defaultAppColor,
        tooltip: _isLoading ? 'Speichern läuft...' : 'Passwort speichern',
        child: _isLoading
            ? Semantics(
                label: 'Passwort wird gespeichert, Ladekreis',
                child: const CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(UIConstants.whiteColor),
                  strokeWidth: UIConstants.defaultStrokeWidth,
                ),
              )
            : const Icon(
                Icons.save,
                color: UIConstants.whiteColor,
                semanticLabel: 'Speichern-Symbol',
              ),
      ),
    );
  }
}
