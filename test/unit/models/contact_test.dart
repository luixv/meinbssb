import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/contact.dart';

void main() {
  test('Contact creates instance from JSON', () {
    final json = {
      'KONTAKTID': 1,
      'PERSONID': 2,
      'KONTAKTTYP': 1,
      'KONTAKT': 'john.doe@example.com',
    };

    final contact = Contact.fromJson(json);

    expect(contact.id, 1);
    expect(contact.personId, 2);
    expect(contact.type, 1);
    expect(contact.value, 'john.doe@example.com');
  });
}
