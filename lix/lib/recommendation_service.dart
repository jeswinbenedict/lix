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
      {
        'title': 'Walking on Sunshine',
        'artist': 'Katrina & The Waves',
        'mood': 'Joyful',
        'vibe':
            'Pure sunshine in song form — upbeat, carefree and impossible not to smile to.',
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
      {
        'title': 'Someone Like You',
        'artist': 'Adele',
        'mood': 'Emotional',
        'vibe':
            'Raw and powerful — a voice that carries the weight of love lost.',
      },
      {
        'title': 'The Night We Met',
        'artist': 'Lord Huron',
        'mood': 'Reflective',
        'vibe':
            'Hauntingly beautiful — a song that takes you back to a moment in time.',
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
      {
        'title': 'Breathe Me',
        'artist': 'Sia',
        'mood': 'Comforting',
        'vibe':
            'Tender and intimate — a soft reminder that it is okay to ask for help.',
      },
      {
        'title': 'Holocene',
        'artist': 'Bon Iver',
        'mood': 'Peaceful',
        'vibe':
            'Vast and cinematic — like standing in nature and feeling completely at peace.',
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
      {
        'title': 'Feel It Still',
        'artist': 'Portugal. The Man',
        'mood': 'Groovy',
        'vibe':
            'Retro-cool with an irresistible beat that makes sitting still impossible.',
      },
      {
        'title': 'Take On Me',
        'artist': 'a-ha',
        'mood': 'Retro Fun',
        'vibe':
            'An 80s classic with a soaring melody that never gets old — pure nostalgia.',
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
      {
        'title': 'Sweet Caroline',
        'artist': 'Neil Diamond',
        'mood': 'Energizing',
        'vibe':
            'Crowd-pleasing and uplifting — a song that turns any task into a celebration.',
      },
      {
        'title': 'Stronger',
        'artist': 'Kanye West',
        'mood': 'Empowering',
        'vibe':
            'Hard-hitting and bold — a reminder that every challenge makes you stronger.',
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
      {
        'title': 'All of Me',
        'artist': 'John Legend',
        'mood': 'Loving',
        'vibe':
            'Deeply personal and soulful — a beautiful tribute to unconditional love.',
      },
      {
        'title': 'Lover',
        'artist': 'Taylor Swift',
        'mood': 'Sweet',
        'vibe':
            'Dreamy and tender — a soft celebration of being completely in love.',
      },
    ],
  };

  // ✅ Used by MusicScreen
  static List<Map<String, String>> getSongsByMood(String mood) {
    return _songDatabase[mood] ?? _songDatabase['Happy']!;
  }

  // ✅ Used by ClaudeService
  static Future<Map<String, dynamic>> getRichRecommendation(
    String userMessage,
  ) async {
    final mood = detectMood(userMessage);
    final movies = await TmdbService.getMoviesByMood(mood);
    final songs = _songDatabase[mood] ?? _songDatabase['Happy']!;
    return {
      'text': '💬 Feeling $mood? Here are my picks for you 💜',
      'movies': movies,
      'songs': songs,
    };
  }

  // ✅ Plain text fallback
  static Future<String> getRecommendation(String userMessage) async {
    final mood = detectMood(userMessage);
    final movies = await TmdbService.getMoviesByMood(mood);
    final songs = _songDatabase[mood] ?? _songDatabase['Happy']!;

    final movieText = movies.isNotEmpty
        ? movies
              .map(
                (m) =>
                    '• ${m['title']} (${m['year']}) — ${m['genre']}\n  ⭐ ${m['rating']}/10\n  ${m['desc']}',
              )
              .join('\n\n')
        : '• Could not load movies. Check internet connection.';

    final songText = songs
        .map((s) => '• ${s['title']} - ${s['artist']}\n  ${s['vibe']}')
        .join('\n\n');

    return '''
💬 Feeling $mood? Here are my picks 💜

🎬 MOVIES:
$movieText

🎵 MUSIC:
$songText
    ''';
  }

  // ✅ Public mood detector
  static String detectMood(String message) {
    message = message.toLowerCase();
    if (message.contains('happy') ||
        message.contains('good') ||
        message.contains('😊')) {
      return 'Happy';
    }
    if (message.contains('sad') ||
        message.contains('depressed') ||
        message.contains('😢')) {
      return 'Sad';
    }
    if (message.contains('anxious') ||
        message.contains('worried') ||
        message.contains('😰')) {
      return 'Anxious';
    }
    if (message.contains('bored') ||
        message.contains('tired') ||
        message.contains('😴')) {
      return 'Bored';
    }
    if (message.contains('motivated') ||
        message.contains('excited') ||
        message.contains('💪')) {
      return 'Motivated';
    }
    if (message.contains('romantic') ||
        message.contains('love') ||
        message.contains('😍')) {
      return 'Romantic';
    }
    return 'Happy';
  }
}
