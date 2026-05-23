import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'movies_screen.dart';
import 'music_screen.dart';
import 'profile_screen.dart';
import 'chat_screen.dart';
import 'language_service.dart';
import 'tmdb_service.dart';
import 'music_api_service.dart';
import 'movie_detail_screen.dart';
import 'music_player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LanguageService get _lang => LanguageService.instance;

  int _selectedNav = 0;
  String _selectedMood = 'Happy';

  List<Map<String, String>> _movies = [];
  List<Map<String, String>> _music = [];
  bool _loadingMovies = true;
  bool _loadingMusic = true;

  static const Color _purple = Color(0xFF7C3AED);
  static const Color _bgColor = Color(0xFFF2F2F7);
  static const Color _cardBg = Color(0xFFFFFFFF);
  static const Color _textDark = Color(0xFF1C1C1E);
  static const Color _textGrey = Color(0xFF8E8E93);
  static const Color _navBg = Color(0xFF1C1C1E);
  static const Color _navActive = Color(0xFF2C2C2E);

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
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _fetchData(_selectedMood),
    );
  }

  Future<void> _fetchData(String mood) async {
    setState(() {
      _loadingMovies = true;
      _loadingMusic = true;
    });

    try {
      final movies = await TmdbService.getMoviesByMood(mood);
      debugPrint(
        '🎬 Movies: ${movies.length} | first poster: ${movies.isNotEmpty ? movies.first['poster'] : 'none'}',
      );
      if (mounted)
        setState(() {
          _movies = movies;
          _loadingMovies = false;
        });
    } catch (e) {
      debugPrint('🎬 Movie error: $e');
      if (mounted) setState(() => _loadingMovies = false);
    }

    try {
      final music = await MusicApiService.getSongsByMood(mood);
      debugPrint(
        '🎵 Music: ${music.length} | first cover: ${music.isNotEmpty ? music.first['cover'] : 'none'}',
      );
      if (mounted)
        setState(() {
          _music = music;
          _loadingMusic = false;
        });
    } catch (e) {
      debugPrint('🎵 Music error: $e');
      if (mounted) setState(() => _loadingMusic = false);
    }
  }

  Route _slideRoute(Widget page) => PageRouteBuilder(
    pageBuilder: (_, a, __) => page,
    transitionsBuilder: (_, a, __, child) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
      child: child,
    ),
    transitionDuration: const Duration(milliseconds: 300),
  );

  String _getUsername(User? user) {
    if (user == null) return 'User';
    if (user.displayName?.isNotEmpty == true)
      return user.displayName!.split(' ').first;
    if (user.email?.isNotEmpty == true) return user.email!.split('@').first;
    return 'User';
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final hPad = screen.width * 0.05;

    return ListenableBuilder(
      listenable: _lang,
      builder: (context, _) {
        final user = FirebaseAuth.instance.currentUser;
        final name = _getUsername(user);
        final photo = user?.photoURL;

        // Responsive card dimensions
        final movieCardW = screen.width * 0.38;
        final movieCardH = movieCardW * 1.5; // 2:3 poster ratio
        final musicCardW = screen.width * 0.36;
        final musicCardH = musicCardW; // 1:1 square

        return Scaffold(
          backgroundColor: _bgColor,
          extendBody: true,
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ───────────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.fromLTRB(hPad, hPad, hPad, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi, $name 👋',
                                style: TextStyle(
                                  color: _textDark,
                                  fontSize: screen.width * 0.068,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _lang.translate('How are you feeling today?'),
                                style: TextStyle(
                                  color: _textGrey,
                                  fontSize: screen.width * 0.038,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            _iconCircle(Icons.notifications_outlined, screen),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                _slideRoute(const ProfileScreen()),
                              ),
                              child: CircleAvatar(
                                radius: screen.width * 0.05,
                                backgroundColor: _purple,
                                backgroundImage: photo != null
                                    ? NetworkImage(photo)
                                    : null,
                                child: photo == null
                                    ? Text(
                                        name.isNotEmpty
                                            ? name[0].toUpperCase()
                                            : 'U',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: screen.width * 0.04,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: screen.height * 0.022),

                  // ── Mood chips ─────────────────────────────────────────
                  SizedBox(
                    height: screen.height * 0.05,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: hPad),
                      itemCount: _moods.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, i) {
                        final mood = _moods[i];
                        final isSelected = _selectedMood == mood;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() => _selectedMood = mood);
                            _fetchData(mood);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(
                              horizontal: screen.width * 0.045,
                              vertical: screen.height * 0.008,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? _purple : _cardBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? _purple
                                    : Colors.grey.shade300,
                                width: 1.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: _purple.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Text(
                              _lang.translate(mood),
                              style: TextStyle(
                                color: isSelected ? Colors.white : _textDark,
                                fontSize: screen.width * 0.033,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: screen.height * 0.03),

                  // ── Movies For You ─────────────────────────────────────
                  _sectionHeader(
                    screen: screen,
                    hPad: hPad,
                    title: _lang.translate('Movies For You'),
                    onSeeAll: () => Navigator.push(
                      context,
                      _slideRoute(MoviesScreen(mood: _selectedMood)),
                    ),
                  ),
                  SizedBox(height: screen.height * 0.015),
                  SizedBox(
                    height: movieCardH + 36,
                    child: _loadingMovies
                        ? _skeletonRow(
                            count: 4,
                            cardW: movieCardW,
                            cardH: movieCardH,
                            hPad: hPad,
                          )
                        : _movies.isEmpty
                        ? _emptyState('No movies found')
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: hPad),
                            itemCount: _movies.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (_, i) =>
                                _movieCard(_movies[i], movieCardW, movieCardH),
                          ),
                  ),

                  SizedBox(height: screen.height * 0.03),

                  // ── Music For You ──────────────────────────────────────
                  _sectionHeader(
                    screen: screen,
                    hPad: hPad,
                    title: _lang.translate('Music For You'),
                    onSeeAll: () => Navigator.push(
                      context,
                      _slideRoute(MusicScreen(mood: _selectedMood)),
                    ),
                  ),
                  SizedBox(height: screen.height * 0.015),
                  SizedBox(
                    height: musicCardH + 48,
                    child: _loadingMusic
                        ? _skeletonRow(
                            count: 4,
                            cardW: musicCardW,
                            cardH: musicCardH,
                            hPad: hPad,
                          )
                        : _music.isEmpty
                        ? _emptyState('No music found')
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: hPad),
                            itemCount: _music.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (_, i) =>
                                _musicCard(_music[i], musicCardW, musicCardH),
                          ),
                  ),

                  SizedBox(height: screen.height * 0.03),
                ],
              ),
            ),
          ),
          bottomNavigationBar: _buildBottomNav(context, screen),
        );
      },
    );
  }

  // ── Movie card with gradient bg so title always visible ──────────────
  Widget _movieCard(Map<String, String> movie, double w, double h) {
    final poster = movie['poster'] ?? '';
    final title = movie['title'] ?? '';
    final rating = movie['rating'] ?? '';
    final year = movie['year'] ?? '';

    return GestureDetector(
      onTap: () =>
          Navigator.push(context, _slideRoute(MovieDetailScreen(movie: movie))),
      child: SizedBox(
        width: w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: w,
                height: h,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Gradient placeholder — always visible
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _purple.withValues(alpha: 0.35),
                            Colors.grey.shade400,
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.movie_outlined,
                        color: Colors.white54,
                        size: 36,
                      ),
                    ),
                    // Poster image
                    if (poster.isNotEmpty)
                      Image.network(
                        poster,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    // Rating + year overlay at bottom
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.75),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              rating,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              year,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: _textDark,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Music card ─────────────────────────────────────────────────────────
  Widget _musicCard(Map<String, String> song, double w, double h) {
    final cover = song['cover'] ?? '';
    final title = song['title'] ?? '';
    final artist = song['artist'] ?? '';

    return GestureDetector(
      onTap: () =>
          Navigator.push(context, _slideRoute(MusicPlayerScreen(song: song))),
      child: SizedBox(
        width: w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: w,
                height: h,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Gradient placeholder
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _purple.withValues(alpha: 0.5),
                            Colors.indigo.shade300,
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.music_note,
                        color: Colors.white70,
                        size: 30,
                      ),
                    ),
                    // Album art
                    if (cover.isNotEmpty)
                      Image.network(
                        cover,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: _textDark,
                fontSize: 12,
              ),
            ),
            Text(
              artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: _textGrey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  // ── Skeleton row ───────────────────────────────────────────────────────
  Widget _skeletonRow({
    required int count,
    required double cardW,
    required double cardH,
    required double hPad,
  }) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: hPad),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: cardW,
              height: cardH,
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: cardW * 0.65,
            height: 11,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconCircle(IconData icon, Size screen) => Container(
    width: screen.width * 0.1,
    height: screen.width * 0.1,
    decoration: BoxDecoration(
      color: _cardBg,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Icon(icon, color: _textDark, size: screen.width * 0.05),
  );

  Widget _sectionHeader({
    required Size screen,
    required double hPad,
    required String title,
    required VoidCallback onSeeAll,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: _textDark,
              fontSize: screen.width * 0.045,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              _lang.translate('See all'),
              style: TextStyle(
                color: _purple,
                fontSize: screen.width * 0.036,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String msg) => Center(
    child: Text(msg, style: const TextStyle(color: _textGrey, fontSize: 14)),
  );

  // ── Bottom nav ─────────────────────────────────────────────────────────
  Widget _buildBottomNav(BuildContext context, Size screen) {
    final systemNavHeight = MediaQuery.of(context).padding.bottom;
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.movie_outlined, 'label': 'Movies'},
      {'icon': Icons.chat_bubble_outline_rounded, 'label': 'Chat'},
      {'icon': Icons.music_note_outlined, 'label': 'Music'},
      {'icon': Icons.person_outline, 'label': 'Profile'},
    ];

    return Container(
      height: 72 + systemNavHeight + 12,
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(
        screen.width * 0.04,
        0,
        screen.width * 0.04,
        systemNavHeight + 8,
      ),
      child: Container(
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
                  if (i == 0) return;
                  if (i == 1)
                    Navigator.push(
                      context,
                      _slideRoute(MoviesScreen(mood: _selectedMood)),
                    );
                  else if (i == 2)
                    Navigator.push(context, _slideRoute(const ChatScreen()));
                  else if (i == 3)
                    Navigator.push(
                      context,
                      _slideRoute(MusicScreen(mood: _selectedMood)),
                    );
                  else if (i == 4)
                    Navigator.push(context, _slideRoute(const ProfileScreen()));
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? _navActive : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        items[i]['icon'] as IconData,
                        color: isActive ? _purple : Colors.white60,
                        size: screen.width * 0.055,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _lang.translate(items[i]['label'] as String),
                        style: TextStyle(
                          color: isActive ? _purple : Colors.white60,
                          fontSize: screen.width * 0.025,
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
      ),
    );
  }
}
