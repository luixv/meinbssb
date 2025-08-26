import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/fremde_verband_data.dart';

void main() {
  group('FremdeVerband', () {
    const testJson = {
      'VEREINID': 4777,
      'VEREINNR': 999901,
      'VEREINNAME': 'Badischer SB',
    };

    test('should create instance from JSON', () {
      final fremdeVerband = FremdeVerband.fromJson(testJson);

      expect(fremdeVerband.vereinId, equals(4777));
      expect(fremdeVerband.vereinNr, equals(999901));
      expect(fremdeVerband.vereinName, equals('Badischer SB'));
    });

    test('should convert to JSON', () {
      final fremdeVerband = FremdeVerband(
        vereinId: 4777,
        vereinNr: 999901,
        vereinName: 'Badischer SB',
      );

      final json = fremdeVerband.toJson();

      expect(json, equals(testJson));
    });

    test('should have correct string representation', () {
      final fremdeVerband = FremdeVerband(
        vereinId: 4777,
        vereinNr: 999901,
        vereinName: 'Badischer SB',
      );

      expect(
        fremdeVerband.toString(),
        equals('FremdeVerband(vereinId: 4777, vereinNr: 999901, vereinName: Badischer SB)'),
      );
    });

    test('should be equal when properties are the same', () {
      final fremdeVerband1 = FremdeVerband(
        vereinId: 4777,
        vereinNr: 999901,
        vereinName: 'Badischer SB',
      );

      final fremdeVerband2 = FremdeVerband(
        vereinId: 4777,
        vereinNr: 999901,
        vereinName: 'Badischer SB',
      );

      expect(fremdeVerband1, equals(fremdeVerband2));
      expect(fremdeVerband1.hashCode, equals(fremdeVerband2.hashCode));
    });

    test('should not be equal when properties are different', () {
      final fremdeVerband1 = FremdeVerband(
        vereinId: 4777,
        vereinNr: 999901,
        vereinName: 'Badischer SB',
      );

      final fremdeVerband2 = FremdeVerband(
        vereinId: 4778,
        vereinNr: 999902,
        vereinName: 'Different Name',
      );

      expect(fremdeVerband1, isNot(equals(fremdeVerband2)));
      expect(fremdeVerband1.hashCode, isNot(equals(fremdeVerband2.hashCode)));
    });

    test('should throw FormatException when JSON is invalid', () {
      final invalidJson = {
        'VEREINID': 'not_an_integer',
        'VEREINNR': 999901,
        'VEREINNAME': 'Badischer SB',
      };

      expect(
        () => FremdeVerband.fromJson(invalidJson),
        throwsA(isA<FormatException>()),
      );
    });

    test('should throw FormatException when required field is missing', () {
      final invalidJson = {
        'VEREINID': 4777,
        'VEREINNR': 999901,
        // Missing VEREINNAME
      };

      expect(
        () => FremdeVerband.fromJson(invalidJson),
        throwsA(isA<FormatException>()),
      );
    });
  });
} 