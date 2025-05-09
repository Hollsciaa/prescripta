import 'package:flutter/material.dart';
import 'package:prescripta/services/auth_services.dart';
import 'package:prescripta/widgets/custom_drawer.dart';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  _AdminUsersScreenState createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final AuthService authService = AuthService();
  List<dynamic> users = [];
  String _errorMessage = "";
  bool isLoading = true;
  String role = "";

  @override
  void initState() {
    super.initState();
    _loadRole();
    _loadUsers();
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
      }
    } catch (error) {
      print("❌ Error loading role: $error");
    }
  }

  Future<void> _loadUsers() async {
    try {
      final List<dynamic> fetchedUsers = await authService.getUsers();
      setState(() {
        users = fetchedUsers;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        _errorMessage = "admin_users.error_loading".tr();
      });
    }
  }

  Future<void> _promoteOrDemote(String userId, bool isPromote) async {
    try {
      if (isPromote) {
        await authService.promoteToAdmin(userId);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("admin_users.promoted".tr())));
      } else {
        await authService.demoteToUser(userId);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("admin_users.demoted".tr())));
      }
      await _loadUsers();
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("admin_users.error_action".tr())));
    }
  }

  Future<void> _removeUser(String userId) async {
    try {
      await authService.deleteUser(userId);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("admin_users.deleted".tr())));
      await _loadUsers();
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("admin_users.error_delete".tr())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("admin_users.title".tr()),
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
      ),
      drawer: CustomDrawer(currentPage: '/admin-users', role: role),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    title: Row(
                      children: [
                        Text(
                          user['username'] ?? "Inconnu",
                          style: TextStyle(
                            fontWeight:
                                user['role'] == 'admin'
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            color:
                                user['role'] == 'admin'
                                    ? Colors.red
                                    : Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                          ),
                        ),
                        if (user['role'] == 'admin')
                          Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Row(
                              children: [
                                Tooltip(
                                  message: 'Admin',
                                  child: Icon(
                                    Icons.verified_user,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'admin_users.admin'.tr(),
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text(user['email'] ?? ""),
                    trailing: PopupMenuButton<String>(
                      onSelected: (String value) async {
                        if (value == 'promote') {
                          await _promoteOrDemote(
                            user['_id'],
                            user['role'] != 'admin',
                          );
                        } else if (value == 'delete') {
                          await _removeUser(user['_id']);
                        }
                      },
                      itemBuilder:
                          (BuildContext context) => <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              value: 'promote',
                              child: Text(
                                user['role'] == 'admin'
                                    ? "admin_users.remove_admin".tr()
                                    : "admin_users.make_admin".tr(),
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Text("admin_users.delete".tr()),
                            ),
                          ],
                    ),
                  );
                },
              ),
    );
  }
}
