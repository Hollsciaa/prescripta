import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  // Change le thème de l'application (sombre/clair)
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners(); // Notifie les widgets qui écoutent ce provider
  }
}
