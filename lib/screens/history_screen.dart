import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_theme.dart';
import '../core/responsive.dart';
import '../services/history_service.dart';
import '../services/global_audio_service.dart';
import 'movie_detail_screen.dart';
import 'music_player_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _loading = true);
    final items = await HistoryService.getHistory();
    if (mounted) {
      setState(() {
        _history = items;
        _loading = false;
      });
    }
  }

  void _confirmClearAll() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Clear History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: const Text(
          'Are you sure you want to delete all watch and playback history? This cannot be undone.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              minimumSize: const Size(100, 42),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await HistoryService.clearAll();
              _loadHistory();
            },
            child: const Text('Clear All', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _formatRelativeDate(dynamic ts) {
    if (ts == null) return '';
    DateTime? dt;
    if (ts is Timestamp) dt = ts.toDate();
    if (ts is DateTime) dt = ts;
    if (ts is int) dt = DateTime.fromMillisecondsSinceEpoch(ts);
    if (ts is String) dt = DateTime.tryParse(ts);
    if (dt == null) return '';

    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new, size: 18),
        ),
        title: const Text(
          'History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.error),
              tooltip: 'Clear History',
              onPressed: _confirmClearAll,
            ),
        ],
      ),
      body: CenteredContent(
        maxWidth: 800,
        child: RefreshIndicator(
          color: AppTheme.primary,
          onRefresh: _loadHistory,
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
              : _history.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.history_rounded, size: 54, color: AppTheme.textSecondary),
                          SizedBox(height: 14),
                          Text(
                            'No watch or listen history yet',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        final item = _history[index];
                        final isSong = item['type'] == 'song';
                        final id = item['id'] ?? item['title'] ?? '';
                        final imageUrl = isSong ? (item['cover'] ?? '') : (item['poster'] ?? '');
                        final timeStr = _formatRelativeDate(item['playedAt'] ?? item['watchedAt']);

                        return Dismissible(
                          key: Key('${item['type']}_$id$index'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: AppTheme.error,
                              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                            ),
                            child: const Icon(Icons.delete_rounded, color: Colors.white),
                          ),
                          onDismissed: (_) {
                            if (isSong) {
                              HistoryService.removeSong(id);
                            } else {
                              HistoryService.removeMovie(id);
                            }
                            setState(() => _history.removeAt(index));
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                              border: Border.all(color: Theme.of(context).dividerColor.withAlpha(30)),
                              boxShadow: AppTheme.shadowSM,
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: imageUrl.isNotEmpty
                                      ? Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => _buildLeadingPlaceholder(isSong),
                                        )
                                      : _buildLeadingPlaceholder(isSong),
                                ),
                              ),
                              title: Text(
                                item['title'] ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              subtitle: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      isSong ? (item['artist'] ?? '') : (item['genre'] ?? 'Movie'),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                    ),
                                  ),
                                  if (timeStr.isNotEmpty)
                                    Text(
                                      timeStr,
                                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                                    ),
                                ],
                              ),
                              trailing: Icon(
                                isSong ? Icons.play_circle_outline_rounded : Icons.chevron_right_rounded,
                                color: isSong ? AppTheme.primary : AppTheme.textSecondary,
                              ),
                              onTap: () {
                                final Map<String, String> stringMap = {};
                                item.forEach((k, v) {
                                  if (v != null && k != 'playedAt' && k != 'watchedAt') {
                                    stringMap[k.toString()] = v.toString();
                                  }
                                });
                                if (isSong) {
                                  GlobalAudioService.instance.playSong(stringMap);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MusicPlayerScreen(song: stringMap),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MovieDetailScreen(movie: stringMap),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }

  Widget _buildLeadingPlaceholder(bool isSong) {
    return Container(
      color: AppTheme.primaryLight,
      child: Icon(
        isSong ? Icons.music_note_rounded : Icons.movie_rounded,
        color: AppTheme.primary,
        size: 22,
      ),
    );
  }
}
