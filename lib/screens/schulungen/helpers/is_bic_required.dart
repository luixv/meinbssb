bool isBicRequired(String iban) {
  return !iban.toUpperCase().startsWith('DE');
}
