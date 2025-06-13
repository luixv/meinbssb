import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/contact.dart';

void main() {
  group('Contact', () {
    test('creates Contact from JSON with uppercase fields', () {
      final json = {
        'KONTAKTID': 1,
        'PERSONID': 123,
        'KONTAKTTYP': 4,
        'KONTAKT': 'test@example.com',
      };

      final contact = Contact.fromJson(json);

      expect(contact.id, equals(1));
      expect(contact.personId, equals(123));
      expect(contact.type, equals(4));
      expect(contact.value, equals('test@example.com'));
    });

    test('creates Contact from JSON with mixed case fields', () {
      final json = {
        'KontaktID': 1,
        'PersonID': 123,
        'KontaktTyp': 4,
        'Kontakt': 'test@example.com',
      };

      final contact = Contact.fromJson(json);

      expect(contact.id, equals(1));
      expect(contact.personId, equals(123));
      expect(contact.type, equals(4));
      expect(contact.value, equals('test@example.com'));
    });

    test('throws FormatException when required fields are missing', () {
      final json = {
        'KONTAKTID': 1,
        'PERSONID': 123,
        // Missing type and value
      };

      expect(
        () => Contact.fromJson(json),
        throwsFormatException,
      );
    });

    test('converts Contact to JSON', () {
      const contact = Contact(
        id: 1,
        personId: 123,
        type: 4,
        value: 'test@example.com',
      );

      final json = contact.toJson();

      expect(json['KONTAKTID'], equals(1));
      expect(json['PERSONID'], equals(123));
      expect(json['KONTAKTTYP'], equals(4));
      expect(json['KONTAKT'], equals('test@example.com'));
    });

    test('copyWith creates new instance with updated fields', () {
      const contact = Contact(
        id: 1,
        personId: 123,
        type: 4,
        value: 'test@example.com',
      );

      final updatedContact = contact.copyWith(
        value: 'new@example.com',
        type: 8,
      );

      expect(updatedContact.id, equals(1));
      expect(updatedContact.personId, equals(123));
      expect(updatedContact.type, equals(8));
      expect(updatedContact.value, equals('new@example.com'));
    });

    test('typeLabel returns correct label for each type', () {
      const Map<int, String> expectedLabels = {
        1: 'Telefonnummer Privat',
        2: 'Mobilnummer Privat',
        3: 'Fax Privat',
        4: 'E-Mail Privat',
        5: 'Telefonnummer Geschäftlich',
        6: 'Mobilnummer Geschäftlich',
        7: 'Fax Geschäftlich',
        8: 'E-Mail Geschäftlich',
      };

      for (final entry in expectedLabels.entries) {
        final contact = Contact(
          id: 1,
          personId: 123,
          type: entry.key,
          value: 'test@example.com',
        );

        expect(contact.typeLabel, equals(entry.value));
      }
    });

    test('typeLabel returns unknown label for invalid type', () {
      const contact = Contact(
        id: 1,
        personId: 123,
        type: 999,
        value: 'test@example.com',
      );

      expect(contact.typeLabel, equals('Unbekannter Kontakt (999)'));
    });

    test('isPrivate returns true for private contact types', () {
      for (var type = 1; type <= 4; type++) {
        final contact = Contact(
          id: 1,
          personId: 123,
          type: type,
          value: 'test@example.com',
        );

        expect(contact.isPrivate, isTrue);
      }
    });

    test('isPrivate returns false for business contact types', () {
      for (var type = 5; type <= 8; type++) {
        final contact = Contact(
          id: 1,
          personId: 123,
          type: type,
          value: 'test@example.com',
        );

        expect(contact.isPrivate, isFalse);
      }
    });

    test('isBusiness returns true for business contact types', () {
      for (var type = 5; type <= 8; type++) {
        final contact = Contact(
          id: 1,
          personId: 123,
          type: type,
          value: 'test@example.com',
        );

        expect(contact.isBusiness, isTrue);
      }
    });

    test('isBusiness returns false for private contact types', () {
      for (var type = 1; type <= 4; type++) {
        final contact = Contact(
          id: 1,
          personId: 123,
          type: type,
          value: 'test@example.com',
        );

        expect(contact.isBusiness, isFalse);
      }
    });

    test('isEmail returns true for email contact types', () {
      const contact1 = Contact(
        id: 1,
        personId: 123,
        type: 4,
        value: 'test@example.com',
      );

      const contact2 = Contact(
        id: 2,
        personId: 123,
        type: 8,
        value: 'test@example.com',
      );

      expect(contact1.isEmail, isTrue);
      expect(contact2.isEmail, isTrue);
    });

    test('isEmail returns false for non-email contact types', () {
      for (var type = 1; type <= 8; type++) {
        if (type == 4 || type == 8) continue;

        final contact = Contact(
          id: 1,
          personId: 123,
          type: type,
          value: 'test@example.com',
        );

        expect(contact.isEmail, isFalse);
      }
    });

    test('isPhone returns true for phone contact types', () {
      const contact1 = Contact(
        id: 1,
        personId: 123,
        type: 1,
        value: '123456789',
      );

      const contact2 = Contact(
        id: 2,
        personId: 123,
        type: 2,
        value: '123456789',
      );

      const contact3 = Contact(
        id: 3,
        personId: 123,
        type: 5,
        value: '123456789',
      );

      const contact4 = Contact(
        id: 4,
        personId: 123,
        type: 6,
        value: '123456789',
      );

      expect(contact1.isPhone, isTrue);
      expect(contact2.isPhone, isTrue);
      expect(contact3.isPhone, isTrue);
      expect(contact4.isPhone, isTrue);
    });

    test('isPhone returns false for non-phone contact types', () {
      for (var type = 1; type <= 8; type++) {
        if (type == 1 || type == 2 || type == 5 || type == 6) continue;

        final contact = Contact(
          id: 1,
          personId: 123,
          type: type,
          value: 'test@example.com',
        );

        expect(contact.isPhone, isFalse);
      }
    });

    test('isFax returns true for fax contact types', () {
      const contact1 = Contact(
        id: 1,
        personId: 123,
        type: 3,
        value: '123456789',
      );

      const contact2 = Contact(
        id: 2,
        personId: 123,
        type: 7,
        value: '123456789',
      );

      expect(contact1.isFax, isTrue);
      expect(contact2.isFax, isTrue);
    });

    test('isFax returns false for non-fax contact types', () {
      for (var type = 1; type <= 8; type++) {
        if (type == 3 || type == 7) continue;

        final contact = Contact(
          id: 1,
          personId: 123,
          type: type,
          value: 'test@example.com',
        );

        expect(contact.isFax, isFalse);
      }
    });

    test('isValidType returns true for valid types', () {
      for (var type = 1; type <= 8; type++) {
        expect(Contact.isValidType(type), isTrue);
      }
    });

    test('isValidType returns false for invalid types', () {
      expect(Contact.isValidType(0), isFalse);
      expect(Contact.isValidType(9), isFalse);
      expect(Contact.isValidType(-1), isFalse);
      expect(Contact.isValidType(999), isFalse);
    });

    test('equality operator works correctly', () {
      const contact1 = Contact(
        id: 1,
        personId: 123,
        type: 4,
        value: 'test@example.com',
      );

      const contact2 = Contact(
        id: 1,
        personId: 123,
        type: 4,
        value: 'test@example.com',
      );

      const contact3 = Contact(
        id: 2,
        personId: 456,
        type: 8,
        value: 'different@example.com',
      );

      expect(contact1, equals(contact2));
      expect(contact1, isNot(equals(contact3)));
    });

    test('hashCode is consistent with equality', () {
      const contact1 = Contact(
        id: 1,
        personId: 123,
        type: 4,
        value: 'test@example.com',
      );

      const contact2 = Contact(
        id: 1,
        personId: 123,
        type: 4,
        value: 'test@example.com',
      );

      expect(contact1.hashCode, equals(contact2.hashCode));
    });

    test('toString returns correct representation', () {
      const contact = Contact(
        id: 1,
        personId: 123,
        type: 4,
        value: 'test@example.com',
      );

      expect(
        contact.toString(),
        equals(
          'Contact(id: 1, personId: 123, type: 4, value: test@example.com)',
        ),
      );
    });
  });
}
