import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class _TmdbCacheEntry {
  final DateTime timestamp;
  final List<Map<String, String>> data;
  _TmdbCacheEntry(this.timestamp, this.data);
}

class TmdbService {
  static const String _apiKey = '2d2cfeb3ff5fe75ecb026790117dd3fb';
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  static const Duration _timeout = Duration(seconds: 10);

  // ── In-Memory TTL Cache ─────────────────────────────────
  static final Map<String, _TmdbCacheEntry> _cache = {};
  static const Duration _cacheTtl = Duration(minutes: 30);

  static List<Map<String, String>>? _getFromCache(String key) {
    final entry = _cache[key];
    if (entry != null && DateTime.now().difference(entry.timestamp) < _cacheTtl) {
      return entry.data;
    }
    return null;
  }

  static void _setCache(String key, List<Map<String, String>> data) {
    _cache[key] = _TmdbCacheEntry(DateTime.now(), data);
  }

  static const Map<int, String> _genreNames = {
    28: 'Action',
    12: 'Adventure',
    16: 'Animation',
    35: 'Comedy',
    80: 'Crime',
    18: 'Drama',
    10751: 'Family',
    14: 'Fantasy',
    27: 'Horror',
    10749: 'Romance',
    878: 'Sci-Fi',
    53: 'Thriller',
    10752: 'War',
    37: 'Western',
    9648: 'Mystery',
    36: 'History',
  };

  static const Map<String, String> _moodGenres = {
    'Happy': '35,16,10751',
    'Sad': '18',
    'Anxious': '53,18',
    'Bored': '12,35',
    'Motivated': '28,18',
    'Romantic': '10749',
  };

  static List<Map<String, String>> _fallbackMovies(String mood) {
    final Map<String, List<Map<String, String>>> fallbacks = {
      'Happy': [
        {
          'title': 'The Secret Life of Walter Mitty',
          'year': '2013',
          'genre': 'Adventure • Comedy',
          'desc': 'A daydreamer embarks on a journey to find a missing photograph.',
          'poster': '',
          'rating': '7.3',
        },
        {
          'title': 'Inside Out',
          'year': '2015',
          'genre': 'Animation • Comedy',
          'desc': 'A young girl is uprooted and her emotions go on a journey.',
          'poster': '',
          'rating': '8.1',
        },
      ],
      'Sad': [
        {
          'title': 'The Pursuit of Happyness',
          'year': '2006',
          'genre': 'Drama',
          'desc': 'A struggling salesman takes custody of his son and fights for success.',
          'poster': '',
          'rating': '8.0',
        },
        {
          'title': 'A Beautiful Mind',
          'year': '2001',
          'genre': 'Drama',
          'desc': 'A brilliant mathematician fights mental illness while making discoveries.',
          'poster': '',
          'rating': '8.2',
        },
      ],
      'Anxious': [
        {
          'title': 'Knives Out',
          'year': '2019',
          'genre': 'Thriller • Mystery',
          'desc': 'A detective investigates the death of a crime novelist.',
          'poster': '',
          'rating': '7.9',
        },
      ],
      'Bored': [
        {
          'title': 'Jumanji: Welcome to the Jungle',
          'year': '2017',
          'genre': 'Adventure • Comedy',
          'desc': 'Four teenagers get sucked into a magical video game.',
          'poster': '',
          'rating': '6.9',
        },
      ],
      'Motivated': [
        {
          'title': 'Rocky',
          'year': '1976',
          'genre': 'Drama • Action',
          'desc': 'A small-time boxer gets a shot at the world heavyweight title.',
          'poster': '',
          'rating': '8.1',
        },
      ],
      'Romantic': [
        {
          'title': 'La La Land',
          'year': '2016',
          'genre': 'Romance • Drama',
          'desc': 'A jazz musician and an actress fall in love in Los Angeles.',
          'poster': '',
          'rating': '8.0',
        },
      ],
    };
    return fallbacks[mood] ?? fallbacks['Happy']!;
  }

  /// Parse a TMDb movie JSON object into a `Map<String, String>`
  static Map<String, String> _parseMovie(dynamic movie) {
    final overview = movie['overview'] ?? '';
    final desc = overview.isNotEmpty
        ? (overview.length > 120
              ? '${overview.substring(0, 120)}...'
              : overview)
        : 'A highly rated movie recommendation.';

    final releaseDate = movie['release_date'] ?? '';
    final year = releaseDate.length >= 4 ? releaseDate.substring(0, 4) : 'N/A';

    final posterPath = movie['poster_path'];
    final poster = posterPath != null ? '$_imageBaseUrl$posterPath' : '';

    final rating = movie['vote_average'] ?? 0.0;

    final genreIdList = (movie['genre_ids'] as List?) ?? [];
    final genreText = genreIdList
        .take(2)
        .map((id) => _genreNames[id] ?? '')
        .where((g) => g.isNotEmpty)
        .join(' • ');

    return <String, String>{
      'id': '${movie['id'] ?? ''}',
      'title': movie['title'] ?? 'Unknown Movie',
      'year': year,
      'genre': genreText.isNotEmpty ? genreText : 'Popular',
      'desc': desc,
      'poster': poster,
      'rating': rating is num ? rating.toStringAsFixed(1) : '$rating',
    };
  }

  static Future<List<Map<String, String>>> getMoviesByMood(String mood) async {
    final cacheKey = 'mood:$mood';
    final cached = _getFromCache(cacheKey);
    if (cached != null) return cached;

    final genreIds = _moodGenres[mood] ?? '18';
    final url = Uri.parse(
      '$_baseUrl/discover/movie?api_key=$_apiKey'
      '&with_genres=$genreIds&sort_by=popularity.desc'
      '&vote_count.gte=1000&page=1',
    );

    for (int attempt = 1; attempt <= 2; attempt++) {
      try {
        final response = await http.get(url).timeout(
              _timeout,
              onTimeout: () => throw http.ClientException('Connection timed out'),
            );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final movies = data['results'] as List;
          if (movies.isEmpty) return _fallbackMovies(mood);

          final result = movies.take(12).map(_parseMovie).toList();
          _setCache(cacheKey, result);
          return result;
        } else {
          if (response.statusCode == 401 || response.statusCode == 403) break;
        }
      } catch (e) {
        debugPrint('TMDb mood fetch error (attempt $attempt): $e');
        if (attempt < 2) await Future.delayed(const Duration(seconds: 2));
      }
    }
    return _fallbackMovies(mood);
  }

  /// Feature 3: Search movies by query
  static Future<List<Map<String, String>>> searchMovies(String query) async {
    if (query.trim().isEmpty) return [];
    final cacheKey = 'search:${query.trim().toLowerCase()}';
    final cached = _getFromCache(cacheKey);
    if (cached != null) return cached;

    final url = Uri.parse(
      '$_baseUrl/search/movie?api_key=$_apiKey'
      '&query=${Uri.encodeComponent(query.trim())}'
      '&include_adult=false&page=1',
    );
    try {
      final response = await http.get(url).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final movies = data['results'] as List;
        final result = movies.take(20).map(_parseMovie).toList();
        _setCache(cacheKey, result);
        return result;
      }
    } catch (e) {
      debugPrint('TMDb search error: $e');
    }
    return [];
  }

  /// Feature 4: Get trending movies (week)
  static Future<List<Map<String, String>>> getTrending() async {
    const cacheKey = 'trending';
    final cached = _getFromCache(cacheKey);
    if (cached != null) return cached;

    final url = Uri.parse('$_baseUrl/trending/movie/week?api_key=$_apiKey');
    try {
      final response = await http.get(url).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final movies = data['results'] as List;
        final result = movies.take(10).map(_parseMovie).toList();
        _setCache(cacheKey, result);
        return result;
      }
    } catch (e) {
      debugPrint('TMDb trending error: $e');
    }
    return [];
  }

  /// Feature 4: Get top rated movies
  static Future<List<Map<String, String>>> getTopRated() async {
    const cacheKey = 'top_rated';
    final cached = _getFromCache(cacheKey);
    if (cached != null) return cached;

    final url = Uri.parse('$_baseUrl/movie/top_rated?api_key=$_apiKey&page=1');
    try {
      final response = await http.get(url).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final movies = data['results'] as List;
        final result = movies.take(10).map(_parseMovie).toList();
        _setCache(cacheKey, result);
        return result;
      }
    } catch (e) {
      debugPrint('TMDb top_rated error: $e');
    }
    return [];
  }
}
