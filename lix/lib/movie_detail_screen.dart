import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'tmdb_service.dart';
import 'favourites_service.dart';
import 'history_service.dart';

class MovieDetailScreen extends StatefulWidget {
  final Map<String, String> movie;
  const MovieDetailScreen({super.key, required this.movie});
  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  static const Color _purple = Color(0xFF7C3AED);
  static const Color _bgColor = Color(0xFFF2F2F7);
  static const Color _cardBg = Color(0xFFFFFFFF);
  static const Color _textDark = Color(0xFF1C1C1E);
  static const Color _textGrey = Color(0xFF8E8E93);
  static const Color _gold = Color(0xFFFFD700);
  static const Color _red = Color(0xFFFF0000);

  bool _isLiked = false;
  bool _likeLoading = false;
  bool _inWatchlist = false;
  bool _trailerLoading = false;
  List<Map<String, String>> _similarMovies = [];
  bool _loadingSimilar = true;

  @override
  void initState() {
    super.initState();
    _loadSimilarMovies();
    _checkFav();
    HistoryService.addMovieHistory(widget.movie);
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
            .map((m) => Map<String, String>.from(m))
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
          backgroundColor: added ? Colors.redAccent : _textGrey,
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
        color: _gold,
        size: 18,
      ),
    );
  }

  Widget _infoChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
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
              fontSize: 12,
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
    final rating = movie['rating'] ?? '0';
    final poster = movie['poster'] ?? '';
    final hasPoster = poster.isNotEmpty;

    return Scaffold(
      backgroundColor: _bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Collapsible Poster Header ─────────────────────
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.45,
            pinned: true,
            backgroundColor: _cardBg,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
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
                      backgroundColor: _purple,
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
                    color: _inWatchlist ? _gold : Colors.white,
                    size: 20,
                  ),
                ),
              ),
              // Favourite
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
                  // Poster image
                  hasPoster
                      ? Image.network(
                          poster,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _posterPlaceholder(),
                        )
                      : _posterPlaceholder(),
                  // Bottom fade into bg
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
                            _bgColor.withOpacity(0.85),
                            _bgColor,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Rating badge
                  Positioned(
                    top: 60,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: _gold,
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

          // ── Body Content ────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    movie['title'] ?? '',
                    style: const TextStyle(
                      color: _textDark,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Stars + rating
                  Row(
                    children: [
                      ..._buildStars(rating),
                      const SizedBox(width: 8),
                      Text(
                        '$rating / 10',
                        style: const TextStyle(
                          color: _gold,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Info chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if ((movie['year'] ?? '').isNotEmpty)
                        _infoChip(
                          movie['year']!,
                          Icons.calendar_today_rounded,
                          _purple,
                        ),
                      if ((movie['genre'] ?? '').isNotEmpty)
                        _infoChip(
                          movie['genre']!,
                          Icons.local_movies_rounded,
                          Colors.teal,
                        ),
                      _infoChip('HD Quality', Icons.hd_rounded, Colors.green),
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
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: _red.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _trailerLoading
                            ? [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              ]
                            : [
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
                                      color: _red,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Watch Trailer on YouTube',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Divider(color: Colors.grey.shade200),
                  const SizedBox(height: 16),

                  // Synopsis
                  const Text(
                    'Synopsis',
                    style: TextStyle(
                      color: _textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    (movie['desc'] != null && movie['desc']!.isNotEmpty)
                        ? movie['desc']!
                        : 'No description available for this movie.',
                    style: const TextStyle(
                      color: _textGrey,
                      fontSize: 14,
                      height: 1.7,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Details card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _detailRow(
                          Icons.calendar_month_rounded,
                          'Release Year',
                          movie['year'] ?? 'N/A',
                        ),
                        Divider(height: 20, color: Colors.grey.shade100),
                        _detailRow(
                          Icons.star_rounded,
                          'TMDB Rating',
                          '$rating / 10',
                        ),
                        Divider(height: 20, color: Colors.grey.shade100),
                        _detailRow(
                          Icons.category_rounded,
                          'Genre',
                          movie['genre'] ?? 'N/A',
                        ),
                        Divider(height: 20, color: Colors.grey.shade100),
                        _detailRow(
                          Icons.language_rounded,
                          'Source',
                          'TMDB Database',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Similar Movies header
                  const Text(
                    'Similar Movies',
                    style: TextStyle(
                      color: _textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // ── Similar Movies Horizontal List ───────────────
          SliverToBoxAdapter(
            child: _loadingSimilar
                ? SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: 5,
                      itemBuilder: (_, __) => _SimilarShimmer(),
                    ),
                  )
                : SizedBox(
                    height: 245,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _similarMovies.length,
                      itemBuilder: (_, i) {
                        final m = _similarMovies[i];
                        final hasCover = (m['poster'] ?? '').isNotEmpty;
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
                              color: _cardBg,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(14),
                                  ),
                                  child: AspectRatio(
                                    aspectRatio: 2 / 3,
                                    child: hasCover
                                        ? Image.network(
                                            m['poster']!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
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
                                        style: const TextStyle(
                                          color: _textDark,
                                          fontSize: 11,
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
                                            color: _gold,
                                            size: 11,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            m['rating'] ?? '',
                                            style: const TextStyle(
                                              color: _gold,
                                              fontSize: 10,
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
            color: _purple.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: _purple, size: 16),
        ),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: _textGrey, fontSize: 14)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: _textDark,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _posterPlaceholder() => Container(
    color: const Color(0xFF1A1A2E),
    child: const Center(
      child: Icon(Icons.movie_outlined, color: Colors.white24, size: 60),
    ),
  );

  Widget _miniPlaceholder() => Container(
    color: const Color(0xFF1A1A2E),
    child: const Center(
      child: Icon(Icons.movie_outlined, color: Colors.white24, size: 24),
    ),
  );
}

// ── Similar Movie Shimmer ─────────────────────────────────────
class _SimilarShimmer extends StatefulWidget {
  @override
  State<_SimilarShimmer> createState() => _SimilarShimmerState();
}

class _SimilarShimmerState extends State<_SimilarShimmer>
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
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
