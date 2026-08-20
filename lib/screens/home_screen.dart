import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/app_theme.dart';
import '../core/responsive.dart';
import '../widgets/adaptive_scaffold.dart';
import '../widgets/offline_banner.dart';
import '../widgets/shimmer_skeleton.dart';
import '../services/language_service.dart';
import '../services/tmdb_service.dart';
import '../services/music_api_service.dart';
import '../services/global_audio_service.dart';
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
  List<Map<String, String>> _trendingMovies = [];
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
      final trending = await TmdbService.getTrending();
      if (mounted) {
        setState(() {
          _trendingMovies = trending;
        });
      }
    } catch (e) {
      debugPrint('Trending error: $e');
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

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: () => _fetchData(_selectedMood),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          const SliverToBoxAdapter(child: OfflineBanner()),
          SliverToBoxAdapter(
            child: CenteredContent(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Header Greeting Banner
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_lang.translate("Hey")}, $userName 👋',
                            style: TextStyle(
                              fontSize: AppTheme.heading1(context),
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _lang.translate("How are you feeling right now?"),
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: AppTheme.shadowPrimary,
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: AppTheme.primaryLight,
                            child: Text(
                              userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Mood Selector Horizontal List
                  SizedBox(
                    height: 48,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _moods.length,
                      itemBuilder: (context, index) {
                        final mood = _moods[index];
                        final isSelected = mood == _selectedMood;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: FilterChip(
                            label: Text(_lang.translate(mood)),
                            selected: isSelected,
                            selectedColor: AppTheme.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 14,
                            ),
                            backgroundColor: Theme.of(context).colorScheme.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                              side: BorderSide(
                                color: isSelected ? AppTheme.primary : Theme.of(context).dividerColor.withAlpha(40),
                              ),
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                HapticFeedback.selectionClick();
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

                  // Section Title: Trending Movies
                  if (_trendingMovies.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.local_fire_department_rounded, color: Color(0xFFEF4444), size: 22),
                            const SizedBox(width: 8),
                            Text(
                              _lang.translate("Trending Now"),
                              style: TextStyle(
                                fontSize: AppTheme.heading3(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () => setState(() => _selectedNav = 1),
                          child: Text(_lang.translate("See All"), style: const TextStyle(color: AppTheme.primary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _trendingMovies.length,
                        itemBuilder: (context, idx) {
                          final m = _trendingMovies[idx];
                          return Padding(
                            padding: const EdgeInsets.only(right: 14.0),
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: m)),
                              ),
                              child: Container(
                                width: 130,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                                  boxShadow: AppTheme.shadowSM,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      (m['poster'] ?? '').isNotEmpty
                                          ? Image.network(m['poster']!, fit: BoxFit.cover)
                                          : Container(color: AppTheme.shimmerBase),
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                              colors: [
                                                Colors.black.withAlpha(200),
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                          child: Text(
                                            m['title'] ?? '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],

                  // Section Title: Mood Movies
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.movie_outlined, color: AppTheme.primary, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            _lang.translate("Movies for your mood"),
                            style: TextStyle(
                              fontSize: AppTheme.heading3(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => setState(() => _selectedNav = 1),
                        child: Text(_lang.translate("See All"), style: const TextStyle(color: AppTheme.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Mood Movies Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: _loadingMovies
                ? buildMovieShimmerGrid()
                : SliverGrid(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
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
                              border: Border.all(color: Theme.of(context).dividerColor.withAlpha(40)),
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
                                        ? Hero(
                                            tag: 'movie_poster_${movie['title']}',
                                            child: Image.network(
                                              movie['poster']!,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                color: AppTheme.shimmerBase,
                                                child: const Icon(Icons.movie, size: 40, color: AppTheme.primary),
                                              ),
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
                                            style: const TextStyle(
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

          // Section Title: Music Tracks
          SliverToBoxAdapter(
            child: CenteredContent(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 36),
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

          // Music Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: _loadingMusic
                ? buildSongShimmerGrid()
                : SliverGrid(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 320,
                      mainAxisExtent: 90,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final song = _music[index];
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            GlobalAudioService.instance.playSong(song, playlist: _music);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MusicPlayerScreen(
                                  song: song,
                                  playlist: _music,
                                  currentIndex: index,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                              boxShadow: AppTheme.shadowSM,
                              border: Border.all(color: Theme.of(context).dividerColor.withAlpha(40)),
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        song['title'] ?? 'Song',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        song['artist'] ?? 'Artist',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.play_circle_fill_rounded, color: AppTheme.primary, size: 28),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: _music.length,
                    ),
                  ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lang,
      builder: (context, _) => AdaptiveScaffold(
        selectedIndex: _selectedNav,
        onDestinationSelected: (index) {
          setState(() => _selectedNav = index);
        },
        destinations: [
          AdaptiveDestination(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
            label: _lang.translate("Home"),
          ),
          AdaptiveDestination(
            icon: Icons.movie_outlined,
            selectedIcon: Icons.movie_rounded,
            label: _lang.translate("Movies"),
          ),
          AdaptiveDestination(
            icon: Icons.music_note_outlined,
            selectedIcon: Icons.music_note_rounded,
            label: _lang.translate("Music"),
          ),
          AdaptiveDestination(
            icon: Icons.chat_bubble_outline_rounded,
            selectedIcon: Icons.chat_bubble_rounded,
            label: _lang.translate("AI Chat"),
          ),
          AdaptiveDestination(
            icon: Icons.person_outline_rounded,
            selectedIcon: Icons.person_rounded,
            label: _lang.translate("Profile"),
          ),
        ],
        body: IndexedStack(
          index: _selectedNav,
          children: [
            _buildHomeFeed(),
            MoviesScreen(mood: _selectedMood),
            MusicScreen(mood: _selectedMood),
            const ChatScreen(),
            const ProfileScreen(),
          ],
        ),
      ),
    );
  }
}
