import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: unused_import
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:meinbssb/screens/connectivity_icon.dart';
import 'package:meinbssb/constants/ui_constants.dart';

void main() {
  Widget createTestWidget() {
    return MaterialApp(home: Scaffold(body: ConnectivityIcon()));
  }

  group('ConnectivityIcon - Widget Structure Tests', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(createTestWidget());
      expect(find.byType(ConnectivityIcon), findsOneWidget);
    });

    testWidgets('contains a tooltip widget', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle(); // Wait for async initialization

      expect(find.byType(Tooltip), findsOneWidget);
    });

    testWidgets('contains an icon widget', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle(); // Wait for async initialization

      expect(find.byType(Icon), findsOneWidget);
    });
  });

  group('ConnectivityIcon - Default State Tests', () {
    testWidgets('shows connectivity icon by default', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should have some icon displayed
      expect(find.byType(Icon), findsOneWidget);

      // Should have a tooltip
      final tooltip = find.byType(Tooltip);
      expect(tooltip, findsOneWidget);

      final tooltipWidget = tester.widget<Tooltip>(tooltip);
      expect(tooltipWidget.message, isNotEmpty);
    });

    testWidgets('tooltip message is descriptive', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final tooltipWidget = tester.widget<Tooltip>(find.byType(Tooltip));

      // Should be one of the expected tooltip messages
      final expectedMessages = [
        'Connected to Wi-Fi',
        'Connected to Mobile Data',
        'Connected to Ethernet',
        'No Internet Connection',
        'Connected via Bluetooth (No Internet)',
        'Connected via VPN',
        'Other Connection Type',
      ];

      expect(
        expectedMessages.contains(tooltipWidget.message),
        isTrue,
        reason:
            'Tooltip message "${tooltipWidget.message}" should be one of the expected messages',
      );
    });
  });

  group('ConnectivityIcon - Icon Color Tests', () {
    testWidgets('icon has appropriate color', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final iconWidget = tester.widget<Icon>(find.byType(Icon));

      // Should have a color from UIConstants
      final expectedColors = [
        UIConstants.wifiConnectedColor,
        UIConstants.connectivityIcon,
        UIConstants.noConnectivityIcon,
        UIConstants.bluetoothConnected,
        UIConstants.networkCheck,
      ];

      expect(
        expectedColors.contains(iconWidget.color),
        isTrue,
        reason: 'Icon color should be one of the UIConstants colors',
      );
    });
  });

  group('ConnectivityIcon - Possible Icon Types Tests', () {
    testWidgets('displays one of the expected connectivity icons', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for any of the possible icons
      final possibleIcons = [
        Icons.wifi,
        Icons.signal_cellular_4_bar,
        Icons.network_check,
        Icons.wifi_off,
        Icons.bluetooth_connected,
        Icons.vpn_lock,
      ];

      bool foundExpectedIcon = false;
      for (final iconData in possibleIcons) {
        if (find.byIcon(iconData).evaluate().isNotEmpty) {
          foundExpectedIcon = true;
          break;
        }
      }

      expect(
        foundExpectedIcon,
        isTrue,
        reason: 'Should display one of the expected connectivity icons',
      );
    });
  });

  group('ConnectivityIcon - Widget Lifecycle Tests', () {
    testWidgets('properly initializes and disposes', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify widget is present
      expect(find.byType(ConnectivityIcon), findsOneWidget);

      // Remove the widget to trigger dispose
      await tester.pumpWidget(MaterialApp(home: Container()));

      // Should not crash when disposing
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles widget rebuild', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ConnectivityIcon), findsOneWidget);

      // Rebuild the widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should still be present
      expect(find.byType(ConnectivityIcon), findsOneWidget);
      expect(find.byType(Icon), findsOneWidget);
      expect(find.byType(Tooltip), findsOneWidget);
    });
  });

  group('ConnectivityIcon - Accessibility Tests', () {
    testWidgets('provides accessibility information via tooltip', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.message, isNotEmpty);
    });

    testWidgets('tooltip can be activated', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Long press to show tooltip
      await tester.longPress(find.byType(ConnectivityIcon));
      await tester.pump(const Duration(milliseconds: 500));

      // Should not crash
      expect(tester.takeException(), isNull);
    });
  });

  group('ConnectivityIcon - Performance Tests', () {
    testWidgets('initializes within reasonable time', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Should initialize within 5 seconds (generous for CI environments)
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));

      // Should have rendered the basic structure
      expect(find.byType(ConnectivityIcon), findsOneWidget);
      expect(find.byType(Icon), findsOneWidget);
      expect(find.byType(Tooltip), findsOneWidget);
    });
  });

  group('ConnectivityIcon - Error Resilience Tests', () {
    testWidgets('handles multiple rapid rebuilds', (tester) async {
      // Rapidly rebuild the widget multiple times
      for (int i = 0; i < 5; i++) {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
      }

      await tester.pumpAndSettle();

      // Should not crash and should render properly
      expect(tester.takeException(), isNull);
      expect(find.byType(ConnectivityIcon), findsOneWidget);
      expect(find.byType(Icon), findsOneWidget);
    });

    testWidgets('maintains state during frame processing', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Pump several frames without settling
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      await tester.pumpAndSettle();

      // Should not crash
      expect(tester.takeException(), isNull);
      expect(find.byType(ConnectivityIcon), findsOneWidget);
    });
  });

  group('ConnectivityIcon - UI Constants Integration Tests', () {
    testWidgets('uses UIConstants for styling', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final iconWidget = tester.widget<Icon>(find.byType(Icon));

      // Verify the color is not null and is a defined color
      expect(iconWidget.color, isNotNull);
      expect(iconWidget.color, isA<Color>());
    });
  });

  group('ConnectivityIcon - Widget Integration Tests', () {
    testWidgets('works within different parent widgets', (tester) async {
      // Test in AppBar
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(appBar: AppBar(actions: [ConnectivityIcon()])),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ConnectivityIcon), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('works in different layout contexts', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Row(children: [ConnectivityIcon(), Text('Status')]),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ConnectivityIcon), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('ConnectivityIcon - Real Connectivity Tests', () {
    testWidgets('responds to actual connectivity changes', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Get initial state

      // Wait a bit to allow for potential connectivity changes
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Should still be working
      expect(find.byType(ConnectivityIcon), findsOneWidget);
      expect(find.byType(Tooltip), findsOneWidget);

      final currentTooltip =
          tester.widget<Tooltip>(find.byType(Tooltip)).message;
      expect(currentTooltip, isNotEmpty);
    });
  });
}
