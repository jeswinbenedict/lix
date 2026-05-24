import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'music_api_service.dart';
import 'music_player_screen.dart';
import 'home_screen.dart';
import 'movies_screen.dart';
import 'profile_screen.dart';
import 'chat_screen.dart';
import 'language_service.dart';

class MusicScreen extends StatefulWidget {
  final String mood;
  const MusicScreen({super.key, required this.mood});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen>
    with SingleTickerProviderStateMixin {
  // ── Light theme tokens (replaces all dark/black values) ───────────────
  static const Color _bg = Color(0xFFF2F2F7); // was #0D0D0F
  static const Color _surface = Color(0xFFFFFFFF); // was #222228
  static const Color _surfaceAlt = Color(0xFFEEEEF4); // was #222228 (secondary)
  static const Color _navBg = Color(
    0xFF1C1C1E,
  ); // nav stays dark (matches rest of app)
  static const Color _navActive = Color(0xFF2C2C2E);
  static const Color _textHigh = Color(0xFF1C1C1E); // was #F5F5F7
  static const Color _textMid = Color(0xFF6C6C72); // was #9A9AA8
  static const Color _textLow = Color(0xFFAEAEB2); // was #55555F
  static const Color _divider = Color(0xFFE5E5EA);

  static const Map<String, List<Color>> _moodPalettes = {
    'Happy': [Color(0xFFFFA040), Color(0xFFFF6060)],
    'Sad': [Color(0xFF4080FF), Color(0xFF8040FF)],
    'Anxious': [Color(0xFF40C0C0), Color(0xFF2060A0)],
    'Bored': [Color(0xFF60A060), Color(0xFF208060)],
    'Motivated': [Color(0xFFFF6020), Color(0xFFFF2060)],
    'Romantic': [Color(0xFFE040A0), Color(0xFF8020C0)],
  };

  LanguageService get _lang => LanguageService.instance;

  late String _selectedMood;
  List<Map<String, String>> _songs = [];
  bool _isLoading = true;
  int _selectedNav = 3;
  Map<String, String>? _currentSong;
  bool _isPlaying = false;
  int _currentIndex = 0;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  final List<String> _moods = const [
    'Happy',
    'Sad',
    'Anxious',
    'Bored',
    'Motivated',
    'Romantic',
  ];

  List<Color> get _palette =>
      _moodPalettes[_selectedMood] ??
      [const Color(0xFF7C3AED), const Color(0xFFE040A0)];

  @override
  void initState() {
    super.initState();
    _selectedMood = widget.mood;
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.96,
      end: 1.04,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSongs());
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
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
    final q = Uri.encodeComponent('$artist $title full song');
    final uri = Uri.parse('https://www.youtube.com/results?search_query=$q');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openAppleMusic(String title, String artist) async {
    final q = Uri.encodeComponent('$artist $title');
    final uri = Uri.parse('https://music.apple.com/search?term=$q');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openPlayer(int index) {
    HapticFeedback.mediumImpact();
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
        pageBuilder: (_, a, _) => MusicPlayerScreen(
          song: enriched[index],
          playlist: enriched,
          currentIndex: index,
        ),
        transitionsBuilder: (_, a, _, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _showListenOptions(Map<String, String> song) {
    HapticFeedback.mediumImpact();
    final title = song['title'] ?? '';
    final artist = song['artist'] ?? '';
    final cover = song['cover'] ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: _surface, // was dark #1A1A1F
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(ctx).padding.bottom + 28,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: _textLow,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _coverWidget(cover, 56, radius: 12),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: _textHigh,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        artist,
                        style: const TextStyle(color: _textMid, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(color: _divider),
            const SizedBox(height: 20),
            const Text(
              'Listen Full Song',
              style: TextStyle(
                color: _textHigh,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Choose your platform',
              style: TextStyle(color: _textMid, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _platformBtn(
                    color: const Color(0xFFFF0000),
                    icon: Icons.play_arrow_rounded,
                    name: 'YouTube',
                    sub: 'Open in app',
                    onTap: () {
                      Navigator.pop(ctx);
                      _openYouTube(title, artist);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _platformBtn(
                    color: const Color(0xFFFC3C44),
                    icon: Icons.apple,
                    name: 'Apple Music',
                    sub: 'Open in app',
                    onTap: () {
                      Navigator.pop(ctx);
                      _openAppleMusic(title, artist);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _platformBtn({
    required Color color,
    required IconData icon,
    required String name,
    required String sub,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Route _slideRoute(Widget page) => PageRouteBuilder(
    pageBuilder: (_, a, _) => page,
    transitionsBuilder: (_, a, _, child) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
      child: child,
    ),
    transitionDuration: const Duration(milliseconds: 300),
  );

  @override
  Widget build(BuildContext context) {
    final systemNavH = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: _bg, // was _ink (black)
      extendBody: true,
      bottomNavigationBar: _buildBottomArea(context, systemNavH),
      body: Column(
        children: [
          _buildHeader(context),
          _buildMoodStrip(),
          const SizedBox(height: 4),
          Expanded(
            child: _isLoading
                ? _buildShimmer()
                : _songs.isEmpty
                ? _buildEmpty()
                : _buildSongList(),
          ),
        ],
      ),
    );
  }

  // ── Header — gradient fades into light bg ─────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final pal = _palette;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
          colors: [
            pal[0].withValues(alpha: 0.75), // was 0.85 on black
            pal[1].withValues(alpha: 0.45), // was 0.5 on black
            _bg, // fades to light bg
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Back button — white card on light bg
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: _textHigh,
                    size: 16,
                  ),
                ),
              ),
              const Spacer(),
              // Mood badge — gradient pill, NO emoji
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: pal),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: pal[0].withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  _selectedMood,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Music for You',
            style: TextStyle(
              color: _textHigh, // was white
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _songs.isEmpty
                ? 'Finding songs...'
                : '${_songs.length} songs curated for your mood',
            style: const TextStyle(
              color: _textMid,
              fontSize: 13,
            ), // was white54
          ),
        ],
      ),
    );
  }

  // ── Mood strip — white chips, NO emojis ───────────────────────────────
  Widget _buildMoodStrip() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _moods.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final mood = _moods[i];
          final isSel = mood == _selectedMood;
          final pal =
              _moodPalettes[mood] ??
              [const Color(0xFF7C3AED), const Color(0xFFE040A0)];
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _selectedMood = mood;
                _currentSong = null;
              });
              _loadSongs();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSel ? LinearGradient(colors: pal) : null,
                color: isSel ? null : _surface, // was _inkCard (dark)
                borderRadius: BorderRadius.circular(22),
                border: isSel ? null : Border.all(color: _divider, width: 1.5),
                boxShadow: isSel
                    ? [
                        BoxShadow(
                          color: pal[0].withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: Text(
                _lang.translate(mood),
                style: TextStyle(
                  color: isSel
                      ? Colors.white
                      : _textMid, // was _textMid on dark
                  fontSize: 13,
                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSongList() {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      itemCount: _songs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final song = _songs[i];
        final isActive =
            _currentSong != null && _currentSong!['title'] == song['title'];
        return _SongRow(
          song: song,
          index: i,
          isActive: isActive,
          isPlaying: isActive && _isPlaying,
          palette: _palette,
          onPlay: () => _openPlayer(i),
          onMore: () => _showListenOptions(song),
        );
      },
    );
  }

  Widget _buildBottomArea(BuildContext context, double systemNavH) {
    return Container(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_currentSong != null) _buildMiniPlayer(),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, systemNavH + 10),
            child: _buildNavPill(context),
          ),
        ],
      ),
    );
  }

  // ── Mini player — gradient accent pill (unchanged design, same colours)
  Widget _buildMiniPlayer() {
    final song = _currentSong!;
    final cover = song['cover'] ?? '';
    final title = song['title'] ?? '';
    final artist = song['artist'] ?? '';
    final pal = _palette;

    return GestureDetector(
      onTap: () => _openPlayer(_currentIndex),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        height: 72,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              pal[0].withValues(alpha: 0.92),
              pal[1].withValues(alpha: 0.92),
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: pal[0].withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, child) => Transform.scale(
                scale: _isPlaying ? _pulseAnim.value : 1.0,
                child: child,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _coverWidget(cover, 48),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    artist,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            _miniBtn(Icons.skip_previous_rounded, () {
              if (_currentIndex > 0) {
                setState(() {
                  _currentIndex--;
                  _currentSong = _songs[_currentIndex];
                });
              }
            }),
            GestureDetector(
              onTap: () => setState(() => _isPlaying = !_isPlaying),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            _miniBtn(Icons.skip_next_rounded, () {
              if (_currentIndex < _songs.length - 1) {
                setState(() {
                  _currentIndex++;
                  _currentSong = _songs[_currentIndex];
                });
              }
            }),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  Widget _miniBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Icon(icon, color: Colors.white, size: 22),
    ),
  );

  // ── Nav pill — stays dark to match home/movies screens ────────────────
  Widget _buildNavPill(BuildContext context) {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.movie_outlined, 'label': 'Movies'},
      {'icon': Icons.chat_bubble_outline_rounded, 'label': 'Chat'},
      {'icon': Icons.music_note_outlined, 'label': 'Music'},
      {'icon': Icons.person_outline, 'label': 'Profile'},
    ];
    final pal = _palette;

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: _navBg,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
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
                    (_) => false,
                  );
                } else if (i == 1)
                  Navigator.pushReplacement(
                    context,
                    _slideRoute(MoviesScreen(mood: _selectedMood)),
                  );
                else if (i == 2)
                  Navigator.push(context, _slideRoute(const ChatScreen()));
                else if (i == 3)
                  return;
                else if (i == 4)
                  Navigator.push(context, _slideRoute(const ProfileScreen()));
              },
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? _navActive : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      items[i]['icon'] as IconData,
                      color: isActive ? pal[0] : Colors.white60,
                      size: 22,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _lang.translate(items[i]['label'] as String),
                      style: TextStyle(
                        color: isActive ? pal[0] : Colors.white60,
                        fontSize: 10,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      itemCount: 7,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, _) => const _ShimmerRow(),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _surfaceAlt, // was _inkCard (dark)
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.music_off_rounded,
              size: 32,
              color: _textLow,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No songs found',
            style: TextStyle(
              color: _textHigh,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try switching your mood',
            style: TextStyle(color: _textMid, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _coverWidget(String url, double size, {double radius = 10}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _surfaceAlt, // was _inkCard (dark)
        borderRadius: BorderRadius.circular(radius),
      ),
      child: url.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Icon(
                  Icons.music_note_rounded,
                  color: _textLow,
                  size: size * 0.4,
                ),
              ),
            )
          : Icon(Icons.music_note_rounded, color: _textLow, size: size * 0.4),
    );
  }
}

// ── Song row ─────────────────────────────────────────────────────────────────
class _SongRow extends StatelessWidget {
  final Map<String, String> song;
  final int index;
  final bool isActive;
  final bool isPlaying;
  final List<Color> palette;
  final VoidCallback onPlay;
  final VoidCallback onMore;

  const _SongRow({
    required this.song,
    required this.index,
    required this.isActive,
    required this.isPlaying,
    required this.palette,
    required this.onPlay,
    required this.onMore,
  });

  // Light theme tokens
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _surfaceAlt = Color(0xFFEEEEF4);
  static const Color _textHigh = Color(0xFF1C1C1E);
  static const Color _textMid = Color(0xFF6C6C72);
  static const Color _textLow = Color(0xFFAEAEB2);

  @override
  Widget build(BuildContext context) {
    final cover = song['cover'] ?? '';
    final title = song['title'] ?? '';
    final artist = song['artist'] ?? '';
    final genre = song['genre'] ?? '';

    return GestureDetector(
      onTap: onPlay,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isActive ? null : _surface, // was _inkCard (dark)
          gradient: isActive
              ? LinearGradient(
                  colors: [
                    palette[0].withValues(alpha: 0.10),
                    palette[1].withValues(alpha: 0.04),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(18),
          border: isActive
              ? Border.all(
                  color: palette[0].withValues(alpha: 0.35),
                  width: 1.2,
                )
              : null,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: palette[0].withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Track number / wave bars
            SizedBox(
              width: 26,
              child: Center(
                child: isActive
                    ? _WaveIcon(color: palette[0])
                    : Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: _textLow,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 10),

            _buildCover(cover),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isActive ? palette[0] : _textHigh,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    artist,
                    style: const TextStyle(color: _textMid, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (genre.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      genre.toUpperCase(),
                      style: TextStyle(
                        color: isActive
                            ? palette[0].withValues(alpha: 0.6)
                            : _textLow,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // More button
            GestureDetector(
              onTap: onMore,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _surfaceAlt, // was dark transparent
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.more_horiz_rounded,
                  color: _textMid,
                  size: 17,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Play button
            GestureDetector(
              onTap: onPlay,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: isActive ? LinearGradient(colors: palette) : null,
                  color: isActive ? null : _surfaceAlt, // was dark transparent
                  shape: BoxShape.circle,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: palette[0].withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  isActive && isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: isActive ? Colors.white : _textMid,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCover(String url) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: _surfaceAlt, // was dark
        borderRadius: BorderRadius.circular(14),
      ),
      child: url.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.music_note_rounded,
                  color: _textLow,
                  size: 22,
                ),
              ),
            )
          : const Icon(Icons.music_note_rounded, color: _textLow, size: 22),
    );
  }
}

// ── Animated wave bars ───────────────────────────────────────────────────────
class _WaveIcon extends StatefulWidget {
  final Color color;
  const _WaveIcon({required this.color});
  @override
  State<_WaveIcon> createState() => _WaveIconState();
}

class _WaveIconState extends State<_WaveIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        final v = _ctrl.value;
        final heights = [0.4 + v * 0.6, 0.75 + v * 0.25, 0.3 + v * 0.7];
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(
            3,
            (i) => Container(
              width: 3,
              height: 14 * heights[i],
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Shimmer row — light grey ─────────────────────────────────────────────────
class _ShimmerRow extends StatefulWidget {
  const _ShimmerRow();
  @override
  State<_ShimmerRow> createState() => _ShimmerRowState();
}

class _ShimmerRowState extends State<_ShimmerRow>
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
    _anim = Tween<double>(
      begin: 0.4,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
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
        height: 76,
        decoration: BoxDecoration(
          color: Colors.grey.shade200, // was dark #222228
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(width: 26, height: 12, color: Colors.grey.shade300),
            const SizedBox(width: 10),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(height: 13, color: Colors.grey.shade300),
                  const SizedBox(height: 8),
                  Container(
                    height: 10,
                    width: 100,
                    color: Colors.grey.shade200,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
