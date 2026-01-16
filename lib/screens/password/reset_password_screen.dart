import 'package:flutter/material.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/screens/password/password_reset_fail_screen.dart';
import 'package:meinbssb/screens/password/password_reset_success_screen.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:provider/provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    required this.apiService,
    required this.token,
    required this.personId,
    super.key,
  });

  final String token;
  final String personId;
  final ApiService apiService;
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _tokenValid = false;
  bool _loading = true;
  String? _error;
  String? _success;
  double _strength = 0;
  bool _showPassword = false;
  bool _showConfirm = false;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  void _failAndExit(String message) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (_) => PasswordResetFailScreen(message: message, userData: null),
      ),
    );
  }

  Future<void> _checkToken() async {
    final entry = await widget.apiService
        .getUserByPasswordResetVerificationToken(widget.token);
    if (entry != null) {
      // Check if personId matches
      final dynamic entryPersonId = entry['person_id'];
      if (entryPersonId == null ||
          entryPersonId.toString() != widget.personId) {
        _failAndExit('Ungültiger Link: PersonID stimmt nicht überein.');
        return;
      }

      // Check if already verified
      if (entry['is_used'] == true) {
        _failAndExit(
          // ignore: require_trailing_commas
          'Dieser Link wurde bereits verwendet. Bitte versuchen Sie erneut.',
        );
        return;
      }
      // Check if verified_at is older than 24 hours
      if (entry['created_at'] != null &&
          entry['created_at'].toString().isNotEmpty) {
        final verifiedAt = DateTime.tryParse(entry['created_at']);
        if (verifiedAt != null &&
            DateTime.now().difference(verifiedAt).inHours > 24) {
          _failAndExit('Der Link ist abgelaufen.');
          return;
        }
      }
      setState(() {
        _tokenValid = true;
        _loading = false;
      });
      return;
    }
    _failAndExit('Ungültiger oder abgelaufener Link.');
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Bitte Passwort eingeben';
    if (value.length < 8) return 'Mindestens 8 Zeichen';
    // Allowed uppercase letters: A-Z, Ä, Ö, Ü
    if (!RegExp(r'[A-ZÄÖÜ]').hasMatch(value)) return 'Mind. 1 Großbuchstabe';
    // Allowed lowercase letters: a-z, ä, ö, ü
    if (!RegExp(r'[a-zäöü]').hasMatch(value)) return 'Mind. 1 Kleinbuchstabe';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Mind. 1 Zahl';
    // Allowed special characters: ! # $ % & * ( ) - + = { } [ ] : ; , . ?
    if (!RegExp('[!#\\\$%&*()\\-+=\\{\\}\\[\\]:;,.?]').hasMatch(value)) {
      return 'Mind. 1 Sonderzeichen';
    }
    // Check for invalid characters (only allow: A-Z, a-z, Ä, Ö, Ü, ä, ö, ü, 0-9, and allowed special chars)
    if (RegExp('[^A-Za-zÄÖÜäöü0-9!#\\\$%&*()\\-+=\\{\\}\\[\\]:;,.?]').hasMatch(value)) {
      return 'Nur erlaubte Zeichen verwenden';
    }
    return null;
  }

  void _checkStrength(String value) {
    double strength = 0;
    if (value.length >= 8) strength += 0.25;
    // Allowed uppercase letters: A-Z, Ä, Ö, Ü
    if (RegExp(r'[A-ZÄÖÜ]').hasMatch(value)) strength += 0.25;
    // Allowed lowercase letters: a-z, ä, ö, ü
    if (RegExp(r'[a-zäöü]').hasMatch(value)) strength += 0.15;
    if (RegExp(r'[0-9]').hasMatch(value)) strength += 0.15;
    // Allowed special characters: ! # $ % & * ( ) - + = { } [ ] : ; , . ?
    if (RegExp('[!#\\\$%&*()\\-+=\\{\\}\\[\\]:;,.?]').hasMatch(value)) strength += 0.2;
    setState(() => _strength = strength);
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmController.text) {
      setState(() => _error = 'Passwörter stimmen nicht überein');
      return;
    }
    setState(() => _loading = true);

    try {
      // Call the password reset method from AuthService
      final result = await widget.apiService.finalizeResetPassword(
        widget.token,
        widget.personId,
        _passwordController.text,
      );

      setState(() => _loading = false);

      if (!mounted) return;

      if (result['success'] == true) {
        // Success case
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (_) => const PasswordResetSuccessScreen(
                  message: 'Passwort wurde erfolgreich zurückgesetzt.',
                  userData: null,
                ),
          ),
        );
      } else {
        // Failure case
        _failAndExit('Fehler beim Zurücksetzen des Passworts.');
      }
    } catch (e) {
      setState(() => _loading = false);
      _failAndExit('Fehler beim Zurücksetzen des Passworts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_tokenValid) {
      return Center(
        child: Text(_error ?? 'Ungültiger Link', style: UIStyles.errorStyle),
      );
    }

    final FontSizeProvider fontSizeProvider = Provider.of<FontSizeProvider>(
      context,
    );
    return BaseScreenLayout(
      title: 'Passwort zurücksetzen',
      userData: null,
      isLoggedIn: false,
      onLogout: () {},
      body: Semantics(
        label:
            'Passwort zurücksetzen Formular. Bitte vergeben Sie ein neues sicheres Passwort und bestätigen Sie es, um Ihr Passwort zurückzusetzen.',
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: UIConstants.spacingM,
                    ),
                    child: ScaledText(
                      _error!,
                      style: UIStyles.errorStyle.copyWith(
                        color: UIConstants.errorColor,
                      ),
                    ),
                  ),
                if (_success != null)
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: UIConstants.spacingM,
                    ),
                    child: ScaledText(
                      _success!,
                      style: UIStyles.successStyle.copyWith(
                        color: UIConstants.successColor,
                      ),
                    ),
                  ),
                const ScaledText(
                  'Bitte vergeben Sie ein neues sicheres Passwort:',
                  style: UIStyles.bodyStyle,
                ),
                const SizedBox(height: UIConstants.spacingS),
                Focus(
                  child: Semantics(
                    label: 'Eingabefeld für neues Passwort',
                    hint:
                        'Mindestens 8 Zeichen, 1 Großbuchstabe (A...Z, Ä, Ö, Ü), 1 Kleinbuchstabe (a...z, ä, ö, ü), 1 Zahl (0...9), 1 Sonderzeichen (! # \$ % & * ( ) - + = { } [ ] : ; , . ?)',
                    textField: true,
                    child: TextFormField(
                      controller: _passwordController,
                      style: UIStyles.formValueStyle.copyWith(
                        fontSize:
                            UIStyles.formValueStyle.fontSize! *
                            fontSizeProvider.scaleFactor,
                      ),
                      obscureText: !_showPassword,
                      decoration: UIStyles.formInputDecoration.copyWith(
                        labelText: 'Neues Passwort',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          tooltip: 'Passwort anzeigen/verbergen',
                          onPressed:
                              () => setState(
                                () => _showPassword = !_showPassword,
                              ),
                        ),
                      ),
                      validator: _validatePassword,
                      onChanged: _checkStrength,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(
                    top: 4.0,
                    bottom: UIConstants.spacingS,
                  ),
                  child: ScaledText(
                    'Mindestens 8 Zeichen, 1 Großbuchstabe (A...Z, Ä, Ö, Ü), 1 Kleinbuchstabe (a...z, ä, ö, ü), 1 Zahl (0...9), 1 Sonderzeichen (! # \$ % & * ( ) - + = { } [ ] : ; , . ?)',
                    style: UIStyles.formLabelStyle,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: _strength,
                        minHeight: 6,
                        backgroundColor: UIConstants.greySubtitleTextColor,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _strengthColor(_strength),
                        ),
                      ),
                    ),
                    const SizedBox(width: UIConstants.spacingS),
                    ScaledText(
                      _strengthLabel(_strength),
                      style: UIStyles.bodyStyle.copyWith(
                        color: _strengthColor(_strength),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: UIConstants.spacingM),
                Focus(
                  child: Semantics(
                    label: 'Eingabefeld für Passwort-Wiederholung',
                    hint:
                        'Bitte wiederholen Sie Ihr neues Passwort zur Bestätigung.',
                    textField: true,
                    child: TextFormField(
                      controller: _confirmController,
                      style: UIStyles.formValueStyle.copyWith(
                        fontSize:
                            UIStyles.formValueStyle.fontSize! *
                            fontSizeProvider.scaleFactor,
                      ),
                      obscureText: !_showConfirm,
                      decoration: UIStyles.formInputDecoration.copyWith(
                        labelText: 'Passwort wiederholen',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          tooltip: 'Passwort anzeigen/verbergen',

                          onPressed:
                              () =>
                                  setState(() => _showConfirm = !_showConfirm),
                        ),
                      ),
                      validator:
                          (v) =>
                              v != _passwordController.text
                                  ? 'Passwörter stimmen nicht überein'
                                  : null,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Focus(
                  child: Semantics(
                    label: 'Passwort zurücksetzen Button',
                    hint:
                        'Tippen, um das neue Passwort zu speichern und den Vorgang abzuschließen.',
                    button: true,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: UIStyles.defaultButtonStyle,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lock_reset, color: Colors.white),
                            SizedBox(width: UIConstants.spacingS),
                            ScaledText(
                              'Passwort zurücksetzen',
                              style: UIStyles.buttonStyle,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
