import 'dart:convert';
import 'package:http/http.dart' as http;

class TmdbService {
  static const String _apiKey = '2d2cfeb3ff5fe75ecb026790117dd3fb';
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

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

  static Future<List<Map<String, String>>> getMoviesByMood(String mood) async {
    final genreIds = _moodGenres[mood] ?? '18';

    final url = Uri.parse(
      '$_baseUrl/discover/movie?api_key=$_apiKey'
      '&with_genres=$genreIds&sort_by=popularity.desc'
      '&vote_count.gte=1000&page=1',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final movies = data['results'] as List;

        return movies.take(5).map((movie) {
          // Safe description
          final overview = movie['overview'] ?? '';
          final desc = overview.isNotEmpty
              ? (overview.length > 120
                    ? overview.substring(0, 120) + '...'
                    : overview)
              : 'A highly rated movie recommendation.';

          // Safe year
          final releaseDate = movie['release_date'] ?? '';
          final year = releaseDate.length >= 4
              ? releaseDate.substring(0, 4)
              : 'N/A';

          // Safe poster
          final posterPath = movie['poster_path'];
          final poster = posterPath != null ? '$_imageBaseUrl$posterPath' : '';

          // Safe rating
          final rating = movie['vote_average'] ?? 0.0;

          // Genre names from IDs
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
        print('TMDB Error: Status ${response.statusCode}');
      }
    } catch (e) {
      print('TMDB Error: $e');
    }
    return [];
  }
}
