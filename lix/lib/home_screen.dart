import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'movies_screen.dart';
import 'music_screen.dart';
import 'profile_screen.dart';
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
  // ✅ Fixed: use singleton instead of new instance
  LanguageService get _lang => LanguageService.instance;

  int _selectedNav = 0;
  String _selectedMood = 'Happy';

  List<Map<String, dynamic>> _movies = [];
  List<Map<String, dynamic>> _music = [];
  bool _loadingMovies = true;
  bool _loadingMusic = true;

  static const Color _purple = Color(0xFF7C3AED);
  static const Color _bgColor = Color(0xFFF2F2F7);
  static const Color _cardBg = Color(0xFFFFFFFF);
  static const Color _textDark = Color(0xFF1C1C1E);
  static const Color _textGrey = Color(0xFF8E8E93);

  final List<Map<String, dynamic>> _moods = const [
    {'label': 'Happy'},
    {'label': 'Sad'},
    {'label': 'Anxious'},
    {'label': 'Bored'},
    {'label': 'Motivated'},
    {'label': 'Romantic'},
  ];

  @override
  void initState() {
    super.initState();
    // ✅ Fixed: delay fetch until after first frame to avoid frame skipping
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData(_selectedMood);
    });
  }

  Future<void> _fetchData(String mood) async {
    setState(() {
      _loadingMovies = true;
      _loadingMusic = true;
    });
    try {
      final movies = await TmdbService.getMoviesByMood(mood);
      if (mounted) {
        setState(() {
          _movies = movies;
          _loadingMovies = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingMovies = false);
    }
    try {
      final music = await MusicApiService.getSongsByMood(mood);
      if (mounted) {
        setState(() {
          _music = music;
          _loadingMusic = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingMusic = false);
    }
  }

  Route _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, animation, _) => page,
      transitionsBuilder: (_, animation, _, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  Map<String, String> _toStringMap(Map<String, dynamic> map) {
    return map.map((key, value) => MapEntry(key, value?.toString() ?? ''));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lang,
      builder: (context, _) {
        final user = FirebaseAuth.instance.currentUser;
        final name =
            (user?.displayName != null && user!.displayName!.isNotEmpty)
            ? user.displayName!.split(' ').first
            : 'there';
        final photo = user?.photoURL;

        return Scaffold(
          backgroundColor: _bgColor,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi, $name',
                              style: const TextStyle(
                                color: _textDark,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _lang.translate('How are you feeling today?'),
                              style: const TextStyle(
                                color: _textGrey,
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
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
                              child: const Icon(
                                Icons.notifications_outlined,
                                color: _textDark,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.push(
                                  context,
                                  _slideRoute(const ProfileScreen()),
                                );
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _purple,
                                  image: photo != null
                                      ? DecorationImage(
                                          image: NetworkImage(photo),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: photo == null
                                    ? Center(
                                        child: Text(
                                          name.isNotEmpty
                                              ? name[0].toUpperCase()
                                              : 'U',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
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

                  const SizedBox(height: 20),

                  // ── Mood Chips ───────────────────────────────
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _moods.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (ctx, i) {
                        final mood = _moods[i];
                        final isSelected = _selectedMood == mood['label'];
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(
                              () => _selectedMood = mood['label'] as String,
                            );
                            _fetchData(mood['label'] as String);
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
                              _lang.translate(mood['label'] as String),
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

                  const SizedBox(height: 28),

                  // ── Movies For You ───────────────────────────
                  _sectionHeader(
                    title: _lang.translate('Movies For You'),
                    onSeeAll: () => Navigator.push(
                      context,
                      _slideRoute(MoviesScreen(mood: _selectedMood)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 210,
                    child: _loadingMovies
                        ? _buildMovieSkeleton()
                        : _movies.isEmpty
                        ? _emptyState('No movies found')
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _movies.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 14),
                            itemBuilder: (ctx, i) => _MovieCard(
                              movie: _movies[i],
                              onTap: () => Navigator.push(
                                context,
                                _slideRoute(
                                  MovieDetailScreen(
                                    movie: _toStringMap(_movies[i]),
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),

                  const SizedBox(height: 28),

                  // ── Music For You ────────────────────────────
                  _sectionHeader(
                    title: _lang.translate('Music For You'),
                    onSeeAll: () => Navigator.push(
                      context,
                      _slideRoute(MusicScreen(mood: _selectedMood)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 180,
                    child: _loadingMusic
                        ? _buildMusicSkeleton()
                        : _music.isEmpty
                        ? _emptyState('No music found')
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _music.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 14),
                            itemBuilder: (ctx, i) => _MusicCard(
                              track: _music[i],
                              onTap: () => Navigator.push(
                                context,
                                _slideRoute(
                                  MusicPlayerScreen(
                                    song: _toStringMap(_music[i]),
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          bottomNavigationBar: _buildBottomNav(context),
        );
      },
    );
  }

  Widget _buildMovieSkeleton() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(width: 14),
      itemBuilder: (_, _) => ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: const SizedBox(width: 140, child: _ShimmerBox()),
      ),
    );
  }

  Widget _buildMusicSkeleton() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(width: 14),
      itemBuilder: (_, _) => ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: const SizedBox(width: 145, child: _ShimmerBox()),
      ),
    );
  }

  Widget _emptyState(String msg) {
    return Center(
      child: Text(msg, style: const TextStyle(color: _textGrey, fontSize: 14)),
    );
  }

  Widget _sectionHeader({
    required String title,
    required VoidCallback onSeeAll,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _textDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              _lang.translate('See all'),
              style: const TextStyle(
                color: _purple,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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
            color: Colors.black.withValues(alpha: 0.06),
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
                if (i == 1) {
                  Navigator.push(
                    context,
                    _slideRoute(MoviesScreen(mood: _selectedMood)),
                  );
                }
                if (i == 2) {
                  Navigator.push(
                    context,
                    _slideRoute(MusicScreen(mood: _selectedMood)),
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
                    _lang.translate(items[i]['label'] as String),
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
}

// ── Shimmer Box ────────────────────────────────────────────────
class _ShimmerBox extends StatefulWidget {
  const _ShimmerBox();
  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
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
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

// ── Movie Card ─────────────────────────────────────────────────
class _MovieCard extends StatelessWidget {
  final Map<String, dynamic> movie;
  final VoidCallback onTap;
  const _MovieCard({required this.movie, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final poster = movie['poster'] as String?;
    final title = movie['title'] as String? ?? '';
    final rating = movie['rating'] as String? ?? '';
    final year = movie['year'] as String? ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: poster != null && poster.isNotEmpty
                  ? Image.network(
                      poster,
                      width: 140,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _posterPlaceholder(),
                    )
                  : _posterPlaceholder(),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.85),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFD700),
                          size: 12,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          rating,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          year,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _posterPlaceholder() {
    return Container(
      width: 140,
      color: const Color(0xFF1A1A2E),
      child: const Center(
        child: Icon(
          Icons.movie_creation_outlined,
          color: Colors.white24,
          size: 40,
        ),
      ),
    );
  }
}

// ── Music Card ─────────────────────────────────────────────────
class _MusicCard extends StatelessWidget {
  final Map<String, dynamic> track;
  final VoidCallback onTap;
  const _MusicCard({required this.track, required this.onTap});

  static const Color _purple = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    final cover = track['cover'] as String?;
    final title = track['title'] as String? ?? '';
    final artist = track['artist'] as String? ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 145,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: cover != null && cover.isNotEmpty
                  ? Image.network(
                      cover,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _albumPlaceholder(),
                    )
                  : _albumPlaceholder(),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF1C1C1E),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              artist,
              style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: _purple,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _albumPlaceholder() {
    return Container(
      width: 56,
      height: 56,
      color: const Color(0xFF3D1A6E),
      child: const Icon(
        Icons.music_note_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}
