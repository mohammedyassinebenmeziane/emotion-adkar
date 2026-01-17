import 'dart:io';

import 'package:flutter/material.dart';
import '../services/emotion_api.dart';
import 'dhikrai_chat_screen.dart';

class EmotionResultScreen extends StatefulWidget {
  const EmotionResultScreen({
    super.key,
    required this.imagePath,
  });

  final String imagePath;

  @override
  State<EmotionResultScreen> createState() => _EmotionResultScreenState();
}

class _EmotionResultScreenState extends State<EmotionResultScreen> {
  final EmotionApiService _emotionApi = EmotionApiService();

  bool _isLoading = true;
  String? _emotion;
  double? _confidence;
  String? _douaa;
  String? _ayahText;
  String? _ayahReference;
  String? _explanationFr;
  String? _errorMessage;
  int _douaaRepetitions = 3; // Nombre de fois par défaut
  int _douaaCurrentCount = 0; // Compteur en cours

  @override
  void initState() {
    super.initState();
    _analyzeEmotion();
  }

  Future<void> _analyzeEmotion() async {
    try {
      final Map<String, dynamic> result =
          await _emotionApi.detectEmotion(File(widget.imagePath));

      if (!mounted) return;

      setState(() {
        _emotion = result['emotion'] as String;
        _confidence = (result['confidence'] as num).toDouble();
        _douaa = result['douaa'] as String?;
        _ayahText = result['ayah_text'] as String?;
        _ayahReference = result['ayah_reference'] as String?;
        _explanationFr = result['explanation_fr'] as String?;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _retryAnalysis() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _analyzeEmotion();
  }

  LinearGradient get _backgroundGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color(0xFF667eea),
          Color(0xFF764ba2),
          Color(0xFFf093fb),
        ],
      );

  @override
  Widget build(BuildContext context) {
    // Show error state if there's an error
    if (_errorMessage != null) {
      return _buildErrorState();
    }

    // Show loading state while analyzing
    if (_isLoading) {
      return _buildLoadingState();
    }

    // Show results once analysis is complete
    final String formattedEmotion = _capitalizeEmotion(_emotion!);
    final Color emotionColor = _getEmotionColor(_emotion!);
    final IconData emotionIcon = _getEmotionIcon(_emotion!);
    final String description = _getEmotionDescription(_emotion!);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: _backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              _buildTopBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 8),
                      const Text(
                        'Émotion Détectée',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Emotion Card (emotion only, no score)
                      _buildSimpleEmotionCard(
                        formattedEmotion,
                        emotionColor,
                        emotionIcon,
                      ),
                      const SizedBox(height: 20),
                      // Captured Image
                      _buildCapturedImageCard(),
                      const SizedBox(height: 20),
                      // Douaa
                      if (_douaa != null && _douaa!.isNotEmpty)
                        _buildDouaaCard(),
                      if (_douaa != null && _douaa!.isNotEmpty)
                        const SizedBox(height: 20),
                      // Quranic Verse
                      if (_ayahText != null && _ayahText!.isNotEmpty)
                        _buildAyahCard(),
                      if (_ayahText != null && _ayahText!.isNotEmpty)
                        const SizedBox(height: 20),
                      // Explanation
                      if (_explanationFr != null && _explanationFr!.isNotEmpty)
                        _buildExplanationCard(),
                      if (_explanationFr != null && _explanationFr!.isNotEmpty)
                        const SizedBox(height: 20),
                      _buildActions(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: <Widget>[
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () => _showComingSoonSnackBar(context),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.share_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(
    String formattedEmotion,
    Color emotionColor,
    IconData emotionIcon,
    String description,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(
            radius: 36,
            backgroundColor: emotionColor.withOpacity(0.15),
            child: Icon(
              emotionIcon,
              size: 36,
              color: emotionColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            formattedEmotion,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: emotionColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildConfidenceBar(),
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleEmotionCard(
    String formattedEmotion,
    Color emotionColor,
    IconData emotionIcon,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(
            radius: 40,
            backgroundColor: emotionColor.withOpacity(0.15),
            child: Icon(
              emotionIcon,
              size: 40,
              color: emotionColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            formattedEmotion,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: emotionColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAffirmationCard(String affirmation) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.favorite,
            color: Colors.pinkAccent,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            affirmation,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceBar() {
    final double percent = (_confidence! * 100).clamp(0, 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text(
              'Confiance',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${percent.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: _confidence!.clamp(0, 1),
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(
              Colors.deepPurpleAccent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExplanationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // Fond dégradé doré
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            const Color(0xFFf5e6d3),
            const Color(0xFFf0d9b5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFd4a574),
          width: 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFFd4a574).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            '💡 Explication',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6b4423),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _explanationFr ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF3e2723),
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDouaaCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // Fond dégradé doré
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            const Color(0xFFf5e6d3),
            const Color(0xFFf0d9b5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFd4a574),
          width: 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFFd4a574).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Titre
          const Text(
            'دعاء',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6b4423),
            ),
          ),
          const SizedBox(height: 20),
          // Texte du Douaa centré
          Text(
            _douaa ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              color: Color(0xFF3e2723),
              height: 2.0,
              fontFamily: 'Traditional Arabic',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          // Ligne décorative
          Container(
            height: 1,
            width: 60,
            color: const Color(0xFFd4a574),
          ),
          const SizedBox(height: 20),
          // Section répétitions
          Text(
            'كررهـــا $_douaaRepetitions مرات',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF6b4423),
              fontWeight: FontWeight.w600,
              fontFamily: 'Traditional Arabic',
            ),
          ),
          const SizedBox(height: 16),
          // Compteur avec boutons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFd4a574),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                // Bouton moins
                InkWell(
                  onTap: _douaaCurrentCount > 0
                      ? () => setState(() => _douaaCurrentCount--)
                      : null,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _douaaCurrentCount > 0
                          ? const Color(0xFF667eea)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.remove,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                // Affichage du compteur
                Column(
                  children: <Widget>[
                    Text(
                      '$_douaaCurrentCount',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF667eea),
                      ),
                    ),
                    Text(
                      'مرات',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontFamily: 'Traditional Arabic',
                      ),
                    ),
                  ],
                ),
                // Bouton plus
                InkWell(
                  onTap: _douaaCurrentCount < _douaaRepetitions
                      ? () => setState(() => _douaaCurrentCount++)
                      : null,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _douaaCurrentCount < _douaaRepetitions
                          ? const Color(0xFF667eea)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Message de félicitations
          if (_douaaCurrentCount == _douaaRepetitions)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF4CAF50),
                    width: 1.5,
                  ),
                ),
                child: const Text(
                  '✨ ما شاء الله! لقد أكملت التكرار',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Traditional Arabic',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAyahCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // Fond dégradé doré
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            const Color(0xFFf5e6d3),
            const Color(0xFFf0d9b5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFd4a574),
          width: 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFFd4a574).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Référence du verset
          if (_ayahReference != null && _ayahReference!.isNotEmpty)
            Text(
              _ayahReference!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6b4423),
                fontFamily: 'Traditional Arabic',
              ),
            ),
          if (_ayahReference != null && _ayahReference!.isNotEmpty)
            const SizedBox(height: 16),
          // Texte du verset centré
          Text(
            _ayahText ?? '',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontSize: 20,
              color: Color(0xFF3e2723),
              height: 2.2,
              fontFamily: 'Traditional Arabic',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapturedImageCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(
                Icons.photo_camera_outlined,
                color: Colors.black87,
              ),
              SizedBox(width: 8),
              Text(
                'Photo Capturée',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Image.file(
                File(widget.imagePath),
                fit: BoxFit.cover,
                errorBuilder: (
                  BuildContext context,
                  Object error,
                  StackTrace? stackTrace,
                ) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: Colors.grey,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<DhikrAIChatScreen>(
                  builder: (BuildContext context) =>
                      DhikrAIChatScreen(initialEmotion: _emotion),
                ),
              );
            },
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            label: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[
                    Color(0xFF667eea),
                    Color(0xFF764ba2),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    '💬 Conseil Personnalisé',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Réessayer'),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: _backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              _buildTopBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 8),
                      const Text(
                        'Analyse en cours',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Veuillez patienter pendant que notre IA analyse votre expression faciale.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildCapturedImageCard(),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: <Widget>[
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF667eea),
                              ),
                              strokeWidth: 4,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Analyse des émotions...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Cela peut prendre quelques instants',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: _backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              _buildTopBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 8),
                      const Text(
                        'Analyse Échouée',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Une erreur s\'est produite lors de l\'analyse de votre émotion.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildCapturedImageCard(),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: <Widget>[
                            const Icon(
                              Icons.error_outline,
                              color: Colors.redAccent,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Erreur',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _errorMessage ?? 'Une erreur inconnue s\'est produite',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF667eea),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                onPressed: _retryAnalysis,
                                icon: const Icon(Icons.refresh),
                                label: const Text(
                                  'Réessayer l\'analyse',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF667eea)),
                                  foregroundColor: const Color(0xFF667eea),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text(
                                  'Prendre une nouvelle photo',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _capitalizeEmotion(String value) {
    if (value.isEmpty) return 'Unknown';
    final String lower = value.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }

  IconData _getEmotionIcon(String value) {
    final String v = value.toLowerCase();
    if (v.contains('happy') || v.contains('joy')) {
      return Icons.sentiment_very_satisfied;
    } else if (v.contains('sad')) {
      return Icons.sentiment_dissatisfied;
    } else if (v.contains('angry') || v.contains('anger')) {
      return Icons.sentiment_very_dissatisfied;
    } else if (v.contains('fear') || v.contains('scared')) {
      return Icons.sentiment_neutral;
    } else if (v.contains('surprise')) {
      return Icons.sentiment_satisfied_alt;
    } else if (v.contains('disgust')) {
      return Icons.sentiment_very_dissatisfied;
    } else if (v.contains('neutral')) {
      return Icons.sentiment_neutral;
    }
    return Icons.emoji_emotions_outlined;
  }

  Color _getEmotionColor(String value) {
    final String v = value.toLowerCase();
    if (v.contains('happy') || v.contains('joy')) {
      return Colors.green;
    } else if (v.contains('sad')) {
      return Colors.blue;
    } else if (v.contains('angry') || v.contains('anger')) {
      return Colors.red;
    } else if (v.contains('fear') || v.contains('scared')) {
      return Colors.purple;
    } else if (v.contains('surprise')) {
      return Colors.orange;
    } else if (v.contains('disgust')) {
      return Colors.brown;
    } else if (v.contains('neutral')) {
      return Colors.blueGrey;
    }
    return Colors.deepPurple;
  }

  String _getEmotionDescription(String value) {
    final String v = value.toLowerCase();
    if (v.contains('happy') || v.contains('joy')) {
      return 'Vous semblez être de bonne humeur. Prenez un moment pour apprécier cette énergie positive.';
    } else if (v.contains('sad')) {
      return 'Vous avez l\'air un peu triste. C\'est normal de se sentir ainsi. Rappelez-vous que chaque émotion est valide.';
    } else if (v.contains('angry') || v.contains('anger')) {
      return 'Il y a de la colère dans votre expression. Essayez de faire une pause, de respirer et de vous donner un peu d\'espace.';
    } else if (v.contains('fear') || v.contains('scared')) {
      return 'La peur est présente. Reconnaissez-la doucement et rappelez-vous que vous n\'êtes pas seul.';
    } else if (v.contains('surprise')) {
      return 'Vous semblez surpris. Quelque chose d\'inattendu s\'est peut-être produit récemment.';
    } else if (v.contains('disgust')) {
      return 'Un peu de dégoût est détecté. Cela peut vous aider de vous éloigner de ce qui vous préoccupe.';
    }
    return 'Votre émotion a été détectée. Prenez un moment pour réfléchir à ce que vous ressentez en ce moment.';
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bientôt Disponible'),
          content: const Text(
            'Bientôt, Emotion Adkār fournira des recommandations spirituelles basées sur l\'IA '
            'en fonction de votre émotion détectée pour vous aider à vous sentir plus ancré et en paix.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showComingSoonSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('La fonctionnalité de partage sera bientôt disponible!'),
      ),
    );
  }
}



