import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../themes/app_theme.dart';

class AiCopilotScreen extends StatefulWidget {
  const AiCopilotScreen({super.key});

  @override
  State<AiCopilotScreen> createState() => _AiCopilotScreenState();
}

class _AiCopilotScreenState extends State<AiCopilotScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isProcessing = false;
  String _selectedLanguage = 'English';

  final List<String> _languages = [
    'English', 'Hindi', 'Punjabi', 'Gujarati',
    'Tamil', 'Telugu', 'Marathi', 'Bengali',
  ];

  final List<String> _suggestions = [
    'How to identify a scam call?',
    'My OTP was shared, what to do?',
    'Is this investment scheme genuine?',
    'How to report UPI fraud?',
    'Protect my parents from scams',
    'What is deepfake fraud?',
  ];

  @override
  void initState() {
    super.initState();
    _addBotMessage(
      'Namaste! 🙏 I am your AI Copilot. I can help you with fraud protection, safety advice, and emergency assistance. How can I help you today?',
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addBotMessage(String text) {
    setState(() => _messages.add(ChatMessage(text: text, isBot: true)));
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() => _messages.add(ChatMessage(text: text, isBot: false)));
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _addUserMessage(text);
    _messageController.clear();
    setState(() => _isProcessing = true);

    // Simulate AI response
    await Future.delayed(const Duration(seconds: 2));

    String response = '';
    final lowerText = text.toLowerCase();

    if (lowerText.contains('scam') || lowerText.contains('call')) {
      response = '🚨 **Scam Call Protection**\n\n'
          'If you receive a suspicious call:\n'
          '1. Do NOT share any personal information\n'
          '2. Do NOT press any numbers\n'
          '3. Hang up immediately\n'
          '4. Block the number\n'
          '5. Report to CyberShield\n\n'
          'Your call protection is currently ACTIVE. All incoming calls are being screened.';
    } else if (lowerText.contains('otp') || lowerText.contains('shared')) {
      response = '⚠️ **OTP Shared - Immediate Action Required**\n\n'
          'If you\'ve shared your OTP:\n'
          '1. Immediately call your bank to freeze accounts\n'
          '2. Change all passwords\n'
          '3. File a complaint on 1930\n'
          '4. Report through CyberShield Emergency\n\n'
          'I can help you file a report right now. Would you like to proceed?';
    } else if (lowerText.contains('upi') || lowerText.contains('payment')) {
      response = '💳 **UPI Fraud Protection**\n\n'
          'To stay safe from UPI fraud:\n'
          '• Never share your UPI PIN\n'
          '• Verify merchant before payment\n'
          '• Use UPI Protection in CyberShield\n'
          '• Enable transaction limits\n\n'
          'If you\'ve lost money, use the Emergency SOS immediately!';
    } else if (lowerText.contains('deepfake')) {
      response = '🎭 **Deepfake Detection**\n\n'
          'Deepfakes use AI to create fake videos/audio. To protect yourself:\n'
          '• Be skeptical of urgent requests from known contacts\n'
          '• Verify through another communication channel\n'
          '• Use our Deepfake Detection tool to analyze media\n'
          '• Look for unnatural blinking or lip movements\n\n'
          'Would you like me to guide you through the detection process?';
    } else if (lowerText.contains('parent') || lowerText.contains('senior') || lowerText.contains('family')) {
      response = '👨‍👩‍👧‍👦 **Family Protection**\n\n'
          'Great that you\'re thinking about family safety!\n\n'
          'Features available:\n'
          '• **Senior Mode**: Simplified UI with large fonts\n'
          '• **Family Alerts**: Real-time scam alerts to all members\n'
          '• **Shared Protection**: Monitor family members\' safety\n'
          '• **Emergency Alert**: One-tap SOS for family\n\n'
          'Enable Family Protection from the home screen!';
    } else {
      response = '🤖 **I\'m here to help!**\n\n'
          'I can assist you with:\n'
          '• 🛡️ Fraud prevention advice\n'
          '• 📞 Call/SMS scam detection\n'
          '• 💳 UPI & Banking safety\n'
          '• 🎭 Deepfake awareness\n'
          '• 👨‍👩‍👧‍👦 Family protection\n'
          '• 🚨 Emergency assistance\n\n'
          'What would you like to know more about?';
    }

    _addBotMessage(response);
    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.psychology, color: Color(0xFF8B5CF6), size: 20),
            ),
            const SizedBox(width: 10),
            const Text('AI Copilot'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language, color: AppTheme.textSecondary),
            onSelected: (lang) => setState(() => _selectedLanguage = lang),
            itemBuilder: (_) => _languages.map((l) => PopupMenuItem(value: l, child: Text(l))).toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Language indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: AppTheme.cardBackground,
            child: Row(
              children: [
                const Icon(Icons.translate, size: 14, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
                Text('Assisting in $_selectedLanguage', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessage(_messages[index]),
            ),
          ),
          // Suggestions
          if (_messages.length <= 2)
            Container(
              height: 50,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _suggestions.length,
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () => _sendMessage(_suggestions[index]),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: Text(_suggestions[index], style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ),
                ),
              ),
            ),
          // Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppTheme.cardBackground,
              border: Border(top: BorderSide(color: AppTheme.borderColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask me anything...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: _isProcessing ? AppTheme.textSecondary : const Color(0xFF8B5CF6),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: IconButton(
                    icon: _isProcessing
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send, color: Colors.white),
                    onPressed: _isProcessing ? null : () => _sendMessage(_messageController.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Align(
      alignment: message.isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: message.isBot
              ? AppTheme.cardBackground
              : const Color(0xFF8B5CF6).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(
            message.isBot ? 4 : 16,
          ).copyWith(
            topLeft: message.isBot ? const Radius.circular(16) : Radius.zero,
            topRight: message.isBot ? Radius.zero : const Radius.circular(16),
          ),
          border: message.isBot ? Border.all(color: AppTheme.borderColor) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isBot) ...[
              Text(message.text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)),
            ],
            if (message.isBot)
              SelectableText(
                message.text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isBot;
  ChatMessage({required this.text, required this.isBot});
}