import 'dart:async';
import 'package:flutter/foundation.dart';
import 'tmdb_service.dart';
import 'music_api_service.dart';

/// Intelligent predictive prefetch engine.
/// Anticipates user actions and silently caches media assets, TMDb data, and iTunes previews.
class PrefetchEngine {
  static final PrefetchEngine _instance = PrefetchEngine._internal();
  factory PrefetchEngine() => _instance;
  static PrefetchEngine get instance => _instance;

  PrefetchEngine._internal();

  final Set<String> _prefetchedMoods = {};
  bool _isPrefetching = false;

  /// Predictive mood sequence map: what mood users typically explore next
  static const Map<String, List<String>> _nextProbableMoods = {
    'Happy': ['Motivated', 'Romantic'],
    'Sad': ['Anxious', 'Happy'],
    'Anxious': ['Sad', 'Bored'],
    'Bored': ['Motivated', 'Happy'],
    'Motivated': ['Happy', 'Romantic'],
    'Romantic': ['Happy', 'Sad'],
  };

  /// Trigger predictive prefetching when a user interacts with a mood
  void onUserSelectedMood(String currentMood) {
    if (_isPrefetching) return;
    final nextMoods = _nextProbableMoods[currentMood] ?? ['Happy', 'Motivated'];

    Timer(const Duration(milliseconds: 600), () {
      _prefetchMoodList(nextMoods);
    });
  }

  /// Prefetch initial cold-start data (Trending, Now Playing, and Top Rated)
  Future<void> prefetchColdStart() async {
    try {
      await Future.wait([
        TmdbService.getTrending(),
        TmdbService.getNowPlaying(),
        TmdbService.getTopRated(),
        MusicApiService.getSongsByMood('Happy'),
      ]);
      debugPrint('⚡ [PrefetchEngine] Cold-start prefetch completed.');
    } catch (e) {
      debugPrint('PrefetchEngine cold-start error: $e');
    }
  }

  Future<void> _prefetchMoodList(List<String> moods) async {
    _isPrefetching = true;
    for (final mood in moods) {
      if (!_prefetchedMoods.contains(mood)) {
        try {
          await Future.wait([
            TmdbService.getMoviesByMood(mood),
            MusicApiService.getSongsByMood(mood),
          ]);
          _prefetchedMoods.add(mood);
          debugPrint('⚡ [PrefetchEngine] Telepathically prefetched mood: $mood');
        } catch (e) {
          debugPrint('Prefetch error for $mood: $e');
        }
      }
    }
    _isPrefetching = false;
  }
}
