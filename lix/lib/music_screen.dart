import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'music_api_service.dart';
import 'music_player_screen.dart';
import 'app_theme.dart';

class MusicScreen extends StatefulWidget {
  final String mood;
  const MusicScreen({super.key, required this.mood});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  late String _selectedMood;
  List<Map<String, String>> _songs = [];
  bool _isLoading = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _moods = const [
    {'label': 'Happy', 'emoji': '😊'},
    {'label': 'Sad', 'emoji': '😢'},
    {'label': 'Anxious', 'emoji': '😰'},
    {'label': 'Bored', 'emoji': '😴'},
    {'label': 'Motivated', 'emoji': '💪'},
    {'label': 'Romantic', 'emoji': '😍'},
  ];

  final Map<String, Color> _moodColors = const {
    'Happy': AppTheme.moodHappy,
    'Sad': AppTheme.moodSad,
    'Anxious': AppTheme.moodAnxious,
    'Bored': AppTheme.moodBored,
    'Motivated': AppTheme.moodMotivated,
    'Romantic': AppTheme.moodRomantic,
  };

  @override
  void initState() {
    super.initState();
    _selectedMood = widget.mood;
    _loadSongs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSongs() async {
    setState(() => _isLoading = true);
    final songs = await MusicApiService.getSongsByMood(_selectedMood);
    if (mounted) {
      setState(() {
        _songs = songs;
        _isLoading = false;
      });
    }
  }

  Future<void> _searchSongs(String query) async {
    if (query.trim().isEmpty) {
      _loadSongs();
      return;
    }
    setState(() => _isLoading = true);
    final songs = await MusicApiService.searchSongs(query.trim());
    if (mounted) {
      setState(() {
        _songs = songs;
        _isLoading = false;
      });
    }
  }

  // ── Open 30s Preview Player ──────────────────────────────
  void _openPlayer(int index) {
    HapticFeedback.lightImpact();
    final enriched = _songs.map((s) => {...s, 'mood': _selectedMood}).toList();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, _) => MusicPlayerScreen(
          song: enriched[index],
          playlist: enriched,
          currentIndex: index,
        ),
        transitionsBuilder: (_, animation, _, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  // ── Open YouTube for full song ───────────────────────────
  Future<void> _openYouTube(String title, String artist) async {
    final query = Uri.encodeComponent('$artist $title full song');
    final uri = Uri.parse(
      'https://www.youtube.com/results?search_query=$query',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ── Open Apple Music for full song ──────────────────────
  Future<void> _openAppleMusic(String title, String artist) async {
    final query = Uri.encodeComponent('$artist $title');
    final uri = Uri.parse('https://music.apple.com/search?term=$query');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ── Bottom Sheet: Full Song Options ─────────────────────
  void _showFullSongOptions(Map<String, String> song) {
    HapticFeedback.mediumImpact();
    final title = song['title'] ?? '';
    final artist = song['artist'] ?? '';
    final moodColor = _moodColors[_selectedMood] ?? AppTheme.primary;
    final hasCover = song['cover'] != null && song['cover']!.isNotEmpty;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXL),
        ),
      ),
      builder: (ctx) {
        final hPad = AppTheme.horizontalPadding(context);
        return Padding(
          padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
              ),
              const SizedBox(height: 20),

              // Song info row
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    child: hasCover
                        ? Image.network(
                            song['cover']!,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _miniCover(moodColor),
                          )
                        : _miniCover(moodColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: AppTheme.bodyLarge(context),
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          artist,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: AppTheme.bodyRegular(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Divider(color: AppTheme.border),
              const SizedBox(height: 16),

              Text(
                'Listen to Full Song',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: AppTheme.heading2(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Choose where to listen',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: AppTheme.bodyRegular(context),
                ),
              ),

              const SizedBox(height: 20),

              // ── YouTube + Apple Music Buttons ────────────
              Row(
                children: [
                  // YouTube
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        _openYouTube(title, artist);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF0000), Color(0xFFCC0000)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusLG,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF0000).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.play_arrow_rounded,
                                  color: Color(0xFFFF0000),
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'YouTube',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Open in YouTube',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: AppTheme.caption(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Apple Music
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        _openAppleMusic(title, artist);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFC3C44), Color(0xFFB71C1C)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusLG,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFC3C44).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.apple,
                                  color: Color(0xFFFC3C44),
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Apple Music',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Open in Apple Music',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: AppTheme.caption(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Song Card ────────────────────────────────────────────
  Widget _buildSongCard(Map<String, String> song, int index) {
    final moodColor = _moodColors[_selectedMood] ?? AppTheme.primary;
    final hasCover = song['cover'] != null && song['cover']!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadowSM,
      ),
      child: Row(
        children: [
          // ── Album Cover ─────────────────────────────────
          GestureDetector(
            onTap: () => _openPlayer(index),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusLG),
                bottomLeft: Radius.circular(AppTheme.radiusLG),
              ),
              child: hasCover
                  ? Image.network(
                      song['cover']!,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _coverPlaceholder(moodColor),
                    )
                  : _coverPlaceholder(moodColor),
            ),
          ),

          const SizedBox(width: 12),

          // ── Title + Artist + Genre + Duration ────────────
          Expanded(
            child: GestureDetector(
              onTap: () => _openPlayer(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song['title'] ?? '',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: AppTheme.bodyLarge(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      song['artist'] ?? '',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: AppTheme.bodyRegular(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        if (song['genre'] != null && song['genre']!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: moodColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusFull,
                              ),
                            ),
                            child: Text(
                              song['genre']!,
                              style: TextStyle(
                                color: moodColor,
                                fontSize: AppTheme.caption(context) - 1,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        const Spacer(),
                        if (song['duration'] != null &&
                            song['duration']!.isNotEmpty)
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 11,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                song['duration']!,
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: AppTheme.caption(context),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Right Buttons Column ─────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Play preview
                GestureDetector(
                  onTap: () => _openPlayer(index),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: moodColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: moodColor.withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // ✅ Full Song button
                GestureDetector(
                  onTap: () => _showFullSongOptions(song),
                  child: Container(
                    width: 38,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.shimmerBase,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      border: Border.all(color: AppTheme.border, width: 1),
                    ),
                    child: Center(
                      child: Text(
                        'Full',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: AppTheme.caption(context) - 1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniCover(Color color) => Container(
    width: 56,
    height: 56,
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
    ),
    child: Icon(Icons.music_note_rounded, color: color, size: 24),
  );

  Widget _coverPlaceholder(Color color) => Container(
    width: 72,
    height: 72,
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      border: Border(right: BorderSide(color: color.withOpacity(0.1))),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.music_note_rounded, color: color, size: 24),
        const SizedBox(height: 2),
        Icon(Icons.apple, color: color.withOpacity(0.5), size: 14),
      ],
    ),
  );

  Widget _buildShimmer() {
    return ListView.builder(
      padding: EdgeInsets.all(AppTheme.horizontalPadding(context)),
      itemCount: 8,
      itemBuilder: (_, _) => Container(
        height: 74,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.shimmerBase,
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppTheme.shimmerBase,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.music_off_rounded,
              color: AppTheme.textSecondary,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No songs found',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: AppTheme.bodyLarge(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Check your internet and try again',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: AppTheme.bodyRegular(context),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _loadSongs,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                boxShadow: AppTheme.shadowPrimary,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.refresh_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Try Again',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppTheme.bodyLarge(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hPad = AppTheme.horizontalPadding(context);
    final moodColor = _moodColors[_selectedMood] ?? AppTheme.primary;
    final moodEmoji = _moods.firstWhere(
      (m) => m['label'] == _selectedMood,
      orElse: () => {'emoji': '🎵'},
    )['emoji']!;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.shimmerBase,
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: AppTheme.textPrimary,
              size: 16,
            ),
          ),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: AppTheme.bodyLarge(context),
                ),
                decoration: InputDecoration(
                  hintText: 'Search songs, artists, language...',
                  hintStyle: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: AppTheme.bodyRegular(context),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                onSubmitted: _searchSongs,
              )
            : Row(
                children: [
                  const Icon(
                    Icons.apple,
                    color: AppTheme.textPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Music Picks',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: AppTheme.heading2(context),
                    ),
                  ),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search_rounded,
              color: AppTheme.textPrimary,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _loadSongs();
                }
              });
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppTheme.border),
        ),
      ),
      body: Column(
        children: [
          // Mood filter chips
          Container(
            color: AppTheme.surface,
            height: AppTheme.isXSmall(context) ? 44 : 52,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
              itemCount: _moods.length,
              itemBuilder: (_, i) {
                final mood = _moods[i]['label']!;
                final emoji = _moods[i]['emoji']!;
                final selected = mood == _selectedMood;
                final chipColor = _moodColors[mood] ?? AppTheme.primary;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedMood = mood);
                    _loadSongs();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: selected ? chipColor : AppTheme.shimmerBase,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: chipColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        '$emoji  $mood',
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : AppTheme.textSecondary,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: AppTheme.bodyRegular(context),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Divider(height: 1, color: AppTheme.border),

          // Mood header
          Container(
            margin: EdgeInsets.fromLTRB(hPad, 12, hPad, 4),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  moodColor.withOpacity(0.12),
                  moodColor.withOpacity(0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusLG),
              border: Border.all(color: moodColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Text(
                  moodEmoji,
                  style: TextStyle(
                    fontSize: AppTheme.isSmall(context) ? 26 : 30,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_selectedMood Vibes',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: AppTheme.bodyLarge(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _isLoading
                          ? '  Loading songs...'
                          : '  ${_songs.length} songs • Tap ▶ for 30s preview',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: AppTheme.caption(context),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _loadSongs,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: moodColor,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      boxShadow: [
                        BoxShadow(
                          color: moodColor.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Refresh',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppTheme.caption(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Songs list
          Expanded(
            child: _isLoading
                ? _buildShimmer()
                : _songs.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 24),
                    itemCount: _songs.length,
                    itemBuilder: (_, i) => _buildSongCard(_songs[i], i),
                  ),
          ),
        ],
      ),
    );
  }
}
