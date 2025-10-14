import 'package:flutter/foundation.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io' show Platform;

class CompulsoryUpdateProvider extends ChangeNotifier {
  CompulsoryUpdateProvider({required this.remoteConfig});
  // Test-only setters
  set testUpdateRequired(bool value) => _updateRequired = value;
  set testUpdateMessage(String? value) => _updateMessage = value;
  final FirebaseRemoteConfig remoteConfig;
  String? _minimumRequiredVersion;
  bool _updateRequired = false;
  String? _updateMessage;

  String? get minimumRequiredVersion => _minimumRequiredVersion;
  bool get updateRequired => _updateRequired;
  String? get updateMessage => _updateMessage;

  Future<void> processRemoteConfig({
    String? testCurrentVersion,
    bool? testBypassPlatformCheck,
  }) async {
    if (testBypassPlatformCheck != true &&
        (kIsWeb || !(Platform.isAndroid || Platform.isIOS))) {
      _updateRequired = false;
      notifyListeners();
      return;
    }
    try {
      remoteConfig.getAll();
      final minVer = remoteConfig.getString('minimum_required_version');
      final updMsg = remoteConfig.getString('update_message');

      _minimumRequiredVersion = minVer.isEmpty ? null : minVer;
      _updateMessage = updMsg.isEmpty ? null : updMsg;
      String currentVersion;
      if (testCurrentVersion != null) {
        currentVersion = testCurrentVersion;
      } else {
        final info = await PackageInfo.fromPlatform();
        currentVersion = info.version;
      }

      _updateRequired = isUpdateRequired(
        currentVersion,
        _minimumRequiredVersion,
      );
      notifyListeners();
    } catch (e) {
      _updateRequired = false;
      notifyListeners();
    }
  }

  bool isUpdateRequired(String currentVersion, String? minimumRequiredVersion) {
    if (minimumRequiredVersion == null || minimumRequiredVersion.isEmpty) {
      return false;
    }

    final cv = currentVersion.split(RegExp(r'[^0-9.]')).first;
    final mv = minimumRequiredVersion.split(RegExp(r'[^0-9.]')).first;

    final cvParts = cv.split('.').map(int.tryParse).toList();
    final mvParts = mv.split('.').map(int.tryParse).toList();

    for (int i = 0; i < mvParts.length; i++) {
      final c = (i < cvParts.length && cvParts[i] != null) ? cvParts[i]! : 0;
      final m = mvParts[i] ?? 0;
      if (c < m) return true;
      if (c > m) return false;
    }
    return false;
  }
}
