String extractPhoneNumber(List<Map<String, dynamic>> contacts) {
  final privateContacts = contacts.firstWhere(
    (category) => category['category'] == 'Privat',
    orElse: () => {'contacts': []},
  )['contacts'] as List<dynamic>;
  var phoneContact = privateContacts.cast<Map<String, dynamic>>().firstWhere(
        (contact) =>
            contact['rawKontaktTyp'] == 1 || contact['rawKontaktTyp'] == 2,
        orElse: () => {'value': ''},
      );
  if (phoneContact['value'] == '') {
    final businessContacts = contacts.firstWhere(
      (category) => category['category'] == 'Geschäftlich',
      orElse: () => {'contacts': []},
    )['contacts'] as List<dynamic>;
    phoneContact = businessContacts.cast<Map<String, dynamic>>().firstWhere(
          (contact) =>
              contact['rawKontaktTyp'] == 5 || contact['rawKontaktTyp'] == 6,
          orElse: () => {'value': ''},
        );
  }
  return phoneContact['value'] as String;
}
