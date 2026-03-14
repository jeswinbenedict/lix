import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'app_theme.dart';
import 'notifications_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
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
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        ),
        title: const Text(
          'Clear Notifications',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          'Remove all notifications?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Clear All', style: TextStyle(color: AppTheme.error)),
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
    final dt = ts.toDate() as DateTime;
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('dd MMM').format(dt);
  }

  // icon + color per notification type
  IconData _typeIcon(String? type) {
    switch (type) {
      case 'song':
        return Icons.music_note_rounded;
      case 'movie':
        return Icons.movie_outlined;
      case 'mood':
        return Icons.mood_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _typeColor(String? type) {
    switch (type) {
      case 'song':
        return AppTheme.secondary;
      case 'movie':
        return AppTheme.primary;
      case 'mood':
        return AppTheme.moodMotivated;
      default:
        return AppTheme.moodBored;
    }
  }

  int get _unreadCount =>
      _notifications.where((n) => n['read'] == false).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.border),
            ),
            child: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppTheme.textPrimary,
              size: 22,
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
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
        centerTitle: true,
        actions: [
          if (_notifications.isNotEmpty)
            PopupMenuButton<String>(
              color: AppTheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              ),
              onSelected: (v) {
                if (v == 'read') _markAllRead();
                if (v == 'clear') _clearAll();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'read',
                  child: Row(
                    children: [
                      Icon(
                        Icons.done_all_rounded,
                        size: 18,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Mark all as read',
                        style: TextStyle(color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_sweep_rounded,
                        size: 18,
                        color: AppTheme.error,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Clear all',
                        style: TextStyle(color: AppTheme.error),
                      ),
                    ],
                  ),
                ),
              ],
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.border),
                ),
                child: const Icon(
                  Icons.more_vert_rounded,
                  color: AppTheme.textPrimary,
                  size: 18,
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : _notifications.isEmpty
          ? _buildEmpty()
          : RefreshIndicator(
              onRefresh: _load,
              color: AppTheme.primary,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.horizontalPadding(context),
                  vertical: 12,
                ),
                itemCount: _notifications.length,
                itemBuilder: (_, i) => _buildTile(_notifications[i], i),
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
          color: AppTheme.error.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(
          Icons.delete_outline_rounded,
          color: AppTheme.error,
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
            color: isRead ? AppTheme.surface : color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            border: Border.all(
              color: isRead ? AppTheme.border : color.withOpacity(0.25),
            ),
            boxShadow: AppTheme.shadowSM,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon / image
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: imgUrl.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          imgUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              Icon(icon, color: color, size: 22),
                        ),
                      )
                    : Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['title'] ?? '',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: isRead
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['body'] ?? '',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatTime(item['createdAt']),
                      style: TextStyle(
                        color: AppTheme.textSecondary.withOpacity(0.7),
                        fontSize: 11,
                      ),
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
          color: AppTheme.textSecondary.withOpacity(0.3),
        ),
        const SizedBox(height: 16),
        const Text(
          'No notifications yet',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'You\'ll get notified about\nrecommendations & updates',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
      ],
    ),
  );
}
