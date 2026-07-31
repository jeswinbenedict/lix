import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/responsive.dart';
import '../services/tmdb_service.dart';
import '../services/language_service.dart';
import 'movie_detail_screen.dart';

class MoviesScreen extends StatefulWidget {
  final String mood;
  const MoviesScreen({super.key, this.mood = 'Happy'});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  LanguageService get _lang => LanguageService.instance;

  List<Map<String, String>> _movies = [];
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
      _fetchMovies(_selectedMood);
    });
  }

  Future<void> _fetchMovies(String mood) async {
    setState(() => _loading = true);
    try {
      final list = await TmdbService.getMoviesByMood(mood);
      if (mounted) {
        setState(() {
          _movies = list;
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
              const Icon(Icons.movie_outlined, color: AppTheme.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                _lang.translate("Movies"),
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
                    // Search box
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
                        decoration: InputDecoration(
                          hintText: _lang.translate("Search movies, genres..."),
                          hintStyle: TextStyle(color: AppTheme.textSecondary),
                          border: InputBorder.none,
                          icon: const Icon(Icons.search, color: AppTheme.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Mood Chips
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
                                  setState(() => _selectedMood = mood);
                                  _fetchMovies(mood);
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
                        maxCrossAxisExtent: 220,
                        mainAxisExtent: 310,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final movie = _movies[index];
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MovieDetailScreen(movie: movie),
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                                border: Border.all(color: AppTheme.border),
                                boxShadow: AppTheme.shadowSM,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(AppTheme.radiusMD),
                                      ),
                                      child: movie['poster'] != null && movie['poster']!.isNotEmpty
                                          ? Image.network(
                                              movie['poster']!,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                color: AppTheme.shimmerBase,
                                                child: const Icon(Icons.movie, size: 40, color: AppTheme.primary),
                                              ),
                                            )
                                          : Container(
                                              color: AppTheme.shimmerBase,
                                              child: const Icon(Icons.movie, size: 40, color: AppTheme.primary),
                                            ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          movie['title'] ?? 'Movie',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '⭐ ${movie['rating']}',
                                              style: const TextStyle(
                                                color: AppTheme.warning,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              movie['year'] ?? '',
                                              style: TextStyle(
                                                color: AppTheme.textSecondary,
                                                fontSize: 12,
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
                        },
                        childCount: _movies.length,
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
