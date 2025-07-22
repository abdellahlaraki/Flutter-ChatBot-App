import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/openai_service.dart';
import '../widgets/message_bubble.dart';
import 'login_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final OpenAiService _openAiService = OpenAiService();
  bool _isLoading = false;

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    final userMessageText = text.trim();
    _textController.clear();
    
    final userMessage = ChatMessage(text: userMessageText, isUser: true);

    setState(() {
      _messages.insert(0, userMessage);
      _listKey.currentState?.insertItem(0, duration: const Duration(milliseconds: 300));
      _isLoading = true;
    });

    final botResponseText = await _openAiService.getChatResponse(_messages);
    final botMessage = ChatMessage(text: botResponseText, isUser: false);
    
    setState(() {
      _isLoading = false;
    });
    
    _messages.insert(0, botMessage);
    _listKey.currentState?.insertItem(0, duration: const Duration(milliseconds: 300));
  }
  
  void _logout() {
    
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatBot'),
        centerTitle: true,
        actions: [
          IconButton(
            
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Déconnexion',
            onPressed: _logout,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: AnimatedList(
              key: _listKey,
              reverse: true,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              initialItemCount: _messages.length,
              itemBuilder: (context, index, animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                  child: FadeTransition(
                    opacity: animation,
                    child: MessageBubble(message: _messages[index]),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            Align(
              alignment: Alignment.centerLeft,
              child: MessageBubble(message: ChatMessage(text: '...', isUser: false)),
            ),
          _buildTextComposer(),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              onSubmitted: _isLoading ? null : _handleSubmitted,
              decoration: InputDecoration(
                hintText: 'Envoyer un message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              enabled: !_isLoading,
            ),
          ),
          const SizedBox(width: 8.0),
          IconButton.filled(
            icon: const Icon(Icons.send),
            onPressed: _isLoading
                ? null
                : () => _handleSubmitted(_textController.text),
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(12.0),
            ),
          ),
        ],
      ),
    );
  }
}