import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_theme.dart';
import '../services/tmdb_service.dart';
import '../services/favourites_service.dart';
import '../services/history_service.dart';
import '../services/imdb_service.dart';

class MovieDetailScreen extends StatefulWidget {
  final Map<String, String> movie;
  const MovieDetailScreen({super.key, required this.movie});
  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  static const Color _purple = AppTheme.primary;
  static const Color _bgColor = AppTheme.background;
  static const Color _cardBg = AppTheme.surface;
  static const Color _textDark = AppTheme.textPrimary;
  static const Color _textGrey = AppTheme.textSecondary;
  static const Color _gold = AppTheme.warning;

  bool _isLiked = false;
  bool _likeLoading = false;
  bool _inWatchlist = false;
  bool _trailerLoading = false;
  List<Map<String, String>> _similarMovies = [];
  bool _loadingSimilar = true;
  Map<String, String> _imdbData = {};
  bool _loadingImdb = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSimilarMovies();
      _checkFav();
      _loadImdbData();
      HistoryService.addMovieHistory(widget.movie);
    });
  }

  Future<void> _loadImdbData() async {
    final title = widget.movie['title'] ?? '';
    final year = widget.movie['year'];
    final data = await ImdbService.getMovieImdbData(title, year: year);
    if (mounted) {
      setState(() {
        _imdbData = data;
        _loadingImdb = false;
      });
    }
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
            .map((m) => m.map((k, v) => MapEntry(k.toString(), v.toString())))
            .toList();
        _loadingSimilar = false;
      });
    }
  }

  Future<void> _toggleFav() async {
    HapticFeedback.lightImpact();
    if (mounted) setState(() => _likeLoading = true);
    final added = await FavouritesService.toggleMovie(widget.movie);
    if (mounted) {
      setState(() {
        _isLiked = added;
        _likeLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            added ? 'Added to Favourites' : 'Removed from Favourites',
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
    if (mounted) setState(() => _trailerLoading = true);
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
    } catch (e) {
      debugPrint('Trailer launch error: $e');
    } finally {
      if (mounted) setState(() => _trailerLoading = false);
    }
  }

  Future<void> _openImdbUrl() async {
    final title = widget.movie['title'] ?? '';
    final urlStr = _imdbData['imdbUrl'] ??
        'https://www.imdb.com/find/?q=${Uri.encodeComponent(title)}';
    final url = Uri.parse(urlStr);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('IMDb url launch error: $e');
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.45,
            pinned: true,
            backgroundColor: _cardBg,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
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
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  final title = widget.movie['title'] ?? 'Movie';
                  final year = widget.movie['year'] ?? '';
                  final rating = widget.movie['rating'] ?? '';
                  final imdbUrl = _imdbData['imdbUrl'] ?? '';
                  final text = imdbUrl.isNotEmpty
                      ? '🎬 Check out "$title" ($year) ⭐ $rating/10 on Lix!\n$imdbUrl'
                      : '🎬 Check out "$title" ($year) ⭐ $rating/10 on Lix — Mood-Based Movies & Music!';
                  Share.share(text, subject: 'Movie Recommendation: $title');
                },
                child: Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.share_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (mounted) setState(() => _inWatchlist = !_inWatchlist);
                },
                child: Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
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
              GestureDetector(
                onTap: _likeLoading ? null : _toggleFav,
                child: Container(
                  margin: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
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
                          poster,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) =>
                              _posterPlaceholder(),
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
                            _bgColor.withValues(alpha: 0.85),
                            _bgColor,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie['title'] ?? '',
                    style: TextStyle(
                      color: _textDark,
                      fontSize: AppTheme.heading1(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ..._buildStars(rating),
                      const SizedBox(width: 8),
                      Text(
                        '$rating / 10 (TMDb)',
                        style: const TextStyle(
                          color: _gold,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_loadingImdb) ...[
                        const SizedBox(width: 8),
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: Color(0xFFF5C518),
                          ),
                        ),
                      ] else if (_imdbData['rating'] != null &&
                          _imdbData['rating']!.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5C518),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'IMDb ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                _imdbData['rating']!,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
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
                      if (_imdbData['rank'] != null &&
                          _imdbData['rank']!.isNotEmpty)
                        _infoChip(
                          'IMDb ${_imdbData['rank']}',
                          Icons.trending_up_rounded,
                          const Color(0xFFF5C518),
                        ),
                      GestureDetector(
                        onTap: _openImdbUrl,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5C518).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFFF5C518).withValues(alpha: 0.6)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.open_in_new_rounded,
                                  size: 14, color: Color(0xFFE2B616)),
                              SizedBox(width: 5),
                              Text(
                                'View on IMDb',
                                style: TextStyle(
                                  color: Color(0xFFE2B616),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _trailerLoading ? null : _openTrailer,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF0000), Color(0xFFCC0000)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                          const SizedBox(width: 8),
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
                  const Text(
                    'Synopsis',
                    style: TextStyle(
                      color: _textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
                  const SizedBox(height: 30),
                  if (_similarMovies.isNotEmpty || _loadingSimilar) ...[
                    const Text(
                      'Similar Movies',
                      style: TextStyle(
                        color: _textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 180,
                      child: _loadingSimilar
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _similarMovies.length,
                              itemBuilder: (ctx, i) {
                                final m = _similarMovies[i];
                                return GestureDetector(
                                  onTap: () => Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MovieDetailScreen(movie: m),
                                    ),
                                  ),
                                  child: Container(
                                    width: 110,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      color: _cardBg,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppTheme.border),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                            child: (m['poster'] ?? '').isNotEmpty
                                                ? Image.network(m['poster']!, fit: BoxFit.cover, width: double.infinity)
                                                : Container(color: Colors.grey.shade300, child: const Icon(Icons.movie)),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: Text(
                                            m['title'] ?? '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _posterPlaceholder() => Container(
    color: const Color(0xFF1A1A2E),
    child: const Center(
      child: Icon(Icons.movie_outlined, color: Colors.white24, size: 60),
    ),
  );
}
