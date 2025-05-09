import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:prescripta/screens/saved_pdfs_screen.dart';
import 'package:prescripta/services/auth_services.dart';

class CustomDrawer extends StatelessWidget {
  final String currentPage;
  final String role;

  const CustomDrawer({
    super.key,
    required this.currentPage,
    required this.role,
  });

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(color: Colors.grey.shade600, thickness: 1.2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.lightBlue),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),

          // 🧭 Navigation
          buildSectionTitle('drawer.navigation'.tr()),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: Text('drawer.dashboard'.tr()),
            selected: currentPage == '/dashboard',
            selectedTileColor: Colors.deepPurple.shade50,
            onTap: () => context.go('/dashboard'),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text('drawer.profile'.tr()),
            selected: currentPage == '/profile',
            selectedTileColor: Colors.deepPurple.shade50,
            onTap: () => context.go('/profile'),
          ),
          buildDivider(),

          // 👥 Gestion des clients
          buildSectionTitle('drawer.client_management'.tr()),
          ListTile(
            leading: const Icon(Icons.groups),
            title: Text('drawer.clients'.tr()),
            selected: currentPage == '/manage-clients',
            selectedTileColor: Colors.deepPurple.shade50,
            onTap: () => context.go('/manage-clients'),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: Text('history.title'.tr()),
            selected: currentPage == '/saved-pdfs',
            selectedTileColor: Colors.deepPurple.shade50,
            onTap: () => context.go('/saved-pdfs'),
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: Text('drawer.catalog'.tr()),
            selected: currentPage == '/partner-catalog',
            selectedTileColor: Colors.deepPurple.shade50,
            onTap: () => context.go('/partner-catalog'),
          ),
          buildDivider(),

          // 🔐 Administration (réservé aux admins uniquement)
          if (role == "admin") ...[
            buildSectionTitle('drawer.administration'.tr()),
            ListTile(
              leading: const Icon(Icons.shield),
              title: Text('drawer.user_management'.tr()),
              onTap: () => context.go('/admin-users'),
              selected: currentPage == '/admin-users',
              selectedTileColor: Colors.deepPurple.shade50,
            ),
            buildDivider(),
          ],

          // ⚙️ Compte
          buildSectionTitle('drawer.account'.tr()),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text('drawer.settings'.tr()),
            selected: currentPage == '/settings',
            selectedTileColor: Colors.deepPurple.shade50,
            onTap: () => context.go('/settings'),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text('drawer.logout'.tr()),
            onTap: () {
              context.go('/login');
              // Ajouter la logique de déconnexion ici
            },
          ),
        ],
      ),
    );
  }
}
