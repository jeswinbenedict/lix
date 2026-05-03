import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'favourites_service.dart';
import 'history_service.dart';

class MusicPlayerScreen extends StatefulWidget {
  final Map<String, String> song;
  final List<Map<String, String>>? playlist;
  final int? currentIndex;
  final int resumePositionMs;

  const MusicPlayerScreen({
    super.key,
    required this.song,
    this.playlist,
    this.currentIndex,
    this.resumePositionMs = 0,
  });

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen>
    with SingleTickerProviderStateMixin {
  static const Color _purple = Color(0xFF7C3AED);
  static const Color _bgColor = Color(0xFFF2F2F7);
  static const Color _cardBg = Color(0xFFFFFFFF);
  static const Color _textDark = Color(0xFF1C1C1E);
  static const Color _textGrey = Color(0xFF8E8E93);

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
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
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

  Future<void> _nextSong() async {
    if (_currentIndex < _playlist.length - 1) {
      await _saveCurrentPosition();
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
      await _saveCurrentPosition();
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

  // Mood colour — subtle tint only, purple stays as accent
  Color get _moodAccent {
    const map = {
      'Happy': Color(0xFFFF9F0A),
      'Sad': Color(0xFF0A84FF),
      'Anxious': Color(0xFFFF6B6B),
      'Bored': Color(0xFF30D158),
      'Motivated': Color(0xFFFF375F),
      'Romantic': Color(0xFFFF2D55),
    };
    return map[_currentSong['mood'] ?? ''] ?? _purple;
  }

  @override
  void dispose() {
    _saveCurrentPosition();
    _audioPlayer.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = _moodAccent;
    final cover = _currentSong['cover'] ?? '';
    final hasCover = cover.isNotEmpty;
    final progress = _total.inMilliseconds > 0
        ? (_current.inMilliseconds / _total.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Down arrow — left
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _cardBg,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: _textDark,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  // Center label
                  Column(
                    children: [
                      const Text(
                        'Now Playing',
                        style: TextStyle(
                          color: _textGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _currentSong['mood'] ?? 'Music',
                        style: TextStyle(
                          color: accent,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // Heart — right
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: _likeLoading ? null : _toggleFav,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _isLiked
                              ? Colors.red.withOpacity(0.08)
                              : _cardBg,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _likeLoading
                            ? const Padding(
                                padding: EdgeInsets.all(10),
                                child: CircularProgressIndicator(
                                  color: Colors.red,
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                _isLiked
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: _isLiked ? Colors.redAccent : _textGrey,
                                size: 20,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ── Album Art (rotating disc) ────────────────
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
                        color: accent.withOpacity(0.25),
                        blurRadius: 40,
                        spreadRadius: 4,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: hasCover
                        ? Image.network(
                            cover,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _artPlaceholder(accent),
                          )
                        : _artPlaceholder(accent),
                  ),
                ),
              ),
            ),

            const Spacer(),

            // ── Song Info ────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    _currentSong['title'] ?? '',
                    style: const TextStyle(
                      color: _textDark,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _currentSong['artist'] ?? '',
                    style: const TextStyle(color: _textGrey, fontSize: 15),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if ((_currentSong['genre'] ?? '').isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _purple.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: _purple.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _currentSong['genre']!,
                        style: TextStyle(
                          color: _purple.withOpacity(0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Progress Bar ─────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: _purple,
                      inactiveTrackColor: _purple.withOpacity(0.15),
                      thumbColor: _purple,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 7,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 16,
                      ),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: progress,
                      onChanged: (v) async {
                        await _audioPlayer.seek(
                          Duration(
                            milliseconds: (v * _total.inMilliseconds).toInt(),
                          ),
                        );
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
                          style: const TextStyle(
                            color: _textGrey,
                            fontSize: 12,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: const Text(
                            '30s Preview',
                            style: TextStyle(color: _textGrey, fontSize: 10),
                          ),
                        ),
                        Text(
                          _formatDuration(_total),
                          style: const TextStyle(
                            color: _textGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Controls ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Previous
                  GestureDetector(
                    onTap: _previousSong,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: _cardBg,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.skip_previous_rounded,
                        color: _textDark,
                        size: 26,
                      ),
                    ),
                  ),

                  // Play / Pause
                  GestureDetector(
                    onTap: _togglePlay,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: _purple,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _purple.withOpacity(0.4),
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

                  // Next
                  GestureDetector(
                    onTap: _nextSong,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: _cardBg,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.skip_next_rounded,
                        color: _textDark,
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Queue indicator ──────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.queue_music_rounded,
                  color: _textGrey,
                  size: 15,
                ),
                const SizedBox(width: 5),
                Text(
                  'Song ${_currentIndex + 1} of ${_playlist.length}',
                  style: const TextStyle(color: _textGrey, fontSize: 12),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _artPlaceholder(Color color) {
    return Container(
      color: color.withOpacity(0.08),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.music_note_rounded, color: color, size: 60),
          const SizedBox(height: 8),
          Icon(Icons.apple, color: color.withOpacity(0.4), size: 24),
        ],
      ),
    );
  }
}
