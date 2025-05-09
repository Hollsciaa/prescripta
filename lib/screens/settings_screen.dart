import 'package:flutter/material.dart';
import 'package:prescripta/services/auth_services.dart';
import 'package:prescripta/widgets/custom_drawer.dart';
import 'dart:convert';
import 'package:prescripta/screens/theme_provider.dart';
import 'package:prescripta/screens/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService authService = AuthService();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  String role = "user";
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    try {
      final token = await authService.getToken();
      if (token.isNotEmpty) {
        final decodedToken = jsonDecode(
          ascii.decode(base64.decode(base64.normalize(token.split(".")[1]))),
        );

        setState(() {
          role = decodedToken['role'] ?? "user";
        });
        print("🔧 Rôle chargé : $role");
      }
    } catch (error) {
      print("❌ Erreur lors du chargement du rôle : $error");
    }
  }

  Future<void> _changePassword(String oldPassword, String newPassword) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await authService.changePassword(oldPassword, newPassword);

      if (result == "Mot de passe changé avec succès") {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('settings.success'.tr())));
        oldPasswordController.clear();
        newPasswordController.clear();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('settings.error'.tr())));
      }
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('settings.error'.tr())));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.toggleTheme();
  }

  void _changeLanguage(String langCode) {
    context.setLocale(Locale(langCode));
  }

  @override
  Widget build(BuildContext context) {
    final currentLangCode = context.locale.languageCode;

    return Scaffold(
      appBar: AppBar(title: Text("settings.title".tr())),
      drawer: CustomDrawer(currentPage: '/settings', role: role),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: Text(
                "settings.theme".tr(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Switch(value: _isDarkMode, onChanged: _toggleTheme),
            ),
            SizedBox(height: 20),
            ListTile(
              title: Text(
                "settings.language".tr(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: DropdownButton<String>(
                value: currentLangCode,
                items:
                    ['fr', 'en'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value == 'fr' ? 'Français' : 'English'),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    _changeLanguage(newValue);
                  }
                },
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: oldPasswordController,
              obscureText: _obscureOldPassword,
              decoration: InputDecoration(
                labelText: "settings.old_password".tr(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureOldPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureOldPassword = !_obscureOldPassword;
                    });
                  },
                ),
              ),
            ),
            TextField(
              controller: newPasswordController,
              obscureText: _obscureNewPassword,
              decoration: InputDecoration(
                labelText: "settings.new_password".tr(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (oldPasswordController.text.isNotEmpty &&
                    newPasswordController.text.isNotEmpty) {
                  _changePassword(
                    oldPasswordController.text,
                    newPasswordController.text,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('settings.missing_fields'.tr())),
                  );
                }
              },
              child:
                  _isLoading
                      ? CircularProgressIndicator()
                      : Text("settings.change_password".tr()),
            ),
          ],
        ),
      ),
    );
  }
}
