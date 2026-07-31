import '../services/tmdb_service.dart';
import '../services/music_api_service.dart';

class VibeMixerService {
  static const Map<String, String> moodKeywords = {
    'Happy': 'upbeat pop comedy Feel-Good cheerful',
    'Sad': 'melancholy drama acoustic emotional nostalgic',
    'Anxious': 'calm lofi ambient peaceful relaxation instrumental',
    'Bored': 'thriller action energy adventure workout dance',
    'Motivated': 'rock epic motivation synthwave energetic hip-hop',
    'Romantic': 'love romance romantic ballad acoustic soul',
  };

  /// Generates hybrid recommendations blending primary and secondary moods
  static Future<Map<String, List<Map<String, String>>>> mixVibes({
    required String primaryMood,
    required String secondaryMood,
    required double primaryRatio, // e.g. 0.7 for 70%
  }) async {
    final primaryMovies = await TmdbService.getMoviesByMood(primaryMood);
    final secondaryMovies = await TmdbService.getMoviesByMood(secondaryMood);

    final primaryRatioInt = (primaryRatio * 10).round();

    final mixedMovies = <Map<String, String>>[];
    mixedMovies.addAll(primaryMovies.take(primaryRatioInt.clamp(1, 8)));
    for (final m in secondaryMovies) {
      if (mixedMovies.length >= 10) break;
      if (!mixedMovies.any((existing) => existing['title'] == m['title'])) {
        mixedMovies.add(m);
      }
    }

    // Blend music queries
    final primaryKeyword = moodKeywords[primaryMood] ?? primaryMood;
    final secondaryKeyword = moodKeywords[secondaryMood] ?? secondaryMood;
    final blendQuery = '$primaryKeyword $secondaryKeyword';

    final songs = await MusicApiService.searchSongs(blendQuery);

    return {
      'movies': mixedMovies,
      'songs': songs.take(12).toList(),
    };
  }
}
