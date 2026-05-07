import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tmdb_service.dart';
import 'movie_detail_screen.dart';
import 'home_screen.dart';
import 'music_screen.dart';
import 'profile_screen.dart';

class MoviesScreen extends StatefulWidget {
  final String mood;
  const MoviesScreen({super.key, required this.mood});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  List<Map<String, String>> _movies = [];
  bool _loading = true;
  String _selectedMood = '';
  int _selectedNav = 1;

  static const Color _purple = Color(0xFF7C3AED);
  static const Color _bgColor = Color(0xFFF2F2F7);
  static const Color _cardBg = Color(0xFFFFFFFF);
  static const Color _textDark = Color(0xFF1C1C1E);
  static const Color _textGrey = Color(0xFF8E8E93);

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
      pageBuilder: (_, animation, __) => page, // ✅ Fixed: __ not _
      transitionsBuilder: (_, animation, __, child) => SlideTransition(
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
                        'Movies for You',
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

            const SizedBox(height: 16),

            // ── Movie Grid ───────────────────────────────
            Expanded(
              child: _loading
                  ? _buildShimmer()
                  : _movies.isEmpty
                  ? _buildEmpty()
                  : GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
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
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.62,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => const _ShimmerCard(), // ✅ Fixed
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.movie_outlined, size: 56, color: Color(0xFF8E8E93)),
          SizedBox(height: 12),
          Text(
            'No movies found',
            style: TextStyle(
              color: Color(0xFF1C1C1E),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Try a different mood',
            style: TextStyle(color: Color(0xFF8E8E93), fontSize: 14),
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
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

// ── Movie Card ────────────────────────────────────────────────
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
              color: Colors.black.withOpacity(0.06),
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
                        errorBuilder: (ctx, err, stack) =>
                            _placeholder(), // ✅ Fixed
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

  Widget _placeholder() {
    return Container(
      color: const Color(0xFF1A1A2E),
      child: const Center(
        child: Icon(Icons.movie_outlined, color: Colors.white24, size: 36),
      ),
    );
  }
}
