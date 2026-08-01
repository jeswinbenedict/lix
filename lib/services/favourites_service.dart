import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FavouritesService {
  static final _db = FirebaseFirestore.instance;
  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static CollectionReference? get _moviesRef {
    final uid = _uid;
    return uid == null
        ? null
        : _db.collection('users').doc(uid).collection('fav_movies');
  }

  static Future<void> addMovie(Map<String, String> movie) async {
    try {
      final id = movie['id'] ?? movie['title'] ?? '';
      if (id.isEmpty) return;
      await _moviesRef?.doc(id).set(movie);
    } catch (e) {
      debugPrint('FavouritesService.addMovie error: $e');
    }
  }

  static Future<void> removeMovie(String id) async {
    try {
      await _moviesRef?.doc(id).delete();
    } catch (e) {
      debugPrint('FavouritesService.removeMovie error: $e');
    }
  }

  static Future<bool> isMovieFav(String id) async {
    try {
      final doc = await _moviesRef?.doc(id).get();
      return doc?.exists ?? false;
    } catch (e) {
      debugPrint('FavouritesService.isMovieFav error: $e');
      return false;
    }
  }

  static Stream<List<Map<String, String>>> moviesStream() {
    final uid = _uid;
    if (uid == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(uid)
        .collection('fav_movies')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => d.data().map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''))).toList(),
        );
  }

  static CollectionReference? get _songsRef {
    final uid = _uid;
    return uid == null
        ? null
        : _db.collection('users').doc(uid).collection('fav_songs');
  }

  static Future<void> addSong(Map<String, String> song) async {
    try {
      final id = song['id'] ?? song['title'] ?? '';
      if (id.isEmpty) return;
      await _songsRef?.doc(id).set(song);
    } catch (e) {
      debugPrint('FavouritesService.addSong error: $e');
    }
  }

  static Future<void> removeSong(String id) async {
    try {
      await _songsRef?.doc(id).delete();
    } catch (e) {
      debugPrint('FavouritesService.removeSong error: $e');
    }
  }

  static Future<bool> isSongFav(String id) async {
    try {
      final doc = await _songsRef?.doc(id).get();
      return doc?.exists ?? false;
    } catch (e) {
      debugPrint('FavouritesService.isSongFav error: $e');
      return false;
    }
  }

  static Stream<List<Map<String, String>>> songsStream() {
    final uid = _uid;
    if (uid == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(uid)
        .collection('fav_songs')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => d.data().map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''))).toList(),
        );
  }

  static Future<bool> toggleMovie(Map<String, String> movie) async {
    try {
      final id = movie['id'] ?? movie['title'] ?? '';
      if (id.isEmpty) return false;
      final fav = await isMovieFav(id);
      if (fav) {
        await removeMovie(id);
        return false;
      } else {
        await addMovie(movie);
        return true;
      }
    } catch (e) {
      debugPrint('FavouritesService.toggleMovie error: $e');
      return false;
    }
  }

  static Future<bool> toggleSong(Map<String, String> song) async {
    try {
      final id = song['id'] ?? song['title'] ?? '';
      if (id.isEmpty) return false;
      final fav = await isSongFav(id);
      if (fav) {
        await removeSong(id);
        return false;
      } else {
        await addSong(song);
        return true;
      }
    } catch (e) {
      debugPrint('FavouritesService.toggleSong error: $e');
      return false;
    }
  }
}
