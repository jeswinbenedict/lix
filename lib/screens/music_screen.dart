import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/responsive.dart';
import '../services/music_api_service.dart';
import '../services/language_service.dart';
import 'music_player_screen.dart';

class MusicScreen extends StatefulWidget {
  final String mood;
  const MusicScreen({super.key, this.mood = 'Happy'});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  LanguageService get _lang => LanguageService.instance;

  List<Map<String, String>> _songs = [];
  bool _loading = true;
  String _selectedMood = 'Happy';
  final _searchController = TextEditingController();

  final List<String> _moods = const [
    'Happy',
    'Sad',
    'Anxious',
    'Bored',
    'Motivated',
    'Romantic',
  ];

  @override
  void initState() {
    super.initState();
    _selectedMood = widget.mood;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSongs(_selectedMood);
    });
  }

  Future<void> _fetchSongs(String mood) async {
    setState(() => _loading = true);
    try {
      final list = await MusicApiService.getSongsByMood(mood);
      if (mounted) {
        setState(() {
          _songs = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      _fetchSongs(_selectedMood);
      return;
    }
    setState(() => _loading = true);
    try {
      final list = await MusicApiService.searchSongs(query);
      if (mounted) {
        setState(() {
          _songs = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lang,
      builder: (context, _) => Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.surface,
          elevation: 0,
          title: Row(
            children: [
              const Icon(Icons.music_note_outlined, color: AppTheme.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                _lang.translate("Music"),
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: AppTheme.heading2(context),
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(height: 1, color: AppTheme.border),
          ),
        ),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: CenteredContent(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Search Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: AppTheme.textPrimary),
                        onSubmitted: _search,
                        decoration: InputDecoration(
                          hintText: _lang.translate("Search song, artist, language..."),
                          hintStyle: TextStyle(color: AppTheme.textSecondary),
                          border: InputBorder.none,
                          icon: const Icon(Icons.search, color: AppTheme.primary),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.send, color: AppTheme.primary, size: 20),
                            onPressed: () => _search(_searchController.text),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Mood Filter Chips
                    SizedBox(
                      height: 44,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _moods.length,
                        itemBuilder: (context, index) {
                          final mood = _moods[index];
                          final isSelected = mood == _selectedMood;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(_lang.translate(mood)),
                              selected: isSelected,
                              selectedColor: AppTheme.primary,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : AppTheme.textPrimary,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  _searchController.clear();
                                  setState(() => _selectedMood = mood);
                                  _fetchSongs(mood);
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: _loading
                  ? const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: CircularProgressIndicator(color: AppTheme.primary),
                        ),
                      ),
                    )
                  : SliverGrid(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 320,
                        mainAxisExtent: 100,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final song = _songs[index];
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MusicPlayerScreen(
                                  song: song,
                                  playlist: _songs,
                                  currentIndex: index,
                                ),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                                border: Border.all(color: AppTheme.border),
                                boxShadow: AppTheme.shadowSM,
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: (song['cover'] ?? '').isNotEmpty
                                        ? Image.network(
                                            song['cover']!,
                                            width: 70,
                                            height: 70,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              width: 70,
                                              height: 70,
                                              color: AppTheme.primaryLight,
                                              child: const Icon(Icons.music_note, color: AppTheme.primary),
                                            ),
                                          )
                                        : Container(
                                            width: 70,
                                            height: 70,
                                            color: AppTheme.primaryLight,
                                            child: const Icon(Icons.music_note, color: AppTheme.primary),
                                          ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          song['title'] ?? 'Track',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          song['artist'] ?? 'Artist',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                        if ((song['duration'] ?? '').isNotEmpty)
                                          Text(
                                            song['duration']!,
                                            style: const TextStyle(
                                              color: AppTheme.primary,
                                              fontSize: 11,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.play_circle_fill, color: AppTheme.primary, size: 32),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: _songs.length,
                      ),
                    ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }
}
