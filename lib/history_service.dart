import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class HistoryService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String? get _uid => _auth.currentUser?.uid;

  // ════════════════════════════════════════════
  //  SONG HISTORY
  // ════════════════════════════════════════════

  static Future<void> addSongHistory(Map<String, String> song) async {
    final uid = _uid;
    if (uid == null) return;
    final id = song['id'] ?? song['title'] ?? '';
    if (id.isEmpty) return;
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('history_songs')
          .doc(id)
          .set({
            ...song,
            'type': 'song',
            'playedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint('HistoryService.addSongHistory error: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getSongHistory() async {
    final uid = _uid;
    if (uid == null) return [];
    try {
      final snap = await _db
          .collection('users')
          .doc(uid)
          .collection('history_songs')
          .orderBy('playedAt', descending: true)
          .get();
      return snap.docs.map((d) => d.data()).toList();
    } catch (e) {
      debugPrint('HistoryService.getSongHistory error: $e');
      return [];
    }
  }

  static Future<void> saveSongPosition(String songId, int posMs) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('history_songs')
          .doc(songId)
          .update({'resumePosition': posMs});
    } catch (e) {
      // ✅ Doc may not exist yet — safe to ignore
      debugPrint('HistoryService.saveSongPosition: $e');
    }
  }

  static Future<int> getSongResumePosition(String songId) async {
    final uid = _uid;
    if (uid == null) return 0;
    try {
      final doc = await _db
          .collection('users')
          .doc(uid)
          .collection('history_songs')
          .doc(songId)
          .get();
      return (doc.data()?['resumePosition'] as int?) ?? 0;
    } catch (e) {
      debugPrint('HistoryService.getSongResumePosition error: $e');
      return 0;
    }
  }

  static Future<void> removeSong(String songId) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('history_songs')
          .doc(songId)
          .delete();
    } catch (e) {
      debugPrint('HistoryService.removeSong error: $e');
    }
  }

  static Future<void> clearAllSongs() async {
    final uid = _uid;
    if (uid == null) return;
    try {
      final snap = await _db
          .collection('users')
          .doc(uid)
          .collection('history_songs')
          .get();
      for (final doc in snap.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint('HistoryService.clearAllSongs error: $e');
    }
  }

  // ════════════════════════════════════════════
  //  MOVIE HISTORY
  // ════════════════════════════════════════════

  static Future<void> addMovieHistory(Map<String, String> movie) async {
    final uid = _uid;
    if (uid == null) return;
    final id = movie['id'] ?? movie['title'] ?? '';
    if (id.isEmpty) return;
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('history_movies')
          .doc(id)
          .set({
            ...movie,
            'type': 'movie',
            'watchedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint('HistoryService.addMovieHistory error: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getMovieHistory() async {
    final uid = _uid;
    if (uid == null) return [];
    try {
      final snap = await _db
          .collection('users')
          .doc(uid)
          .collection('history_movies')
          .orderBy('watchedAt', descending: true)
          .get();
      return snap.docs.map((d) => d.data()).toList();
    } catch (e) {
      debugPrint('HistoryService.getMovieHistory error: $e');
      return [];
    }
  }

  static Future<void> removeMovie(String movieId) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('history_movies')
          .doc(movieId)
          .delete();
    } catch (e) {
      debugPrint('HistoryService.removeMovie error: $e');
    }
  }

  static Future<void> clearAllMovies() async {
    final uid = _uid;
    if (uid == null) return;
    try {
      final snap = await _db
          .collection('users')
          .doc(uid)
          .collection('history_movies')
          .get();
      for (final doc in snap.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint('HistoryService.clearAllMovies error: $e');
    }
  }

  // ════════════════════════════════════════════
  //  COMBINED
  // ════════════════════════════════════════════

  static Future<List<Map<String, dynamic>>> getHistory() async {
    final songs = await getSongHistory();
    final movies = await getMovieHistory();

    final combined = [...songs, ...movies];

    combined.sort((a, b) {
      // ✅ Safe Timestamp extraction — server timestamps can be null on first write
      final aTs = a['playedAt'] ?? a['watchedAt'];
      final bTs = b['playedAt'] ?? b['watchedAt'];

      if (aTs == null && bTs == null) return 0;
      if (aTs == null) return 1;
      if (bTs == null) return -1;

      try {
        // ✅ Fixed: .toDate() already returns DateTime, no need to cast
        final aTime = (aTs as Timestamp).toDate();
        final bTime = (bTs as Timestamp).toDate();
        return bTime.compareTo(aTime);
      } catch (e) {
        debugPrint('HistoryService.getHistory sort error: $e');
        return 0;
      }
    });

    return combined;
  }

  static Future<void> clearAll() async {
    await clearAllSongs();
    await clearAllMovies();
  }
}
