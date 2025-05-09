import 'package:flutter/material.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = Locale('fr', ''); // Valeur par défaut: français

  Locale get locale => _locale;

  // Changer la langue
  void changeLanguage(Locale newLocale) {
    _locale = newLocale;
    notifyListeners();
  }

  // Vérifier si la langue actuelle est l'anglais
  bool get isEnglish => _locale.languageCode == 'en';
}
