import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'screens/camera_screen.dart';
import 'screens/emotion_result_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

/// Liste globale des caméras disponibles.
List<CameraDescription> cameras = <CameraDescription>[];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    cameras = await availableCameras();
  } catch (_) {
    // En cas d'erreur, on laisse simplement la liste vide
    // et on gérera l'absence de caméra dans l'UI.
    cameras = <CameraDescription>[];
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Emotion Adkār',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const LoginScreen(),
      routes: <String, WidgetBuilder>{
        '/camera': (BuildContext context) {
          if (cameras.isEmpty) {
            return _buildCameraErrorScreen(context);
          }

          // Sélection de la caméra frontale si disponible.
          CameraDescription selectedCamera = cameras.first;
          for (final CameraDescription camera in cameras) {
            if (camera.lensDirection == CameraLensDirection.front) {
              selectedCamera = camera;
              break;
            }
          }

          return CameraScreen(camera: selectedCamera);
        },
        '/home': (BuildContext context) => const HomeScreen(),
        '/emotion-result': (BuildContext context) {
          final Object? args = ModalRoute.of(context)?.settings.arguments;

          if (args is Map<String, dynamic>) {
            final String imagePath = args['imagePath'] as String;

            return EmotionResultScreen(
              imagePath: imagePath,
            );
          }

          // Fallback simple en cas de mauvais arguments.
          return Scaffold(
            appBar: AppBar(
              title: const Text('Résultat émotion'),
            ),
            body: const Center(
              child: Text('Paramètres invalides pour l\'écran de résultat.'),
            ),
          );
        },
      },
    );
  }
}

/// Écran simple affiché lorsqu’aucune caméra n’est disponible.
Widget _buildCameraErrorScreen(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Camera Error'),
    ),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            const Text(
              'No camera available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Aucune caméra n’a été détectée sur cet appareil. '
              'Veuillez vérifier vos permissions ou utiliser un autre appareil.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    ),
  );
}
