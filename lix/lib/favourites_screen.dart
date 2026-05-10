import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';
import 'favourites_service.dart';
import 'movie_detail_screen.dart';
import 'music_player_screen.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});
  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hPad = AppTheme.horizontalPadding(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.shimmerBase,
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: AppTheme.textPrimary,
              size: 16,
            ),
          ),
        ),
        title: Text(
          'My Favourites',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: AppTheme.bodyLarge(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Column(
            children: [
              Divider(height: 1, color: AppTheme.border),
              TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.primary,
                indicatorWeight: 3,
                labelColor: AppTheme.primary,
                unselectedLabelColor: AppTheme.textSecondary,
                labelStyle: TextStyle(
                  fontSize: AppTheme.bodyRegular(context),
                  fontWeight: FontWeight.bold,
                ),
                tabs: const [
                  Tab(text: '🎬  Movies'),
                  Tab(text: '🎵  Songs'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MoviesTab(hPad: hPad),
          _SongsTab(hPad: hPad),
        ],
      ),
    );
  }
}

// ── Movies Tab ────────────────────────────────────────────────
class _MoviesTab extends StatelessWidget {
  final double hPad;
  const _MoviesTab({required this.hPad});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, String>>>(
      stream: FavouritesService.moviesStream(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }

        final movies = snap.data ?? [];

        if (movies.isEmpty) {
          return _EmptyState(
            icon: Icons.movie_outlined,
            title: 'No favourite movies yet',
            subtitle: 'Tap ❤️ on any movie to save it here',
          );
        }

        return GridView.builder(
          padding: EdgeInsets.all(hPad),
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.62,
          ),
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            return _MovieFavCard(movie: movie);
          },
        );
      },
    );
  }
}

class _MovieFavCard extends StatelessWidget {
  final Map<String, String> movie;
  const _MovieFavCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    final hasPoster = (movie['poster'] ?? '').isNotEmpty;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
      ),
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _confirmRemove(context);
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
            // Poster
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusLG),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    hasPoster
                        ? Image.network(
                            movie['poster']!,
                            fit: BoxFit.cover,
                            // ✅ Fixed: distinct parameter names
                            errorBuilder: (ctx, err, stack) => _placeholder(),
                          )
                        : _placeholder(),
                    // Heart badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: Colors.red,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(8),
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
                  const SizedBox(height: 3),
                  Text(
                    '⭐ ${movie['rating']}  •  ${movie['year']}',
                    style: TextStyle(
                      color: AppTheme.warning,
                      fontSize: AppTheme.caption(context) - 1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

  void _confirmRemove(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXL),
        ),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.favorite_rounded, color: Colors.red, size: 40),
            const SizedBox(height: 12),
            Text(
              'Remove from Favourites?',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: AppTheme.bodyLarge(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              movie['title'] ?? '',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: AppTheme.bodyRegular(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.shimmerBase,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                      ),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: AppTheme.bodyRegular(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      final id = movie['id'] ?? movie['title'] ?? '';
                      await FavouritesService.removeMovie(id);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Remove',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: AppTheme.bodyRegular(context),
                          ),
                        ),
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
}

// ── Songs Tab ─────────────────────────────────────────────────
class _SongsTab extends StatelessWidget {
  final double hPad;
  const _SongsTab({required this.hPad});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, String>>>(
      stream: FavouritesService.songsStream(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }

        final songs = snap.data ?? [];

        if (songs.isEmpty) {
          return _EmptyState(
            icon: Icons.music_note_outlined,
            title: 'No favourite songs yet',
            subtitle: 'Tap ❤️ on any song to save it here',
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(hPad),
          physics: const BouncingScrollPhysics(),
          itemCount: songs.length,
          itemBuilder: (context, index) {
            return _SongFavCard(song: songs[index]);
          },
        );
      },
    );
  }
}

class _SongFavCard extends StatelessWidget {
  final Map<String, String> song;
  const _SongFavCard({required this.song});

  @override
  Widget build(BuildContext context) {
    final hasCover = (song['cover'] ?? '').isNotEmpty;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MusicPlayerScreen(song: song)),
      ),
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _confirmRemove(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          border: Border.all(color: AppTheme.border),
          boxShadow: AppTheme.shadowSM,
        ),
        child: Row(
          children: [
            // Cover
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              child: hasCover
                  ? Image.network(
                      song['cover']!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      // ✅ Fixed: distinct parameter names
                      errorBuilder: (ctx, err, stack) => _musicIcon(),
                    )
                  : _musicIcon(),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song['title'] ?? '',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: AppTheme.bodyRegular(context),
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    song['artist'] ?? '',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: AppTheme.caption(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if ((song['duration'] ?? '').isNotEmpty)
                    Text(
                      song['duration']!,
                      style: TextStyle(
                        color: AppTheme.primary.withValues(alpha: 0.7),
                        fontSize: AppTheme.caption(context) - 1,
                      ),
                    ),
                ],
              ),
            ),
            // Heart + Play
            Column(
              children: [
                GestureDetector(
                  onTap: () => _confirmRemove(context),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(
                  Icons.play_circle_outline,
                  color: AppTheme.primary,
                  size: 24,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _musicIcon() => Container(
    width: 56,
    height: 56,
    decoration: BoxDecoration(
      color: AppTheme.primary.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
    ),
    child: const Icon(Icons.music_note, color: AppTheme.primary, size: 26),
  );

  void _confirmRemove(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXL),
        ),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.favorite_rounded, color: Colors.red, size: 40),
            const SizedBox(height: 12),
            Text(
              'Remove from Favourites?',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: AppTheme.bodyLarge(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              song['title'] ?? '',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: AppTheme.bodyRegular(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.shimmerBase,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                      ),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: AppTheme.bodyRegular(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      final id = song['id'] ?? song['title'] ?? '';
                      await FavouritesService.removeSong(id);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Remove',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: AppTheme.bodyRegular(context),
                          ),
                        ),
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
}

// ── Empty State ───────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primary, size: 48),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: AppTheme.bodyLarge(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: AppTheme.bodyRegular(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
