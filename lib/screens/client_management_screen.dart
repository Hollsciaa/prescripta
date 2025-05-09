import 'package:flutter/material.dart';
import 'package:prescripta/widgets/custom_drawer.dart';
import 'package:prescripta/models/client.dart';
import 'package:prescripta/services/client_services.dart';
import 'package:prescripta/screens/client_form_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:prescripta/services/auth_services.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ClientManagementScreen extends StatefulWidget {
  const ClientManagementScreen({super.key});

  @override
  State<ClientManagementScreen> createState() => _ClientManagementScreenState();
}

class _ClientManagementScreenState extends State<ClientManagementScreen> {
  List<Client> clients = [];
  List<Client> filteredClients = [];
  final searchController = TextEditingController();
  final AuthService authService = AuthService();
  String role = "";

  @override
  void initState() {
    super.initState();
    _loadClients();
    _loadUserRole();
    searchController.addListener(_filterClients);
  }

  Future<void> _loadUserRole() async {
    final token = await AuthService().getToken();
    if (token.isNotEmpty) {
      final decodedToken = JwtDecoder.decode(token);
      setState(() {
        role = decodedToken["role"] ?? "";
      });
    }
  }

  Future<void> _loadClients() async {
    try {
      final fetchedClients = await ClientService().fetchClients();
      print("✅ Clients récupérés : $fetchedClients");
      setState(() {
        clients = fetchedClients;
        filteredClients = fetchedClients;
      });
    } catch (e) {
      print('❌ Erreur lors du chargement des clients : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de chargement des clients")),
      );
    }
  }

  void _filterClients() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredClients =
          clients.where((client) {
            return client.firstName.toLowerCase().contains(query) ||
                client.name.toLowerCase().contains(query) ||
                client.email.toLowerCase().contains(query);
          }).toList();
    });
  }

  void _addOrEditClient({Client? client}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ClientFormScreen(client: client)),
    ).then((_) => _loadClients());
  }

  void _confirmDelete(Client client) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('clients.delete_confirm_title'.tr()),
            content: Text('clients.delete_confirm_message'.tr()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('clients.delete_confirm_cancel'.tr()),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  try {
                    await ClientService().deleteClient(client.id!);
                    _loadClients();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("clients.deleted_success".tr())),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("clients.delete_error".tr())),
                    );
                  }
                },
                child: Text(
                  'clients.delete_confirm_confirm'.tr(),
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("clients.title".tr()),
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
      ),
      drawer: CustomDrawer(currentPage: '/manage-clients', role: role),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔍 Barre de recherche
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "clients.search_hint".tr(),
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 16),

            // 📋 Liste filtrée
            Expanded(
              child:
                  filteredClients.isEmpty
                      ? Center(child: Text("clients.empty".tr()))
                      : ListView.builder(
                        itemCount: filteredClients.length,
                        itemBuilder: (context, index) {
                          final client = filteredClients[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Text(client.firstName[0]),
                                foregroundColor: Colors.white,
                              ),
                              title: Text('${client.firstName} ${client.name}'),
                              subtitle: Text(client.email),
                              onTap: () => _addOrEditClient(client: client),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmDelete(client),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditClient(),
        child: Icon(Icons.add),
      ),
    );
  }
}
