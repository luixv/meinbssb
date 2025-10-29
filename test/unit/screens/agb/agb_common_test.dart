import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/screens/agb/agb_common.dart';

void main() {
  group('parseAgbText', () {
    test('parses sections and paragraphs', () {
      const sampleText = '''
1. Section One
1.1 First paragraph.
1.2 Second paragraph.

2. Section Two
2.1 Another paragraph.
Stand: 21.10.2025
''';
      final sections = parseAgbText(sampleText);
      expect(sections.length, 2);
      expect(sections[0].title, '1. Section One');
      expect(sections[0].paragraphs, contains('1.1 First paragraph.'));
      expect(sections[1].title, '2. Section Two');
      expect(sections[1].paragraphs, contains('2.1 Another paragraph.'));
      expect(sections[1].paragraphs.last, 'Stand: 21.10.2025');
    });
  });

  group('buildNumberedParagraph', () {
    testWidgets('renders bold number for numbered paragraph', (tester) async {
      const para = '1.1. Some numbered paragraph.';
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: buildNumberedParagraph(para))));
      final richText = find.byType(RichText);
      expect(richText, findsOneWidget);
      expect(find.textContaining('1.1.'), findsOneWidget);
      expect(find.textContaining('Some numbered paragraph.'), findsOneWidget);
    });

    testWidgets('renders plain text for non-numbered paragraph', (tester) async {
      const para = 'This is a plain paragraph.';
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: buildNumberedParagraph(para))));
      expect(find.text(para), findsOneWidget);
    });
  });
}
