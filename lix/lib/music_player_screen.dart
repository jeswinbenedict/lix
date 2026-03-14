import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'app_theme.dart';
import 'favourites_service.dart';
import 'history_service.dart'; // ✅ NEW

class MusicPlayerScreen extends StatefulWidget {
  final Map<String, String> song;
  final List<Map<String, String>>? playlist;
  final int? currentIndex;
  final int resumePositionMs; // ✅ NEW

  const MusicPlayerScreen({
    super.key,
    required this.song,
    this.playlist,
    this.currentIndex,
    this.resumePositionMs = 0, // ✅ NEW
  });

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _rotationController;

  late Map<String, String> _currentSong;
  late List<Map<String, String>> _playlist;
  late int _currentIndex;

  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isLiked = false;
  bool _likeLoading = false;
  Duration _current = Duration.zero;
  Duration _total = Duration.zero;

  @override
  void initState() {
    super.initState();
    _currentSong = widget.song;
    _playlist = widget.playlist ?? [widget.song];
    _currentIndex = widget.currentIndex ?? 0;

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    _setupPlayer();
    _playSong();
    _checkFav();
  }

  Future<void> _checkFav() async {
    final id = _currentSong['id'] ?? _currentSong['title'] ?? '';
    final fav = await FavouritesService.isSongFav(id);
    if (mounted) setState(() => _isLiked = fav);
  }

  void _setupPlayer() {
    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _total = d);
    });
    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) setState(() => _current = p);
    });
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state == PlayerState.playing);
        if (state == PlayerState.playing) {
          _rotationController.repeat();
        } else {
          _rotationController.stop();
        }
      }
    });
    _audioPlayer.onPlayerComplete.listen((_) => _nextSong());
  }

  Future<void> _playSong() async {
    final preview = _currentSong['preview'] ?? '';
    if (preview.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No preview available for this song'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            ),
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    await _audioPlayer.stop();

    try {
      await _audioPlayer.play(UrlSource(preview));

      // ✅ Resume from saved position (from HistoryScreen or Firestore)
      int resumeMs = widget.resumePositionMs;
      if (resumeMs == 0) {
        final id = _currentSong['id'] ?? _currentSong['title'] ?? '';
        if (id.isNotEmpty) {
          resumeMs = await HistoryService.getSongResumePosition(id);
        }
      }
      if (resumeMs > 0) {
        await _audioPlayer.seek(Duration(milliseconds: resumeMs));
      }

      // ✅ Save into history (playedAt timestamp)
      await HistoryService.addSongHistory(_currentSong);
    } catch (_) {}

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _togglePlay() async {
    HapticFeedback.lightImpact();
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (_current >= _total && _total > Duration.zero) {
        await _audioPlayer.seek(Duration.zero);
      }
      await _audioPlayer.resume();
    }
  }

  Future<void> _toggleFav() async {
    HapticFeedback.lightImpact();
    setState(() => _likeLoading = true);
    final added = await FavouritesService.toggleSong(_currentSong);
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

  Future<void> _nextSong() async {
    if (_currentIndex < _playlist.length - 1) {
      await _saveCurrentPosition(); // ✅ save before switching
      setState(() {
        _currentIndex++;
        _currentSong = _playlist[_currentIndex];
        _current = Duration.zero;
        _total = Duration.zero;
        _isLiked = false;
      });
      await _playSong();
      await _checkFav();
    }
  }

  Future<void> _previousSong() async {
    if (_current.inSeconds > 3) {
      await _audioPlayer.seek(Duration.zero);
    } else if (_currentIndex > 0) {
      await _saveCurrentPosition(); // ✅ save before switching
      setState(() {
        _currentIndex--;
        _currentSong = _playlist[_currentIndex];
        _current = Duration.zero;
        _total = Duration.zero;
        _isLiked = false;
      });
      await _playSong();
      await _checkFav();
    }
  }

  Future<void> _saveCurrentPosition() async {
    final id = _currentSong['id'] ?? _currentSong['title'] ?? '';
    if (id.isNotEmpty) {
      await HistoryService.saveSongPosition(id, _current.inMilliseconds);
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Color get _moodColor {
    final mood = _currentSong['mood'] ?? '';
    const colors = {
      'Happy': AppTheme.moodHappy,
      'Sad': AppTheme.moodSad,
      'Anxious': AppTheme.moodAnxious,
      'Bored': AppTheme.moodBored,
      'Motivated': AppTheme.moodMotivated,
      'Romantic': AppTheme.moodRomantic,
    };
    return colors[mood] ?? AppTheme.primary;
  }

  @override
  void dispose() {
    _saveCurrentPosition(); // ✅ save when closing player
    _audioPlayer.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _moodColor;
    final hasCover = (_currentSong['cover'] ?? '').isNotEmpty;
    final progress = _total.inMilliseconds > 0
        ? _current.inMilliseconds / _total.inMilliseconds
        : 0.0;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withOpacity(0.15),
              AppTheme.background,
              AppTheme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Top Bar ──────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppTheme.horizontalPadding(context),
                  12,
                  AppTheme.horizontalPadding(context),
                  0,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.border),
                          boxShadow: AppTheme.shadowSM,
                        ),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppTheme.textPrimary,
                          size: 22,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        Text(
                          'Now Playing',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: AppTheme.caption(context),
                          ),
                        ),
                        Text(
                          _currentSong['mood'] ?? 'Music',
                          style: TextStyle(
                            color: color,
                            fontSize: AppTheme.bodyRegular(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _likeLoading ? null : _toggleFav,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _isLiked
                              ? color.withOpacity(0.1)
                              : AppTheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _isLiked
                                ? color.withOpacity(0.3)
                                : AppTheme.border,
                          ),
                          boxShadow: AppTheme.shadowSM,
                        ),
                        child: _likeLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: color,
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                _isLiked
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: _isLiked
                                    ? color
                                    : AppTheme.textSecondary,
                                size: 20,
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ── Rotating Album Art ───────────────────────
              Center(
                child: AnimatedBuilder(
                  animation: _rotationController,
                  builder: (_, child) => Transform.rotate(
                    angle: _rotationController.value * 6.28318,
                    child: child,
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.65,
                    height: MediaQuery.of(context).size.width * 0.65,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: hasCover
                          ? Image.network(
                              _currentSong['cover']!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _artPlaceholder(color),
                            )
                          : _artPlaceholder(color),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // ── Song Info ────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.horizontalPadding(context),
                ),
                child: Column(
                  children: [
                    Text(
                      _currentSong['title'] ?? '',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: AppTheme.heading2(context),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _currentSong['artist'] ?? '',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: AppTheme.bodyLarge(context),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if ((_currentSong['genre'] ?? '').isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusFull,
                          ),
                          border: Border.all(color: color.withOpacity(0.3)),
                        ),
                        child: Text(
                          _currentSong['genre']!,
                          style: TextStyle(
                            color: color,
                            fontSize: AppTheme.caption(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Progress Bar ─────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.horizontalPadding(context),
                ),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: color,
                        inactiveTrackColor: color.withOpacity(0.2),
                        thumbColor: color,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 7,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 16,
                        ),
                        trackHeight: 4,
                      ),
                      child: Slider(
                        value: progress.clamp(0.0, 1.0),
                        onChanged: (v) async {
                          final pos = Duration(
                            milliseconds: (v * _total.inMilliseconds).toInt(),
                          );
                          await _audioPlayer.seek(pos);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_current),
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: AppTheme.caption(context),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.shimmerBase,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusFull,
                              ),
                            ),
                            child: Text(
                              '30s Preview',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: AppTheme.caption(context) - 1,
                              ),
                            ),
                          ),
                          Text(
                            _formatDuration(_total),
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

              const SizedBox(height: 24),

              // ── Playback Controls ────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.horizontalPadding(context),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: _previousSong,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.border),
                          boxShadow: AppTheme.shadowSM,
                        ),
                        child: const Icon(
                          Icons.skip_previous_rounded,
                          color: AppTheme.textPrimary,
                          size: 26,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _togglePlay,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.45),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: _isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Icon(
                                _isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 38,
                              ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _nextSong,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.border),
                          boxShadow: AppTheme.shadowSM,
                        ),
                        child: const Icon(
                          Icons.skip_next_rounded,
                          color: AppTheme.textPrimary,
                          size: 26,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.queue_music_rounded,
                    color: AppTheme.textSecondary,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Song ${_currentIndex + 1} of ${_playlist.length}',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: AppTheme.caption(context),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _artPlaceholder(Color color) {
    return Container(
      color: color.withOpacity(0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.music_note_rounded, color: color, size: 60),
          const SizedBox(height: 8),
          Icon(Icons.apple, color: color.withOpacity(0.5), size: 24),
        ],
      ),
    );
  }
}
