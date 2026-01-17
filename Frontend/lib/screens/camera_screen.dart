import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../services/emotion_api.dart';
import 'emotion_result_screen.dart';

/// Écran de prise de selfie et d'envoi à l'API d'émotion.
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key, required this.camera});

  final CameraDescription camera;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isProcessing = false;
  String? _errorMessage;

  final EmotionApiService _emotionApi = EmotionApiService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    final CameraController newController = CameraController(
      widget.camera,
      ResolutionPreset.low, // Use lower resolution for faster processing
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    _controller = newController;

    _initializeControllerFuture = newController.initialize().then((_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = null;
      });
    }).catchError((Object e) {
      setState(() {
        _errorMessage = 'Impossible d’initialiser la caméra.';
      });
    });

    setState(() {});
  }

  Future<void> _captureAndAnalyze() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await _initializeControllerFuture;

      // Capture with lower resolution for faster processing
      final XFile file = await _controller!.takePicture();

      // Process image in a separate isolate to avoid blocking UI
      final String processedPath = await _processImageInBackground(file.path);

      if (!mounted) return;

      // Navigate immediately to result screen with the captured image
      // The result screen will handle the API call and show loading state
      Navigator.of(context).push(
        MaterialPageRoute<EmotionResultScreen>(
          builder: (BuildContext context) => EmotionResultScreen(
            imagePath: processedPath,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  /// Process image in background to avoid blocking UI
  Future<String> _processImageInBackground(String imagePath) async {
    // Read and process image
    final Uint8List bytes = await File(imagePath).readAsBytes();
    final img.Image? capturedImage = img.decodeImage(bytes);

    if (capturedImage == null) {
      throw Exception('Impossible de decoder l\'image capturee.');
    }

    // Resize image for faster processing (max 480px width for smaller file size)
    img.Image resized = capturedImage;
    if (capturedImage.width > 480) {
      resized = img.copyResize(capturedImage, width: 480);
    }

    // Pour la caméra frontale, on applique un flip horizontal pour corriger l'effet miroir.
    final img.Image flipped = img.flipHorizontal(resized);

    // Sauvegarde en JPEG optimisé dans le répertoire temporaire.
    final Directory tempDir = await getTemporaryDirectory();
    final String fileName =
        'emotion_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String jpgPath = p.join(tempDir.path, fileName);

    // Use lower quality for faster encoding and much smaller file size
    final File jpgFile = File(jpgPath)
      ..writeAsBytesSync(img.encodeJpg(flipped, quality: 60));

    return jpgPath;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _buildTopBar(context),
            Expanded(
              child: _buildCameraPreview(),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: <Widget>[
          _buildCircleButton(
            icon: Icons.arrow_back_ios_new,
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Emotion Detection',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildCircleButton(
            icon: Icons.info_outline,
            onTap: _showInfoDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      );
    }

    final CameraController? controller = _controller;

    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    // On utilise LayoutBuilder + Transform.scale pour remplir l'écran
    // tout en préservant le ratio de la caméra.
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double screenRatio =
            constraints.maxWidth / constraints.maxHeight;
        final double previewRatio = controller.value.aspectRatio;

        double scale = screenRatio * previewRatio;
        if (scale < 1) {
          scale = 1 / scale;
        }

        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Transform.scale(
              scale: scale,
              child: Center(
                child: CameraPreview(controller),
              ),
            ),
            _buildFaceGuideOverlay(),
          ],
        );
      },
    );
  }

  Widget _buildFaceGuideOverlay() {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 260,
          height: 320,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withOpacity(0.85),
              width: 2,
            ),
            color: Colors.black.withOpacity(0.1),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.face_retouching_natural,
                color: Colors.white,
                size: 48,
              ),
              SizedBox(height: 8),
              Text(
                'Positionnez votre visage ici',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'Alignez votre visage et appuyez pour capturer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _isProcessing ? null : _captureAndAnalyze,
            child: Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ),
              ),
              child: Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: <Color>[
                        Color(0xFF667eea),
                        Color(0xFF764ba2),
                      ],
                    ),
                  ),
                  child: Center(
                    child: _isProcessing
                        ? const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 3,
                            ),
                          )
                        : const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 28,
                          ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _isProcessing ? 'Analyse en cours…' : 'Capturer l’émotion',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Comment ça marche ?'),
          content: const Text(
            '1. Positionnez votre visage dans le cadre.\n'
            '2. Appuyez sur le bouton de capture.\n'
            '3. Patientez pendant que l’IA analyse votre émotion.\n'
            '4. Consultez le résultat et l’image capturée.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Compris'),
            ),
          ],
        );
      },
    );
  }
}
