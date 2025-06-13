import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/zweitmitgliedschaft_data.dart';

void main() {
  group('ZweitmitgliedschaftData', () {
    late Map<String, dynamic> validJson;
    late ZweitmitgliedschaftData validData;
    late DateTime validDate;

    setUp(() {
      validDate = DateTime.parse('2012-02-26T00:00:00.000+01:00');
      validJson = {
        'VEREINID': 1474,
        'VEREINNR': 401006,
        'VEREINNAME': 'Vereinigte Sportschützen Paartal Aichach',
        'EINTRITTVEREIN': validDate.toIso8601String(),
      };
      validData = ZweitmitgliedschaftData(
        vereinId: 1474,
        vereinNr: 401006,
        vereinName: 'Vereinigte Sportschützen Paartal Aichach',
        eintrittVerein: validDate,
      );
    });

    group('fromJson', () {
      test('should create ZweitmitgliedschaftData from valid JSON', () {
        final result = ZweitmitgliedschaftData.fromJson(validJson);

        expect(result.vereinId, equals(validData.vereinId));
        expect(result.vereinNr, equals(validData.vereinNr));
        expect(result.vereinName, equals(validData.vereinName));
        expect(result.eintrittVerein, equals(validData.eintrittVerein));
      });

      test('should throw FormatException for invalid date format', () {
        final invalidJson = Map<String, dynamic>.from(validJson)
          ..['EINTRITTVEREIN'] = 'invalid-date';

        expect(
          () => ZweitmitgliedschaftData.fromJson(invalidJson),
          throwsFormatException,
        );
      });

      test('should throw TypeError for missing required fields', () {
        final invalidJson = Map<String, dynamic>.from(validJson)
          ..remove('VEREINID');

        expect(
          () => ZweitmitgliedschaftData.fromJson(invalidJson),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group('toJson', () {
      test('should convert ZweitmitgliedschaftData to JSON', () {
        final result = validData.toJson();

        expect(result, equals(validJson));
      });

      test('should maintain ISO8601 date format', () {
        final result = validData.toJson();

        expect(
          result['EINTRITTVEREIN'],
          equals(validDate.toIso8601String()),
        );
      });
    });

    group('equality', () {
      test('should be equal to itself', () {
        expect(validData, equals(validData));
        expect(validData.hashCode, equals(validData.hashCode));
      });

      test('should be equal to identical data', () {
        final identicalData = ZweitmitgliedschaftData(
          vereinId: validData.vereinId,
          vereinNr: validData.vereinNr,
          vereinName: validData.vereinName,
          eintrittVerein: validData.eintrittVerein,
        );

        expect(validData, equals(identicalData));
        expect(validData.hashCode, equals(identicalData.hashCode));
      });

      test('should not be equal to different data', () {
        final differentData = ZweitmitgliedschaftData(
          vereinId: 2420,
          vereinNr: validData.vereinNr,
          vereinName: validData.vereinName,
          eintrittVerein: validData.eintrittVerein,
        );

        expect(validData, isNot(equals(differentData)));
        expect(validData.hashCode, isNot(equals(differentData.hashCode)));
      });
    });

    group('toString', () {
      test('should return formatted string representation', () {
        const expectedString = 'ZweitmitgliedschaftData(vereinId: 1474, '
            'vereinNr: 401006, vereinName: Vereinigte Sportschützen Paartal '
            'Aichach, eintrittVerein: 2012-02-26 00:00:00.000+01:00)';

        expect(validData.toString(), equals(expectedString));
      });
    });
  });
}
