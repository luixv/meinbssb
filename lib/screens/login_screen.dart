import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/constants/messages.dart';

import 'package:meinbssb/screens/registration/registration_screen.dart';
import 'package:meinbssb/screens/password/password_reset_screen.dart';
import 'package:meinbssb/screens/logo_widget.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/core/logger_service.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({required this.onLoginSuccess, this.logoWidget, super.key});
  final Function(UserData) onLoginSuccess;
  final Widget? logoWidget;

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _loginButtonFocusNode = FocusNode();
  final FocusNode _checkboxFocusNode = FocusNode();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String _errorMessage = '';
  final Color _appColor = UIConstants.defaultAppColor;
  UserData? _userData;
  bool _isLoggedIn = false;
  bool _rememberMe = false;
  bool _hasLoginButtonKeyboardFocus = false;
  bool _hasCheckboxKeyboardFocus = false;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  @override
  void initState() {
    super.initState();
    _initRememberMe();
    _loginButtonFocusNode.addListener(_onLoginButtonFocusChange);
    _checkboxFocusNode.addListener(_onCheckboxFocusChange);
  }

  Future<void> _initRememberMe() async {
    await _loadRememberMeState();
    if (_rememberMe) {
      await _loadStoredCredentials();
    }
  }

  Future<void> _loadRememberMeState() async {
    final prefs = await SharedPreferences.getInstance();
    _rememberMe = prefs.getBool('rememberMe') ?? false;
  }

  Future<void> _loadStoredCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('savedEmail');
    final savedPassword = await _secureStorage.read(
      key: 'saved_password_remember_me',
    );

    setState(() {
      if (savedEmail != null && savedEmail.isNotEmpty) {
        _emailController.text = savedEmail;
        // Set cursor position to the end of the text
        _emailController.selection = TextSelection.fromPosition(
          TextPosition(offset: _emailController.text.length),
        );
      }
      if (savedPassword != null && savedPassword.isNotEmpty) {
        _passwordController.text = savedPassword;
        // Set cursor position to the end of the text
        _passwordController.selection = TextSelection.fromPosition(
          TextPosition(offset: _passwordController.text.length),
        );
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _loginButtonFocusNode.removeListener(_onLoginButtonFocusChange);
    _checkboxFocusNode.removeListener(_onCheckboxFocusChange);
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _loginButtonFocusNode.dispose();
    _checkboxFocusNode.dispose();
    super.dispose();
  }

  void _onLoginButtonFocusChange() {
    final isKeyboardMode =
        FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
    setState(() {
      _hasLoginButtonKeyboardFocus =
          _loginButtonFocusNode.hasFocus && isKeyboardMode;
    });
  }

  void _onCheckboxFocusChange() {
    final isKeyboardMode =
        FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
    setState(() {
      _hasCheckboxKeyboardFocus = _checkboxFocusNode.hasFocus && isKeyboardMode;
    });
  }

  Future<void> _handleLogin() async {
    final apiService = Provider.of<ApiService>(context, listen: false);

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // Save remember me state before attempting login
    await _saveRememberMeState();

    try {
      final response = await apiService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      LoggerService.logInfo('Login response: $response');

      if (response['ResultType'] == 1) {
        await _handleSuccessfulLogin(
          apiService,
          response['PersonID'],
          response['WebLoginID'],
        );
      } else {
        setState(() => _errorMessage = Messages.loginFailed);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSuccessfulLogin(
    ApiService apiService,
    int personId,
    int webloginId,
  ) async {
    LoggerService.logInfo('Retrieving passdaten');
    var passdaten = await apiService.fetchPassdaten(personId);
    LoggerService.logInfo('User data: $passdaten');

    if (!mounted) return;

    if (passdaten != null) {
      _userData = passdaten.copyWith(webLoginId: webloginId);
      _isLoggedIn = true;
      widget.onLoginSuccess(_userData!);

      // Save credentials if Remember Me is checked (after successful login)
      if (_rememberMe) {
        await _saveRememberMeCredentials();
      }

      apiService.fetchSchuetzenausweis(personId);
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: {'userData': _userData!.toJson(), 'isLoggedIn': true},
      );
    } else {
      setState(() => _errorMessage = 'Fehler beim Laden der Passdaten.');
    }
  }

  void _navigateToRegistrationPage() {
    final apiService = Provider.of<ApiService>(context, listen: false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistrationScreen(apiService: apiService),
      ),
    );
  }

  Future<void> _navigateToPasswordReset() async {
    if (!mounted) return;
    final apiService = Provider.of<ApiService>(context, listen: false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => PasswordResetScreen(
              apiService: apiService,
              userData: _userData,
              isLoggedIn: _isLoggedIn,
              onLogout: _handleLogout,
            ),
      ),
    );
  }

  void _handleLogout() async {
    // Clear stored credentials when logging out
    await _clearStoredCredentials();

    setState(() {
      _isLoggedIn = false;
      _userData = null;
    });
    // Navigation is handled by the app's logout handler
  }

  Future<void> _saveRememberMeCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', true);
    await prefs.setString('savedEmail', _emailController.text);
    // Save password to secure storage with separate key for remember me functionality
    await _secureStorage.write(
      key: 'saved_password_remember_me',
      value: _passwordController.text,
    );
    LoggerService.logInfo('Remember Me credentials saved successfully.');
  }

  Future<void> _saveRememberMeState() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setBool('rememberMe', true);
      await prefs.setString('savedEmail', _emailController.text);
      // Save password to secure storage with separate key for remember me functionality
      await _secureStorage.write(
        key: 'saved_password_remember_me',
        value: _passwordController.text,
      );
    } else {
      await prefs.setBool('rememberMe', false);
      await prefs.remove('savedEmail');
      // Clear password from secure storage when "remember me" is disabled
      await _secureStorage.delete(key: 'saved_password_remember_me');
    }
  }

  Future<void> _clearStoredCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('rememberMe');
    await prefs.remove('savedEmail');
    await _secureStorage.delete(key: 'saved_password_remember_me');
  }

  Widget _buildEmailField() {
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, child) {
        return Semantics(
          label: 'E-Mail Eingabefeld',
          hint: 'Geben Sie Ihre E-Mail Adresse ein',
          textField: true,
          child: TextField(
            key: const Key('usernameField'),
            controller: _emailController,
            focusNode: _emailFocusNode,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            enableInteractiveSelection: true,
            enableSuggestions: true,
            autocorrect: false,
            style: UIStyles.formValueStyle.copyWith(
              fontSize:
                  UIStyles.formValueStyle.fontSize! *
                  fontSizeProvider.scaleFactor,
            ),
            decoration: UIStyles.formInputDecoration.copyWith(
              labelText: 'E-mail',
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              labelStyle: UIStyles.formLabelStyle.copyWith(
                fontSize:
                    UIStyles.formLabelStyle.fontSize! *
                    fontSizeProvider.scaleFactor,
              ),
            ),
            onEditingComplete: () {
              // Move focus to password field when Tab is pressed
              _passwordFocusNode.requestFocus();
            },
            onSubmitted: (value) {
              // Move focus to password field when Enter is pressed
              _passwordFocusNode.requestFocus();
            },
          ),
        );
      },
    );
  }

  Widget _buildPasswordField() {
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, child) {
        return Semantics(
          label: 'Passwort Eingabefeld',
          hint:
              'Geben Sie Ihr Passwort ein. Sichtbarkeit kann mit dem Symbol geändert werden.',
          textField: true,
          child: TextField(
            key: const Key('passwordField'),
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            obscureText: !_isPasswordVisible,
            textInputAction: TextInputAction.done,
            style: UIStyles.formLabelStyle.copyWith(
              fontSize:
                  UIStyles.formLabelStyle.fontSize! *
                  fontSizeProvider.scaleFactor,
            ),
            decoration: UIStyles.formInputDecoration.copyWith(
              labelText: 'Passwort',
              labelStyle: UIStyles.formLabelStyle.copyWith(
                fontSize:
                    UIStyles.formLabelStyle.fontSize! *
                    fontSizeProvider.scaleFactor,
              ),
              suffixIcon: Semantics(
                label:
                    _isPasswordVisible
                        ? 'Passwort verbergen'
                        : 'Passwort anzeigen',
                hint: 'Tippen, um die Passwort-Sichtbarkeit zu ändern',
                button: true,
                child: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  tooltip: 'Passwort anzeigen/verbergen',
                  onPressed: () {
                    if (mounted) {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    }
                  },
                ),
              ),
            ),
            onSubmitted: (value) => _handleLogin(),
          ),
        );
      },
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        key: const Key('loginButton'),
        onPressed: _isLoading ? null : _handleLogin,
        style: UIStyles.defaultButtonStyle,
        child: SizedBox(
          height:
              UIConstants
                  .defaultButtonHeight, // Match the minimumSize height from defaultButtonStyle
          child: Center(
            child:
                _isLoading
                    ? UIConstants.defaultLoadingIndicator
                    : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login, color: UIConstants.whiteColor),
                        SizedBox(width: UIConstants.spacingS),
                        ScaledText(
                          Messages.loginButtonLabel,
                          style: UIStyles.buttonStyle,
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return TextButton(
      key: const Key('forgotPasswordButton'),
      onPressed: _navigateToPasswordReset,
      style: UIStyles.textButtonStyle,
      child: const ScaledText(
        Messages.forgotPasswordLabel,
        style: UIStyles.linkStyle,
      ),
    );
  }

  Widget _buildHelpButton() {
    return TextButton(
      key: const Key('helpButton'),
      onPressed: () {
        Navigator.pushNamed(context, '/help');
      },
      style: UIStyles.textButtonStyle,
      child: const ScaledText(Messages.helpTitle, style: UIStyles.linkStyle),
    );
  }

  Widget _buildRegisterButton() {
    return TextButton(
      key: const Key('registerButton'),
      onPressed: _navigateToRegistrationPage,
      style: UIStyles.textButtonStyle,
      child: const ScaledText(
        Messages.registerButtonLabel,
        style: UIStyles.linkStyle,
      ),
    );
  }

  Widget _buildRememberMeCheckbox() {
    return Focus(
      focusNode: _checkboxFocusNode,
      child: Semantics(
        label: 'Angemeldet bleiben',
        hint:
            'Aktivieren, um beim nächsten Start automatisch eingeloggt zu bleiben',
        value: _rememberMe ? 'Aktiviert' : 'Nicht aktiviert',
        toggled: _rememberMe,
        child: Container(
          decoration:
              _hasCheckboxKeyboardFocus
                  ? BoxDecoration(
                    border: Border.all(
                      color: Colors.yellow.shade700,
                      width: 3.0,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  )
                  : null,
          child: InkWell(
            onTap: () {
              setState(() {
                _rememberMe = !_rememberMe;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (bool? value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                  activeColor: _appColor,
                ),
                const ScaledText(
                  'Angemeldet bleiben',
                  style: UIStyles.bodyStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Padding(
              padding: UIConstants.screenPadding,
              child: Semantics(
                label:
                    'Login-Bereich. Geben Sie Ihre Anmeldedaten ein, um sich anzumelden.',
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExcludeSemantics(
                      child: widget.logoWidget ?? const LogoWidget(),
                    ),
                    const SizedBox(height: UIConstants.spacingS),
                    Semantics(
                      header: true,
                      label: '${Messages.loginTitle}, Überschrift',
                      hint: 'Login-Bereich für registrierte Nutzer',
                      child: ScaledText(
                        Messages.loginTitle,
                        style: UIStyles.headerStyle.copyWith(color: _appColor),
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingS),
                    if (_errorMessage.isNotEmpty)
                      Semantics(
                        label: 'Fehlermeldung: $_errorMessage',
                        hint:
                            'Fehler beim Login. Bitte überprüfen Sie Ihre Eingaben.',
                        liveRegion: true,
                        child: ScaledText(
                          _errorMessage,
                          style: UIStyles.errorStyle,
                        ),
                      ),
                    const SizedBox(height: UIConstants.spacingM),
                    _buildEmailField(),
                    const SizedBox(height: UIConstants.spacingS),
                    _buildPasswordField(),
                    const SizedBox(height: UIConstants.spacingS),
                    _buildRememberMeCheckbox(),
                    const SizedBox(height: UIConstants.spacingM),
                    Focus(
                      focusNode: _loginButtonFocusNode,
                      onKey: (node, event) {
                        if ((event.isKeyPressed(LogicalKeyboardKey.enter) ||
                                event.isKeyPressed(
                                  LogicalKeyboardKey.numpadEnter,
                                )) &&
                            !_isLoading) {
                          _handleLogin();
                          return KeyEventResult.handled;
                        }
                        return KeyEventResult.ignored;
                      },
                      child: Semantics(
                        label: 'Login Button',
                        hint: 'Tippen, um sich einzuloggen',
                        button: true,
                        child: Container(
                          decoration:
                              _hasLoginButtonKeyboardFocus
                                  ? BoxDecoration(
                                    border: Border.all(
                                      color: Colors.yellow.shade700,
                                      width: 3.0,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  )
                                  : null,
                          child: _buildLoginButton(),
                        ),
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingS),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Focus(
                          child: Semantics(
                            label: 'Passwort vergessen Button',
                            hint: 'Tippen, um das Passwort zurückzusetzen',
                            child: _buildForgotPasswordButton(),
                          ),
                        ),
                        Focus(
                          child: Semantics(
                            label: 'Hilfe Button',
                            hint:
                                'Tippen, um Hilfe und Informationen zu erhalten',
                            child: _buildHelpButton(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: UIConstants.spacingS),
                    Center(
                      child: Focus(
                        child: Semantics(
                          label: 'Registrieren Button',
                          hint:
                              'Tippen, um ein neues Benutzerkonto zu erstellen',
                          child: _buildRegisterButton(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
