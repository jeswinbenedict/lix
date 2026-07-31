import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/responsive.dart';
import '../services/favourites_service.dart';
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
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary, size: 18),
        ),
        title: const Text(
          'My Favourites',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
          tabs: const [
            Tab(icon: Icon(Icons.movie_outlined), text: 'Movies'),
            Tab(icon: Icon(Icons.music_note_outlined), text: 'Songs'),
          ],
        ),
      ),
      body: CenteredContent(
        maxWidth: 900,
        child: TabBarView(
          controller: _tabController,
          children: [
            // Movies Tab
            StreamBuilder<List<Map<String, String>>>(
              stream: FavouritesService.moviesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final movies = snapshot.data ?? [];
                if (movies.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border, size: 48, color: AppTheme.textSecondary),
                        SizedBox(height: 12),
                        Text('No favourite movies added yet', style: TextStyle(color: AppTheme.textSecondary)),
                      ],
                    ),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    mainAxisExtent: 290,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusMD)),
                                child: (movie['poster'] ?? '').isNotEmpty
                                    ? Image.network(movie['poster']!, fit: BoxFit.cover, width: double.infinity)
                                    : Container(color: AppTheme.shimmerBase, child: const Icon(Icons.movie)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(movie['title'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            // Songs Tab
            StreamBuilder<List<Map<String, String>>>(
              stream: FavouritesService.songsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final songs = snapshot.data ?? [];
                if (songs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.music_off_outlined, size: 48, color: AppTheme.textSecondary),
                        SizedBox(height: 12),
                        Text('No favourite songs added yet', style: TextStyle(color: AppTheme.textSecondary)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    return ListTile(
                      leading: (song['cover'] ?? '').isNotEmpty
                          ? Image.network(song['cover']!, width: 48, height: 48, fit: BoxFit.cover)
                          : const Icon(Icons.music_note),
                      title: Text(song['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(song['artist'] ?? ''),
                      trailing: const Icon(Icons.play_circle_fill, color: AppTheme.primary),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MusicPlayerScreen(song: song)),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
