import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../core/app_theme.dart';
import '../services/favourites_service.dart';
import '../services/history_service.dart';

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
  static const Color _purple = AppTheme.primary;
  static const Color _bgColor = AppTheme.background;
  static const Color _cardBg = AppTheme.surface;
  static const Color _textDark = AppTheme.textPrimary;
  static const Color _textGrey = AppTheme.textSecondary;

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
      if (!mounted) return;
      setState(() => _isPlaying = state == PlayerState.playing);
      if (state == PlayerState.playing) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
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

    if (mounted) setState(() => _isLoading = true);
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
    } catch (e) {
      debugPrint('MusicPlayer play error: $e');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _togglePlay() async {
    HapticFeedback.lightImpact();
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (_total > Duration.zero && _current >= _total) {
        await _audioPlayer.seek(Duration.zero);
      }
      await _audioPlayer.resume();
    }
  }

  Future<void> _toggleFav() async {
    HapticFeedback.lightImpact();
    if (mounted) setState(() => _likeLoading = true);
    final added = await FavouritesService.toggleSong(_currentSong);
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
    if (id.isNotEmpty && _current.inMilliseconds > 0) {
      await HistoryService.saveSongPosition(id, _current.inMilliseconds);
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _saveCurrentPosition().catchError((_) {});
    _audioPlayer.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: _cardBg,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: _textDark,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    _currentSong['title'] ?? 'Now Playing',
                    style: const TextStyle(
                      color: _textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: _likeLoading ? null : _toggleFav,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: _cardBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
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
            Center(
              child: AnimatedBuilder(
                animation: _rotationController,
                builder: (_, child) => Transform.rotate(
                  angle: _rotationController.value * 6.28318,
                  child: child,
                ),
                child: Container(
                  width: (MediaQuery.of(context).size.width * 0.65).clamp(200.0, 320.0),
                  height: (MediaQuery.of(context).size.width * 0.65).clamp(200.0, 320.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: AppTheme.shadowPrimary,
                  ),
                  child: ClipOval(
                    child: hasCover
                        ? Image.network(
                            cover,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => _artPlaceholder(),
                          )
                        : _artPlaceholder(),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Text(
              _currentSong['title'] ?? '',
              style: const TextStyle(
                color: _textDark,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              _currentSong['artist'] ?? '',
              style: const TextStyle(color: _textGrey, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Slider(
                    value: progress,
                    activeColor: _purple,
                    onChanged: (v) async {
                      await _audioPlayer.seek(
                        Duration(
                          milliseconds: (v * _total.inMilliseconds).toInt(),
                        ),
                      );
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(_current), style: const TextStyle(color: _textGrey, fontSize: 12)),
                      Text(_formatDuration(_total), style: const TextStyle(color: _textGrey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous_rounded, size: 36),
                  onPressed: _previousSong,
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: _togglePlay,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: _purple,
                      shape: BoxShape.circle,
                    ),
                    child: _isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : Icon(
                            _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                  ),
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.skip_next_rounded, size: 36),
                  onPressed: _nextSong,
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _artPlaceholder() => Container(
    color: AppTheme.primaryLight,
    child: const Center(
      child: Icon(Icons.music_note_rounded, color: AppTheme.primary, size: 60),
    ),
  );
}
