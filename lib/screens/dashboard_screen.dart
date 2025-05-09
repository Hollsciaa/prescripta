import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:prescripta/services/auth_services.dart';
import 'package:prescripta/widgets/custom_drawer.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService authService = AuthService();
  final storage = FlutterSecureStorage();
  String username = "Utilisateur";
  String role = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final token = await authService.getToken();

    if (token.isNotEmpty) {
      final decodedToken = jsonDecode(
        ascii.decode(base64.decode(base64.normalize(token.split(".")[1]))),
      );

      setState(() {
        username = decodedToken['username'];
        role = decodedToken['role'] ?? "user";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("dashboard.title".tr())),
      drawer: CustomDrawer(currentPage: '/dashboard', role: role),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${"dashboard.welcome".tr()} $username 👋",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.go('/manage-clients');
              },
              child: Text("dashboard.manage_clients".tr()),
            ),
          ],
        ),
      ),
    );
  }
}
