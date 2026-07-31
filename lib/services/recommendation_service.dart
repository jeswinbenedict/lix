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
    message = message.toLowerCase();
    if (message.contains('happy') || message.contains('good')) {
      return 'Happy';
    }
    if (message.contains('sad') || message.contains('depressed')) {
      return 'Sad';
    }
    if (message.contains('anxious') || message.contains('worried')) {
      return 'Anxious';
    }
    if (message.contains('bored') || message.contains('tired')) {
      return 'Bored';
    }
    if (message.contains('motivated') || message.contains('excited')) {
      return 'Motivated';
    }
    if (message.contains('romantic') || message.contains('love')) {
      return 'Romantic';
    }
    return 'Happy';
  }
}
