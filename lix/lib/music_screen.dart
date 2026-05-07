import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'music_api_service.dart';
import 'music_player_screen.dart';
import 'home_screen.dart';
import 'movies_screen.dart';
import 'profile_screen.dart';

class MusicScreen extends StatefulWidget {
  final String mood;
  const MusicScreen({super.key, required this.mood});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  static const Color _purple = Color(0xFF7C3AED);
  static const Color _bgColor = Color(0xFFF2F2F7);
  static const Color _cardBg = Color(0xFFFFFFFF);
  static const Color _textDark = Color(0xFF1C1C1E);
  static const Color _textGrey = Color(0xFF8E8E93);

  late String _selectedMood;
  List<Map<String, String>> _songs = [];
  bool _isLoading = true;
  int _selectedNav = 2;

  Map<String, String>? _currentSong;
  bool _isPlaying = false;
  int _currentIndex = 0;

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
    // ✅ Delay fetch until after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSongs();
    });
  }

  Future<void> _loadSongs() async {
    setState(() => _isLoading = true);
    final songs = await MusicApiService.getSongsByMood(_selectedMood);
    if (mounted) {
      setState(() {
        _songs = songs;
        _isLoading = false;
        if (_songs.isNotEmpty && _currentSong == null) {
          _currentSong = _songs[0];
          _currentIndex = 0;
        }
      });
    }
  }

  Future<void> _openYouTube(String title, String artist) async {
    final query = Uri.encodeComponent('$artist $title full song');
    final uri = Uri.parse(
      'https://www.youtube.com/results?search_query=$query',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openAppleMusic(String title, String artist) async {
    final query = Uri.encodeComponent('$artist $title');
    final uri = Uri.parse('https://music.apple.com/search?term=$query');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openPlayer(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _currentSong = _songs[index];
      _currentIndex = index;
      _isPlaying = true;
    });
    final enriched = _songs
        .map((s) => Map<String, String>.from({...s, 'mood': _selectedMood}))
        .toList();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => MusicPlayerScreen(
          // ✅ Fixed
          song: enriched[index],
          playlist: enriched,
          currentIndex: index,
        ),
        transitionsBuilder: (_, animation, __, child) => SlideTransition(
          // ✅ Fixed
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

  void _showFullSongOptions(Map<String, String> song) {
    HapticFeedback.mediumImpact();
    final title = song['title'] ?? '';
    final artist = song['artist'] ?? '';
    final cover = song['cover'] ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: _cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: cover.isNotEmpty
                      ? Image.network(
                          cover,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx2, err, stack) =>
                              _albumPlaceholder(52), // ✅ Fixed
                        )
                      : _albumPlaceholder(52),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: _textDark,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        artist,
                        style: const TextStyle(color: _textGrey, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Divider(color: Colors.grey.shade200),
            const SizedBox(height: 16),
            const Text(
              'Listen to Full Song',
              style: TextStyle(
                color: _textDark,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Choose where to listen',
              style: TextStyle(color: _textGrey, fontSize: 13),
            ),
            const SizedBox(height: 20),
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
                        color: const Color(0xFFFF0000),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
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
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Open in YouTube',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
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
                        color: const Color(0xFFFC3C44),
                        borderRadius: BorderRadius.circular(14),
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
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Open in Apple Music',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
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
      ),
    );
  }

  Route _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, animation, __) => page, // ✅ Fixed
      transitionsBuilder: (_, animation, __, child) => SlideTransition(
        // ✅ Fixed
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────
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
                  Column(
                    children: [
                      const Text(
                        'Music for You',
                        style: TextStyle(
                          color: _textDark,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Based on your mood',
                        style: TextStyle(color: _textGrey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Mood Chips ───────────────────────────────
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _moods.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: 8), // ✅ Fixed
                itemBuilder: (_, i) {
                  final mood = _moods[i];
                  final isSelected = mood == _selectedMood;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _selectedMood = mood);
                      _loadSongs();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? _purple : _cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? _purple : Colors.grey.shade300,
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: _purple.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Text(
                        mood,
                        style: TextStyle(
                          color: isSelected ? Colors.white : _textDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // ── Songs List ───────────────────────────────
            Expanded(
              child: _isLoading
                  ? _buildShimmer()
                  : _songs.isEmpty
                  ? _buildEmpty()
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: _songs.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10), // ✅ Fixed
                      itemBuilder: (_, i) => _SongCard(
                        song: _songs[i],
                        onPlay: () => _openPlayer(i),
                        onFullSong: () => _showFullSongOptions(_songs[i]),
                      ),
                    ),
            ),

            if (_currentSong != null) _buildMiniPlayer(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildMiniPlayer() {
    final song = _currentSong!;
    final cover = song['cover'] ?? '';
    final title = song['title'] ?? '';
    final artist = song['artist'] ?? '';

    return Container(
      height: 64,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: cover.isNotEmpty
                ? Image.network(
                    cover,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) =>
                        _albumPlaceholder(44), // ✅ Fixed
                  )
                : _albumPlaceholder(44),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  artist,
                  style: const TextStyle(color: _textGrey, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              if (_currentIndex > 0) {
                setState(() {
                  _currentIndex--;
                  _currentSong = _songs[_currentIndex];
                });
              }
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                Icons.skip_previous_rounded,
                color: _textDark,
                size: 22,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _isPlaying = !_isPlaying),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: _purple,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (_currentIndex < _songs.length - 1) {
                setState(() {
                  _currentIndex++;
                  _currentSong = _songs[_currentIndex];
                });
              }
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.skip_next_rounded, color: _textDark, size: 22),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.movie_outlined, 'label': 'Movies'},
      {'icon': Icons.music_note_outlined, 'label': 'Music'},
      {'icon': Icons.person_outline, 'label': 'Profile'},
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
                    (route) => false,
                  );
                }
                if (i == 1) {
                  Navigator.pushReplacement(
                    context,
                    _slideRoute(MoviesScreen(mood: _selectedMood)),
                  );
                }
                if (i == 3) {
                  Navigator.push(context, _slideRoute(const ProfileScreen()));
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

  Widget _buildShimmer() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: 7,
      separatorBuilder: (_, __) => const SizedBox(height: 10), // ✅ Fixed
      itemBuilder: (_, __) => const _ShimmerCard(), // ✅ Fixed + const
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.music_off_rounded, size: 52, color: _textGrey),
          SizedBox(height: 12),
          Text(
            'No songs found',
            style: TextStyle(
              color: _textDark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Try a different mood',
            style: TextStyle(color: _textGrey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _albumPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF3D1A6E),
        borderRadius: BorderRadius.circular(size * 0.2),
      ),
      child: Icon(
        Icons.music_note_rounded,
        color: Colors.white54,
        size: size * 0.45,
      ),
    );
  }
}

// ── Song Card ─────────────────────────────────────────────────
class _SongCard extends StatelessWidget {
  final Map<String, String> song;
  final VoidCallback onPlay;
  final VoidCallback onFullSong;
  const _SongCard({
    required this.song,
    required this.onPlay,
    required this.onFullSong,
  });

  static const Color _purple = Color(0xFF7C3AED);
  static const Color _textDark = Color(0xFF1C1C1E);
  static const Color _textGrey = Color(0xFF8E8E93);

  @override
  Widget build(BuildContext context) {
    final cover = song['cover'] ?? '';
    final title = song['title'] ?? '';
    final artist = song['artist'] ?? '';
    final genre = song['genre'] ?? '';

    return GestureDetector(
      onTap: onPlay,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: cover.isNotEmpty
                  ? Image.network(
                      cover,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) =>
                          _placeholder(), // ✅ Fixed
                    )
                  : _placeholder(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      artist,
                      style: const TextStyle(color: _textGrey, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (genre.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _purple.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          genre,
                          style: TextStyle(
                            color: _purple.withOpacity(0.8),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: onPlay,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: _purple,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 72,
      height: 72,
      color: const Color(0xFF3D1A6E),
      child: const Center(
        child: Icon(Icons.music_note_rounded, color: Colors.white54, size: 28),
      ),
    );
  }
}

// ── Shimmer Card ──────────────────────────────────────────────
class _ShimmerCard extends StatefulWidget {
  const _ShimmerCard(); // ✅ Added const constructor

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
