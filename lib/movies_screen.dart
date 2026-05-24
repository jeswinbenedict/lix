import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tmdb_service.dart';
import 'movie_detail_screen.dart';
import 'home_screen.dart';
import 'music_screen.dart';
import 'profile_screen.dart';
import 'chat_screen.dart';
import 'language_service.dart';

class MoviesScreen extends StatefulWidget {
  final String mood;
  const MoviesScreen({super.key, required this.mood});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  LanguageService get _lang => LanguageService.instance;

  List<Map<String, String>> _movies = [];
  bool _loading = true;
  String _selectedMood = '';
  int _selectedNav = 1;

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
    _selectedMood = widget.mood;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMovies(_selectedMood);
    });
  }

  Future<void> _fetchMovies(String mood) async {
    setState(() => _loading = true);
    final movies = await TmdbService.getMoviesByMood(mood);
    if (mounted) {
      setState(() {
        _movies = movies;
        _loading = false;
      });
    }
  }

  Route _slideRoute(Widget page) {
    return PageRouteBuilder(
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────────────
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
                      Text(
                        _lang.translate('Movies for You'),
                        style: const TextStyle(
                          color: _textDark,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _lang.translate('Based on your mood'),
                        style: const TextStyle(color: _textGrey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Mood chips ──────────────────────────────────────────────
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _moods.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final mood = _moods[i];
                  final isSelected = mood == _selectedMood;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _selectedMood = mood);
                      _fetchMovies(mood);
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
                                  color: _purple.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Text(
                        _lang.translate(mood),
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
            const SizedBox(height: 16),

            // ── Grid ────────────────────────────────────────────────────
            Expanded(
              child: _loading
                  ? _buildShimmer()
                  : _movies.isEmpty
                  ? _buildEmpty()
                  : GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.62,
                          ),
                      itemCount: _movies.length,
                      itemBuilder: (_, i) => _MovieCard(movie: _movies[i]),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildShimmer() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.62,
      ),
      itemCount: 6,
      itemBuilder: (_, _) => const _ShimmerCard(),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.movie_outlined, size: 56, color: _textGrey),
          const SizedBox(height: 12),
          Text(
            _lang.translate('No movies found'),
            style: const TextStyle(
              color: _textDark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _lang.translate('Try a different mood'),
            style: const TextStyle(color: _textGrey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
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
      padding: EdgeInsets.fromLTRB(16, 0, 16, systemNavHeight + 8),
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
                  if (i == 0) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      _slideRoute(const HomeScreen()),
                      (_) => false,
                    );
                  } else if (i == 1) {
                    return; // already here
                  } else if (i == 2) {
                    Navigator.push(context, _slideRoute(const ChatScreen()));
                  } else if (i == 3) {
                    Navigator.push(
                      context,
                      _slideRoute(MusicScreen(mood: _selectedMood)),
                    );
                  } else if (i == 4) {
                    Navigator.push(context, _slideRoute(const ProfileScreen()));
                  }
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
                        size: 22,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _lang.translate(items[i]['label'] as String),
                        style: TextStyle(
                          color: isActive ? _purple : Colors.white60,
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
      ),
    );
  }
}

// ── Shimmer card ──────────────────────────────────────────────────────────────
class _ShimmerCard extends StatefulWidget {
  const _ShimmerCard();
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
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

// ── Movie card ────────────────────────────────────────────────────────────────
class _MovieCard extends StatelessWidget {
  final Map<String, String> movie;
  const _MovieCard({required this.movie});

  static const Color _textDark = Color(0xFF1C1C1E);
  static const Color _textGrey = Color(0xFF8E8E93);

  @override
  Widget build(BuildContext context) {
    final poster = movie['poster'] ?? '';
    final title = movie['title'] ?? '';
    final rating = movie['rating'] ?? '';
    final year = movie['year'] ?? '';

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: poster.isNotEmpty
                    ? Image.network(
                        poster,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, _, _) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
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
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFD700),
                        size: 13,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        rating,
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        year,
                        style: const TextStyle(color: _textGrey, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: const Color(0xFF1A1A2E),
    child: const Center(
      child: Icon(Icons.movie_outlined, color: Colors.white24, size: 36),
    ),
  );
}
