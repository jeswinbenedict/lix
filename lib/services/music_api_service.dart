import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class _MusicCacheEntry {
  final DateTime timestamp;
  final List<Map<String, String>> data;
  _MusicCacheEntry(this.timestamp, this.data);
}

class MusicApiService {
  static const String _baseUrl = 'https://itunes.apple.com/search';
  static const Duration _timeout = Duration(seconds: 12);

  // ── In-Memory TTL Cache ─────────────────────────────────
  static final Map<String, _MusicCacheEntry> _cache = {};
  static const Duration _cacheTtl = Duration(minutes: 15);

  static List<Map<String, String>>? _getFromCache(String key) {
    final entry = _cache[key];
    if (entry != null && DateTime.now().difference(entry.timestamp) < _cacheTtl) {
      return entry.data;
    }
    return null;
  }

  static void _setCache(String key, List<Map<String, String>> data) {
    _cache[key] = _MusicCacheEntry(DateTime.now(), data);
  }

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
      'tamil sad songs',
      'kpop sad ballad',
      'piano acoustic sad',
    ],
    'Anxious': [
      'ambient chillout',
      'calm piano meditation',
      'relaxing acoustic',
      'lofi study beats',
      'nature rain sounds',
      'deep sleep music',
    ],
    'Bored': [
      'upbeat rock hits',
      'synthwave retro',
      'hip hop bangers',
      'funk disco pop',
      'edm festival hits',
      'indie pop energetic',
    ],
    'Motivated': [
      'gym workout motivation',
      'eye of the tiger rock',
      'epic cinematic gym',
      'hip hop pump up',
      'bhangra high energy',
      'power metal rock',
    ],
    'Romantic': [
      'love songs ed sheeran',
      'romantic acoustic ballad',
      'bollywood romantic hits',
      'tamil love melody',
      'rnb soul love',
      'romantic saxophone',
    ],
  };

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
          'title': 'Can\'t Stop the Feeling!',
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
      ],
      'Sad': [
        {
          'title': 'Someone Like You',
          'artist': 'Adele',
          'album': '21',
          'cover': '',
          'preview': '',
          'duration': '04:45',
          'genre': 'Pop',
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
          'duration': '08:00',
          'genre': 'Ambient',
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
      ],
      'Romantic': [
        {
          'title': 'Perfect',
          'artist': 'Ed Sheeran',
          'album': '÷',
          'cover': '',
          'preview': '',
          'duration': '04:23',
          'genre': 'Pop',
          'mood': 'Romantic',
          'itunes_id': '',
          'apple_url': '',
        },
      ],
    };
    return fallbacks[mood] ?? fallbacks['Happy']!;
  }

  static Future<List<Map<String, String>>> getSongsByMood(String mood) async {
    final cacheKey = 'mood:$mood';
    final cached = _getFromCache(cacheKey);
    if (cached != null) return cached;

    final queries = _moodQueries[mood] ?? _moodQueries['Happy']!;
    final query = queries[Random().nextInt(queries.length)];

    for (int attempt = 1; attempt <= 2; attempt++) {
      try {
        debugPrint(
          'iTunes attempt $attempt | query: "$query" | mood: $mood',
        );
        final result = await _fetchSongs(query, mood);
        if (result.isNotEmpty) {
          _setCache(cacheKey, result);
          return result;
        }
      } on http.ClientException catch (e) {
        debugPrint('iTunes ClientException attempt $attempt: $e');
        if (attempt < 2) await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        debugPrint('iTunes error attempt $attempt: $e');
        if (attempt < 2) await Future.delayed(const Duration(seconds: 2));
      }
    }

    debugPrint('iTunes: all attempts failed — returning fallback songs');
    return _fallbackSongs(mood);
  }

  static Future<List<Map<String, String>>> searchSongs(String query) async {
    if (query.trim().isEmpty) return [];
    final cacheKey = 'search:${query.trim().toLowerCase()}';
    final cached = _getFromCache(cacheKey);
    if (cached != null) return cached;

    try {
      final result = await _fetchSongs(query, '');
      if (result.isNotEmpty) _setCache(cacheKey, result);
      return result;
    } on http.ClientException catch (e) {
      debugPrint('iTunes search ClientException: $e');
      return [];
    } catch (e) {
      debugPrint('iTunes search error: $e');
      return [];
    }
  }

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
      },
    );

    final response = await http
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(_timeout);

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
      final rawCover = (track['artworkUrl100'] ?? '') as String;
      final cover = rawCover.isNotEmpty
          ? rawCover
                .replaceAll('100x100bb', '600x600bb')
                .replaceAll('100x100', '600x600')
          : '';

      return {
        'title': (track['trackName'] ?? 'Unknown').toString(),
        'artist': (track['artistName'] ?? 'Unknown Artist').toString(),
        'album': (track['collectionName'] ?? '').toString(),
        'cover': cover,
        'preview': (track['previewUrl'] ?? '').toString(),
        'duration': _formatMs((track['trackTimeMillis'] ?? 0) as int),
        'genre': (track['primaryGenreName'] ?? '').toString(),
        'mood': mood,
        'itunes_id': '${track['trackId'] ?? ''}',
        'apple_url': (track['trackViewUrl'] ?? '').toString(),
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
