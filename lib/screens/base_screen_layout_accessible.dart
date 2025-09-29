import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/screens/app_menu_accessible.dart';
import '/screens/connectivity_icon.dart';
import '/models/user_data.dart';
import '/widgets/scaled_text.dart';
import 'package:provider/provider.dart';
import '../providers/font_size_provider.dart';

/// BITV 2.0 compliant base screen layout with comprehensive accessibility features
///
/// This accessible version provides:
/// - Semantic structure for screen readers
/// - German language accessibility labels
/// - Proper focus management
/// - Live regions for dynamic content
/// - Keyboard navigation support
/// - WCAG 2.1 Level AA compliance
class BaseScreenLayoutAccessible extends StatefulWidget {
  const BaseScreenLayoutAccessible({
    super.key,
    required this.title,
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
    required this.body,
    this.actions = const [],
    this.automaticallyImplyLeading = true,
    this.leading,
    this.floatingActionButton,
    this.showMenu = true,
    this.showConnectivityIcon = true,
    this.semanticScreenLabel,
    this.screenDescription,
  });

  final String title;
  final UserData? userData;
  final bool isLoggedIn;
  final VoidCallback onLogout;
  final Widget body;
  final List<Widget> actions;
  final bool automaticallyImplyLeading;
  final Widget? leading;
  final Widget? floatingActionButton;
  final bool showMenu;
  final bool showConnectivityIcon;
  final String? semanticScreenLabel;
  final String? screenDescription;

  @override
  State<BaseScreenLayoutAccessible> createState() =>
      _BaseScreenLayoutAccessibleState();
}

class _BaseScreenLayoutAccessibleState
    extends State<BaseScreenLayoutAccessible> {
  late FocusNode _menuFocusNode;
  late FocusNode _backButtonFocusNode;
  final String _connectionStatus = 'Verbindung wird geprüft';

  @override
  void initState() {
    super.initState();
    _menuFocusNode = FocusNode();
    _backButtonFocusNode = FocusNode();

    // Announce screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _announceScreenLoad();
    });
  }

  @override
  void dispose() {
    _menuFocusNode.dispose();
    _backButtonFocusNode.dispose();
    super.dispose();
  }

  void _announceScreenLoad() {
    final screenName = widget.semanticScreenLabel ?? widget.title;
    final description = widget.screenDescription ?? 'Seite geladen';

    SemanticsService.announce(
      'Bildschirm: $screenName. $description',
      TextDirection.ltr,
    );
  }

  void _handleMenuPress(BuildContext context) {
    Scaffold.of(context).openEndDrawer();

    // Announce menu opening
    SemanticsService.announce(
      'Hauptmenü geöffnet. Verwenden Sie die Pfeiltasten zur Navigation.',
      TextDirection.ltr,
    );
  }

  void _handleBackPress() {
    Navigator.of(context).pop();

    SemanticsService.announce(
      'Zurück zur vorherigen Seite',
      TextDirection.ltr,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Hauptlayout der Anwendung ${widget.title}',
      hint: widget.screenDescription ??
          'Basis-Layout mit Navigation und Inhaltsbereich',
      child: Scaffold(
        backgroundColor: UIConstants.backgroundColor,
        // Accessible AppBar with comprehensive semantic support
        appBar: _buildAccessibleAppBar(context),
        // Accessible End Drawer
        endDrawer: widget.showMenu ? _buildAccessibleDrawer() : null,
        onEndDrawerChanged: (isOpened) {
          if (!isOpened) {
            SemanticsService.announce(
              'Hauptmenü geschlossen',
              TextDirection.ltr,
            );
          }
        },
        // Accessible body with font scaling support
        body: Semantics(
          container: true,
          label: 'Hauptinhalt der Seite',
          hint: 'Inhaltsbereich mit anpassbarer Schriftgröße',
          child: Consumer<FontSizeProvider>(
            builder: (context, fontSizeProvider, child) {
              return Semantics(
                liveRegion: true,
                label:
                    'Inhaltsbereich mit Schriftgröße ${(fontSizeProvider.scaleFactor * 100).round()}%',
                child: widget.body,
              );
            },
          ),
        ),
        // Accessible Floating Action Button
        floatingActionButton:
            widget.floatingActionButton != null ? _buildAccessibleFAB() : null,
      ),
    );
  }

  PreferredSizeWidget _buildAccessibleAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading:
          false, // We handle this manually for better accessibility
      backgroundColor: UIConstants.backgroundColor,
      iconTheme: const IconThemeData(color: UIConstants.textColor),

      // Accessible leading widget (back button)
      leading: _buildAccessibleLeading(),

      // Accessible title as main heading
      title: Semantics(
        header: true,
        liveRegion: true,
        label: 'Hauptüberschrift: ${widget.title}',
        hint: 'Titel der aktuellen Seite',
        child: ScaledText(
          widget.title,
          style: UIStyles.appBarTitleStyle,
        ),
      ),

      // Accessible actions
      actions: _buildAccessibleActions(context),
    );
  }

  Widget? _buildAccessibleLeading() {
    if (widget.leading != null) {
      return Semantics(
        button: true,
        enabled: true,
        label: 'Benutzerdefinierte Navigation',
        child: widget.leading!,
      );
    }

    if (widget.automaticallyImplyLeading && Navigator.of(context).canPop()) {
      return Semantics(
        button: true,
        enabled: true,
        label: 'Zurück zur vorherigen Seite',
        hint: 'Kehrt zur letzten besuchten Seite zurück',
        child: IconButton(
          focusNode: _backButtonFocusNode,
          icon: const Icon(
            Icons.arrow_back,
            color: UIConstants.textColor,
            semanticLabel: 'Zurück-Symbol',
          ),
          onPressed: _handleBackPress,
          tooltip: 'Zurück',
        ),
      );
    }

    return null;
  }

  List<Widget> _buildAccessibleActions(BuildContext context) {
    final accessibleActions = <Widget>[];

    // Make existing actions accessible
    for (int i = 0; i < widget.actions.length; i++) {
      accessibleActions.add(
        Semantics(
          button: true,
          enabled: true,
          label: 'Aktion ${i + 1} in der Symbolleiste',
          hint: 'Zusätzliche Funktionen für diese Seite',
          sortKey: OrdinalSortKey(i.toDouble()),
          child: widget.actions[i],
        ),
      );
    }

    // Accessible connectivity icon
    if (widget.showConnectivityIcon) {
      accessibleActions.add(
        Padding(
          padding: UIConstants.appBarRightPadding,
          child: Semantics(
            liveRegion: true,
            label: 'Verbindungsstatus',
            value: _connectionStatus,
            hint: 'Aktuelle Internetverbindung',
            child: const ConnectivityIcon(),
          ),
        ),
      );
    }

    // Accessible menu button
    if (widget.showMenu) {
      accessibleActions.add(
        Builder(
          builder: (context) => Semantics(
            button: true,
            enabled: true,
            label: 'Hauptmenü öffnen',
            hint:
                'Öffnet das Navigationsmenü mit allen verfügbaren Bereichen der Anwendung',
            onTap: () => _handleMenuPress(context),
            child: IconButton(
              focusNode: _menuFocusNode,
              icon: const Icon(
                Icons.menu,
                color: UIConstants.textColor,
                semanticLabel: 'Menü-Symbol',
              ),
              onPressed: () => _handleMenuPress(context),
              tooltip: 'Hauptmenü öffnen',
            ),
          ),
        ),
      );
    }

    return accessibleActions;
  }

  Widget _buildAccessibleDrawer() {
    return Semantics(
      container: true,
      namesRoute: true,
      label: 'Hauptnavigationsmenü',
      hint: 'Navigationsbereich mit allen verfügbaren Funktionen der Anwendung',
      child: AppDrawerAccessible(
        userData: widget.userData,
        isLoggedIn: widget.isLoggedIn,
        onLogout: () {
          // Announce logout
          SemanticsService.announce(
            'Abmeldung wird durchgeführt',
            TextDirection.ltr,
          );
          widget.onLogout();
        },
      ),
    );
  }

  Widget _buildAccessibleFAB() {
    return Semantics(
      button: true,
      enabled: true,
      label: 'Schwebende Aktionsschaltfläche',
      hint: 'Hauptaktion für diese Seite',
      child: widget.floatingActionButton!,
    );
  }
}

/// Extension to add accessibility helpers
extension BaseScreenLayoutAccessibility on BaseScreenLayoutAccessible {
  /// Helper method to create accessibility announcements
  static void announceToUser(String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Helper method to create semantic labels for navigation
  static String createNavigationLabel(String destination) {
    return 'Navigation zu $destination';
  }

  /// Helper method to create action descriptions
  static String createActionHint(String action) {
    return 'Führt folgende Aktion aus: $action';
  }
}

/// Accessibility constants specific to BaseScreenLayout
class BaseScreenLayoutAccessibilityConstants {
  static const String defaultScreenLabel = 'Anwendungsbildschirm';
  static const String defaultScreenDescription = 'Hauptlayout der Anwendung';
  static const String menuButtonLabel = 'Hauptmenü öffnen';
  static const String backButtonLabel = 'Zurück zur vorherigen Seite';
  static const String connectionStatusLabel = 'Verbindungsstatus';
  static const String fabLabel = 'Schwebende Aktionsschaltfläche';

  // Semantic hints
  static const String menuButtonHint =
      'Öffnet das Navigationsmenü mit allen verfügbaren Bereichen';
  static const String backButtonHint =
      'Kehrt zur letzten besuchten Seite zurück';
  static const String connectionStatusHint = 'Aktuelle Internetverbindung';
  static const String fabHint = 'Hauptaktion für diese Seite';
}
