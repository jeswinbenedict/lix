import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_theme.dart';
import 'language_service.dart';
import 'gemini_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  final LanguageService _lang = LanguageService();

  // ── UI strings ────────────────────────────────────────────────────────
  static const Map<String, Map<String, String>> _uiStrings = {
    'English': {
      'online': 'Online',
      'thinking': 'Lix is thinking...',
      'placeholder': 'Ask me anything...',
      'try_saying': '💡 Try saying:',
      'welcome_title': "Hey {name}! I'm Lix 👋",
      'welcome_sub':
          'Tell me your mood, ask about movies,\nmusic, or just chat! 💜',
    },
    'Hindi': {
      'online': 'ऑनलाइन',
      'thinking': 'Lix सोच रहा है...',
      'placeholder': 'कुछ भी पूछें...',
      'try_saying': '💡 ये आज़माएं:',
      'welcome_title': 'नमस्ते {name}! मैं Lix हूँ 👋',
      'welcome_sub': 'अपना मूड बताएं या कुछ भी पूछें! 💜',
    },
    'Tamil': {
      'online': 'ஆன்லைன்',
      'thinking': 'Lix யோசிக்கிறது...',
      'placeholder': 'எதையும் கேளுங்கள்...',
      'try_saying': '💡 இதை முயற்சிக்கவும்:',
      'welcome_title': 'வணக்கம் {name}! நான் Lix 👋',
      'welcome_sub': 'உங்கள் மூட் சொல்லுங்கள் அல்லது எதையும் கேளுங்கள்! 💜',
    },
    'Telugu': {
      'online': 'ఆన్‌లైన్',
      'thinking': 'Lix ఆలోచిస్తోంది...',
      'placeholder': 'ఏదైనా అడగండి...',
      'try_saying': '💡 ఇది ప్రయత్నించండి:',
      'welcome_title': 'నమస్కారం {name}! నేను Lix 👋',
      'welcome_sub': 'మీ మూడ్ చెప్పండి లేదా ఏదైనా అడగండి! 💜',
    },
    'Kannada': {
      'online': 'ಆನ್‌ಲೈನ್',
      'thinking': 'Lix ಯೋಚಿಸುತ್ತಿದೆ...',
      'placeholder': 'ಏನಾದರೂ ಕೇಳಿ...',
      'try_saying': '💡 ಇದನ್ನು ಪ್ರಯತ್ನಿಸಿ:',
      'welcome_title': 'ನಮಸ್ಕಾರ {name}! ನಾನು Lix 👋',
      'welcome_sub': 'ನಿಮ್ಮ ಮೂಡ್ ಹೇಳಿ ಅಥವಾ ಏನಾದರೂ ಕೇಳಿ! 💜',
    },
    'Malayalam': {
      'online': 'ഓൺലൈൻ',
      'thinking': 'Lix ചിന്തിക്കുന്നു...',
      'placeholder': 'എന്തും ചോദിക്കൂ...',
      'try_saying': '💡 ഇത് ശ്രമിക്കൂ:',
      'welcome_title': 'നമസ്കാരം {name}! ഞാൻ Lix 👋',
      'welcome_sub': 'മൂഡ് പറയൂ അല്ലെങ്കിൽ എന്തും ചോദിക്കൂ! 💜',
    },
    'Bengali': {
      'online': 'অনলাইন',
      'thinking': 'Lix ভাবছে...',
      'placeholder': 'যেকোনো কিছু জিজ্ঞেস করুন...',
      'try_saying': '💡 এটি চেষ্টা করুন:',
      'welcome_title': 'নমস্কার {name}! আমি Lix 👋',
      'welcome_sub': 'মুড বলুন বা যেকোনো কিছু জিজ্ঞেস করুন! 💜',
    },
    'Arabic': {
      'online': 'متصل',
      'thinking': 'Lix يفكر...',
      'placeholder': 'اسأل عن أي شيء...',
      'try_saying': '💡 جرب قول:',
      'welcome_title': 'مرحباً {name}! أنا Lix 👋',
      'welcome_sub': 'أخبرني بمزاجك أو اسألني أي شيء! 💜',
    },
    'Spanish': {
      'online': 'En línea',
      'thinking': 'Lix está pensando...',
      'placeholder': 'Pregunta cualquier cosa...',
      'try_saying': '💡 Prueba decir:',
      'welcome_title': '¡Hola {name}! Soy Lix 👋',
      'welcome_sub':
          '¡Cuéntame tu estado de ánimo o pregúntame lo que quieras! 💜',
    },
    'French': {
      'online': 'En ligne',
      'thinking': 'Lix réfléchit...',
      'placeholder': 'Pose-moi une question...',
      'try_saying': '💡 Essaie de dire:',
      'welcome_title': 'Bonjour {name}! Je suis Lix 👋',
      'welcome_sub':
          "Dis-moi ton humeur ou pose-moi n'importe quelle question! 💜",
    },
    'German': {
      'online': 'Online',
      'thinking': 'Lix denkt nach...',
      'placeholder': 'Stell mir eine Frage...',
      'try_saying': '💡 Versuch zu sagen:',
      'welcome_title': 'Hallo {name}! Ich bin Lix 👋',
      'welcome_sub': 'Sag mir deine Stimmung oder frag mich alles! 💜',
    },
    'Japanese': {
      'online': 'オンライン',
      'thinking': 'Lixが考えています...',
      'placeholder': '何でも聞いてください...',
      'try_saying': '💡 試してみて:',
      'welcome_title': 'こんにちは {name}! 私はLixです 👋',
      'welcome_sub': '気分を教えて、何でも聞いてください! 💜',
    },
    'Korean': {
      'online': '온라인',
      'thinking': 'Lix가 생각 중...',
      'placeholder': '무엇이든 물어보세요...',
      'try_saying': '💡 이렇게 말해보세요:',
      'welcome_title': '안녕하세요 {name}! 저는 Lix입니다 👋',
      'welcome_sub': '무드를 알려주세요 또는 무엇이든 물어보세요! 💜',
    },
  };

  String _ui(String key, {String name = ''}) {
    final lang = _lang.language;
    final map = _uiStrings[lang] ?? _uiStrings['English']!;
    String text = map[key] ?? _uiStrings['English']![key] ?? key;
    return text.replaceAll('{name}', name);
  }

  // ── Detect script from typed characters ───────────────────────────────
  String _detectInputLanguage(String text) {
    if (RegExp(r'[\u0900-\u097F]').hasMatch(text)) return 'Hindi';
    if (RegExp(r'[\u0B80-\u0BFF]').hasMatch(text)) return 'Tamil';
    if (RegExp(r'[\u0C00-\u0C7F]').hasMatch(text)) return 'Telugu';
    if (RegExp(r'[\u0C80-\u0CFF]').hasMatch(text)) return 'Kannada';
    if (RegExp(r'[\u0D00-\u0D7F]').hasMatch(text)) return 'Malayalam';
    if (RegExp(r'[\u0980-\u09FF]').hasMatch(text)) return 'Bengali';
    if (RegExp(r'[\u0600-\u06FF]').hasMatch(text)) return 'Arabic';
    if (RegExp(r'[\u3040-\u30FF]').hasMatch(text)) return 'Japanese';
    if (RegExp(r'[\u4E00-\u9FFF]').hasMatch(text)) return 'Japanese';
    if (RegExp(r'[\uAC00-\uD7AF]').hasMatch(text)) return 'Korean';
    return _lang.language;
  }

  List<Map<String, String>> _buildConversationHistory() {
    final recent = _messages.length > 10
        ? _messages.sublist(_messages.length - 10)
        : List<Map<String, dynamic>>.from(_messages);
    return recent
        .map(
          (msg) => {
            'role': msg['role'] as String,
            'text': msg['text'] as String? ?? '',
          },
        )
        .toList();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    final detectedLang = _detectInputLanguage(text);
    final history = _buildConversationHistory();

    setState(() {
      _messages.add({'role': 'user', 'type': 'text', 'text': text});
      _isTyping = true;
    });
    _messageController.clear();
    _scrollToBottom();

    final reply = await GeminiService.generateReply(
      userMessage: text,
      language: detectedLang,
      mood: 'neutral',
      intent: 'chat',
      conversationHistory: history,
    );

    if (mounted) {
      setState(() {
        _messages.add({'role': 'bot', 'type': 'text', 'text': reply});
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Lix avatar ────────────────────────────────────────────────────────
  Widget _lixAvatar({double size = 28}) => Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(
      gradient: LinearGradient(colors: [AppTheme.primary, Color(0xFF9C8FFF)]),
      shape: BoxShape.circle,
    ),
    child: Center(
      child: Text(
        'L',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.45,
        ),
      ),
    ),
  );

  // ── Message bubble ────────────────────────────────────────────────────
  Widget _buildMessage(Map<String, dynamic> message) {
    final isUser = message['role'] == 'user';
    final maxW = MediaQuery.of(context).size.width * 0.75;

    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          constraints: BoxConstraints(maxWidth: maxW),
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppTheme.radiusLG),
              topRight: Radius.circular(AppTheme.radiusLG),
              bottomLeft: Radius.circular(AppTheme.radiusLG),
              bottomRight: Radius.circular(4),
            ),
            boxShadow: AppTheme.shadowPrimary,
          ),
          child: Text(
            message['text'] ?? '',
            style: TextStyle(
              color: Colors.white,
              fontSize: AppTheme.bodyRegular(context),
              height: 1.45,
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        constraints: BoxConstraints(maxWidth: maxW),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(AppTheme.radiusLG),
            bottomLeft: Radius.circular(AppTheme.radiusLG),
            bottomRight: Radius.circular(AppTheme.radiusLG),
          ),
          border: Border.all(color: AppTheme.border),
          boxShadow: AppTheme.shadowSM,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _lixAvatar(),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message['text'] ?? '',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: AppTheme.bodyRegular(context),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Typing indicator ──────────────────────────────────────────────────
  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _lixAvatar(),
            const SizedBox(width: 10),
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _ui('thinking'),
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: AppTheme.caption(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Welcome screen ────────────────────────────────────────────────────
  Widget _buildWelcomeScreen() {
    final hPad = AppTheme.horizontalPadding(context);
    final screen = MediaQuery.of(context).size;
    final name =
        FirebaseAuth.instance.currentUser?.displayName?.split(' ').first ??
        'there';

    final moods = [
      {
        'emoji': '😊',
        'label': _lang.translate('Happy'),
        'value': 'I am feeling happy',
      },
      {
        'emoji': '😢',
        'label': _lang.translate('Sad'),
        'value': 'I am feeling sad',
      },
      {
        'emoji': '😰',
        'label': _lang.translate('Anxious'),
        'value': 'I am feeling anxious',
      },
      {'emoji': '😴', 'label': _lang.translate('Bored'), 'value': 'I am bored'},
      {
        'emoji': '💪',
        'label': _lang.translate('Motivated'),
        'value': 'I am feeling motivated',
      },
      {
        'emoji': '😍',
        'label': _lang.translate('Romantic'),
        'value': 'I am feeling romantic',
      },
    ];

    final examples = _lang.language == 'Tamil'
        ? [
            '"AR Rahman பத்தி சொல்லு"',
            '"சோகமா இருக்கேன்"',
            '"Vikram படம் எப்படி?"',
          ]
        : _lang.language == 'Hindi'
        ? [
            '"Arijit Singh के बारे में बताओ"',
            '"movie suggest करो"',
            '"motivate करो"',
          ]
        : _lang.language == 'Korean'
        ? ['"BTS에 대해 말해줘"', '"좋은 영화 추천해줘"']
        : _lang.language == 'Japanese'
        ? ['"好きな映画について話して"', '"音楽を勧めて"']
        : [
            '"Tell me about AR Rahman"',
            '"Recommend a good movie for tonight"',
            '"I just broke up, need comfort"',
            '"What makes Interstellar so special?"',
          ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(hPad, screen.height * 0.05, hPad, 24),
      child: Column(
        children: [
          // ── Avatar ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, Color(0xFF9C8FFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: AppTheme.shadowPrimary,
            ),
            child: const Text('🎬', style: TextStyle(fontSize: 40)),
          ),

          SizedBox(height: screen.height * 0.025),

          // ── Title ───────────────────────────────────────────────────
          Text(
            _ui('welcome_title', name: name),
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: AppTheme.heading1(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _ui('welcome_sub'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: AppTheme.bodyRegular(context),
              height: 1.55,
            ),
          ),

          SizedBox(height: screen.height * 0.03),

          // ── Mood chips — horizontal scroll, never wraps ─────────────
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              // No extra padding — let the parent handle horizontal padding
              itemCount: moods.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final mood = moods[i];
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _messageController.text = mood['value']!;
                    _sendMessage();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.35),
                      ),
                      boxShadow: AppTheme.shadowSM,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          mood['emoji']!,
                          style: TextStyle(
                            fontSize: AppTheme.bodyRegular(context),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          mood['label']!,
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: AppTheme.bodyRegular(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: screen.height * 0.025),

          // ── Try saying card ─────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusLG),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _ui('try_saying'),
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: AppTheme.caption(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                ...examples.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: GestureDetector(
                      onTap: () {
                        // Strip quotes and send directly
                        _messageController.text = e.replaceAll('"', '').trim();
                        _sendMessage();
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: 10, top: 1),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              e,
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontSize: AppTheme.caption(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Input bar ─────────────────────────────────────────────────────────
  // KEY FIX: accounts for BOTH keyboard height (viewInsets.bottom)
  // AND system nav bar height (padding.bottom) so the bar never
  // hides behind Android's gesture nav / button bar.
  Widget _buildInputBar() {
    final mq = MediaQuery.of(context);
    final keyboardH = mq.viewInsets.bottom;
    final systemNavH = mq.padding.bottom;
    // When keyboard is up, viewInsets.bottom already includes system nav.
    // When keyboard is down, we need systemNavH explicitly.
    final bottomPad = keyboardH > 0 ? keyboardH + 8 : systemNavH + 8;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppTheme.horizontalPadding(context),
        10,
        AppTheme.horizontalPadding(context),
        bottomPad,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border, width: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.shimmerBase,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                border: Border.all(color: AppTheme.border),
              ),
              child: TextField(
                controller: _messageController,
                onSubmitted: (_) => _sendMessage(),
                maxLines: null,
                textInputAction: TextInputAction.send,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: AppTheme.bodyRegular(context),
                ),
                decoration: InputDecoration(
                  hintText: _ui('placeholder'),
                  hintStyle: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: AppTheme.bodyRegular(context),
                  ),
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 11,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
                boxShadow: AppTheme.shadowPrimary,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lang,
      builder: (context, _) => Scaffold(
        backgroundColor: AppTheme.background,
        // resizeToAvoidBottomInset keeps body from being obscured by keyboard
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: AppTheme.surface,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.shimmerBase,
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: AppTheme.textPrimary,
                size: 16,
              ),
            ),
          ),
          title: Row(
            children: [
              _lixAvatar(size: 36),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lix',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: AppTheme.bodyLarge(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _ui('online'),
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: AppTheme.caption(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(
                  Icons.logout_outlined,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                tooltip: _lang.translate('Logout'),
                onPressed: () async => await FirebaseAuth.instance.signOut(),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(height: 1, color: AppTheme.border),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? _buildWelcomeScreen()
                  : ListView.builder(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        AppTheme.horizontalPadding(context),
                        16,
                        AppTheme.horizontalPadding(context),
                        16,
                      ),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (_isTyping && index == _messages.length) {
                          return _buildTypingIndicator();
                        }
                        return _buildMessage(_messages[index]);
                      },
                    ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }
}
