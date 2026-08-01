import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ImdbService {
  static const Duration _timeout = Duration(seconds: 8);

  // In-memory TTL Cache: title.toLowerCase() -> { 'timestamp': DateTime, 'data': Map }
  static final Map<String, _CacheEntry> _cache = {};
  static const Duration _cacheTtl = Duration(hours: 1);

  static const Map<String, String> _headers = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'application/json, text/plain, */*',
    'Accept-Language': 'en-US,en;q=0.9',
  };

  /// Fetches live IMDb data for a given movie title and optional year.
  /// Returns a Map with keys:
  /// - `imdbId`: String (e.g. 'tt0499549')
  /// - `imdbUrl`: String (e.g. 'https://www.imdb.com/title/tt0499549/')
  /// - `rating`: String (e.g. '7.9')
  /// - `rank`: String (e.g. '#15')
  /// - `cast`: String (e.g. 'Sam Worthington, Zoe Saldana')
  /// - `year`: String
  static Future<Map<String, String>> getMovieImdbData(
    String title, {
    String? year,
  }) async {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) return {};

    final cacheKey = cleanTitle.toLowerCase();

    // 1. Check in-memory cache
    if (_cache.containsKey(cacheKey)) {
      final entry = _cache[cacheKey]!;
      if (DateTime.now().difference(entry.timestamp) < _cacheTtl) {
        return entry.data;
      }
    }

    try {
      final encodedQuery = Uri.encodeComponent(cleanTitle.toLowerCase());
      final firstChar =
          encodedQuery.isNotEmpty ? encodedQuery.substring(0, 1) : 'a';

      final suggestionUrl = Uri.parse(
        'https://v3.sg.media-imdb.com/suggestion/$firstChar/$encodedQuery.json',
      );

      final response = await http
          .get(suggestionUrl, headers: _headers)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = (data['d'] as List?) ?? [];

        if (results.isNotEmpty) {
          // Find matching title (preferably movie type 'q' == 'feature' or 'movie')
          final match = results.firstWhere(
            (item) {
              final id = item['id']?.toString() ?? '';
              return id.startsWith('tt');
            },
            orElse: () => results.first,
          );

          final imdbId = match['id']?.toString() ?? '';
          final matchYear = match['y']?.toString() ?? year ?? '';
          final rank = match['rank']?.toString() ?? '';
          final cast = match['s']?.toString() ?? '';

          if (imdbId.startsWith('tt')) {
            // Attempt to scrape or fetch rating from IMDb title summary if available
            final rating = await _fetchImdbRating(imdbId);

            final resultMap = <String, String>{
              'imdbId': imdbId,
              'imdbUrl': 'https://www.imdb.com/title/$imdbId/',
              'rating': rating.isNotEmpty ? rating : 'IMDb',
              'rank': rank.isNotEmpty ? '#$rank' : '',
              'cast': cast,
              'year': matchYear,
            };

            _cache[cacheKey] = _CacheEntry(DateTime.now(), resultMap);
            return resultMap;
          }
        }
      }
    } catch (e) {
      debugPrint('ImdbService.getMovieImdbData error for "$title": $e');
    }

    // Return empty fallback map on error or missing data
    final fallback = <String, String>{
      'imdbId': '',
      'imdbUrl':
          'https://www.imdb.com/find/?q=${Uri.encodeComponent(cleanTitle)}',
      'rating': '',
      'rank': '',
      'cast': '',
      'year': year ?? '',
    };
    return fallback;
  }

  /// Helper method to scrape/extract IMDb rating from title page fallback
  static Future<String> _fetchImdbRating(String imdbId) async {
    try {
      final titleUrl = Uri.parse('https://www.imdb.com/title/$imdbId/');
      final response =
          await http.get(titleUrl, headers: _headers).timeout(_timeout);

      if (response.statusCode == 200) {
        final html = response.body;

        // Try regex match for aggregateRating value in JSON-LD or HTML tag
        final jsonLdMatch =
            RegExp(r'"ratingValue"\s*:\s*"?([0-9]\.[0-9])"?').firstMatch(html);
        if (jsonLdMatch != null && jsonLdMatch.groupCount >= 1) {
          return jsonLdMatch.group(1)!;
        }

        final aggregateMatch = RegExp(
          r'aggregateRating"\s*:\s*\{\s*"@type":\s*"AggregateRating",\s*"ratingValue":\s*([0-9\.]+)',
        ).firstMatch(html);
        if (aggregateMatch != null && aggregateMatch.groupCount >= 1) {
          return aggregateMatch.group(1)!;
        }
      }
    } catch (e) {
      debugPrint('ImdbService._fetchImdbRating error for $imdbId: $e');
    }
    return '';
  }
}

class _CacheEntry {
  final DateTime timestamp;
  final Map<String, String> data;

  _CacheEntry(this.timestamp, this.data);
}
