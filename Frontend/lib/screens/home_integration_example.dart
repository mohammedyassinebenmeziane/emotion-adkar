// Exemple d'intégration du chat DhikrAI dans le home screen

import 'package:flutter/material.dart';
import 'screens/dhikrai_chat_screen.dart';

class HomeScreenWithDhikrAI extends StatelessWidget {
  const HomeScreenWithDhikrAI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emotion Adkar'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF667eea),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF667eea).withOpacity(0.1),
              const Color(0xFF764ba2).withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Bienvenue',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Comment va tu aujourd\'hui?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 30),

                // Carte pour la détection d'émotion
                _buildFeatureCard(
                  context,
                  title: 'Détecter mon émotion',
                  description: 'Scannez votre visage pour détecter votre émotion',
                  icon: Icons.emoji_emotions,
                  color: Colors.green,
                  onTap: () {
                    // Navigator.of(context).push(...);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Caméra en cours...')),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Carte pour le chat DhikrAI - NOUVEAU
                _buildFeatureCard(
                  context,
                  title: 'Parler avec DhikrAI',
                  description: 'Conversation bienveillante et apaisante 🌙',
                  icon: Icons.chat_bubble_outline,
                  color: const Color(0xFF667eea),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const DhikrAIChatScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Carte pour les versets du Coran
                _buildFeatureCard(
                  context,
                  title: 'Versets du Coran',
                  description: 'Trouvez des versets inspirants',
                  icon: Icons.menu_book,
                  color: Colors.orange,
                  onTap: () {
                    // Navigator.of(context).push(...);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bientôt disponible')),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Carte pour les Douaa
                _buildFeatureCard(
                  context,
                  title: 'Recueil de Douaa',
                  description: 'Supplications inspirantes',
                  icon: Icons.favorite,
                  color: Colors.red,
                  onTap: () {
                    // Navigator.of(context).push(...);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bientôt disponible')),
                    );
                  },
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// Comment intégrer dans votre app principal:
/*

Dans main.dart, remplacez l'écran home par:

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emotion Adkar',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const HomeScreenWithDhikrAI(),  // ← ici
    );
  }
}

*/
