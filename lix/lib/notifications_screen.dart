import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'notifications_service.dart';
import 'home_screen.dart';
import 'movies_screen.dart';
import 'music_screen.dart';
import 'profile_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // ── Theme ─────────────────────────────────────────────────
  static const Color _purple = Color(0xFF7C3AED);
  static const Color _bgColor = Color(0xFFF2F2F7);
  static const Color _cardBg = Color(0xFFFFFFFF);
  static const Color _textDark = Color(0xFF1C1C1E);
  static const Color _textGrey = Color(0xFF8E8E93);

  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;
  int _selectedNav = 3; // Profile tab active (came from profile)

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
    final dt = ts.toDate() as DateTime;
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

  Route _slideRoute(Widget page) => PageRouteBuilder(
    pageBuilder: (_, animation, _) => page,
    transitionsBuilder: (_, animation, _, child) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    ),
    transitionDuration: const Duration(milliseconds: 300),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Back arrow
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

                  // Title + badge
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

                  // Three-dot menu
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
                              children: [
                                const Icon(
                                  Icons.done_all_rounded,
                                  size: 18,
                                  color: _purple,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Mark all as read',
                                  style: TextStyle(color: _textDark),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'clear',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.delete_sweep_rounded,
                                  size: 18,
                                  color: Colors.redAccent,
                                ),
                                const SizedBox(width: 10),
                                const Text(
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

      // ── Bottom Nav ─────────────────────────────────────
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // ── Notification tile ─────────────────────────────────────
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
          color: Colors.redAccent.withOpacity(0.12),
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
                color: Colors.black.withOpacity(0.04),
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
                          errorBuilder: (_, _, _) =>
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
                    // Title row + timestamp
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
                        // Timestamp + unread dot
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

                    // Body
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

  // ── Empty state ───────────────────────────────────────────
  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.notifications_off_outlined,
          size: 72,
          color: _textGrey.withOpacity(0.3),
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

  // ── Bottom Nav ────────────────────────────────────────────
  Widget _buildBottomNav(BuildContext context) {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.movie_outlined, 'label': 'Movies'},
      {'icon': Icons.music_note_outlined, 'label': 'Music'},
      {'icon': Icons.person_rounded, 'label': 'Profile'},
    ];

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: _cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final isActive = _selectedNav == i;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _selectedNav = i);
                if (i == 0) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    _slideRoute(const HomeScreen()),
                    (r) => false,
                  );
                }
                if (i == 1) {
                  Navigator.pushReplacement(
                    context,
                    _slideRoute(MoviesScreen(mood: 'Happy')),
                  );
                }
                if (i == 2) {
                  Navigator.pushReplacement(
                    context,
                    _slideRoute(MusicScreen(mood: 'Happy')),
                  );
                }
                if (i == 3) {
                  Navigator.pushReplacement(
                    context,
                    _slideRoute(const ProfileScreen()),
                  );
                }
              },
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    items[i]['icon'] as IconData,
                    color: isActive ? _purple : _textGrey,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    items[i]['label'] as String,
                    style: TextStyle(
                      color: isActive ? _purple : _textGrey,
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isActive ? 18 : 0,
                    height: isActive ? 3 : 0,
                    decoration: BoxDecoration(
                      color: _purple,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
