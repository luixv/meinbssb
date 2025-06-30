import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'package:meinbssb/constants/ui_constants.dart';

final _log = Logger('StartScreen');

class ConnectivityIcon extends StatefulWidget {
  const ConnectivityIcon({super.key});

  @override
  State<ConnectivityIcon> createState() => _ConnectivityIconState();
}

class _ConnectivityIconState extends State<ConnectivityIcon> {
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  final bool _useSvg = false; // Set this to true if you are using SVG assets
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionState);
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _initConnectivity() async {
    List<ConnectivityResult> results;
    try {
      results = await _connectivity.checkConnectivity();
    } catch (e) {
      _log.warning('Couldn\'t check connectivity status: $e');
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }
    setState(() {
      _connectivityResult =
          results.isNotEmpty ? results.first : ConnectivityResult.none;
    });
  }

  void _updateConnectionState(List<ConnectivityResult> results) {
    if (!mounted) return;
    if (results.isNotEmpty) {
      setState(() {
        _connectivityResult = results.first;
      });
    } else {
      setState(() {
        _connectivityResult = ConnectivityResult.none;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget icon;
    String tooltip;

    switch (_connectivityResult) {
      case ConnectivityResult.wifi:
        icon = _useSvg
            ? SvgPicture.asset(
                'assets/wifi_on.svg', // Replace with your SVG asset path
                width: UIConstants.defaultIconSize,
                height: UIConstants.defaultIconSize,
                colorFilter: const ColorFilter.mode(
                  Colors.green,
                  BlendMode.srcIn,
                ),
              )
            : const Icon(Icons.wifi, color: Colors.green);
        tooltip = 'Connected to Wi-Fi';
        break;
      case ConnectivityResult.mobile:
        icon = _useSvg
            ? SvgPicture.asset(
                'assets/signal_cellular_4_bar.svg',
                width: UIConstants.defaultIconSize,
                height: UIConstants.defaultIconSize,
                colorFilter: const ColorFilter.mode(
                  UIConstants.connectivityIcon,
                  BlendMode.srcIn,
                ),
              )
            : const Icon(
                Icons.signal_cellular_4_bar,
                color: UIConstants.connectivityIcon,
              );
        tooltip = 'Connected to Mobile Data';
        break;
      case ConnectivityResult.ethernet:
        // Use a generic network icon or your own custom icon for Ethernet
        icon = _useSvg
            ? SvgPicture.asset(
                'assets/ethernet.svg', // Replace with your SVG asset path
                width: UIConstants.defaultIconSize,
                height: UIConstants.defaultIconSize,
                colorFilter: const ColorFilter.mode(
                  UIConstants.connectivityIcon,
                  BlendMode.srcIn,
                ),
              )
            : const Icon(
                Icons
                    .network_check, // Using a more widely available network icon
                color: UIConstants.connectivityIcon,
              );
        tooltip = 'Connected to Ethernet';
        break;
      case ConnectivityResult.none:
        icon = _useSvg
            ? SvgPicture.asset(
                'assets/wifi_off.svg', // Replace with your SVG asset path
                width: UIConstants.defaultIconSize,
                height: UIConstants.defaultIconSize,
                colorFilter: const ColorFilter.mode(
                  UIConstants.noConnectivityIcon,
                  BlendMode.srcIn,
                ),
              )
            : const Icon(Icons.wifi_off, color: UIConstants.noConnectivityIcon);
        tooltip = 'No Internet Connection';
        break;
      case ConnectivityResult
            .bluetooth: // You might want to handle this differently
        icon = const Icon(
          Icons.bluetooth_connected,
          color: UIConstants.bluetoothConnected,
        );
        tooltip = 'Connected via Bluetooth (No Internet)';
        break;
      case ConnectivityResult.vpn: //  treat this as connected
        icon = const Icon(Icons.vpn_lock, color: UIConstants.connectivityIcon);
        tooltip = 'Connected via VPN';
        break;
      case ConnectivityResult.other: // Handle other types as needed
        icon = const Icon(Icons.network_check, color: UIConstants.networkCheck);
        tooltip = 'Other Connection Type';
        break;
    }

    return Tooltip(message: tooltip, child: icon);
  }
}
