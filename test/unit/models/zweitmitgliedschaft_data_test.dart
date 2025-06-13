import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/zweitmitgliedschaft_data.dart';

void main() {
  group('ZweitmitgliedschaftData', () {
    test('creates ZweitmitgliedschaftData from JSON', () {
      final json = {
        'VEREINID': 123,
        'VEREINNR': 456,
        'VEREINNAME': 'Test Club',
        'EINTRITTVEREIN': '2024-01-01T00:00:00.000Z',
      };

      final data = ZweitmitgliedschaftData.fromJson(json);

      expect(data.vereinId, equals(123));
      expect(data.vereinNr, equals(456));
      expect(data.vereinName, equals('Test Club'));
      expect(
        data.eintrittVerein,
        equals(DateTime.parse('2024-01-01T00:00:00.000Z')),
      );
    });

    test('converts ZweitmitgliedschaftData to JSON', () {
      final data = ZweitmitgliedschaftData(
        vereinId: 123,
        vereinNr: 456,
        vereinName: 'Test Club',
        eintrittVerein: DateTime.parse('2024-01-01T00:00:00.000Z'),
      );

      final json = data.toJson();

      expect(json['VEREINID'], equals(123));
      expect(json['VEREINNR'], equals(456));
      expect(json['VEREINNAME'], equals('Test Club'));
      expect(json['EINTRITTVEREIN'], equals('2024-01-01T00:00:00.000Z'));
    });

    test('equality operator works correctly', () {
      final data1 = ZweitmitgliedschaftData(
        vereinId: 123,
        vereinNr: 456,
        vereinName: 'Test Club',
        eintrittVerein: DateTime.parse('2024-01-01T00:00:00.000Z'),
      );

      final data2 = ZweitmitgliedschaftData(
        vereinId: 123,
        vereinNr: 456,
        vereinName: 'Test Club',
        eintrittVerein: DateTime.parse('2024-01-01T00:00:00.000Z'),
      );

      final data3 = ZweitmitgliedschaftData(
        vereinId: 789,
        vereinNr: 101,
        vereinName: 'Different Club',
        eintrittVerein: DateTime.parse('2024-02-01T00:00:00.000Z'),
      );

      expect(data1, equals(data2));
      expect(data1, isNot(equals(data3)));
    });

    test('hashCode is consistent with equality', () {
      final data1 = ZweitmitgliedschaftData(
        vereinId: 123,
        vereinNr: 456,
        vereinName: 'Test Club',
        eintrittVerein: DateTime.parse('2024-01-01T00:00:00.000Z'),
      );

      final data2 = ZweitmitgliedschaftData(
        vereinId: 123,
        vereinNr: 456,
        vereinName: 'Test Club',
        eintrittVerein: DateTime.parse('2024-01-01T00:00:00.000Z'),
      );

      expect(data1.hashCode, equals(data2.hashCode));
    });

    test('toString returns correct representation', () {
      final data = ZweitmitgliedschaftData(
        vereinId: 123,
        vereinNr: 456,
        vereinName: 'Test Club',
        eintrittVerein: DateTime.parse('2024-01-01T00:00:00.000Z'),
      );

      expect(
        data.toString(),
        equals(
          'ZweitmitgliedschaftData(vereinId: 123, vereinNr: 456, '
          'vereinName: Test Club, eintrittVerein: 2024-01-01 00:00:00.000Z)',
        ),
      );
    });

    test('handles invalid date format in JSON', () {
      final json = {
        'VEREINID': 123,
        'VEREINNR': 456,
        'VEREINNAME': 'Test Club',
        'EINTRITTVEREIN': 'invalid-date',
      };

      expect(
        () => ZweitmitgliedschaftData.fromJson(json),
        throwsFormatException,
      );
    });

    test('handles missing required fields in JSON', () {
      final json = {
        'VEREINID': 123,
        'VEREINNR': 456,
        // Missing vereinName and eintrittVerein
      };

      expect(
        () => ZweitmitgliedschaftData.fromJson(json),
        throwsA(isA<TypeError>()),
      );
    });

    test('handles null values in JSON', () {
      final json = {
        'VEREINID': 123,
        'VEREINNR': 456,
        'VEREINNAME': null,
        'EINTRITTVEREIN': '2024-01-01T00:00:00.000Z',
      };

      expect(
        () => ZweitmitgliedschaftData.fromJson(json),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
