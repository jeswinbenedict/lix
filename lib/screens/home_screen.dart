import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/app_theme.dart';
import '../core/responsive.dart';
import '../widgets/adaptive_scaffold.dart';
import '../services/language_service.dart';
import '../services/tmdb_service.dart';
import '../services/music_api_service.dart';
import 'chat_screen.dart';
import 'movies_screen.dart';
import 'music_screen.dart';
import 'profile_screen.dart';
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
      if (mounted) {
        setState(() {
          _movies = movies;
          _loadingMovies = false;
        });
      }
    } catch (e) {
      debugPrint('Movie error: $e');
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
    } catch (e) {
      debugPrint('Music error: $e');
      if (mounted) setState(() => _loadingMusic = false);
    }
  }

  Widget _buildHomeFeed() {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName?.split(' ').first ?? 'Friend';

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: CenteredContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Header Banner
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, $userName',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: AppTheme.heading2(context),
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _lang.translate("Select a mood category to filter recommendations"),
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: AppTheme.bodyRegular(context),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.search_rounded, color: AppTheme.primary, size: 26),
                      onPressed: () {
                        setState(() => _selectedNav = 1);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Mood Selector Carousel
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _moods.length,
                    itemBuilder: (context, index) {
                      final mood = _moods[index];
                      final isSelected = mood == _selectedMood;
                      return Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(
                            _lang.translate(mood),
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppTheme.textPrimary,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                          selectedColor: AppTheme.primary,
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          shape: StadiumBorder(
                            side: BorderSide(
                              color: isSelected ? AppTheme.primary : AppTheme.border,
                            ),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedMood = mood);
                              _fetchData(mood);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 28),
                // AI Assistant Teaser Banner
                GestureDetector(
                  onTap: () => setState(() => _selectedNav = 1),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                      boxShadow: AppTheme.shadowPrimary,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(45),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 26),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Lix AI Assistant",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Intelligent media recommendations and natural conversation",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Section Title: Movie Picks
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.movie_outlined, color: AppTheme.primary, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          _lang.translate("Recommended Movies"),
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: AppTheme.heading3(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => setState(() => _selectedNav = 2),
                      child: Text(_lang.translate("See All"), style: const TextStyle(color: AppTheme.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        // Movie Grid / List
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: _loadingMovies
              ? const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(30.0),
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    ),
                  ),
                )
              : SliverGrid(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    mainAxisExtent: 290,
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
                            boxShadow: AppTheme.shadowSM,
                            border: Border.all(color: AppTheme.border),
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
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${movie['rating']} • ${movie['year']}',
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
        SliverToBoxAdapter(
          child: CenteredContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 36),
                // Section Title: Music Tracks
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.music_note_outlined, color: AppTheme.primary, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          _lang.translate("Music for your mood"),
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: AppTheme.heading3(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => setState(() => _selectedNav = 3),
                      child: Text(_lang.translate("See All"), style: const TextStyle(color: AppTheme.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        // Music Grid / List
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: _loadingMusic
              ? const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(30.0),
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    ),
                  ),
                )
              : SliverGrid(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 280,
                    mainAxisExtent: 90,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final song = _music[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MusicPlayerScreen(
                              song: song,
                              playlist: _music,
                              currentIndex: index,
                            ),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                            boxShadow: AppTheme.shadowSM,
                            border: Border.all(color: AppTheme.border),
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
                                      song['title'] ?? 'Track',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      song['artist'] ?? 'Artist',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.play_circle_fill, color: AppTheme.primary, size: 32),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: _music.length,
                  ),
                ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 40),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeFeed(),
      const ChatScreen(),
      const MoviesScreen(),
      const MusicScreen(),
      const ProfileScreen(),
    ];

    return ListenableBuilder(
      listenable: _lang,
      builder: (context, _) {
        return AdaptiveScaffold(
          selectedIndex: _selectedNav,
          onDestinationSelected: (index) => setState(() => _selectedNav = index),
          destinations: [
            AdaptiveDestination(
              label: _lang.translate("Home"),
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
            ),
            AdaptiveDestination(
              label: _lang.translate("Chat AI"),
              icon: Icons.chat_bubble_outline,
              selectedIcon: Icons.chat_bubble,
            ),
            AdaptiveDestination(
              label: _lang.translate("Movies"),
              icon: Icons.movie_outlined,
              selectedIcon: Icons.movie,
            ),
            AdaptiveDestination(
              label: _lang.translate("Music"),
              icon: Icons.music_note_outlined,
              selectedIcon: Icons.music_note,
            ),
            AdaptiveDestination(
              label: _lang.translate("Profile"),
              icon: Icons.person_outline,
              selectedIcon: Icons.person,
            ),
          ],
          body: IndexedStack(
            index: _selectedNav,
            children: pages,
          ),
        );
      },
    );
  }
}
