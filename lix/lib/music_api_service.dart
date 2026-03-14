import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class MusicApiService {
  // Apple Music / iTunes Search API — FREE, No Key needed ✅
  static const String _baseUrl = 'https://itunes.apple.com/search';

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

  /// Get songs by mood from iTunes ✅
  static Future<List<Map<String, String>>> getSongsByMood(String mood) async {
    try {
      final queries = _moodQueries[mood] ?? _moodQueries['Happy']!;
      final query = queries[Random().nextInt(queries.length)];
      return await _fetchSongs(query, mood);
    } catch (e) {
      return _fallback(mood);
    }
  }

  /// Search any song / artist / language ✅
  static Future<List<Map<String, String>>> searchSongs(String query) async {
    try {
      return await _fetchSongs(query, '');
    } catch (e) {
      return [];
    }
  }

  /// Core fetch function
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
        'country': 'IN', // Change to your country code if needed
      },
    );

    final response = await http
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      return mood.isEmpty ? [] : _fallback(mood);
    }

    final data = json.decode(response.body);
    final List results = data['results'] ?? [];

    if (results.isEmpty) {
      return mood.isEmpty ? [] : _fallback(mood);
    }

    return results.map<Map<String, String>>((track) {
      // Get high-res cover: replace 100x100 with 300x300
      final rawCover = track['artworkUrl100'] ?? '';
      final cover = rawCover.replaceAll('100x100', '300x300');

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
    final totalSec = ms ~/ 1000;
    final m = (totalSec ~/ 60).toString().padLeft(2, '0');
    final s = (totalSec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  static List<Map<String, String>> _fallback(String mood) => [
    {
      'title': 'Could not load songs',
      'artist': 'Tap Refresh to try again',
      'album': '',
      'cover': '',
      'preview': '',
      'duration': '0:00',
      'genre': '',
      'mood': mood,
      'itunes_id': '',
      'apple_url': '',
    },
  ];
}
