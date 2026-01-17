import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// Service d'authentification centralisé pour l'application Emotion Adkār.
class AuthService {
  /// Base URL de l'API FastAPI.
  ///
  /// 10.0.2.2 correspond au localhost de la machine hôte
  /// lorsqu'on utilise l'émulateur Android. Pour un appareil
  /// physique ou iOS, adaptez cette valeur (ex: IP du PC).
  static const String baseUrl = 'http://10.0.2.2:8000';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Inscription d'un nouvel utilisateur.
  ///
  /// Retourne:
  ///   - {'user': data} en cas de succès
  ///   - {'error': 'message'} en cas d'erreur
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final Uri url = Uri.parse('$baseUrl/auth/register');

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return <String, dynamic>{'user': data};
      } else {
        return <String, dynamic>{
          'error': data['detail']?.toString() ??
              "Erreur lors de l'inscription. Veuillez réessayer."
        };
      }
    } catch (e) {
      // On garde un message simple pour l'utilisateur.
      return <String, dynamic>{
        'error': 'Erreur de connexion au serveur. Veuillez vérifier votre réseau.'
      };
    }
  }

  /// Connexion d'un utilisateur.
  ///
  /// Retourne:
  ///   - {'access_token': token, 'user': data['user']} en cas de succès
  ///   - {'error': 'message'} en cas d'erreur
  Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final Uri url = Uri.parse('$baseUrl/auth/login');

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'email': email,
          'password': password,
        }),
      );

      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final String? token = data['access_token']?.toString();
        final dynamic user = data['user'];

        if (token != null && token.isNotEmpty) {
          await saveToken(token);
        }

        return <String, dynamic>{
          'access_token': token,
          'user': user,
        };
      } else {
        return <String, dynamic>{
          'error': data['detail']?.toString() ??
              'Identifiants invalides. Veuillez vérifier vos informations.',
        };
      }
    } catch (e) {
      return <String, dynamic>{
        'error': 'Erreur de connexion au serveur. Veuillez vérifier votre réseau.'
      };
    }
  }

  /// Sauvegarde manuelle d'un token dans le stockage sécurisé.
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'jwt_token', value: token);
  }

  /// Récupère les informations de l'utilisateur courant via /me.
  Future<Map<String, dynamic>?> getMe() async {
    final String? token = await _secureStorage.read(key: 'jwt_token');
    if (token == null || token.isEmpty) {
      return null;
    }

    final Uri url = Uri.parse('$baseUrl/me');

    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Déconnexion : suppression du token JWT.
  Future<void> logout() async {
    await _secureStorage.delete(key: 'jwt_token');
  }
}



