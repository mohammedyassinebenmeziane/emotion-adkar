import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

/// Service responsable des appels à l'API de détection d'émotion.
class EmotionApiService {
  /// Base URL de l'API FastAPI.
  static const String baseUrl = 'http://10.0.2.2:8000';

  /// Envoie une image au backend pour détecter l'émotion.
  ///
  /// Retourne une map contenant au minimum :
  ///  - 'emotion' : String
  ///  - 'confidence' : double
  ///  - 'douaa' : String
  ///  - 'ayah_text' : String
  ///  - 'ayah_reference' : String
  ///  - 'explanation_fr' : String
  ///
  /// En cas d'erreur, une exception est levée avec un message explicite.
  Future<Map<String, dynamic>> detectEmotion(File imageFile) async {
    final Uri uri = Uri.parse('$baseUrl/emotion/predict');

    final String fileName = imageFile.path.split(Platform.pathSeparator).last;
    final String lower = fileName.toLowerCase();

    // On choisit le bon type MIME selon l'extension.
    final MediaType mediaType;
    if (lower.endsWith('.png')) {
      mediaType = MediaType('image', 'png');
    } else {
      mediaType = MediaType('image', 'jpeg');
    }

    try {
      print('[EmotionAPI] Starting request to $uri');
      print('[EmotionAPI] Image file size: ${await imageFile.length()} bytes');

      final Stopwatch stopwatch = Stopwatch()..start();

      final http.MultipartRequest request = http.MultipartRequest('POST', uri)
        ..files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
            contentType: mediaType,
          ),
        );

      print('[EmotionAPI] Sending request...');
      final http.StreamedResponse streamedResponse =
          await request.send().timeout(const Duration(seconds: 300));

      print('[EmotionAPI] Received response, status: ${streamedResponse.statusCode}');
      final http.Response response =
          await http.Response.fromStream(streamedResponse);

      stopwatch.stop();
      print('[EmotionAPI] Total request time: ${stopwatch.elapsedMilliseconds}ms');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;

        final String emotion = data['emotion']?.toString() ?? 'neutral';
        final double confidence =
            (data['confidence'] as num?)?.toDouble() ?? 0.0;
        final String douaa = data['douaa']?.toString() ?? '';
        final String ayahText = data['ayah_text']?.toString() ?? '';
        final String ayahReference = data['ayah_reference']?.toString() ?? '';
        final String explanationFr = data['explanation_fr']?.toString() ?? '';

        print('[EmotionAPI] Received: emotion=$emotion, confidence=$confidence');
        print('[EmotionAPI] Douaa length: ${douaa.length} chars');
        print('[EmotionAPI] Ayah: $ayahReference');
        print('[EmotionAPI] Explanation length: ${explanationFr.length} chars');

        return <String, dynamic>{
          'emotion': emotion,
          'confidence': confidence,
          'douaa': douaa,
          'ayah_text': ayahText,
          'ayah_reference': ayahReference,
          'explanation_fr': explanationFr,
        };
      } else {
        // Tentative de récupération d'un message d'erreur plus précis.
        try {
          final dynamic body = jsonDecode(response.body);
          String message = 'Unknown error';
          if (body is Map<String, dynamic> && body['detail'] != null) {
            message = body['detail'].toString();
          } else {
            message = body.toString();
          }
          throw Exception('Server error: $message');
        } catch (_) {
          throw Exception(
            'Server error: HTTP ${response.statusCode}. '
            'Veuillez réessayer plus tard.',
          );
        }
      }
    } on SocketException {
      throw Exception(
        'No internet connection or server is not reachable. '
        'Veuillez vérifier votre connexion réseau.',
      );
    } on TimeoutException {
      throw Exception(
        'La requête a expiré. Le serveur met trop de temps à répondre.',
      );
    } on FormatException {
      throw Exception(
        'Invalid response format from server. '
        'La réponse du serveur est invalide.',
      );
    } catch (e) {
      // On relance l'erreur pour que l'UI puisse afficher un message approprié.
      throw Exception(e.toString());
    }
  }

  /// Test simple pour vérifier que le backend est accessible.
  Future<bool> testConnection() async {
    final Uri uri = Uri.parse('$baseUrl/docs');

    try {
      final http.Response response = await http
          .get(uri)
          .timeout(const Duration(seconds: 5), onTimeout: () => http.Response('', 408));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}



