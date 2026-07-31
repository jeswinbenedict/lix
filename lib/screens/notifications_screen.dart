import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/responsive.dart';
import '../services/notifications_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary, size: 18),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: AppTheme.primary),
            onPressed: () async {
              await NotificationsService.markAllAsRead();
              _load();
            },
          ),
        ],
      ),
      body: CenteredContent(
        maxWidth: 800,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _notifications.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none, size: 48, color: AppTheme.textSecondary),
                        SizedBox(height: 12),
                        Text('No notifications yet', style: TextStyle(color: AppTheme.textSecondary)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final item = _notifications[index];
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const Icon(Icons.notifications, color: AppTheme.primary),
                          title: Text(item['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(item['body'] ?? ''),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
