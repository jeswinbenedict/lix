import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class MusicApiService {
  static const String _baseUrl = 'https://itunes.apple.com/search';
  static const Duration _timeout = Duration(seconds: 12);

  static const Map<String, List<String>> _moodQueries = {
    'Happy': [
      'happy pop',
      'feel good hits',
      'upbeat dance',
      'pharrell happy',
      'bollywood dance',
      'kpop happy',
      'bhangra punjabi',
      'afrobeats',
      'tamil kuthu',
      'latin pop',
    ],
    'Sad': [
      'sad songs adele',
      'heartbreak ballad',
      'emotional songs',
      'bollywood sad',
      'kpop sad ballad',
      'hindi sad songs',
      'indie sad acoustic',
      'tamil sad',
      'soul heartbreak',
      'crying songs',
    ],
    'Anxious': [
      'calm relaxing music',
      'lofi chill',
      'meditation music',
      'stress relief',
      'peaceful piano',
      'ambient relaxing',
      'yoga music',
      'nature sounds music',
      'soothing instrumental',
      'sleep music',
    ],
    'Bored': [
      'chill lofi hip hop',
      'sunday morning acoustic',
      'indie bedroom pop',
      'jazz background',
      'soft rock',
      'bollywood chill',
      'acoustic guitar',
      'frank ocean chill',
      'tamil chill',
      'coffee shop music',
    ],
    'Motivated': [
      'workout pump up',
      'motivational hip hop',
      'gym energy music',
      'running music',
      'eminem motivational',
      'kpop workout',
      'bollywood motivation',
      'power rock',
      'tamil mass',
      'beast mode music',
    ],
    'Romantic': [
      'romantic love songs',
      'bollywood romance',
      'kpop love',
      'hindi love songs',
      'slow dance romantic',
      'ed sheeran romantic',
      'tamil love',
      'r&b love',
      'french romantic',
      'valentine songs',
    ],
  };

  // ✅ Real fallback songs for each mood — shown when network fails
  static List<Map<String, String>> _fallbackSongs(String mood) {
    final Map<String, List<Map<String, String>>> fallbacks = {
      'Happy': [
        {
          'title': 'Happy',
          'artist': 'Pharrell Williams',
          'album': 'G I R L',
          'cover': '',
          'preview': '',
          'duration': '03:53',
          'genre': 'Pop',
          'mood': 'Happy',
          'itunes_id': '',
          'apple_url': '',
        },
        {
          'title': 'Can\'t Stop the Feeling',
          'artist': 'Justin Timberlake',
          'album': 'Trolls',
          'cover': '',
          'preview': '',
          'duration': '03:56',
          'genre': 'Pop',
          'mood': 'Happy',
          'itunes_id': '',
          'apple_url': '',
        },
        {
          'title': 'Uptown Funk',
          'artist': 'Mark Ronson ft. Bruno Mars',
          'album': 'Uptown Special',
          'cover': '',
          'preview': '',
          'duration': '04:30',
          'genre': 'Funk',
          'mood': 'Happy',
          'itunes_id': '',
          'apple_url': '',
        },
      ],
      'Sad': [
        {
          'title': 'Someone Like You',
          'artist': 'Adele',
          'album': '21',
          'cover': '',
          'preview': '',
          'duration': '04:45',
          'genre': 'Soul',
          'mood': 'Sad',
          'itunes_id': '',
          'apple_url': '',
        },
        {
          'title': 'The Night We Met',
          'artist': 'Lord Huron',
          'album': 'Strange Trails',
          'cover': '',
          'preview': '',
          'duration': '03:28',
          'genre': 'Indie',
          'mood': 'Sad',
          'itunes_id': '',
          'apple_url': '',
        },
        {
          'title': 'Fix You',
          'artist': 'Coldplay',
          'album': 'X&Y',
          'cover': '',
          'preview': '',
          'duration': '04:54',
          'genre': 'Rock',
          'mood': 'Sad',
          'itunes_id': '',
          'apple_url': '',
        },
      ],
      'Anxious': [
        {
          'title': 'Weightless',
          'artist': 'Marconi Union',
          'album': 'Weightless',
          'cover': '',
          'preview': '',
          'duration': '08:09',
          'genre': 'Ambient',
          'mood': 'Anxious',
          'itunes_id': '',
          'apple_url': '',
        },
        {
          'title': 'Clair de Lune',
          'artist': 'Claude Debussy',
          'album': 'Suite Bergamasque',
          'cover': '',
          'preview': '',
          'duration': '05:01',
          'genre': 'Classical',
          'mood': 'Anxious',
          'itunes_id': '',
          'apple_url': '',
        },
        {
          'title': 'Breathe',
          'artist': 'Pink Floyd',
          'album': 'Dark Side of the Moon',
          'cover': '',
          'preview': '',
          'duration': '02:43',
          'genre': 'Rock',
          'mood': 'Anxious',
          'itunes_id': '',
          'apple_url': '',
        },
      ],
      'Bored': [
        {
          'title': 'Redbone',
          'artist': 'Childish Gambino',
          'album': 'Awaken My Love',
          'cover': '',
          'preview': '',
          'duration': '05:26',
          'genre': 'R&B',
          'mood': 'Bored',
          'itunes_id': '',
          'apple_url': '',
        },
        {
          'title': 'Slow Dancing in the Dark',
          'artist': 'Joji',
          'album': 'BALLADS 1',
          'cover': '',
          'preview': '',
          'duration': '03:09',
          'genre': 'R&B',
          'mood': 'Bored',
          'itunes_id': '',
          'apple_url': '',
        },
        {
          'title': 'Nights',
          'artist': 'Frank Ocean',
          'album': 'Blonde',
          'cover': '',
          'preview': '',
          'duration': '05:07',
          'genre': 'R&B',
          'mood': 'Bored',
          'itunes_id': '',
          'apple_url': '',
        },
      ],
      'Motivated': [
        {
          'title': 'Lose Yourself',
          'artist': 'Eminem',
          'album': '8 Mile',
          'cover': '',
          'preview': '',
          'duration': '05:26',
          'genre': 'Hip-Hop',
          'mood': 'Motivated',
          'itunes_id': '',
          'apple_url': '',
        },
        {
          'title': 'Eye of the Tiger',
          'artist': 'Survivor',
          'album': 'Eye of the Tiger',
          'cover': '',
          'preview': '',
          'duration': '04:05',
          'genre': 'Rock',
          'mood': 'Motivated',
          'itunes_id': '',
          'apple_url': '',
        },
        {
          'title': 'Till I Collapse',
          'artist': 'Eminem',
          'album': 'The Eminem Show',
          'cover': '',
          'preview': '',
          'duration': '04:57',
          'genre': 'Hip-Hop',
          'mood': 'Motivated',
          'itunes_id': '',
          'apple_url': '',
        },
      ],
      'Romantic': [
        {
          'title': 'Perfect',
          'artist': 'Ed Sheeran',
          'album': '÷ (Divide)',
          'cover': '',
          'preview': '',
          'duration': '04:23',
          'genre': 'Pop',
          'mood': 'Romantic',
          'itunes_id': '',
          'apple_url': '',
        },
        {
          'title': 'All of Me',
          'artist': 'John Legend',
          'album': 'Love in the Future',
          'cover': '',
          'preview': '',
          'duration': '04:29',
          'genre': 'R&B',
          'mood': 'Romantic',
          'itunes_id': '',
          'apple_url': '',
        },
        {
          'title': 'Thinking Out Loud',
          'artist': 'Ed Sheeran',
          'album': 'X',
          'cover': '',
          'preview': '',
          'duration': '04:41',
          'genre': 'Pop',
          'mood': 'Romantic',
          'itunes_id': '',
          'apple_url': '',
        },
      ],
    };
    return fallbacks[mood] ?? fallbacks['Happy']!;
  }

  /// Get songs by mood — with retry + fallback ✅
  static Future<List<Map<String, String>>> getSongsByMood(String mood) async {
    final queries = _moodQueries[mood] ?? _moodQueries['Happy']!;
    final query = queries[Random().nextInt(queries.length)];

    // ✅ Retry up to 2 times
    for (int attempt = 1; attempt <= 2; attempt++) {
      try {
        debugPrint('iTunes attempt $attempt — query: "$query" mood: $mood');
        final result = await _fetchSongs(query, mood);
        if (result.isNotEmpty) return result;
      } on SocketException catch (e) {
        debugPrint('iTunes SocketException attempt $attempt: $e');
        if (attempt < 2) await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        debugPrint('iTunes Error attempt $attempt: $e');
        if (attempt < 2) await Future.delayed(const Duration(seconds: 2));
      }
    }

    debugPrint('iTunes: returning fallback songs for $mood');
    return _fallbackSongs(mood);
  }

  /// Search any song / artist ✅
  static Future<List<Map<String, String>>> searchSongs(String query) async {
    try {
      final result = await _fetchSongs(query, '');
      return result;
    } on SocketException catch (e) {
      debugPrint('iTunes search SocketException: $e');
      return [];
    } catch (e) {
      debugPrint('iTunes search error: $e');
      return [];
    }
  }

  /// Core fetch function ✅
  static Future<List<Map<String, String>>> _fetchSongs(
    String query,
    String mood,
  ) async {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'term': query,
        'media': 'music',
        'entity': 'song',
        'limit': '25',
        'country': 'IN',
      },
    );

    final response = await http
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(
          _timeout,
          onTimeout: () {
            debugPrint('iTunes timeout for query: $query');
            throw const SocketException('Connection timed out');
          },
        );

    if (response.statusCode != 200) {
      debugPrint('iTunes bad status: ${response.statusCode}');
      return mood.isEmpty ? [] : _fallbackSongs(mood);
    }

    final data = json.decode(response.body);
    final List results = data['results'] ?? [];

    if (results.isEmpty) {
      debugPrint('iTunes empty results for: $query');
      return mood.isEmpty ? [] : _fallbackSongs(mood);
    }

    return results.map<Map<String, String>>((track) {
      final rawCover = track['artworkUrl100'] ?? '';
      // ✅ Try to get 600x600 first, fall back to 300x300
      final cover = rawCover.isNotEmpty
          ? rawCover
                .replaceAll('100x100bb', '600x600bb')
                .replaceAll('100x100', '300x300')
          : '';

      return {
        'title': track['trackName'] ?? 'Unknown',
        'artist': track['artistName'] ?? 'Unknown Artist',
        'album': track['collectionName'] ?? '',
        'cover': cover,
        'preview': track['previewUrl'] ?? '',
        'duration': _formatMs(track['trackTimeMillis'] ?? 0),
        'genre': track['primaryGenreName'] ?? '',
        'mood': mood,
        'itunes_id': '${track['trackId'] ?? ''}',
        'apple_url': track['trackViewUrl'] ?? '',
      };
    }).toList();
  }

  static String _formatMs(int ms) {
    if (ms <= 0) return '00:00';
    final totalSec = ms ~/ 1000;
    final m = (totalSec ~/ 60).toString().padLeft(2, '0');
    final s = (totalSec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
