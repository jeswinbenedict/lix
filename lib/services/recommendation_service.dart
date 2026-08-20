import 'tmdb_service.dart';

class RecommendationService {
  static const Map<String, List<Map<String, String>>> _songDatabase = {
    'Happy': [
      {
        'title': 'Happy',
        'artist': 'Pharrell Williams',
        'mood': 'Uplifting',
        'vibe':
            'A feel-good anthem that instantly lifts your spirits and makes you want to dance.',
      },
      {
        'title': 'Dynamite',
        'artist': 'BTS',
        'mood': 'Energetic',
        'vibe':
            'A bright disco-pop bop bursting with joy, colour and unstoppable energy.',
      },
    ],
    'Sad': [
      {
        'title': 'Fix You',
        'artist': 'Coldplay',
        'mood': 'Healing',
        'vibe':
            'A gentle, emotional journey from heartbreak to hope and quiet strength.',
      },
    ],
    'Anxious': [
      {
        'title': 'Weightless',
        'artist': 'Marconi Union',
        'mood': 'Calming',
        'vibe':
            'Scientifically designed to reduce anxiety — let the slow rhythm ease your mind.',
      },
    ],
    'Bored': [
      {
        'title': 'Electric Feel',
        'artist': 'MGMT',
        'mood': 'Fun',
        'vibe':
            'Psychedelic and groovy — the perfect track to shake off a dull afternoon.',
      },
    ],
    'Motivated': [
      {
        'title': 'Eye of the Tiger',
        'artist': 'Survivor',
        'mood': 'Motivational',
        'vibe':
            'The ultimate pump-up anthem — feel the drive and determination with every beat.',
      },
    ],
    'Romantic': [
      {
        'title': 'Perfect',
        'artist': 'Ed Sheeran',
        'mood': 'Romantic',
        'vibe':
            'Warm and heartfelt — a love song that feels like a slow dance under the stars.',
      },
    ],
  };

  static List<Map<String, String>> getSongsByMood(String mood) {
    return _songDatabase[mood] ?? _songDatabase['Happy']!;
  }

  static Future<Map<String, dynamic>> getRichRecommendation(
    String userMessage,
  ) async {
    final mood = detectMood(userMessage);
    final movies = await TmdbService.getMoviesByMood(mood);
    final songs = _songDatabase[mood] ?? _songDatabase['Happy']!;
    return {
      'text': 'Feeling $mood? Here are my picks for you:',
      'movies': movies,
      'songs': songs,
    };
  }

  static Future<String> getRecommendation(String userMessage) async {
    final mood = detectMood(userMessage);
    final movies = await TmdbService.getMoviesByMood(mood);
    final songs = _songDatabase[mood] ?? _songDatabase['Happy']!;

    final movieText = movies.isNotEmpty
        ? movies
              .map(
                (m) =>
                    '• ${m['title']} (${m['year']}) — ${m['genre']}\n  Rating: ${m['rating']}/10\n  ${m['desc']}',
              )
              .join('\n\n')
        : '• Could not load movies. Check internet connection.';

    final songText = songs
        .map((s) => '• ${s['title']} - ${s['artist']}\n  ${s['vibe']}')
        .join('\n\n');

    return '''
Feeling $mood? Here are my picks for you:

MOVIES:
$movieText

MUSIC:
$songText
    ''';
  }

  static String detectMood(String message) {
    final lower = message.toLowerCase();

    // 1. Emoji Direct Matching (using exact code-point containment)
    const happyEmojis = ['😊', '😄', '😃', '😁', '🎉', '🥳', '✨', '💃', '🕺', '🌞'];
    const sadEmojis = ['😢', '😭', '😔', '💔', '😞', '🌧️', '🌧', '😿', '🥀'];
    const anxiousEmojis = ['😰', '😨', '😥', '😱', '🥺', '🧘‍♂️', '🧘‍♀️', '🧘', '🕯️'];
    const boredEmojis = ['🥱', '😴', '💤', '😑', '😒', '🛋️'];
    const motivatedEmojis = ['💪', '🔥', '⚡', '🏃‍♂️', '🏃', '🏋️‍♀️', '🏋️', '🏆', '🚀'];
    const romanticEmojis = ['❤️', '💖', '💕', '😍', '🥰', '🌹', '😘', '💌'];

    if (sadEmojis.any(message.contains)) return 'Sad';
    if (happyEmojis.any(message.contains)) return 'Happy';
    if (anxiousEmojis.any(message.contains)) return 'Anxious';
    if (boredEmojis.any(message.contains)) return 'Bored';
    if (motivatedEmojis.any(message.contains)) return 'Motivated';
    if (romanticEmojis.any(message.contains)) return 'Romantic';

    // 2. Phrase & Keyword Patterns
    final happyScores = _countMatches(lower, [
      'happy', 'good', 'great', 'joy', 'cheerful', 'party', 'dance', 'celebrate',
      'blessed', 'fun', 'awesome', 'smiling', 'ecstatic', 'upbeat', 'wonderful'
    ]);

    final sadScores = _countMatches(lower, [
      'sad', 'depressed', 'crying', 'broken', 'heartbreak', 'gloomy', 'lonely',
      'down', 'hurt', 'pain', 'grief', 'melancholy', 'miss you', 'unhappy', 'terrible', 'awful'
    ]);

    final anxiousScores = _countMatches(lower, [
      'anxious', 'worried', 'stress', 'nervous', 'calm', 'relax', 'peace',
      'meditate', 'chill', 'lofi', 'panic', 'overwhelmed', 'deep breath', 'soothe'
    ]);

    final boredScores = _countMatches(lower, [
      'bored', 'tired', 'dull', 'nothing to do', 'sleepy', 'lazy', 'uninspired',
      'tedious', 'exhausted', 'slow day'
    ]);

    final motivatedScores = _countMatches(lower, [
      'motivated', 'excited', 'workout', 'gym', 'energy', 'grind', 'focus',
      'run', 'power', 'hustle', 'beast', 'pump', 'ambition', 'action'
    ]);

    final romanticScores = _countMatches(lower, [
      'romantic', 'love', 'date', 'couple', 'crush', 'kiss', 'candle',
      'valentine', 'sweetheart', 'darling', 'romance', 'slow dance'
    ]);

    final scores = {
      'Happy': happyScores,
      'Sad': sadScores,
      'Anxious': anxiousScores,
      'Bored': boredScores,
      'Motivated': motivatedScores,
      'Romantic': romanticScores,
    };

    String bestMood = 'Happy';
    int maxScore = 0;

    scores.forEach((mood, score) {
      if (score > maxScore) {
        maxScore = score;
        bestMood = mood;
      }
    });

    return bestMood;
  }

  static int _countMatches(String text, List<String> keywords) {
    int count = 0;
    for (final kw in keywords) {
      if (text.contains(kw)) count++;
    }
    return count;
  }
}
