
bool validateIBAN(String iban) {
  iban = iban.toUpperCase().replaceAll(' ', ''); // Remove spaces and uppercase

  if (!RegExp(r'^[A-Z0-9]+$').hasMatch(iban)) {
    return false; // Invalid characters
  }

  if (iban.length < 5) {
    return false; // Too short to be a valid IBAN
  }

  String countryCode = iban.substring(0, 2);
  String checkDigits = iban.substring(2, 4);
  String bban = iban.substring(4);

  String movedIban = bban + countryCode + checkDigits;

  String numericIban = '';
  for (int i = 0; i < movedIban.length; i++) {
    String char = movedIban[i];
    if (RegExp(r'^[0-9]$').hasMatch(char)) {
      numericIban += char;
    } else {
      numericIban += (char.codeUnitAt(0) - 55).toString(); // A=10, B=11, ...
    }
  }

  int remainder = _mod97(numericIban);

  return remainder == 1;
}

int _mod97(String numericIban) {
  int remainder = 0;
  for (int i = 0; i < numericIban.length; i++) {
    remainder = (remainder * 10 + int.parse(numericIban[i])) % 97;
  }
  return remainder;
}
/*
void main() {
  String iban1 = 'GB82 WEST 1234 5698 7654 32';
  String iban2 = 'DE89 3704 0044 0532 0130 00';
  String iban3 = 'GB82WEST12345698765432';
  String iban4 = 'DE89370400440532013000';
  String iban5 = "FR1420041010050500013M02606";
  String iban6 = "FR14 20041 01005 0500013M026 06";

  print('IBAN 1 is ${validateIBAN(iban1) ? 'valid' : 'invalid'}');
  print('IBAN 2 is ${validateIBAN(iban2) ? 'valid' : 'invalid'}');
  print('IBAN 3 is ${validateIBAN(iban3) ? 'valid' : 'invalid'}');
  print('IBAN 4 is ${validateIBAN(iban4) ? 'valid' : 'invalid'}');
  print('IBAN 5 is ${validateIBAN(iban5) ? 'valid' : 'invalid'}');
  print('IBAN 6 is ${validateIBAN(iban6) ? 'valid' : 'invalid'}');
}
*/