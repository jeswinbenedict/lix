import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_theme.dart';
import '../core/responsive.dart';
import '../services/music_api_service.dart';
import '../services/language_service.dart';
import '../services/global_audio_service.dart';
import '../widgets/shimmer_skeleton.dart';
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
  Timer? _debounce;
  bool _isSearching = false;

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
    setState(() {
      _loading = true;
      _isSearching = false;
    });
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

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isNotEmpty) {
        _search(query.trim());
      } else {
        _fetchSongs(_selectedMood);
      }
    });
  }

  Future<void> _search(String query) async {
    setState(() {
      _loading = true;
      _isSearching = true;
    });
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
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lang,
      builder: (context, _) => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          title: Row(
            children: [
              const Icon(Icons.music_note_outlined, color: AppTheme.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                _lang.translate("Music"),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: AppTheme.heading2(context),
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(height: 1, color: Theme.of(context).dividerColor.withAlpha(40)),
          ),
        ),
        body: RefreshIndicator(
          color: AppTheme.primary,
          onRefresh: () async {
            if (_isSearching && _searchController.text.isNotEmpty) {
              await _search(_searchController.text.trim());
            } else {
              await _fetchSongs(_selectedMood);
            }
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              SliverToBoxAdapter(
                child: CenteredContent(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Search Box
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          onSubmitted: (q) => _search(q.trim()),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: _lang.translate("Search songs, artists..."),
                            hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 15),
                            prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primary, size: 22),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      _fetchSongs(_selectedMood);
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                              borderSide: BorderSide(color: Theme.of(context).dividerColor.withAlpha(40), width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                              borderSide: const BorderSide(color: AppTheme.primary, width: 1.8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Mood Filter Chips
                      if (!_isSearching)
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: SizedBox(
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
                                      color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                    onSelected: (selected) {
                                      if (selected) {
                                        HapticFeedback.selectionClick();
                                        setState(() => _selectedMood = mood);
                                        _fetchSongs(mood);
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: _loading
                    ? buildSongShimmerGrid()
                    : _songs.isEmpty
                        ? SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Center(
                                child: Column(
                                  children: [
                                    const Icon(Icons.music_off_rounded, size: 48, color: AppTheme.textSecondary),
                                    const SizedBox(height: 12),
                                    Text(
                                      _lang.translate("No songs found."),
                                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : SliverGrid(
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 340,
                              mainAxisExtent: 94,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final song = _songs[index];
                                return GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    GlobalAudioService.instance.playSong(song, playlist: _songs);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MusicPlayerScreen(
                                          song: song,
                                          playlist: _songs,
                                          currentIndex: index,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                                      border: Border.all(color: Theme.of(context).dividerColor.withAlpha(40)),
                                      boxShadow: AppTheme.shadowSM,
                                    ),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: (song['cover'] ?? '').isNotEmpty
                                              ? Image.network(
                                                  song['cover']!,
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => Container(
                                                    width: 60,
                                                    height: 60,
                                                    color: AppTheme.primaryLight,
                                                    child: const Icon(Icons.music_note, color: AppTheme.primary),
                                                  ),
                                                )
                                              : Container(
                                                  width: 60,
                                                  height: 60,
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
                                                song['title'] ?? 'Unknown Track',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                song['artist'] ?? 'Unknown Artist',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                              ),
                                              if (song['duration'] != null && song['duration']!.isNotEmpty) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  song['duration']!,
                                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.play_circle_fill_rounded, color: AppTheme.primary, size: 28),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              childCount: _songs.length,
                            ),
                          ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }
}
