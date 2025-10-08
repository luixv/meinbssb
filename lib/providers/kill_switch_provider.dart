import 'package:flutter/foundation.dart';
import '../services/kill_switch/kill_switch_service.dart';

class KillSwitchProvider with ChangeNotifier {
  KillSwitchProvider(this._service);

  final KillSwitchService _service;
  bool _enabled = true;
  String _title = '';
  String _body = '';

  bool get appEnabled => _enabled;
  String get title => _title;
  String get body => _body;

  Future<void> load() async {
    await _service.refresh();
    _enabled = _service.isEnabled;
    _title = _service.title;
    _body = _service.body;
    notifyListeners();
  }
}
