import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:prescripta/services/auth_services.dart';
import 'package:prescripta/widgets/custom_drawer.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService authService = AuthService();
  final storage = FlutterSecureStorage();

  String username = "Utilisateur";
  String email = "Email";
  String role = "user";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final token = await authService.getToken();

    if (token.isNotEmpty) {
      final decodedToken = await authService.decodeToken(token);
      setState(() {
        username = decodedToken['username'] ?? "Utilisateur";
        email = decodedToken['email'] ?? "Email";
        role = decodedToken['role'] ?? "user";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("profile.title".tr())),
      drawer: CustomDrawer(currentPage: '/profile', role: role),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              username,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(email, style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            if (role == "admin")
              Chip(
                label: Text("profile.admin".tr()),
                backgroundColor: Colors.red,
                labelStyle: TextStyle(color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}
