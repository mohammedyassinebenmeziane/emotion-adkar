import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatMessage {
  final String content;
  final String role; // 'user' ou 'assistant'

  ChatMessage({required this.content, required this.role});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      content: json['content'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'role': role,
    };
  }
}

class DhikrAIChatService {
  // 10.0.2.2 = IP spéciale pour Android emulator pour atteindre le host
  final String baseUrl = "http://10.0.2.2:8000"; 

  // Envoyer un message au LLM via le backend
  Future<String> sendMessage(String message, List<ChatMessage> history) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': message,
          'history': history.map((msg) => msg.toJson()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] as String;
      } else {
        return 'Une erreur est survenue. Réessaye plus tard. 💙';
      }
    } catch (e) {
      print('Error sending message: $e');
      return 'Je suis temporairement indisponible. Prends soin de toi. 🌙';
    }
  }
}

class DhikrAIChatScreen extends StatefulWidget {
  const DhikrAIChatScreen({super.key, this.initialEmotion});

  final String? initialEmotion;

  @override
  State<DhikrAIChatScreen> createState() => _DhikrAIChatScreenState();
}

class _DhikrAIChatScreenState extends State<DhikrAIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final DhikrAIChatService _chatService = DhikrAIChatService();

  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Message de bienvenue de DhikrAI
    _messages.add(
      ChatMessage(
        content: 'Salam alaykoum 🌙\nJe suis DhikrAI. Je suis là pour toi.',
        role: 'assistant',
      ),
    );
    
    // Si une émotion a été passée, envoyer un message initial
    if (widget.initialEmotion != null) {
      Future.delayed(const Duration(milliseconds: 500), _sendInitialEmotion);
    }
  }

  // Envoyer le message initial basé sur l'émotion
  Future<void> _sendInitialEmotion() async {
    final String emotionFr = _translateEmotion(widget.initialEmotion!);
    final String initialMessage = 'Je me sens $emotionFr, peux-tu m\'aider?';
    _messageController.text = initialMessage;
    await _sendMessage(initialMessage);
  }

  // Traduction émotion anglais -> français
  String _translateEmotion(String emotion) {
    const Map<String, String> emotionMap = {
      'happy': 'heureux(se)',
      'sad': 'triste',
      'angry': 'en colère',
      'neutral': 'neutre',
      'anxious': 'anxieux(se)',
      'excited': 'excité(e)',
      'fear': 'effrayé(e)',
      'grateful': 'reconnaissant(e)',
      'hopeful': 'plein(e) d\'espoir',
      'lonely': 'seul(e)',
      'surprised': 'surpris(e)',
    };
    return emotionMap[emotion.toLowerCase()] ?? emotion;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Scroller vers le bas automatiquement
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // Envoyer un message
  Future<void> _sendMessage(String message) async {
    if (message.isEmpty) return;

    // Ajouter le message de l'utilisateur
    setState(() {
      _messages.add(ChatMessage(content: message, role: 'user'));
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Obtenir la réponse du LLM
    final response =
        await _chatService.sendMessage(message, _messages.sublist(1)); // Exclure le message de bienvenue

    // Ajouter la réponse de l'assistant
    setState(() {
      _messages.add(ChatMessage(content: response, role: 'assistant'));
      _isLoading = false;
    });

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('DhikrAI 🌙'),
          ],
        ),
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
        child: Column(
          children: [
            // Liste des messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message.role == 'user';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: isUser
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        if (!isUser)
                          Container(
                            width: 32,
                            height: 32,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF667eea),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Text(
                                '🌙',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? const Color(0xFF667eea)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              message.content,
                              style: TextStyle(
                                fontSize: 14,
                                color: isUser ? Colors.white : Colors.black87,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                        if (isUser)
                          Container(
                            width: 32,
                            height: 32,
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF667eea),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Text(
                                '👤',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indicateur de chargement
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF667eea),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          '🌙',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const SizedBox(
                        width: 30,
                        height: 20,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              child: _TypingDot(delay: 0),
                            ),
                            Positioned(
                              left: 10,
                              child: _TypingDot(delay: 200),
                            ),
                            Positioned(
                              left: 20,
                              child: _TypingDot(delay: 400),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Zone d'entrée
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Parle-moi de ce que tu ressens...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                            color: Color(0xFF667eea),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: _sendMessage,
                      minLines: 1,
                      maxLines: 3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF667eea),
                          Color(0xFF764ba2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isLoading
                            ? null
                            : () => _sendMessage(_messageController.text),
                        borderRadius: BorderRadius.circular(24),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 20,
                                ),
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
    );
  }
}

// Widget pour l'animation des points de saisie
class _TypingDot extends StatefulWidget {
  final int delay;

  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.forward();
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -(_animation.value * 4)),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFF667eea),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      },
    );
  }
}
