import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Importation de la librairie flutter_secure_storage
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  final String apiUrl =
      "http://localhost:5000/api/auth"; // URL de l'API pour un Emulateur Android
  final storage = FlutterSecureStorage(); // Stockage sécurisé

  // Fonction de connexion utilisateur
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/api/auth/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // Stockage du token dans le stockage sécurisé
      await storage.write(key: 'jwt', value: data['token']);
      print("✅ Token stocké : ${data['token']}");

      return data;
    } else {
      print("⚠️ Erreur de connexion : ${data['message']}");
      throw Exception(data['message']);
    }
  }

  // Fonction d'inscription utilisateur
  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/api/auth/register'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      print("✅ Inscription réussie, token : ${data['token']}");
      return data;
    } else {
      throw Exception('Échec d\'inscription');
    }
  }

  // Récupération du token stocké
  Future<String> getToken() async {
    final token = await storage.read(key: 'jwt');
    if (token == null || token.isEmpty) {
      print("❌ Aucun token trouvé !");
    }
    return token ?? ""; // Retourne un string vide si aucun token n'est trouvé
  }

  // Déconnexion utilisateur
  Future<void> logout() async {
    await storage.delete(key: 'jwt');
    print("❌ Déconnecté, Token supprimé");
  }

  // Récupérer tous les utilisateurs
  Future<List<Map<String, dynamic>>> getUsers() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/api/users/all'),
      headers: {
        "Authorization": "Bearer ${await getToken()}",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      for (var user in data) {
        user['role'] = user['role'] ?? "user";
      }

      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('❌ Erreur de récupération des utilisateurs');
    }
  }

  // Promouvoir un utilisateur en admin
  Future<void> promoteToAdmin(String userId) async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:5000/api/users/set-admin/$userId'),
      headers: {
        "Authorization": "Bearer ${await getToken()}",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode != 200) {
      print("❌ Erreur lors de la promotion : ${response.body}");
      throw Exception('❌ Erreur de promotion');
    }
  }

  // Rétrograder un admin en utilisateur
  Future<void> demoteToUser(String userId) async {
    final response = await http.put(
      Uri.parse(
        'http://10.0.2.2:5000/api/users/remove-admin/$userId',
      ), // 🔧 Correction de l'URL
      headers: {
        "Authorization": "Bearer ${await getToken()}",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode != 200) {
      print("❌ Erreur lors de la rétrogradation : ${response.body}");
      throw Exception('❌ Erreur de rétrogradation');
    }
  }

  // Récupérer tous les utilisateurs (admin seulement)
  Future<List<dynamic>> fetchAllUsers() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/api/users/all'),
      headers: {
        "Authorization": "Bearer ${await getToken()}",
        "Contrnt-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("❌ Erreur API : ${response.body}");
      throw Exception('❌ Erreur de récupération des utilisateurs');
    }
  }

  // Supprimer un utilisateur
  Future<void> deleteUser(String userId) async {
    final authService = AuthService();
    final token = await authService.getToken();
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:5000/api/users/delete/$userId'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      print("Utilisateur supprimé avec succès");
    } else {
      print("❌ Erreur lors de la suppression : ${response.body}");
      throw Exception('❌ Impossible de supprimer l\'utilisateur');
    }
  }

  // Décoder le token JWT pour récupérer les informations utilisateurs
  Future<Map<String, dynamic>> decodeToken(String token) async {
    try {
      final parts = token.split('.');
      if (parts.length != 3) throw Exception("Format de token invalide");

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));

      return jsonDecode(decoded);
    } catch (e) {
      print("❌ Erreur lors du décodage du token : $e");
      throw Exception("Erreur de décodage du token");
    }
  }

  // Changer le mot de passe
  Future<String> changePassword(String oldPassword, String newPassword) async {
    try {
      final token =
          await getToken(); // Récupère le token depuis le stockage sécurisé
      print("🔧 Token récupéré : $token");

      if (token.isEmpty) {
        throw Exception("Token manquant ou invalide");
      }

      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/profile/change-password'),
        headers: {
          "Authorization": "Bearer $token", // Envoie le token ici
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "oldPassword": oldPassword,
          "newPassword": newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return "Mot de passe changé avec succès";
      } else {
        print(
          "🔧 Réponse du serveur : ${response.statusCode}, ${response.body}",
        );
        throw Exception('❌ Impossible de changer le mot de passe');
      }
    } catch (error) {
      print("❌ Erreur lors du changement de mot de passe : $error");
      throw Exception('❌ Impossible de changer le mot de passe');
    }
  }

  Future<bool> isAdmin() async {
    final token = await getToken();
    if (token.isEmpty) return false;

    final decoded = await decodeToken(token);
    return decoded['role'] == 'admin';
  }

  Future<String> getUserId() async {
    final token = await storage.read(key: 'token');
    if (token != null && token.isNotEmpty) {
      final decoded = JwtDecoder.decode(token);
      return decoded['_id'] ?? ''; // ou 'id' selon ton backend
    }
    return '';
  }

  Future<String> getUserRole() async {
    final token = await storage.read(key: 'token');
    if (token != null && token.isNotEmpty) {
      final decoded = JwtDecoder.decode(token);
      return decoded['role'] ?? '';
    }
    return '';
  }
}
