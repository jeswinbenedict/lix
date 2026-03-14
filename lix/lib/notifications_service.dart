import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String? get _uid => _auth.currentUser?.uid;

  // ── Fetch all notifications ───────────────────────────
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    if (_uid == null) return [];
    final snap = await _db
        .collection('users')
        .doc(_uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => {...d.data(), 'docId': d.id}).toList();
  }

  // ── Unread count ──────────────────────────────────────
  static Future<int> getUnreadCount() async {
    if (_uid == null) return 0;
    final snap = await _db
        .collection('users')
        .doc(_uid)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .get();
    return snap.docs.length;
  }

  // ── Mark single as read ───────────────────────────────
  static Future<void> markAsRead(String docId) async {
    if (_uid == null) return;
    await _db
        .collection('users')
        .doc(_uid)
        .collection('notifications')
        .doc(docId)
        .update({'read': true});
  }

  // ── Mark all as read ──────────────────────────────────
  static Future<void> markAllAsRead() async {
    if (_uid == null) return;
    final snap = await _db
        .collection('users')
        .doc(_uid)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .get();
    for (final doc in snap.docs) {
      await doc.reference.update({'read': true});
    }
  }

  // ── Delete single ─────────────────────────────────────
  static Future<void> deleteNotification(String docId) async {
    if (_uid == null) return;
    await _db
        .collection('users')
        .doc(_uid)
        .collection('notifications')
        .doc(docId)
        .delete();
  }

  // ── Clear all ─────────────────────────────────────────
  static Future<void> clearAll() async {
    if (_uid == null) return;
    final snap = await _db
        .collection('users')
        .doc(_uid)
        .collection('notifications')
        .get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  // ── Add a notification (called from app logic) ────────
  static Future<void> addNotification({
    required String title,
    required String body,
    String type = 'general', // 'song' | 'movie' | 'mood' | 'general'
    String? imageUrl,
  }) async {
    if (_uid == null) return;
    await _db.collection('users').doc(_uid).collection('notifications').add({
      'title': title,
      'body': body,
      'type': type,
      'imageUrl': imageUrl ?? '',
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
