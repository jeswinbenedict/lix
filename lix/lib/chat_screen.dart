import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'recommendation_service.dart';
import 'music_api_service.dart';
import 'tmdb_service.dart';
import 'app_theme.dart';
import 'movie_detail_screen.dart';
import 'music_player_screen.dart';
import 'language_service.dart';

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

  // ── Multilingual bot responses ─────────────────────────────
  static const Map<String, Map<String, String>> _botStrings = {
    'English': {
      'greeting':
          "Hey {name}! 👋 I'm Lix, your mood-based movie & music assistant!\n\nTell me how you're feeling, ask for songs in any language, or search any artist! 🎬🎵",
      'smalltalk':
          "I'm Lix! 💜 Here's what I can do:\n\n• 🎬 Recommend movies by mood\n• 🎵 Songs in any language\n• 🎤 Search any artist\n• 🎧 Genre picks (lofi, party, workout...)\n• 💬 Understand your mood\n\nJust ask me anything!",
      'thanks':
          "You're welcome! 😊💜\nAsk me for songs, movies, or tell me your mood anytime!",
      'song_search': "🎵 Here are {label} for you, {name}:",
      'movies_only': "🎬 Here are some movies for your {mood} mood, {name}:",
      'music_only': "🎵 Here are some songs matching your {mood} vibe, {name}:",
      'ask_mood':
          "I'd love to help! 💜 How are you feeling?\n\nOr try:\n• \"Give me Tamil sad songs\"\n• \"Songs by Arijit Singh\"\n• \"Show me action movies\"",
      'no_results': "Couldn't find results. Try another artist or mood! 🎵",
      'online': "Online",
      'thinking': "Lix is thinking...",
      'placeholder': "Songs, movies, artist, language...",
      'movie_picks': "🎬  Movie Picks",
      'music_picks': "🎵  Music Picks",
      'try_saying': "💡 Try saying:",
      'Happy':
          "Yay! 😊 Happiness looks good on you, {name}!\nHere are some picks to keep the good vibes going:",
      'Sad':
          "Sending you a big virtual hug 🤗💜\nThese might help you feel better, {name}:",
      'Anxious':
          "Take a deep breath 🌬️ You've got this, {name}!\nHere are some calming picks:",
      'Bored':
          "Let's fix that boredom! 😴➡️🔥\nHere are some exciting picks, {name}:",
      'Motivated':
          "LET'S GO {name}! 💪🔥\nFuel that energy with these power picks:",
      'Romantic':
          "Ooh, love is in the air! 😍💕\nPerfect picks for your romantic mood, {name}:",
      'welcome_title': "Hey {name}! I'm Lix 👋",
      'welcome_sub':
          "Tell me your mood, ask for songs in\nany language, or search any artist! 💜",
    },
    'Hindi': {
      'greeting':
          "नमस्ते {name}! 👋 मैं Lix हूँ, आपका मूड-बेस्ड मूवी और म्यूज़िक असिस्टेंट!\n\nबताइए आप कैसा महसूस कर रहे हैं! 🎬🎵",
      'smalltalk':
          "मैं Lix हूँ! 💜\n\n• 🎬 मूड के हिसाब से मूवी\n• 🎵 किसी भी भाषा में गाने\n• 🎤 कोई भी आर्टिस्ट सर्च\n• 🎧 लोफि, पार्टी, वर्कआउट...\n\nकुछ भी पूछें!",
      'thanks': "आपका स्वागत है! 😊💜",
      'song_search': "🎵 {name} के लिए {label}:",
      'movies_only': "🎬 {name}, आपके {mood} मूड के लिए मूवी:",
      'music_only': "🎵 {name}, आपके {mood} वाइब के लिए गाने:",
      'ask_mood': "मैं मदद करना चाहता हूँ! 💜 आप कैसा महसूस कर रहे हैं?",
      'no_results': "कोई रिजल्ट नहीं मिला। दूसरा आज़माएं! 🎵",
      'online': "ऑनलाइन",
      'thinking': "Lix सोच रहा है...",
      'placeholder': "गाने, मूवी, आर्टिस्ट, भाषा...",
      'movie_picks': "🎬  मूवी पिक्स",
      'music_picks': "🎵  म्यूज़िक पिक्स",
      'try_saying': "💡 ये आज़माएं:",
      'Happy': "वाह! 😊 खुशी आप पर खूब जँचती है, {name}!\nगुड वाइब्स के लिए:",
      'Sad':
          "एक बड़ा वर्चुअल गले मिलना 🤗💜\n{name}, ये आपको बेहतर महसूस कराएगा:",
      'Anxious':
          "गहरी सांस लें 🌬️ आप कर सकते हैं, {name}!\nशांत करने वाले पिक्स:",
      'Bored': "बोरियत दूर करते हैं! 😴➡️🔥\n{name} के लिए मजेदार पिक्स:",
      'Motivated': "चलो {name}! 💪🔥\nएनर्जी बढ़ाने के लिए:",
      'Romantic': "प्यार हवा में है! 😍💕\n{name} के रोमांटिक मूड के लिए:",
      'welcome_title': "नमस्ते {name}! मैं Lix हूँ 👋",
      'welcome_sub': "अपना मूड बताएं, किसी भी भाषा में\nगाने माँगें! 💜",
    },
    'Tamil': {
      'greeting':
          "வணக்கம் {name}! 👋 நான் Lix, உங்கள் மூட்-பேஸ்டு அசிஸ்டன்ட்!\n\nஉங்கள் மூட் சொல்லுங்கள்! 🎬🎵",
      'smalltalk':
          "நான் Lix! 💜\n\n• 🎬 மூட் படங்கள்\n• 🎵 எந்த மொழியிலும் பாடல்கள்\n• 🎤 கலைஞர் தேடல்\n\nகேளுங்கள்!",
      'thanks': "நன்றி! 😊💜",
      'song_search': "🎵 {name} க்காக {label}:",
      'movies_only': "🎬 {name}, உங்கள் {mood} மூட்க்கு படங்கள்:",
      'music_only': "🎵 {name}, உங்கள் {mood} வைப்க்கு பாடல்கள்:",
      'ask_mood': "உதவ விரும்புகிறேன்! 💜 நீங்கள் எப்படி உணர்கிறீர்கள்?",
      'no_results':
          "முடிவுகள் கிடைக்கவில்லை. வேறு ஒன்று முயற்சி செய்யுங்கள்! 🎵",
      'online': "ஆன்லைன்",
      'thinking': "Lix யோசிக்கிறது...",
      'placeholder': "பாடல்கள், படங்கள், கலைஞர், மொழி...",
      'movie_picks': "🎬  படம் பிக்ஸ்",
      'music_picks': "🎵  இசை பிக்ஸ்",
      'try_saying': "💡 இதை முயற்சிக்கவும்:",
      'Happy': "அருமை! 😊 மகிழ்ச்சி, {name}!\nநல்ல வைப்ஸ் தொடர:",
      'Sad': "ஒரு பெரிய virtual அணைப்பு 🤗💜\n{name}, இவை உதவும்:",
      'Anxious': "ஆழமாக சுவாசியுங்கள் 🌬️ {name}!\nசில அமைதியான பிக்ஸ்:",
      'Bored': "சலிப்பை சரி செய்வோம்! 😴➡️🔥\n{name} க்கு பிக்ஸ்:",
      'Motivated': "வாங்க {name}! 💪🔥\nஆற்றலை அதிகரிக்க:",
      'Romantic': "காதல் காற்றில்! 😍💕\n{name} க்கு ரோமாண்டிக் பிக்ஸ்:",
      'welcome_title': "வணக்கம் {name}! நான் Lix 👋",
      'welcome_sub':
          "உங்கள் மூட் சொல்லுங்கள், எந்த மொழியிலும்\nபாடல்கள் கேளுங்கள்! 💜",
    },
    'Telugu': {
      'greeting': "నమస్కారం {name}! 👋 నేను Lix!\n\nమీ మూడ్ చెప్పండి! 🎬🎵",
      'smalltalk':
          "నేను Lix! 💜\n\n• 🎬 మూడ్ సినిమాలు\n• 🎵 ఏ భాషలోనైనా పాటలు\n• 🎤 కళాకారుడు తేడు\n\nఏదైనా అడగండి!",
      'thanks': "స్వాగతం! 😊💜",
      'song_search': "🎵 {name} కోసం {label}:",
      'movies_only': "🎬 {name}, మీ {mood} మూడ్ కోసం:",
      'music_only': "🎵 {name}, మీ {mood} వైబ్ కోసం:",
      'ask_mood': "సహాయం చేయాలని ఉంది! 💜 మీరు ఎలా అనుభవిస్తున్నారు?",
      'no_results': "ఫలితాలు దొరకలేదు. వేరే ప్రయత్నించండి! 🎵",
      'online': "ఆన్‌లైన్",
      'thinking': "Lix ఆలోచిస్తోంది...",
      'placeholder': "పాటలు, సినిమాలు, కళాకారుడు...",
      'movie_picks': "🎬  సినిమా పిక్స్",
      'music_picks': "🎵  మ్యూజిక్ పిక్స్",
      'try_saying': "💡 ఇది ప్రయత్నించండి:",
      'Happy': "అద్భుతం! 😊 {name}!\nమంచి వైబ్స్ కొనసాగించడానికి:",
      'Sad': "వర్చువల్ హగ్ 🤗💜 {name}:",
      'Anxious': "లోతుగా శ్వాసించండి 🌬️ {name}!\nప్రశాంతమైన పిక్స్:",
      'Bored': "విసుగు తొలగిద్దాం! 😴➡️🔥 {name}:",
      'Motivated': "వెళ్దాం {name}! 💪🔥",
      'Romantic': "ప్రేమ గాలిలో! 😍💕 {name}:",
      'welcome_title': "నమస్కారం {name}! నేను Lix 👋",
      'welcome_sub': "మీ మూడ్ చెప్పండి, ఏ భాషలోనైనా\nపాటలు అడగండి! 💜",
    },
    'Kannada': {
      'greeting': "ನಮಸ್ಕಾರ {name}! 👋 ನಾನು Lix!\n\nನಿಮ್ಮ ಮೂಡ್ ಹೇಳಿ! 🎬🎵",
      'smalltalk':
          "ನಾನು Lix! 💜\n\n• 🎬 ಮೂಡ್ ಚಲನಚಿತ್ರಗಳು\n• 🎵 ಯಾವ ಭಾಷೆಯಲ್ಲಾದರೂ ಹಾಡುಗಳು\n\nಏಳ್ ಕೇಳಿ!",
      'thanks': "ಸ್ವಾಗತ! 😊💜",
      'song_search': "🎵 {name} ಗಾಗಿ {label}:",
      'movies_only': "🎬 {name}, {mood} ಮೂಡ್‌ಗೆ:",
      'music_only': "🎵 {name}, {mood} ವೈಬ್‌ಗೆ:",
      'ask_mood': "ಸಹಾಯ ಮಾಡಲು ಬಯಸುತ್ತೇನೆ! 💜 ಹೇಗೆ ಅನಿಸುತ್ತಿದೆ?",
      'no_results': "ಫಲಿತಾಂಶ ಸಿಗಲಿಲ್ಲ. ಬೇರೆ ಪ್ರಯತ್ನಿಸಿ! 🎵",
      'online': "ಆನ್‌ಲೈನ್",
      'thinking': "Lix ಯೋಚಿಸುತ್ತಿದೆ...",
      'placeholder': "ಹಾಡುಗಳು, ಚಲನಚಿತ್ರಗಳು, ಕಲಾವಿದ...",
      'movie_picks': "🎬  ಚಲನಚಿತ್ರ ಪಿಕ್ಸ್",
      'music_picks': "🎵  ಸಂಗೀತ ಪಿಕ್ಸ್",
      'try_saying': "💡 ಇದನ್ನು ಪ್ರಯತ್ನಿಸಿ:",
      'Happy': "ಅದ್ಭುತ! 😊 {name}!\nಒಳ್ಳೆಯ ವೈಬ್ ಮುಂದುವರಿಸಲು:",
      'Sad': "ಒಂದು ಅಪ್ಪುಗೆ 🤗💜 {name}:",
      'Anxious': "ಉಸಿರಾಡಿ 🌬️ {name}!\nಶಾಂತ ಪಿಕ್ಸ್:",
      'Bored': "ಬೇಸರ ನಿವಾರಿಸೋಣ! 😴➡️🔥 {name}:",
      'Motivated': "ಹೋಗೋಣ {name}! 💪🔥",
      'Romantic': "ಪ್ರೀತಿ ಗಾಳಿಯಲ್ಲಿ! 😍💕 {name}:",
      'welcome_title': "ನಮಸ್ಕಾರ {name}! ನಾನು Lix 👋",
      'welcome_sub': "ನಿಮ್ಮ ಮೂಡ್ ಹೇಳಿ, ಯಾವ ಭಾಷೆಯಲ್ಲಾದರೂ\nಹಾಡುಗಳನ್ನು ಕೇಳಿ! 💜",
    },
    'Malayalam': {
      'greeting':
          "നമസ്കാരം {name}! 👋 ഞാൻ Lix!\n\nഏത് ഭാഷയിലും പാട്ടുകൾ ചോദിക്കൂ! 🎬🎵",
      'smalltalk':
          "ഞാൻ Lix! 💜\n\n• 🎬 മൂഡ് സിനിമകൾ\n• 🎵 ഏത് ഭാഷയിലും പാട്ടുകൾ\n\nഎന്തും ചോദിക്കൂ!",
      'thanks': "സ്വാഗതം! 😊💜",
      'song_search': "🎵 {name} നു {label}:",
      'movies_only': "🎬 {name}, {mood} മൂഡിന്:",
      'music_only': "🎵 {name}, {mood} വൈബിന്:",
      'ask_mood': "സഹായിക്കാൻ ആഗ്രഹിക്കുന്നു! 💜 എങ്ങനെ അനുഭവിക്കുന്നു?",
      'no_results': "ഫലങ്ങൾ കിട്ടിയില്ല. മറ്റൊന്ന് ശ്രമിക്കൂ! 🎵",
      'online': "ഓൺലൈൻ",
      'thinking': "Lix ചിന്തിക്കുന്നു...",
      'placeholder': "പാട്ടുകൾ, സിനിമകൾ, കലാകാരൻ...",
      'movie_picks': "🎬  സിനിമ പിക്സ്",
      'music_picks': "🎵  മ്യൂസിക് പിക്സ്",
      'try_saying': "💡 ഇത് ശ്രമിക്കൂ:",
      'Happy': "ഗംഭീരം! 😊 {name}!\nനല്ല വൈബ്സ് തുടരാൻ:",
      'Sad': "ആലിംഗനം 🤗💜 {name}:",
      'Anxious': "ശ്വസിക്കൂ 🌬️ {name}!\nശാന്തമായ പിക്സ്:",
      'Bored': "മടുപ്പ് മാറ്റാം! 😴➡️🔥 {name}:",
      'Motivated': "പോകാം {name}! 💪🔥",
      'Romantic': "പ്രണയം! 😍💕 {name}:",
      'welcome_title': "നമസ്കാരം {name}! ഞാൻ Lix 👋",
      'welcome_sub': "മൂഡ് പറയൂ, ഏത് ഭാഷയിലും\nപാട്ടുകൾ ചോദിക്കൂ! 💜",
    },
    'Bengali': {
      'greeting':
          "নমস্কার {name}! 👋 আমি Lix!\n\nযেকোনো ভাষায় গান চাইতে পারেন! 🎬🎵",
      'smalltalk':
          "আমি Lix! 💜\n\n• 🎬 মুড মুভি\n• 🎵 যেকোনো ভাষায় গান\n\nযা খুশি জিজ্ঞেস করুন!",
      'thanks': "আপনাকে স্বাগতম! 😊💜",
      'song_search': "🎵 {name} এর জন্য {label}:",
      'movies_only': "🎬 {name}, {mood} মুডের জন্য:",
      'music_only': "🎵 {name}, {mood} ভাইবের জন্য:",
      'ask_mood': "সাহায্য করতে চাই! 💜 কেমন অনুভব করছেন?",
      'no_results': "ফলাফল পাওয়া যায়নি। অন্য কিছু চেষ্টা করুন! 🎵",
      'online': "অনলাইন",
      'thinking': "Lix ভাবছে...",
      'placeholder': "গান, মুভি, শিল্পী, ভাষা...",
      'movie_picks': "🎬  মুভি পিক্স",
      'music_picks': "🎵  মিউজিক পিক্স",
      'try_saying': "💡 এটি চেষ্টা করুন:",
      'Happy': "দারুণ! 😊 {name}!\nভালো ভাইবস চালিয়ে যেতে:",
      'Sad': "আলিঙ্গন 🤗💜 {name}:",
      'Anxious': "গভীরে শ্বাস নিন 🌬️ {name}!\nশান্তিপূর্ণ পিক্স:",
      'Bored': "বিরক্তি দূর করা যাক! 😴➡️🔥 {name}:",
      'Motivated': "চলো {name}! 💪🔥",
      'Romantic': "ভালোবাসা বাতাসে! 😍💕 {name}:",
      'welcome_title': "নমস্কার {name}! আমি Lix 👋",
      'welcome_sub': "মুড বলুন, যেকোনো ভাষায়\nগান চাইতে পারেন! 💜",
    },
    'Arabic': {
      'greeting': "مرحباً {name}! 👋 أنا Lix!\n\nأخبرني كيف تشعر! 🎬🎵",
      'smalltalk':
          "أنا Lix! 💜\n\n• 🎬 أفلام حسب المزاج\n• 🎵 أغاني بأي لغة\n\nاسألني أي شيء!",
      'thanks': "على الرحب! 😊💜",
      'song_search': "🎵 {name} هذه {label}:",
      'movies_only': "🎬 {name}، أفلام لمزاجك {mood}:",
      'music_only': "🎵 {name}، أغاني لأجواءك {mood}:",
      'ask_mood': "أريد المساعدة! 💜 كيف تشعر الآن؟",
      'no_results': "لم يتم العثور على نتائج. جرب شيئاً آخر! 🎵",
      'online': "متصل",
      'thinking': "Lix يفكر...",
      'placeholder': "أغاني، أفلام، فنان، لغة...",
      'movie_picks': "🎬  اختيارات الأفلام",
      'music_picks': "🎵  اختيارات الموسيقى",
      'try_saying': "💡 جرب قول:",
      'Happy': "رائع! 😊 {name}!\nللحفاظ على هذه الأجواء:",
      'Sad': "عناق افتراضي 🤗💜 {name}:",
      'Anxious': "خذ نفساً عميقاً 🌬️ {name}!\nاختيارات مهدئة:",
      'Bored': "لنعالج الملل! 😴➡️🔥 {name}:",
      'Motivated': "هيا {name}! 💪🔥",
      'Romantic': "الحب في الهواء! 😍💕 {name}:",
      'welcome_title': "مرحباً {name}! أنا Lix 👋",
      'welcome_sub': "أخبرني بمزاجك، اطلب أغاني\nبأي لغة! 💜",
    },
    'Spanish': {
      'greeting':
          "¡Hola {name}! 👋 ¡Soy Lix!\n\n¡Pide canciones en cualquier idioma! 🎬🎵",
      'smalltalk':
          "¡Soy Lix! 💜\n\n• 🎬 Películas por estado de ánimo\n• 🎵 Canciones en cualquier idioma\n\n¡Pregúntame lo que quieras!",
      'thanks': "¡De nada! 😊💜",
      'song_search': "🎵 {label} para ti, {name}:",
      'movies_only': "🎬 {name}, películas para tu estado {mood}:",
      'music_only': "🎵 {name}, canciones para tu vibra {mood}:",
      'ask_mood': "¡Me encantaría ayudar! 💜 ¿Cómo te sientes?",
      'no_results': "No se encontraron resultados. ¡Prueba con otro! 🎵",
      'online': "En línea",
      'thinking': "Lix está pensando...",
      'placeholder': "Canciones, películas, artista...",
      'movie_picks': "🎬  Películas",
      'music_picks': "🎵  Música",
      'try_saying': "💡 Prueba decir:",
      'Happy': "¡Genial! 😊 {name}!\nPara mantener las buenas vibras:",
      'Sad': "Un gran abrazo virtual 🤗💜 {name}:",
      'Anxious': "Respira profundo 🌬️ {name}!\nAlgunas opciones relajantes:",
      'Bored': "¡Arreglemos el aburrimiento! 😴➡️🔥 {name}:",
      'Motivated': "¡Vamos {name}! 💪🔥",
      'Romantic': "¡El amor está en el aire! 😍💕 {name}:",
      'welcome_title': "¡Hola {name}! Soy Lix 👋",
      'welcome_sub':
          "Cuéntame tu estado de ánimo, ¡pide canciones\nen cualquier idioma! 💜",
    },
    'French': {
      'greeting':
          "Bonjour {name}! 👋 Je suis Lix!\n\nDemande des chansons dans n'importe quelle langue! 🎬🎵",
      'smalltalk':
          "Je suis Lix! 💜\n\n• 🎬 Films selon l'humeur\n• 🎵 Chansons dans toutes les langues\n\nDemande-moi n'importe quoi!",
      'thanks': "De rien! 😊💜",
      'song_search': "🎵 {label} pour toi, {name}:",
      'movies_only': "🎬 {name}, films pour ton humeur {mood}:",
      'music_only': "🎵 {name}, chansons pour ta vibe {mood}:",
      'ask_mood': "J'adorerais t'aider! 💜 Comment tu te sens?",
      'no_results': "Pas de résultats. Essaie autre chose! 🎵",
      'online': "En ligne",
      'thinking': "Lix réfléchit...",
      'placeholder': "Chansons, films, artiste...",
      'movie_picks': "🎬  Films",
      'music_picks': "🎵  Musique",
      'try_saying': "💡 Essaie de dire:",
      'Happy': "Super! 😊 {name}!\nPour garder cette bonne humeur:",
      'Sad': "Un grand câlin virtuel 🤗💜 {name}:",
      'Anxious': "Respire profondément 🌬️ {name}!\nQuelques choix apaisants:",
      'Bored': "Réglons cet ennui! 😴➡️🔥 {name}:",
      'Motivated': "Allons-y {name}! 💪🔥",
      'Romantic': "L'amour est dans l'air! 😍💕 {name}:",
      'welcome_title': "Bonjour {name}! Je suis Lix 👋",
      'welcome_sub':
          "Dis-moi ton humeur, demande des chansons\ndans n'importe quelle langue! 💜",
    },
    'German': {
      'greeting':
          "Hallo {name}! 👋 Ich bin Lix!\n\nFrag nach Songs in jeder Sprache! 🎬🎵",
      'smalltalk':
          "Ich bin Lix! 💜\n\n• 🎬 Filme nach Stimmung\n• 🎵 Songs in jeder Sprache\n\nFrag mich alles!",
      'thanks': "Bitte sehr! 😊💜",
      'song_search': "🎵 {label} für dich, {name}:",
      'movies_only': "🎬 {name}, Filme für deine {mood} Stimmung:",
      'music_only': "🎵 {name}, Songs für deine {mood} Stimmung:",
      'ask_mood': "Ich würde gerne helfen! 💜 Wie fühlst du dich?",
      'no_results': "Keine Ergebnisse. Versuch etwas anderes! 🎵",
      'online': "Online",
      'thinking': "Lix denkt nach...",
      'placeholder': "Songs, Filme, Künstler...",
      'movie_picks': "🎬  Film-Picks",
      'music_picks': "🎵  Musik-Picks",
      'try_saying': "💡 Versuch zu sagen:",
      'Happy': "Super! 😊 {name}!\nUm die gute Stimmung zu halten:",
      'Sad': "Eine große virtuelle Umarmung 🤗💜 {name}:",
      'Anxious': "Atme tief durch 🌬️ {name}!\nEinige beruhigende Picks:",
      'Bored': "Lass uns die Langeweile vertreiben! 😴➡️🔥 {name}:",
      'Motivated': "Los geht's {name}! 💪🔥",
      'Romantic': "Liebe liegt in der Luft! 😍💕 {name}:",
      'welcome_title': "Hallo {name}! Ich bin Lix 👋",
      'welcome_sub':
          "Sag mir deine Stimmung, frag nach Songs\nin jeder Sprache! 💜",
    },
    'Japanese': {
      'greeting': "こんにちは {name}! 👋 私はLixです!\n\nどんな言語でも曲をリクエストできます! 🎬🎵",
      'smalltalk': "私はLixです! 💜\n\n• 🎬 ムード映画\n• 🎵 どの言語でも曲\n\n何でも聞いて!",
      'thanks': "どういたしまして! 😊💜",
      'song_search': "🎵 {name}さんのための{label}:",
      'movies_only': "🎬 {name}さん、{mood}な気分の映画:",
      'music_only': "🎵 {name}さん、{mood}な気分の曲:",
      'ask_mood': "お手伝いしたいです! 💜 どんな気分ですか?",
      'no_results': "結果が見つかりませんでした。別のものを試してください! 🎵",
      'online': "オンライン",
      'thinking': "Lixが考えています...",
      'placeholder': "曲、映画、アーティスト...",
      'movie_picks': "🎬  映画ピックス",
      'music_picks': "🎵  音楽ピックス",
      'try_saying': "💡 試してみて:",
      'Happy': "やったー! 😊 {name}さん!\nその良い気分を続けるために:",
      'Sad': "バーチャルハグ 🤗💜 {name}さん:",
      'Anxious': "深呼吸して 🌬️ {name}さん!\n落ち着くピックス:",
      'Bored': "退屈を解消しましょう! 😴➡️🔥 {name}さん:",
      'Motivated': "行くよ{name}さん! 💪🔥",
      'Romantic': "恋愛気分ですね! 😍💕 {name}さん:",
      'welcome_title': "こんにちは {name}! 私はLixです 👋",
      'welcome_sub': "気分を教えて、どの言語でも\n曲をリクエストできます! 💜",
    },
    'Korean': {
      'greeting': "안녕하세요 {name}! 👋 저는 Lix입니다!\n\n어떤 언어로든 노래를 요청하세요! 🎬🎵",
      'smalltalk':
          "저는 Lix입니다! 💜\n\n• 🎬 무드별 영화\n• 🎵 모든 언어의 노래\n\n무엇이든 물어보세요!",
      'thanks': "천만에요! 😊💜",
      'song_search': "🎵 {name}님을 위한 {label}:",
      'movies_only': "🎬 {name}님, {mood} 무드를 위한 영화:",
      'music_only': "🎵 {name}님, {mood} 바이브를 위한 노래:",
      'ask_mood': "도와드리고 싶어요! 💜 어떤 기분이세요?",
      'no_results': "결과를 찾을 수 없습니다. 다른 것을 시도해보세요! 🎵",
      'online': "온라인",
      'thinking': "Lix가 생각 중...",
      'placeholder': "노래, 영화, 아티스트...",
      'movie_picks': "🎬  영화 픽스",
      'music_picks': "🎵  음악 픽스",
      'try_saying': "💡 이렇게 말해보세요:",
      'Happy': "와! 😊 {name}님!\n좋은 분위기 유지하기 위해:",
      'Sad': "가상 포옹 🤗💜 {name}님:",
      'Anxious': "깊게 숨을 쉬세요 🌬️ {name}님!\n진정시키는 픽스:",
      'Bored': "지루함을 해결해봐요! 😴➡️🔥 {name}님:",
      'Motivated': "가자 {name}님! 💪🔥",
      'Romantic': "사랑이 공기 중에! 😍💕 {name}님:",
      'welcome_title': "안녕하세요 {name}! 저는 Lix입니다 👋",
      'welcome_sub': "무드를 알려주세요, 어떤 언어로든\n노래를 요청하세요! 💜",
    },
  };

  // ── Detect language from user's input script ──────────────
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
    return _lang.language; // fallback to app's selected language
  }

  // ── Get string in current or overridden language ───────────
  String _s(
    String key, {
    String name = '',
    String label = '',
    String mood = '',
    String? langOverride,
  }) {
    final lang = langOverride ?? _lang.language;
    final map = _botStrings[lang] ?? _botStrings['English']!;
    String text = map[key] ?? _botStrings['English']![key] ?? key;
    return text
        .replaceAll('{name}', name)
        .replaceAll('{label}', label)
        .replaceAll('{mood}', mood);
  }

  // ── Intent detection ──────────────────────────────────────
  Map<String, dynamic> _detectIntent(String text) {
    final t = text.toLowerCase().trim();
    if (RegExp(
          r'\b(hi|hello|hey|hola|howdy|namaste|vanakkam|namaskar|annyeong|konnichiwa|bonjour|hallo)\b',
        ).hasMatch(t) ||
        RegExp(
          r'\b(good morning|good evening|good afternoon|good night)\b',
        ).hasMatch(t) ||
        RegExp(r"\b(what'?s up|sup)\b").hasMatch(t)) {
      return {'intent': 'greeting'};
    }
    if (RegExp(
          r'\b(how are you|how r u|who are you|what are you|what can you do)\b',
        ).hasMatch(t) ||
        (RegExp(r'\bhelp\b').hasMatch(t) && t.length < 10)) {
      return {'intent': 'smalltalk'};
    }
    if (RegExp(
          r'\b(thank|thanks|thx|ty|awesome|nice|perfect|great|shukriya|dhanyavad|nandri)\b',
        ).hasMatch(t) ||
        t.contains('good job') ||
        t.contains('love it')) {
      return {'intent': 'thanks'};
    }
    final languages = {
      'tamil': 'Tamil',
      'hindi': 'Hindi',
      'telugu': 'Telugu',
      'malayalam': 'Malayalam',
      'kannada': 'Kannada',
      'punjabi': 'Punjabi',
      'bengali': 'Bengali',
      'marathi': 'Marathi',
      'english': 'English',
      'korean': 'Korean',
      'japanese': 'Japanese',
      'spanish': 'Spanish',
      'arabic': 'Arabic',
      'french': 'French',
      'german': 'German',
      'portuguese': 'Portuguese',
      'russian': 'Russian',
      'italian': 'Italian',
      'turkish': 'Turkish',
      'chinese': 'Mandarin',
      'mandarin': 'Mandarin',
    };
    for (final entry in languages.entries) {
      if (RegExp(r'\b' + entry.key + r'\b').hasMatch(t)) {
        String moodCtx = '';
        if (RegExp(r'\b(sad|dukhi|emotional|kazhivu)\b').hasMatch(t))
          moodCtx = 'sad';
        else if (RegExp(r'\b(happy|khushi|joyful)\b').hasMatch(t))
          moodCtx = 'happy';
        else if (RegExp(r'\b(love|romantic|romance|kadhal)\b').hasMatch(t))
          moodCtx = 'love';
        else if (RegExp(r'\b(motivat|energy|pump|power)\b').hasMatch(t))
          moodCtx = 'motivation';
        else if (RegExp(r'\b(lofi|chill|relax)\b').hasMatch(t))
          moodCtx = 'chill';
        else if (RegExp(r'\b(party|dance|kuthu)\b').hasMatch(t))
          moodCtx = 'party';
        else if (RegExp(r'\b(devotional|bhajan|worship)\b').hasMatch(t))
          moodCtx = 'devotional';
        else if (RegExp(r'\b(workout|gym)\b').hasMatch(t))
          moodCtx = 'workout';
        else if (RegExp(r'\b(sleep|night|calm)\b').hasMatch(t))
          moodCtx = 'sleep';
        else if (RegExp(r'\b(classical|instrumental)\b').hasMatch(t))
          moodCtx = 'classical';
        final q = moodCtx.isNotEmpty
            ? '${entry.value} $moodCtx songs'
            : '${entry.value} songs';
        return {'intent': 'song_search', 'query': q, 'label': q};
      }
    }
    final artistPatterns = [
      RegExp(r'songs?\s+by\s+(.+)'),
      RegExp(r'music\s+by\s+(.+)'),
      RegExp(r'playlist\s+(?:of|by)\s+(.+)'),
      RegExp(r'play\s+(.+)\s+songs?'),
      RegExp(r'(?:give\s+me|show\s+me|get\s+me)\s+(.+)\s+songs?'),
      RegExp(r'(.+)\s+songs?$'),
      RegExp(r'(.+)\s+music$'),
    ];
    for (final pattern in artistPatterns) {
      final match = pattern.firstMatch(t);
      if (match != null) {
        final artist = match.group(1)?.trim() ?? '';
        if (artist.isNotEmpty &&
            !_isMoodWord(artist) &&
            !_isGenreWord(artist)) {
          return {
            'intent': 'song_search',
            'query': artist,
            'label': '$artist songs',
          };
        }
      }
    }
    final genreMap = {
      'lofi': 'lofi chill beats',
      'lo-fi': 'lofi chill beats',
      'party': 'party hits dance',
      'devotional': 'devotional spiritual songs',
      'worship': 'worship praise songs',
      'bhajan': 'bhajan devotional songs',
      'workout': 'workout gym motivation',
      'gym': 'gym workout pump up',
      'sleep': 'sleep relaxing calm',
      'study': 'study focus concentration',
      'classical': 'classical instrumental',
      'jazz': 'jazz smooth',
      'rock': 'rock hits',
      'pop': 'pop hits',
      'rap': 'rap hip hop',
      'hip hop': 'hip hop rap',
      'hip-hop': 'hip hop rap',
      'indie': 'indie alternative',
      'acoustic': 'acoustic guitar',
      'instrumental': 'instrumental music',
      'retro': 'retro 80s 90s',
      'folk': 'folk music',
      'edm': 'edm electronic dance',
      'metal': 'metal rock heavy',
      'romantic': 'romantic love songs',
      'wedding': 'wedding songs romantic',
    };
    for (final entry in genreMap.entries) {
      if (t.contains(entry.key)) {
        return {
          'intent': 'song_search',
          'query': entry.value,
          'label': '${entry.key} songs',
        };
      }
    }
    if (RegExp(
      r'\b(movie|film|watch|cinema|series|show|netflix|disney|horror|action|comedy|thriller|anime|documentary|sci.fi)\b',
    ).hasMatch(t)) {
      return {'intent': 'movies_only'};
    }
    if (RegExp(
      r'\b(music|song|playlist|listen|spotify|beats|track|album|artist|singer|band)\b',
    ).hasMatch(t)) {
      return {'intent': 'music_only'};
    }
    if (RegExp(
      r'\b(happy|happiness|joyful|excited|wonderful|amazing|cheerful|smile|glad)\b',
    ).hasMatch(t)) {
      return {'intent': 'mood:Happy'};
    }
    if (RegExp(
          r'\b(sad|depressed|unhappy|cry|crying|tears|heartbreak|lonely|grief|upset)\b',
        ).hasMatch(t) ||
        t.contains('miss ') ||
        t.contains('broke up') ||
        t.contains('break up')) {
      return {'intent': 'mood:Sad'};
    }
    if (RegExp(
      r'\b(anxious|anxiety|stress|stressed|nervous|worried|panic|fear|scared|overthinking)\b',
    ).hasMatch(t)) {
      return {'intent': 'mood:Anxious'};
    }
    if (RegExp(r'\b(bored|boring|lazy|dull|sleepy|empty)\b').hasMatch(t) ||
        t.contains('nothing to do') ||
        t.contains('nothing to watch')) {
      return {'intent': 'mood:Bored'};
    }
    if (RegExp(
      r'\b(motivated|motivation|energy|workout|hustle|grind|focus|productive|goal|achieve)\b',
    ).hasMatch(t)) {
      return {'intent': 'mood:Motivated'};
    }
    if (RegExp(
      r'\b(romance|love|crush|date|valentine|sweet|tender|girlfriend|boyfriend)\b',
    ).hasMatch(t)) {
      return {'intent': 'mood:Romantic'};
    }
    if (RegExp(r'\b(feel|feeling|mood|vibe|emotion)\b').hasMatch(t)) {
      return {'intent': 'ask_mood'};
    }
    return {
      'intent': 'song_search',
      'query': text.trim(),
      'label': 'results for "$text"',
    };
  }

  bool _isMoodWord(String s) => RegExp(
    r'\b(happy|sad|anxious|bored|motivated|romantic|chill|calm|angry)\b',
  ).hasMatch(s.toLowerCase());

  bool _isGenreWord(String s) => RegExp(
    r'\b(pop|rock|jazz|classical|lofi|indie|rap|edm|metal|folk|party)\b',
  ).hasMatch(s.toLowerCase());

  // ── Build bot text in detected or app language ─────────────
  String _buildBotText(
    Map<String, dynamic> result,
    String mood, {
    String? langOverride,
  }) {
    final intent = result['intent'] as String;
    final label = result['label'] as String? ?? '';
    final name =
        FirebaseAuth.instance.currentUser?.displayName?.split(' ').first ??
        'friend';
    switch (intent) {
      case 'greeting':
        return _s('greeting', name: name, langOverride: langOverride);
      case 'smalltalk':
        return _s('smalltalk', name: name, langOverride: langOverride);
      case 'thanks':
        return _s('thanks', name: name, langOverride: langOverride);
      case 'song_search':
        return _s(
          'song_search',
          name: name,
          label: label,
          langOverride: langOverride,
        );
      case 'movies_only':
        return _s(
          'movies_only',
          name: name,
          mood: mood,
          langOverride: langOverride,
        );
      case 'music_only':
        return _s(
          'music_only',
          name: name,
          mood: mood,
          langOverride: langOverride,
        );
      case 'ask_mood':
        return _s('ask_mood', name: name, langOverride: langOverride);
      default:
        if (intent.startsWith('mood:')) {
          final m = intent.split(':')[1];
          return _s(m, name: name, langOverride: langOverride);
        }
        return _s(
          'song_search',
          name: name,
          label: label,
          langOverride: langOverride,
        );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // ✅ Detect language from what the user typed
    final detectedLang = _detectInputLanguage(text);

    setState(() {
      _messages.add({'role': 'user', 'type': 'text', 'text': text});
      _isTyping = true;
    });
    _messageController.clear();
    _scrollToBottom();
    await Future.delayed(const Duration(milliseconds: 800));

    final result = _detectIntent(text);
    final intent = result['intent'] as String;
    final query = result['query'] as String?;
    final mood = intent.startsWith('mood:')
        ? intent.split(':')[1]
        : RecommendationService.detectMood(text);

    // ✅ Pass detected language so bot replies in the same language
    final botText = _buildBotText(result, mood, langOverride: detectedLang);

    List<Map<String, String>> movies = [];
    List<Map<String, String>> songs = [];
    const noMedia = {'greeting', 'smalltalk', 'thanks', 'ask_mood'};
    if (!noMedia.contains(intent)) {
      switch (intent) {
        case 'song_search':
          songs = await MusicApiService.searchSongs(query ?? text);
          if (songs.isEmpty) songs = await MusicApiService.getSongsByMood(mood);
          break;
        case 'music_only':
          songs = await MusicApiService.getSongsByMood(mood);
          break;
        case 'movies_only':
          movies = await TmdbService.getMoviesByMood(mood);
          break;
        default:
          movies = await TmdbService.getMoviesByMood(mood);
          songs = await MusicApiService.getSongsByMood(mood);
          break;
      }
    }
    if (mounted) {
      setState(() {
        _messages.add({
          'role': 'bot',
          'type': noMedia.contains(intent) ? 'text' : 'rich',
          'text': botText,
          'movies': movies,
          'songs': songs,
        });
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

  Widget _buildMovieRow(List<Map<String, String>> movies) {
    const cardH = 220.0;
    const imageH = 140.0;
    final cardW = MediaQuery.of(context).size.width * 0.32;
    return SizedBox(
      height: cardH,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: movies.map((movie) {
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MovieDetailScreen(movie: movie),
              ),
            ),
            child: Container(
              width: cardW,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                border: Border.all(color: AppTheme.border),
                boxShadow: AppTheme.shadowSM,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppTheme.radiusMD),
                    ),
                    child: SizedBox(
                      width: cardW,
                      height: imageH,
                      child:
                          movie['poster'] != null && movie['poster']!.isNotEmpty
                          ? Image.network(
                              movie['poster']!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _moviePlaceholder(),
                            )
                          : _moviePlaceholder(),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 5, 6, 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            movie['title'] ?? '',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: AppTheme.caption(context),
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '⭐ ${movie['rating']}  •  ${movie['year']}',
                            style: TextStyle(
                              color: AppTheme.warning,
                              fontSize: AppTheme.caption(context) - 1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _moviePlaceholder() => Container(
    color: AppTheme.shimmerBase,
    child: const Center(
      child: Icon(
        Icons.movie_outlined,
        color: AppTheme.textSecondary,
        size: 28,
      ),
    ),
  );

  Widget _buildSongList(List<Map<String, String>> songs) {
    return Column(
      children: songs.take(6).map((song) {
        final hasCover = (song['cover'] ?? '').isNotEmpty;
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MusicPlayerScreen(song: song)),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: hasCover
                      ? Image.network(
                          song['cover']!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _musicIcon(),
                        )
                      : _musicIcon(),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song['title'] ?? '',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: AppTheme.caption(context),
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        song['artist'] ?? '',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: AppTheme.caption(context) - 1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if ((song['duration'] ?? '00:00') != '00:00')
                        Text(
                          song['duration']!,
                          style: TextStyle(
                            color: AppTheme.primary.withOpacity(0.7),
                            fontSize: AppTheme.caption(context) - 2,
                          ),
                        ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.play_circle_outline,
                  color: AppTheme.primary,
                  size: 24,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _musicIcon() => Container(
    width: 40,
    height: 40,
    color: AppTheme.primary.withOpacity(0.15),
    child: const Icon(Icons.music_note, color: AppTheme.primary, size: 20),
  );

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

  Widget _buildMessage(Map<String, dynamic> message) {
    final isUser = message['role'] == 'user';
    final maxW = MediaQuery.of(context).size.width * 0.75;
    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              height: 1.4,
            ),
          ),
        ),
      );
    }
    if (message['type'] == 'rich') {
      final movies =
          (message['movies'] as List?)?.cast<Map<String, String>>() ?? [];
      final songs =
          (message['songs'] as List?)?.cast<Map<String, String>>() ?? [];
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.all(14),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.92,
          ),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
              if (movies.isNotEmpty) ...[
                SizedBox(height: AppTheme.sectionGap(context) * 0.5),
                Text(
                  _s('movie_picks'),
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: AppTheme.bodyRegular(context),
                  ),
                ),
                const SizedBox(height: 8),
                _buildMovieRow(movies),
              ],
              if (songs.isNotEmpty) ...[
                SizedBox(height: AppTheme.sectionGap(context) * 0.5),
                Text(
                  _s('music_picks'),
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: AppTheme.bodyRegular(context),
                  ),
                ),
                const SizedBox(height: 8),
                _buildSongList(songs),
              ],
              if (movies.isEmpty && songs.isEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.shimmerBase,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppTheme.textSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _s('no_results'),
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: AppTheme.caption(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              _s('thinking'),
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

  Widget _buildMoodButtons() {
    final moods = [
      {
        'label': '😊 ${_lang.translate('Happy')}',
        'value': 'I am feeling happy',
      },
      {'label': '😢 ${_lang.translate('Sad')}', 'value': 'I am feeling sad'},
      {
        'label': '😰 ${_lang.translate('Anxious')}',
        'value': 'I am feeling anxious',
      },
      {'label': '😴 ${_lang.translate('Bored')}', 'value': 'I am bored'},
      {
        'label': '💪 ${_lang.translate('Motivated')}',
        'value': 'I am feeling motivated',
      },
      {
        'label': '😍 ${_lang.translate('Romantic')}',
        'value': 'I am feeling romantic',
      },
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: moods.map((mood) {
        return GestureDetector(
          onTap: () {
            _messageController.text = mood['value']!;
            _sendMessage();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
              boxShadow: AppTheme.shadowSM,
            ),
            child: Text(
              mood['label']!,
              style: TextStyle(
                color: AppTheme.primary,
                fontSize: AppTheme.bodyRegular(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWelcomeScreen() {
    final hPad = AppTheme.horizontalPadding(context);
    final name =
        FirebaseAuth.instance.currentUser?.displayName?.split(' ').first ??
        'there';
    final examples = _lang.language == 'Tamil'
        ? [
            '"தமிழ் சோக பாடல்கள் கொடு"',
            '"AR Rahman பாடல்கள்"',
            '"Action படம் காட்டு"',
            '"Lofi இசை போடு"',
          ]
        : _lang.language == 'Hindi'
        ? [
            '"हिंदी पार्टी सॉन्ग दो"',
            '"अरिजीत सिंह के गाने"',
            '"एक्शन मूवी दिखाओ"',
            '"लोफि चलाओ"',
          ]
        : _lang.language == 'Arabic'
        ? [
            '"أغاني عربية حزينة"',
            '"أغاني أم كلثوم"',
            '"أفلام إثارة"',
            '"موسيقى هادئة"',
          ]
        : _lang.language == 'Korean'
        ? ['"한국 슬픈 노래"', '"BTS 노래"', '"액션 영화 보여줘"', '"로파이 음악 틀어줘"']
        : _lang.language == 'Japanese'
        ? ['"日本語の悲しい曲"', '"アクション映画"', '"ロフィ音楽"', '"J-POP 曲"']
        : [
            '"Give me Hindi party songs"',
            '"Tamil sad songs"',
            '"Songs by AR Rahman"',
            '"Play some lofi music"',
            '"Show me action movies"',
            '"I just broke up, need comfort"',
          ];

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.06),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, Color(0xFF9C8FFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: AppTheme.shadowPrimary,
            ),
            child: const Text('🎬', style: TextStyle(fontSize: 44)),
          ),
          SizedBox(height: AppTheme.sectionGap(context)),
          Text(
            _s('welcome_title', name: name),
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: AppTheme.heading1(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _s('welcome_sub'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: AppTheme.bodyRegular(context),
              height: 1.6,
            ),
          ),
          SizedBox(height: AppTheme.sectionGap(context)),
          _buildMoodButtons(),
          SizedBox(height: AppTheme.sectionGap(context) * 0.5),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusLG),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _s('try_saying'),
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: AppTheme.caption(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                for (final e in examples)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '  • $e',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: AppTheme.caption(context),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: AppTheme.sectionGap(context)),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppTheme.horizontalPadding(context),
        10,
        AppTheme.horizontalPadding(context),
        10 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
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
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: AppTheme.bodyRegular(context),
                ),
                decoration: InputDecoration(
                  hintText: _s('placeholder'),
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
                    vertical: 12,
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
        appBar: AppBar(
          backgroundColor: AppTheme.surface,
          elevation: 0,
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
                        _s('online'),
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
                        if (_isTyping && index == _messages.length)
                          return _buildTypingIndicator();
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
