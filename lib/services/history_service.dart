import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class HistoryService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String? get _uid => _auth.currentUser?.uid;

  static DateTime? _parseDateTime(dynamic ts) {
    if (ts == null) return null;
    if (ts is Timestamp) return ts.toDate();
    if (ts is DateTime) return ts;
    if (ts is int) return DateTime.fromMillisecondsSinceEpoch(ts);
    if (ts is String) return DateTime.tryParse(ts);
    return null;
  }

  static Future<void> addSongHistory(Map<String, String> song) async {
    final uid = _uid;
    if (uid == null) return;
    final id = song['id'] ?? song['title'] ?? '';
    if (id.isEmpty) return;
    final cleanSong = Map<String, String>.from(song)
      ..remove('playedAt')
      ..remove('watchedAt');
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('history_songs')
          .doc(id)
          .set({
            ...cleanSong,
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

  static Future<void> addMovieHistory(Map<String, String> movie) async {
    final uid = _uid;
    if (uid == null) return;
    final id = movie['id'] ?? movie['title'] ?? '';
    if (id.isEmpty) return;
    final cleanMovie = Map<String, String>.from(movie)
      ..remove('playedAt')
      ..remove('watchedAt');
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('history_movies')
          .doc(id)
          .set({
            ...cleanMovie,
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

  static Future<List<Map<String, dynamic>>> getHistory() async {
    final songs = await getSongHistory();
    final movies = await getMovieHistory();

    final combined = [...songs, ...movies];

    combined.sort((a, b) {
      final aTs = a['playedAt'] ?? a['watchedAt'];
      final bTs = b['playedAt'] ?? b['watchedAt'];

      final aTime = _parseDateTime(aTs);
      final bTime = _parseDateTime(bTs);

      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;

      return bTime.compareTo(aTime);
    });

    return combined;
  }

  static Future<void> clearAll() async {
    await clearAllSongs();
    await clearAllMovies();
  }
}
