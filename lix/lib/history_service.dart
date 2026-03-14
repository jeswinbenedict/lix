import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String? get _uid => _auth.currentUser?.uid;

  // ════════════════════════════════════════════
  //  SONG HISTORY
  // ════════════════════════════════════════════

  static Future<void> addSongHistory(Map<String, String> song) async {
    if (_uid == null) return;
    final id = song['id'] ?? song['title'] ?? '';
    if (id.isEmpty) return;
    await _db
        .collection('users')
        .doc(_uid)
        .collection('history_songs')
        .doc(id)
        .set({
          ...song,
          'type': 'song',
          'playedAt': FieldValue.serverTimestamp(),
        });
  }

  static Future<List<Map<String, dynamic>>> getSongHistory() async {
    if (_uid == null) return [];
    final snap = await _db
        .collection('users')
        .doc(_uid)
        .collection('history_songs')
        .orderBy('playedAt', descending: true)
        .get();
    return snap.docs.map((d) => d.data()).toList();
  }

  static Future<void> saveSongPosition(String songId, int posMs) async {
    if (_uid == null) return;
    await _db
        .collection('users')
        .doc(_uid)
        .collection('history_songs')
        .doc(songId)
        .update({'resumePosition': posMs});
  }

  static Future<int> getSongResumePosition(String songId) async {
    if (_uid == null) return 0;
    final doc = await _db
        .collection('users')
        .doc(_uid)
        .collection('history_songs')
        .doc(songId)
        .get();
    return (doc.data()?['resumePosition'] as int?) ?? 0;
  }

  static Future<void> removeSong(String songId) async {
    if (_uid == null) return;
    await _db
        .collection('users')
        .doc(_uid)
        .collection('history_songs')
        .doc(songId)
        .delete();
  }

  static Future<void> clearAllSongs() async {
    if (_uid == null) return;
    final snap = await _db
        .collection('users')
        .doc(_uid)
        .collection('history_songs')
        .get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  // ════════════════════════════════════════════
  //  MOVIE HISTORY
  // ════════════════════════════════════════════

  static Future<void> addMovieHistory(Map<String, String> movie) async {
    if (_uid == null) return;
    final id = movie['id'] ?? movie['title'] ?? '';
    if (id.isEmpty) return;
    await _db
        .collection('users')
        .doc(_uid)
        .collection('history_movies')
        .doc(id)
        .set({
          ...movie,
          'type': 'movie',
          'watchedAt': FieldValue.serverTimestamp(),
        });
  }

  static Future<List<Map<String, dynamic>>> getMovieHistory() async {
    if (_uid == null) return [];
    final snap = await _db
        .collection('users')
        .doc(_uid)
        .collection('history_movies')
        .orderBy('watchedAt', descending: true)
        .get();
    return snap.docs.map((d) => d.data()).toList();
  }

  static Future<void> removeMovie(String movieId) async {
    if (_uid == null) return;
    await _db
        .collection('users')
        .doc(_uid)
        .collection('history_movies')
        .doc(movieId)
        .delete();
  }

  static Future<void> clearAllMovies() async {
    if (_uid == null) return;
    final snap = await _db
        .collection('users')
        .doc(_uid)
        .collection('history_movies')
        .get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  // ════════════════════════════════════════════
  //  COMBINED  ✅ — fixes getHistory() error
  // ════════════════════════════════════════════

  static Future<List<Map<String, dynamic>>> getHistory() async {
    final songs = await getSongHistory();
    final movies = await getMovieHistory();

    final combined = [...songs, ...movies];

    combined.sort((a, b) {
      final aTs = a['playedAt'] ?? a['watchedAt'];
      final bTs = b['playedAt'] ?? b['watchedAt'];
      if (aTs == null && bTs == null) return 0;
      if (aTs == null) return 1;
      if (bTs == null) return -1;
      final aTime = aTs.toDate() as DateTime;
      final bTime = bTs.toDate() as DateTime;
      return bTime.compareTo(aTime);
    });

    return combined;
  }

  static Future<void> clearAll() async {
    await clearAllSongs();
    await clearAllMovies();
  }
}
