import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavouritesService {
  static final _db = FirebaseFirestore.instance;
  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // ── Movies ───────────────────────────────────────────────
  static CollectionReference? get _moviesRef => _uid == null
      ? null
      : _db.collection('users').doc(_uid).collection('fav_movies');

  static Future<void> addMovie(Map<String, String> movie) async {
    final id = movie['id'] ?? movie['title'] ?? '';
    await _moviesRef?.doc(id).set(movie);
  }

  static Future<void> removeMovie(String id) async {
    await _moviesRef?.doc(id).delete();
  }

  static Future<bool> isMovieFav(String id) async {
    final doc = await _moviesRef?.doc(id).get();
    return doc?.exists ?? false;
  }

  static Stream<List<Map<String, String>>> moviesStream() {
    if (_uid == null) return Stream.value([]);
    return _moviesRef!.snapshots().map(
      (snap) => snap.docs
          .map((d) => Map<String, String>.from(d.data() as Map))
          .toList(),
    );
  }

  // ── Songs ────────────────────────────────────────────────
  static CollectionReference? get _songsRef => _uid == null
      ? null
      : _db.collection('users').doc(_uid).collection('fav_songs');

  static Future<void> addSong(Map<String, String> song) async {
    final id = song['id'] ?? song['title'] ?? '';
    await _songsRef?.doc(id).set(song);
  }

  static Future<void> removeSong(String id) async {
    await _songsRef?.doc(id).delete();
  }

  static Future<bool> isSongFav(String id) async {
    final doc = await _songsRef?.doc(id).get();
    return doc?.exists ?? false;
  }

  static Stream<List<Map<String, String>>> songsStream() {
    if (_uid == null) return Stream.value([]);
    return _songsRef!.snapshots().map(
      (snap) => snap.docs
          .map((d) => Map<String, String>.from(d.data() as Map))
          .toList(),
    );
  }

  // ── Toggle helpers ───────────────────────────────────────
  static Future<bool> toggleMovie(Map<String, String> movie) async {
    final id = movie['id'] ?? movie['title'] ?? '';
    final fav = await isMovieFav(id);
    if (fav) {
      await removeMovie(id);
      return false;
    } else {
      await addMovie(movie);
      return true;
    }
  }

  static Future<bool> toggleSong(Map<String, String> song) async {
    final id = song['id'] ?? song['title'] ?? '';
    final fav = await isSongFav(id);
    if (fav) {
      await removeSong(id);
      return false;
    } else {
      await addSong(song);
      return true;
    }
  }
}
