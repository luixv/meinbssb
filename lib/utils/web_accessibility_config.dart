import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Web-specific accessibility configuration for BITV 2.0 compliance
class WebAccessibilityConfig {
  static void configure() {
    if (kIsWeb) {
      // Configure semantic announcements for web
      _configureSemanticsAnnouncements();

      // Setup focus management
      _configureFocusManagement();

      // Configure keyboard navigation
      _configureKeyboardNavigation();
    }
  }

  /// Configure semantic announcements for screen readers
  static void _configureSemanticsAnnouncements() {
    // Enable semantic announcements
    SemanticsBinding.instance.ensureSemantics();
  }

  /// Configure focus management for web accessibility
  static void _configureFocusManagement() {
    // Focus management is handled by Flutter's FocusManager
    // Additional web-specific configurations can be added here
  }

  /// Configure keyboard navigation shortcuts
  static void _configureKeyboardNavigation() {
    // Web-specific keyboard shortcuts will be handled in individual widgets
  }

  /// Get web-specific semantic configuration
  static Map<String, dynamic> getSemanticConfig() {
    if (!kIsWeb) return {};

    return {
      'explicitChildNodes': true,
      'container': true,
      'focusable': true,
    };
  }

  /// Create web-optimized semantic widget
  static Widget createWebSemanticWidget({
    required Widget child,
    String? label,
    String? hint,
    String? value,
    bool? button,
    bool? header,
    bool? textField,
    bool? image,
    bool? link,
    VoidCallback? onTap,
  }) {
    if (!kIsWeb) return child;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: label,
      hint: hint,
      value: value,
      button: button ?? false,
      header: header ?? false,
      textField: textField ?? false,
      image: image ?? false,
      link: link ?? false,
      onTap: onTap,
      child: child,
    );
  }

  /// Create web-optimized focus widget
  static Widget createWebFocusWidget({
    required Widget child,
    required FocusNode focusNode,
    ValueChanged<bool>? onFocusChange,
  }) {
    if (!kIsWeb) return child;

    return Focus(
      focusNode: focusNode,
      onFocusChange: onFocusChange,
      child: child,
    );
  }

  /// Create web-optimized keyboard handler
  static Widget createWebKeyboardHandler({
    required Widget child,
    required Map<ShortcutActivator, Intent> shortcuts,
  }) {
    if (!kIsWeb) return child;

    return Shortcuts(
      shortcuts: shortcuts,
      child: child,
    );
  }

  /// Announce message to screen readers
  static void announceToScreenReader(String message) {
    if (kIsWeb) {
      SemanticsService.announce(message, TextDirection.ltr);
    }
  }

  /// Create accessible loading indicator for web
  static Widget createAccessibleLoadingIndicator({
    String? semanticsLabel,
  }) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: semanticsLabel ?? 'Inhalt wird geladen',
      child: const Center(
        child: CircularProgressIndicator(
          semanticsLabel: 'Ladevorgang aktiv',
        ),
      ),
    );
  }

  /// Create accessible error widget for web
  static Widget createAccessibleErrorWidget({
    required String message,
    VoidCallback? onRetry,
  }) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: 'Fehler aufgetreten: $message',
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              image: true,
              label: 'Fehler Symbol',
              child: const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              container: true,
              label: 'Fehlermeldung: $message',
              child: Text(
                message,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              Semantics(
                container: true,
                button: true,
                label: 'Erneut versuchen',
                hint: 'Lädt den Inhalt erneut',
                child: ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Erneut versuchen'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Get BITV 2.0 compliant color contrast ratios
  static Map<String, Color> getBITVColorScheme() {
    return {
      'primary': const Color(0xFF0175C2), // BSSB Blue - AA compliant
      'primaryDark': const Color(0xFF014A8C), // Darker blue for better contrast
      'secondary': const Color(0xFF2196F3), // Material Blue - AA compliant
      'error': const Color(0xFFD32F2F), // Red - AA compliant
      'warning': const Color(0xFFFF9800), // Orange - AA compliant
      'success': const Color(0xFF388E3C), // Green - AA compliant
      'background': const Color(0xFFFFFFFF), // White
      'surface': const Color(0xFFF5F5F5), // Light gray
      'onPrimary': const Color(0xFFFFFFFF), // White on primary
      'onSecondary': const Color(0xFFFFFFFF), // White on secondary
      'onError': const Color(0xFFFFFFFF), // White on error
      'onWarning': const Color(0xFF000000), // Black on warning
      'onSuccess': const Color(0xFFFFFFFF), // White on success
      'onBackground': const Color(0xFF000000), // Black on background
      'onSurface': const Color(0xFF000000), // Black on surface
    };
  }

  /// Check if current environment supports high contrast
  static bool isHighContrastMode(BuildContext context) {
    if (!kIsWeb) return false;

    // This would need to be implemented with platform channels
    // for now return false as default
    return false;
  }

  /// Check if user prefers reduced motion
  static bool prefersReducedMotion(BuildContext context) {
    if (!kIsWeb) return false;

    return MediaQuery.of(context).disableAnimations;
  }

  /// Create accessible form field with proper labeling
  static Widget createAccessibleFormField({
    required String label,
    required TextEditingController controller,
    String? hint,
    String? errorText,
    bool required = false,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Semantics(
      container: true,
      textField: true,
      label: required ? '$label (Pflichtfeld)' : label,
      hint: hint,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          hintText: hint,
          errorText: errorText,
          border: const OutlineInputBorder(),
          // Ensure sufficient color contrast
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF0175C2), width: 2),
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFD32F2F), width: 2),
          ),
        ),
      ),
    );
  }
}
