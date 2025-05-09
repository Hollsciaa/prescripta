import 'package:flutter/services.dart';

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Ne garde que les 10 premiers chiffres
    if (digits.length > 10) {
      digits = digits.substring(0, 10);
    }

    String formatted = '';
    for (int i = 0; i < digits.length; i++) {
      if (i % 2 == 0 && i != 0) {
        formatted += '.';
      }
      formatted += digits[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
