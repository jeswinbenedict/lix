import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class TmdbService {
  static const String _apiKey = '2d2cfeb3ff5fe75ecb026790117dd3fb';
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  // ✅ Timeout duration
  static const Duration _timeout = Duration(seconds: 10);

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

  // ✅ Fallback movies shown when network fails
  static List<Map<String, String>> _fallbackMovies(String mood) {
    final Map<String, List<Map<String, String>>> fallbacks = {
      'Happy': [
        {
          'title': 'The Secret Life of Walter Mitty',
          'year': '2013',
          'genre': 'Adventure • Comedy',
          'desc':
              'A daydreamer embarks on a journey to find a missing photograph.',
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
          'desc':
              'A struggling salesman takes custody of his son and fights for success.',
          'poster': '',
          'rating': '8.0',
        },
        {
          'title': 'A Beautiful Mind',
          'year': '2001',
          'genre': 'Drama',
          'desc':
              'A brilliant mathematician fights mental illness while making discoveries.',
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
        {
          'title': 'Gone Girl',
          'year': '2014',
          'genre': 'Thriller • Drama',
          'desc': 'A man becomes the suspect in his wife\'s disappearance.',
          'poster': '',
          'rating': '8.1',
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
        {
          'title': 'The Grand Budapest Hotel',
          'year': '2014',
          'genre': 'Comedy • Adventure',
          'desc': 'A concierge and lobby boy go on a wild adventure.',
          'poster': '',
          'rating': '8.1',
        },
      ],
      'Motivated': [
        {
          'title': 'Rocky',
          'year': '1976',
          'genre': 'Drama • Action',
          'desc':
              'A small-time boxer gets a shot at the world heavyweight title.',
          'poster': '',
          'rating': '8.1',
        },
        {
          'title': 'The Social Network',
          'year': '2010',
          'genre': 'Drama',
          'desc': 'The story of the founding of Facebook.',
          'poster': '',
          'rating': '7.7',
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
        {
          'title': 'The Notebook',
          'year': '2004',
          'genre': 'Romance • Drama',
          'desc': 'A poor young man falls in love with a rich young woman.',
          'poster': '',
          'rating': '7.8',
        },
      ],
    };
    return fallbacks[mood] ?? fallbacks['Happy']!;
  }

  static Future<List<Map<String, String>>> getMoviesByMood(String mood) async {
    final genreIds = _moodGenres[mood] ?? '18';

    final url = Uri.parse(
      '$_baseUrl/discover/movie?api_key=$_apiKey'
      '&with_genres=$genreIds&sort_by=popularity.desc'
      '&vote_count.gte=1000&page=1',
    );

    // ✅ Retry up to 2 times
    for (int attempt = 1; attempt <= 2; attempt++) {
      try {
        debugPrint('TMDB attempt $attempt for mood: $mood');

        final response = await http
            .get(url)
            .timeout(
              _timeout,
              onTimeout: () {
                debugPrint('TMDB timeout on attempt $attempt');
                throw const SocketException('Connection timed out');
              },
            );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final movies = data['results'] as List;

          if (movies.isEmpty) {
            debugPrint('TMDB returned empty results');
            return _fallbackMovies(mood);
          }

          return movies.take(10).map((movie) {
            final overview = movie['overview'] ?? '';
            final desc = overview.isNotEmpty
                ? (overview.length > 120
                      ? '${overview.substring(0, 120)}...'
                      : overview)
                : 'A highly rated movie recommendation.';

            final releaseDate = movie['release_date'] ?? '';
            final year = releaseDate.length >= 4
                ? releaseDate.substring(0, 4)
                : 'N/A';

            final posterPath = movie['poster_path'];
            final poster = posterPath != null
                ? '$_imageBaseUrl$posterPath'
                : '';

            final rating = movie['vote_average'] ?? 0.0;

            final genreIdList = (movie['genre_ids'] as List?) ?? [];
            final genreText = genreIdList
                .take(2)
                .map((id) => _genreNames[id] ?? '')
                .where((g) => g.isNotEmpty)
                .join(' • ');

            return <String, String>{
              'title': movie['title'] ?? 'Unknown Movie',
              'year': year,
              'genre': genreText.isNotEmpty ? genreText : 'Popular',
              'desc': desc,
              'poster': poster,
              'rating': rating.toStringAsFixed(1),
            };
          }).toList();
        } else {
          debugPrint('TMDB Error: Status ${response.statusCode}');
          // ✅ Don't retry on auth errors
          if (response.statusCode == 401 || response.statusCode == 403) break;
        }
      } on SocketException catch (e) {
        debugPrint('TMDB SocketException attempt $attempt: $e');
        // ✅ Wait before retry
        if (attempt < 2) await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        debugPrint('TMDB Error attempt $attempt: $e');
        if (attempt < 2) await Future.delayed(const Duration(seconds: 2));
      }
    }

    // ✅ Return fallback movies instead of empty list
    debugPrint('TMDB: returning fallback movies for $mood');
    return _fallbackMovies(mood);
  }
}
