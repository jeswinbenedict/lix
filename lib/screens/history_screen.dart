import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/responsive.dart';
import '../services/history_service.dart';
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
          'History',
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.error),
            onPressed: () async {
              await HistoryService.clearAll();
              _loadHistory();
            },
          ),
        ],
      ),
      body: CenteredContent(
        maxWidth: 800,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _history.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 48, color: AppTheme.textSecondary),
                        SizedBox(height: 12),
                        Text('No watch or listen history yet', style: TextStyle(color: AppTheme.textSecondary)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      final item = _history[index];
                      final isSong = item['type'] == 'song';
                      return ListTile(
                        leading: Icon(
                          isSong ? Icons.music_note : Icons.movie,
                          color: AppTheme.primary,
                        ),
                        title: Text(item['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(isSong ? (item['artist'] ?? '') : (item['genre'] ?? '')),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          if (isSong) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MusicPlayerScreen(song: Map<String, String>.from(item)),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MovieDetailScreen(movie: Map<String, String>.from(item)),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
      ),
    );
  }
}
