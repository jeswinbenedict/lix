import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'app_theme.dart';
import 'history_service.dart';
import 'music_player_screen.dart';
import 'movie_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _history = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_applyFilter);
    _loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => _loading = true);
    final data = await HistoryService.getHistory();
    if (mounted) {
      setState(() {
        _history = data;
        _loading = false;
      });
      _applyFilter();
    }
  }

  void _applyFilter() {
    setState(() {
      if (_tabController.index == 0) {
        _filtered = _history;
      } else if (_tabController.index == 1) {
        _filtered = _history.where((e) => e['type'] == 'song').toList();
      } else {
        _filtered = _history.where((e) => e['type'] == 'movie').toList();
      }
    });
  }

  Future<void> _removeItem(Map<String, dynamic> item, int index) async {
    final id = item['id']?.toString() ?? item['title']?.toString() ?? '';
    final isMovie = item['type'] == 'movie';

    if (isMovie) {
      await HistoryService.removeMovie(id);
    } else {
      await HistoryService.removeSong(id);
    }

    final histIdx = _history.indexWhere(
      (e) => (e['id']?.toString() ?? e['title']?.toString()) == id,
    );
    setState(() {
      if (histIdx != -1) _history.removeAt(histIdx);
      _filtered.removeAt(index);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Removed from history'),
          backgroundColor: AppTheme.textSecondary,
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          ),
        ),
      );
    }
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
          'Clear History',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          _tabController.index == 0
              ? 'Remove all items from your history?'
              : _tabController.index == 1
              ? 'Remove all songs from your history?'
              : 'Remove all movies from your history?',
          style: const TextStyle(color: AppTheme.textSecondary),
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
      if (_tabController.index == 0) {
        await HistoryService.clearAll();
        setState(() {
          _history.clear();
          _filtered.clear();
        });
      } else if (_tabController.index == 1) {
        await HistoryService.clearAllSongs();
        setState(() {
          _history.removeWhere((e) => e['type'] == 'song');
          _filtered.clear();
        });
      } else {
        await HistoryService.clearAllMovies();
        setState(() {
          _history.removeWhere((e) => e['type'] == 'movie');
          _filtered.clear();
        });
      }
    }
  }

  String _formatTime(Map<String, dynamic> item) {
    final ts = item['playedAt'] ?? item['watchedAt'];
    if (ts == null) return '';
    // ✅ Fixed: removed incorrect cast, toDate() already returns DateTime
    final dt = ts.toDate();
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('dd MMM').format(dt);
  }

  Color _moodColor(String? mood) {
    const colors = {
      'Happy': AppTheme.moodHappy,
      'Sad': AppTheme.moodSad,
      'Anxious': AppTheme.moodAnxious,
      'Bored': AppTheme.moodBored,
      'Motivated': AppTheme.moodMotivated,
      'Romantic': AppTheme.moodRomantic,
    };
    return colors[mood] ?? AppTheme.primary;
  }

  void _onTap(Map<String, dynamic> item) {
    final isMovie = item['type'] == 'movie';
    final resumeMs = (item['resumePosition'] as int?) ?? 0;

    final stringMap = Map<String, String>.from(
      item.map((k, v) => MapEntry(k, v?.toString() ?? '')),
    );

    if (isMovie) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: stringMap)),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              MusicPlayerScreen(song: stringMap, resumePositionMs: resumeMs),
        ),
      );
    }
  }

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
        title: const Text(
          'History',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_filtered.isNotEmpty)
            TextButton(
              onPressed: _clearAll,
              child: Text(
                'Clear All',
                style: TextStyle(color: AppTheme.error, fontSize: 13),
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Songs'),
            Tab(text: 'Movies'),
          ],
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(_filtered),
                _buildList(_history.where((e) => e['type'] == 'song').toList()),
                _buildList(
                  _history.where((e) => e['type'] == 'movie').toList(),
                ),
              ],
            ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> list) {
    if (list.isEmpty) return _buildEmpty();
    return RefreshIndicator(
      onRefresh: _loadHistory,
      color: AppTheme.primary,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.horizontalPadding(context),
          vertical: 12,
        ),
        itemCount: list.length,
        itemBuilder: (_, i) => _buildTile(list[i], i),
      ),
    );
  }

  Widget _buildTile(Map<String, dynamic> item, int index) {
    final isMovie = item['type'] == 'movie';
    final color = _moodColor(item['mood']);
    final coverUrl = item['cover'] ?? item['poster'] ?? '';
    final hasCover = coverUrl.isNotEmpty;
    final itemId = item['id']?.toString() ?? item['title']?.toString() ?? '';
    final resumeMs = (item['resumePosition'] as int?) ?? 0;
    final label = isMovie ? (item['genre'] ?? '') : (item['mood'] ?? '');

    return Dismissible(
      key: Key(itemId + index.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.error.withValues(alpha: 0.15),
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
      onDismissed: (_) => _removeItem(item, index),
      child: GestureDetector(
        onTap: () => _onTap(item),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            border: Border.all(color: AppTheme.border),
            boxShadow: AppTheme.shadowSM,
          ),
          child: Row(
            children: [
              // ── Thumbnail ─────────────────────────────
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  child: hasCover
                      ? Image.network(
                          coverUrl,
                          fit: BoxFit.cover,
                          // ✅ Fixed: distinct parameter names
                          errorBuilder: (ctx, err, stack) =>
                              _thumb(color, isMovie),
                        )
                      : _thumb(color, isMovie),
                ),
              ),
              const SizedBox(width: 14),

              // ── Info ──────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isMovie
                              ? Icons.movie_outlined
                              : Icons.music_note_rounded,
                          size: 11,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          isMovie ? 'Movie' : 'Song',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['title'] ?? 'Unknown',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isMovie
                          ? (item['overview'] ?? '')
                          : (item['artist'] ?? ''),
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (label.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusFull,
                              ),
                              border: Border.all(
                                color: color.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                color: color,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (!isMovie && resumeMs > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusFull,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.play_circle_outline_rounded,
                                  size: 10,
                                  color: AppTheme.primary,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'Resume',
                                  style: TextStyle(
                                    color: AppTheme.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // ── Time + icon ───────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatTime(item),
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    isMovie
                        ? Icons.play_circle_outline_rounded
                        : Icons.play_arrow_rounded,
                    color: color,
                    size: 22,
                  ),
                ],
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
          Icons.history_rounded,
          size: 72,
          color: AppTheme.textSecondary.withValues(alpha: 0.3),
        ),
        const SizedBox(height: 16),
        const Text(
          'No history yet',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Songs & movies you open will appear here',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
      ],
    ),
  );

  Widget _thumb(Color color, bool isMovie) => Container(
    color: color.withValues(alpha: 0.1),
    child: Icon(
      isMovie ? Icons.movie_outlined : Icons.music_note_rounded,
      color: color,
      size: 26,
    ),
  );
}
