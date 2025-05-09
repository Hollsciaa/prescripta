import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:prescripta/models/client.dart';
import 'package:prescripta/services/auth_services.dart';

class ClientService {
  final String baseUrl = 'http://10.0.2.2:5000/api/clients';
  final storage = FlutterSecureStorage();

  Future<String> getToken() async {
    return await storage.read(key: 'jwt') ?? "";
  }

  // ✅ Créer un client
  Future<Client> createClient(Client client) async {
    final token = await getToken();

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(client.toJson()),
    );

    if (response.statusCode == 201) {
      return Client.fromJson(jsonDecode(response.body));
    } else {
      print("❌ Erreur lors de la création du client : ${response.body}");
      throw Exception("Erreur de création client");
    }
  }

  Future<List<Client>> fetchClients() async {
    final token = await AuthService().getToken();

    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/api/clients'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Client.fromJson(json)).toList();
    } else {
      print("❌ Erreur API : ${response.statusCode}, ${response.body}");
      throw Exception("Erreur lors du chargement des clients");
    }
  }

  Future<void> deleteClient(String clientId) async {
    final token = await getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/$clientId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      print("❌ Erreur suppression client : ${response.body}");
      throw Exception("Erreur de suppression");
    }
  }

  Future<void> updateClient(Client client) async {
    final token = await getToken();

    final response = await http.put(
      Uri.parse('$baseUrl/${client.id}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(client.toJson()),
    );

    if (response.statusCode != 200) {
      print("❌ Erreur update client : ${response.body}");
      throw Exception("Erreur mise à jour du client");
    }
  }
}
