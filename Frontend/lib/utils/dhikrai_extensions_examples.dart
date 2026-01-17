"""
Exemples d'extensions pour DhikrAI Chat:
- Exercices de respiration guidée
- Courtes prières inspirantes
- Suggestions de contenu
"""

# ============================================
# EXEMPLE 1: Ajouter des boutons de suggestion
# ============================================

# Dans dhikrai_chat_screen.dart, ajouter avant _buildActions:

class _SuggestionButtons extends StatelessWidget {
  final Function(String) onSuggestionTap;

  const _SuggestionButtons({required this.onSuggestionTap});

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      "Je me sens mal",
      "Peux-tu m'aider?",
      "Propose-moi une prière",
      "Exercice de respiration",
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: suggestions.map((suggestion) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSuggestionTap(suggestion),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea).withOpacity(0.1),
                  border: Border.all(color: const Color(0xFF667eea)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  suggestion,
                  style: const TextStyle(
                    color: Color(0xFF667eea),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

# Puis dans le build() de DhikrAIChatScreen:
# Avant la zone d'entrée, ajouter:
#   _SuggestionButtons(
#     onSuggestionTap: (suggestion) {
#       _messageController.text = suggestion;
#       _sendMessage(suggestion);
#     },
#   ),


# ============================================
# EXEMPLE 2: Contenu de respiration guidée
# ============================================

# Créer lib/utils/breathing_exercises.dart

class BreathingExercise {
  final String name;
  final String description;
  final int inhaleSeconds;
  final int holdSeconds;
  final int exhaleSeconds;
  final int cycles;

  BreathingExercise({
    required this.name,
    required this.description,
    required this.inhaleSeconds,
    required this.holdSeconds,
    required this.exhaleSeconds,
    required this.cycles,
  });
}

final List<BreathingExercise> BREATHING_EXERCISES = [
  BreathingExercise(
    name: "Box Breathing (4-4-4-4)",
    description: "Une technique simple pour se calmer",
    inhaleSeconds: 4,
    holdSeconds: 4,
    exhaleSeconds: 4,
    cycles: 5,
  ),
  BreathingExercise(
    name: "4-7-8 Breathing",
    description: "Inspiration courte, expiration longue",
    inhaleSeconds: 4,
    holdSeconds: 7,
    exhaleSeconds: 8,
    cycles: 4,
  ),
  BreathingExercise(
    name: "Simple 3-3-3",
    description: "Pour les débutants",
    inhaleSeconds: 3,
    holdSeconds: 3,
    exhaleSeconds: 3,
    cycles: 6,
  ),
];


# ============================================
# EXEMPLE 3: Contenu de prières courtes
# ============================================

# Créer lib/utils/islamic_content.dart

class DuaaEntry {
  final String arabic;
  final String english;
  final String french;
  final String category;

  DuaaEntry({
    required this.arabic,
    required this.english,
    required this.french,
    required this.category,
  });
}

final List<DuaaEntry> SHORT_DOUAA = [
  DuaaEntry(
    arabic: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
    english: "In the name of Allah, the Most Gracious, the Most Merciful",
    french: "Au nom d'Allah, le Très Miséricordieux",
    category: "Opening",
  ),
  DuaaEntry(
    arabic: "الحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ",
    english: "All praise is due to Allah, Lord of all worlds",
    french: "Louange à Allah, Seigneur de tous les mondes",
    category: "Gratitude",
  ),
  DuaaEntry(
    arabic: "يَا مُقَلِّبَ الْقُلُوبِ ثَبِّتْ قَلْبِي عَلَىٰ دِينِكَ",
    english: "O Turner of hearts, keep my heart firm upon Your religion",
    french: "Ô Celui qui retourne les cœurs, affermis mon cœur dans Ta religion",
    category: "Strength",
  ),
  DuaaEntry(
    arabic: "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ",
    english: "O Allah, I seek refuge in You from sadness and grief",
    french: "Ô Allah, je me réfugie en Toi contre la tristesse et la peine",
    category: "Mental Health",
  ),
];


# ============================================
# EXEMPLE 4: Modifié system prompt avec prières
# ============================================

# Dans services/llm_service.py, modifier __init__:

SYSTEM_PROMPT_WITH_CONTENT = """Tu es DhikrAI, un assistant bienveillant et apaisant.

Tu aides l'utilisateur à se sentir mieux avec des mots simples et réconfortants.
Tu ne fais JAMAIS de diagnostic médical ou psychologique.

Tu peux proposer:
1. De petits exercices de respiration (ex: "Essaie de respirer lentement...")
2. Des prières courtes inspirées de l'islam
3. Des versets du Coran réconfortants
4. Des affirmations positives

Style:
- Réponses courtes (1-3 phrases max)
- Langage simple et naturel comme un SMS
- Toujours rassurant et bienveillant
- Utilise des emojis avec parcimonie

Exemples bons:
- "Je suis là. Respire lentement. Tu vas aller mieux. 💙"
- "Veux-tu un exercice de respiration? C'est facile."
- "Souvenez-vous: 'Verily, with hardship comes ease.' (Coran 94:5)"

Exemples mauvais:
- "Tu as une dépression" (diagnostic)
- "Récitations très longues" (trop verbeux)
- "Ton" neutre ou froid (pas empathique)

Aide l'utilisateur pas à pas avec douceur.
"""


# ============================================
# EXEMPLE 5: Endpoint amélioré avec contenu
# ============================================

# Dans routes/chat.py, ajouter:

@router.get("/suggestions")
async def get_chat_suggestions():
    """
    Retourne des suggestions rapides pour l'utilisateur
    """
    return {
        "suggestions": [
            "Je me sens mal",
            "Peux-tu m'aider?",
            "Propose-moi une prière",
            "Guide-moi dans une respiration",
            "Je suis en colère",
            "Je suis triste",
        ]
    }


@router.get("/breathing-exercises")
async def get_breathing_exercises():
    """
    Retourne les exercices de respiration disponibles
    """
    return {
        "exercises": [
            {
                "name": "Box Breathing",
                "inhale": 4,
                "hold": 4,
                "exhale": 4,
                "cycles": 5,
            },
            {
                "name": "4-7-8 Breathing",
                "inhale": 4,
                "hold": 7,
                "exhale": 8,
                "cycles": 4,
            },
        ]
    }


@router.get("/douaa")
async def get_douaa(category: str = "random"):
    """
    Retourne des Douaa (prières courtes) par catégorie
    """
    return {
        "douaa": {
            "arabic": "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ",
            "french": "Ô Allah, je me réfugie en Toi contre la tristesse et la peine",
            "category": "Mental Health",
        }
    }


# ============================================
# EXEMPLE 6: Widget de respiration guidée
# ============================================

# Créer lib/widgets/breathing_widget.dart

class BreathingAnimationWidget extends StatefulWidget {
  final BreathingExercise exercise;

  const BreathingAnimationWidget({
    required this.exercise,
  });

  @override
  State<BreathingAnimationWidget> createState() =>
      _BreathingAnimationWidgetState();
}

class _BreathingAnimationWidgetState extends State<BreathingAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  int _currentCycle = 0;
  String _currentPhase = "Inspire";

  @override
  void initState() {
    super.initState();
    _startBreathingAnimation();
  }

  void _startBreathingAnimation() {
    final totalDuration = widget.exercise.inhaleSeconds +
        widget.exercise.holdSeconds +
        widget.exercise.exhaleSeconds;

    _controller = AnimationController(
      duration: Duration(seconds: totalDuration),
      vsync: this,
    )..repeat();

    _sizeAnimation = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addListener(_updatePhase);
  }

  void _updatePhase() {
    final totalDuration = widget.exercise.inhaleSeconds +
        widget.exercise.holdSeconds +
        widget.exercise.exhaleSeconds;
    final elapsed = (_controller.value * totalDuration * 1000).toInt();

    setState(() {
      if (elapsed < widget.exercise.inhaleSeconds * 1000) {
        _currentPhase = "Inspire";
      } else if (elapsed <
          (widget.exercise.inhaleSeconds + widget.exercise.holdSeconds) * 1000) {
        _currentPhase = "Retiens";
      } else {
        _currentPhase = "Expire";
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.exercise.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
        AnimatedBuilder(
          animation: _sizeAnimation,
          builder: (context, child) {
            return Container(
              width: 200 * _sizeAnimation.value,
              height: 200 * _sizeAnimation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF667eea).withOpacity(0.5),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        Text(
          _currentPhase,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF667eea),
          ),
        ),
      ],
    );
  }
}


# ============================================
# UTILISATION:
# ============================================

/*

// Dans dhikrai_chat_screen.dart:

// Ajouter les suggestions
if (_messages.length == 1) // Après le message de bienvenue
  _SuggestionButtons(
    onSuggestionTap: (suggestion) {
      _messageController.text = suggestion;
      _sendMessage(suggestion);
    },
  ),

// Ajouter un bouton respiration dans les actions
FloatingActionButton(
  onPressed: () {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Respiration Guidée'),
        content: BreathingAnimationWidget(
          exercise: BREATHING_EXERCISES[0],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Terminé'),
          ),
        ],
      ),
    );
  },
  child: const Icon(Icons.air),
)

*/
