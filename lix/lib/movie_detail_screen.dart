import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'tmdb_service.dart';
import 'app_theme.dart';
import 'favourites_service.dart';
import 'history_service.dart'; // ✅ NEW

class MovieDetailScreen extends StatefulWidget {
  final Map<String, String> movie;
  const MovieDetailScreen({super.key, required this.movie});
  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool _isLiked = false;
  bool _likeLoading = false;
  bool _inWatchlist = false;
  List<Map<String, String>> _similarMovies = [];
  bool _loadingSimilar = true;
  bool _trailerLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSimilarMovies();
    _checkFav();
    HistoryService.addMovieHistory(widget.movie); // ✅ NEW — save to history
  }

  Future<void> _checkFav() async {
    final id = widget.movie['id'] ?? widget.movie['title'] ?? '';
    final fav = await FavouritesService.isMovieFav(id);
    if (mounted) setState(() => _isLiked = fav);
  }

  Future<void> _loadSimilarMovies() async {
    final genre = widget.movie['genre'] ?? 'Happy';
    final movies = await TmdbService.getMoviesByMood(genre);
    if (mounted) {
      setState(() {
        _similarMovies = movies
            .where((m) => m['title'] != widget.movie['title'])
            .take(10)
            .toList();
        _loadingSimilar = false;
      });
    }
  }

  Future<void> _toggleFav() async {
    HapticFeedback.lightImpact();
    setState(() => _likeLoading = true);
    final added = await FavouritesService.toggleMovie(widget.movie);
    if (mounted) {
      setState(() {
        _isLiked = added;
        _likeLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            added ? '❤️ Added to Favourites' : '💔 Removed from Favourites',
          ),
          backgroundColor: added ? Colors.red : AppTheme.textSecondary,
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          ),
        ),
      );
    }
  }

  Future<void> _openTrailer() async {
    final title = widget.movie['title'] ?? '';
    final year = widget.movie['year'] ?? '';
    final query = Uri.encodeComponent('$title $year official trailer');
    final ytUrl = Uri.parse(
      'https://www.youtube.com/results?search_query=$query',
    );
    setState(() => _trailerLoading = true);
    try {
      if (await canLaunchUrl(ytUrl)) {
        await launchUrl(ytUrl, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Could not open YouTube'),
              backgroundColor: AppTheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              ),
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _trailerLoading = false);
    }
  }

  List<Widget> _buildStars(String ratingStr) {
    final rating = double.tryParse(ratingStr) ?? 0;
    final stars = (rating / 2).round().clamp(0, 5);
    return List.generate(
      5,
      (i) => Icon(
        i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
        color: AppTheme.warning,
        size: 18,
      ),
    );
  }

  Widget _infoChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: AppTheme.caption(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    final hPad = AppTheme.horizontalPadding(context);
    final rating = movie['rating'] ?? '0';
    final hasPoster = movie['poster'] != null && movie['poster']!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Collapsible Header ───────────────────────────
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.45,
            pinned: true,
            backgroundColor: AppTheme.surface,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
            actions: [
              // Watchlist
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _inWatchlist = !_inWatchlist);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _inWatchlist
                            ? '✅ Added to Watchlist'
                            : 'Removed from Watchlist',
                      ),
                      backgroundColor: AppTheme.primary,
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _inWatchlist
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: _inWatchlist ? AppTheme.warning : Colors.white,
                    size: 20,
                  ),
                ),
              ),
              // Like — saves to Firebase
              GestureDetector(
                onTap: _likeLoading ? null : _toggleFav,
                child: Container(
                  margin: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: _likeLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          _isLiked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: _isLiked ? Colors.redAccent : Colors.white,
                          size: 20,
                        ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  hasPoster
                      ? Image.network(
                          movie['poster']!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _posterPlaceholder(),
                        )
                      : _posterPlaceholder(),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppTheme.background.withOpacity(0.9),
                            AppTheme.background,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 60,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppTheme.warning,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const Text(
                            '/10',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
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

          // ── Content ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie['title'] ?? '',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: AppTheme.heading1(context),
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ..._buildStars(rating),
                      const SizedBox(width: 8),
                      Text(
                        '$rating / 10',
                        style: TextStyle(
                          color: AppTheme.warning,
                          fontSize: AppTheme.bodyRegular(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (movie['year'] != null && movie['year']!.isNotEmpty)
                        _infoChip(
                          movie['year']!,
                          Icons.calendar_today_rounded,
                          AppTheme.primary,
                        ),
                      if (movie['genre'] != null && movie['genre']!.isNotEmpty)
                        _infoChip(
                          movie['genre']!,
                          Icons.local_movies_rounded,
                          AppTheme.secondary,
                        ),
                      _infoChip(
                        'HD Quality',
                        Icons.hd_rounded,
                        AppTheme.moodMotivated,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Watch Trailer Button
                  GestureDetector(
                    onTap: _trailerLoading
                        ? null
                        : () {
                            HapticFeedback.mediumImpact();
                            _openTrailer();
                          },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF0000), Color(0xFFCC0000)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF0000).withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_trailerLoading)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          else ...[
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.play_arrow_rounded,
                                  color: Color(0xFFFF0000),
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Watch Trailer on YouTube',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: AppTheme.bodyLarge(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Divider(color: AppTheme.border),
                  const SizedBox(height: 16),

                  Text(
                    'Synopsis',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: AppTheme.heading2(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    movie['desc'] != null && movie['desc']!.isNotEmpty
                        ? movie['desc']!
                        : 'No description available for this movie.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: AppTheme.bodyRegular(context),
                      height: 1.7,
                    ),
                  ),

                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                      border: Border.all(color: AppTheme.border),
                      boxShadow: AppTheme.shadowSM,
                    ),
                    child: Column(
                      children: [
                        _detailRow(
                          Icons.calendar_month_rounded,
                          'Release Year',
                          movie['year'] ?? 'N/A',
                        ),
                        Divider(height: 20, color: AppTheme.border),
                        _detailRow(
                          Icons.star_rounded,
                          'TMDB Rating',
                          '$rating / 10',
                        ),
                        Divider(height: 20, color: AppTheme.border),
                        _detailRow(
                          Icons.category_rounded,
                          'Genre',
                          movie['genre'] ?? 'N/A',
                        ),
                        Divider(height: 20, color: AppTheme.border),
                        _detailRow(
                          Icons.language_rounded,
                          'Source',
                          'TMDB Database',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),
                  Text(
                    'Similar Movies',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: AppTheme.heading2(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // ── Similar Movies ───────────────────────────────
          SliverToBoxAdapter(
            child: _loadingSimilar
                ? SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: hPad),
                      itemCount: 5,
                      itemBuilder: (_, _) => Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.shimmerBase,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMD,
                          ),
                        ),
                      ),
                    ),
                  )
                : SizedBox(
                    height: 245,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: hPad),
                      itemCount: _similarMovies.length,
                      itemBuilder: (_, i) {
                        final m = _similarMovies[i];
                        final hasCover =
                            m['poster'] != null && m['poster']!.isNotEmpty;
                        return GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MovieDetailScreen(movie: m),
                            ),
                          ),
                          child: Container(
                            width: 120,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusMD,
                              ),
                              border: Border.all(color: AppTheme.border),
                              boxShadow: AppTheme.shadowSM,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(AppTheme.radiusMD),
                                  ),
                                  child: AspectRatio(
                                    aspectRatio: 2 / 3,
                                    child: hasCover
                                        ? Image.network(
                                            m['poster']!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, _, _) =>
                                                _miniPlaceholder(),
                                          )
                                        : _miniPlaceholder(),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        m['title'] ?? '',
                                        style: TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontSize: AppTheme.caption(context),
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star_rounded,
                                            color: AppTheme.warning,
                                            size: 11,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            m['rating'] ?? '',
                                            style: TextStyle(
                                              color: AppTheme.warning,
                                              fontSize:
                                                  AppTheme.caption(context) - 1,
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
                    ),
                  ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 16),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: AppTheme.bodyRegular(context),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: AppTheme.bodyRegular(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _posterPlaceholder() => Container(
    color: AppTheme.shimmerBase,
    child: const Center(
      child: Icon(
        Icons.movie_outlined,
        color: AppTheme.textSecondary,
        size: 60,
      ),
    ),
  );

  Widget _miniPlaceholder() => Container(
    color: AppTheme.shimmerBase,
    child: const Center(
      child: Icon(
        Icons.movie_outlined,
        color: AppTheme.textSecondary,
        size: 24,
      ),
    ),
  );
}
