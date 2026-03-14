import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tmdb_service.dart';
import 'movie_detail_screen.dart';
import 'app_theme.dart';

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

  final List<Map<String, dynamic>> _moods = const [
    {'label': 'Happy', 'emoji': '😊', 'color': AppTheme.moodHappy},
    {'label': 'Sad', 'emoji': '😢', 'color': AppTheme.moodSad},
    {'label': 'Anxious', 'emoji': '😰', 'color': AppTheme.moodAnxious},
    {'label': 'Bored', 'emoji': '😴', 'color': AppTheme.moodBored},
    {'label': 'Motivated', 'emoji': '💪', 'color': AppTheme.moodMotivated},
    {'label': 'Romantic', 'emoji': '😍', 'color': AppTheme.moodRomantic},
  ];

  @override
  void initState() {
    super.initState();
    _selectedMood = widget.mood;
    _fetchMovies(_selectedMood);
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

  @override
  Widget build(BuildContext context) {
    final hPad = AppTheme.horizontalPadding(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                        border: Border.all(color: AppTheme.border),
                        boxShadow: AppTheme.shadowSM,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 16,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Movies for You 🎬',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: AppTheme.heading2(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Mood: $_selectedMood',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: AppTheme.caption(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Mood Filter Chips ────────────────────────
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: hPad),
                itemCount: _moods.length,
                itemBuilder: (_, i) {
                  final m = _moods[i];
                  final selected = m['label'] == _selectedMood;
                  final color = m['color'] as Color;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _selectedMood = m['label']);
                      _fetchMovies(m['label']);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? color : AppTheme.surface,
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusFull,
                        ),
                        border: Border.all(
                          color: selected ? color : AppTheme.border,
                        ),
                        boxShadow: selected ? AppTheme.shadowSM : [],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            m['emoji'],
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            m['label'],
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : AppTheme.textSecondary,
                              fontSize: AppTheme.caption(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // ── Movie Grid ──────────────────────────────
            Expanded(
              child: _loading
                  ? _buildShimmer(hPad)
                  : _movies.isEmpty
                  ? _buildEmpty()
                  : GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.62,
                          ),
                      itemCount: _movies.length,
                      itemBuilder: (_, i) => _MovieCard(movie: _movies[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer(double hPad) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.62,
      ),
      itemCount: 6,
      itemBuilder: (_, _) => Container(
        decoration: BoxDecoration(
          color: AppTheme.shimmerBase,
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎬', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            'No movies found',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: AppTheme.bodyLarge(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try a different mood',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: AppTheme.bodyRegular(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Movie Card ───────────────────────────────────────────────
class _MovieCard extends StatelessWidget {
  final Map<String, String> movie;
  const _MovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    final hasPoster = movie['poster'] != null && movie['poster']!.isNotEmpty;

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
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          border: Border.all(color: AppTheme.border),
          boxShadow: AppTheme.shadowSM,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusLG),
                ),
                child: hasPoster
                    ? Image.network(
                        movie['poster']!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, _, _) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie['title'] ?? '',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: AppTheme.caption(context),
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: AppTheme.warning,
                        size: 13,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        movie['rating'] ?? '',
                        style: TextStyle(
                          color: AppTheme.warning,
                          fontSize: AppTheme.caption(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        movie['year'] ?? '',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: AppTheme.caption(context),
                        ),
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
    color: AppTheme.shimmerBase,
    child: const Center(
      child: Icon(
        Icons.movie_outlined,
        color: AppTheme.textSecondary,
        size: 32,
      ),
    ),
  );
}
