import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'notifications_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const Color _purple = Color(0xFF7C3AED);
  static const Color _bgColor = Color(0xFFF2F2F7);
  static const Color _cardBg = Color(0xFFFFFFFF);
  static const Color _textDark = Color(0xFF1C1C1E);
  static const Color _textGrey = Color(0xFF8E8E93);

  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await NotificationsService.getNotifications();
    if (mounted) {
      setState(() {
        _notifications = data;
        _loading = false;
      });
    }
  }

  Future<void> _markAllRead() async {
    await NotificationsService.markAllAsRead();
    setState(() {
      for (final n in _notifications) {
        n['read'] = true;
      }
    });
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Clear Notifications',
          style: TextStyle(color: _textDark, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Remove all notifications?',
          style: TextStyle(color: _textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: _textGrey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await NotificationsService.clearAll();
      setState(() => _notifications.clear());
    }
  }

  Future<void> _deleteItem(String docId, int index) async {
    await NotificationsService.deleteNotification(docId);
    setState(() => _notifications.removeAt(index));
  }

  Future<void> _onTap(Map<String, dynamic> item) async {
    if (item['read'] == false) {
      await NotificationsService.markAsRead(item['docId']);
      setState(() => item['read'] = true);
    }
  }

  String _formatTime(dynamic ts) {
    if (ts == null) return '';
    final dt = ts.toDate();
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('dd MMM').format(dt);
  }

  IconData _typeIcon(String? type) {
    switch (type) {
      case 'song':
        return Icons.music_note_rounded;
      case 'movie':
        return Icons.movie_rounded;
      case 'mood':
        return Icons.mood_rounded;
      case 'system':
        return Icons.info_rounded;
      case 'success':
        return Icons.check_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _typeColor(String? type) {
    switch (type) {
      case 'song':
        return const Color(0xFF7C3AED);
      case 'movie':
        return const Color(0xFFFF2D55);
      case 'mood':
        return const Color(0xFFFF9500);
      case 'system':
        return const Color(0xFF007AFF);
      case 'success':
        return const Color(0xFF34C759);
      default:
        return const Color(0xFF8E8E93);
    }
  }

  int get _unreadCount =>
      _notifications.where((n) => n['read'] == false).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      // ── No bottomNavigationBar — removed entirely ──
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 18,
                          color: _textDark,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Notifications',
                        style: TextStyle(
                          color: _textDark,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (_unreadCount > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _purple,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            '$_unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (_notifications.isNotEmpty)
                    Align(
                      alignment: Alignment.centerRight,
                      child: PopupMenuButton<String>(
                        color: _cardBg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        onSelected: (v) {
                          if (v == 'read') _markAllRead();
                          if (v == 'clear') _clearAll();
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'read',
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.done_all_rounded,
                                  size: 18,
                                  color: _purple,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Mark all as read',
                                  style: TextStyle(color: _textDark),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'clear',
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.delete_sweep_rounded,
                                  size: 18,
                                  color: Colors.redAccent,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Clear all',
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ],
                            ),
                          ),
                        ],
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.more_vert_rounded,
                            size: 22,
                            color: _textDark,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── List ─────────────────────────────────────
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: _purple),
                    )
                  : _notifications.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: _purple,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: _notifications.length,
                        itemBuilder: (_, i) => _buildTile(_notifications[i], i),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(Map<String, dynamic> item, int index) {
    final isRead = item['read'] == true;
    final type = item['type'] as String?;
    final color = _typeColor(type);
    final icon = _typeIcon(type);
    final docId = item['docId'] as String;
    final imgUrl = item['imageUrl'] as String? ?? '';

    return Dismissible(
      key: Key(docId),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.redAccent,
          size: 24,
        ),
      ),
      onDismissed: (_) => _deleteItem(docId, index),
      child: GestureDetector(
        onTap: () => _onTap(item),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Colored circle icon ───────────────────
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: imgUrl.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          imgUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) =>
                              Icon(icon, color: Colors.white, size: 22),
                        ),
                      )
                    : Icon(icon, color: Colors.white, size: 22),
              ),

              const SizedBox(width: 12),

              // ── Text ─────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item['title'] ?? '',
                            style: TextStyle(
                              color: _textDark,
                              fontSize: 14,
                              fontWeight: isRead
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatTime(item['createdAt']),
                              style: const TextStyle(
                                color: _textGrey,
                                fontSize: 11,
                              ),
                            ),
                            if (!isRead) ...[
                              const SizedBox(height: 4),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['body'] ?? '',
                      style: const TextStyle(
                        color: _textGrey,
                        fontSize: 12,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.notifications_off_outlined,
          size: 72,
          color: _textGrey.withValues(alpha: 0.3),
        ),
        const SizedBox(height: 16),
        const Text(
          'No notifications yet',
          style: TextStyle(
            color: _textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'You\'ll get notified about\nrecommendations & updates',
          textAlign: TextAlign.center,
          style: TextStyle(color: _textGrey, fontSize: 14),
        ),
      ],
    ),
  );
}
