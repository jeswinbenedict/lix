import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../core/app_theme.dart';
import '../services/favourites_service.dart';
import '../services/global_audio_service.dart';
import '../widgets/synesthetic_visualizer.dart';

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
  late AnimationController _rotationController;
  final GlobalAudioService _audioService = GlobalAudioService.instance;

  bool _isLiked = false;
  bool _likeLoading = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );

    _initPlayback();
    _checkFav();
  }

  Future<void> _initPlayback() async {
    // If the requested song is not already playing, trigger playback
    if (_audioService.currentSong?['title'] != widget.song['title']) {
      await _audioService.playSong(widget.song, playlist: widget.playlist);
    }
  }

  Future<void> _checkFav() async {
    final current = _audioService.currentSong ?? widget.song;
    final id = current['id'] ?? current['title'] ?? '';
    final fav = await FavouritesService.isSongFav(id);
    if (mounted) setState(() => _isLiked = fav);
  }

  Future<void> _toggleFav() async {
    HapticFeedback.lightImpact();
    final current = _audioService.currentSong ?? widget.song;
    if (mounted) setState(() => _likeLoading = true);
    final added = await FavouritesService.toggleSong(current);
    if (mounted) {
      setState(() {
        _isLiked = added;
        _likeLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(added ? 'Added to Favourites' : 'Removed from Favourites'),
          backgroundColor: added ? Colors.redAccent : AppTheme.textSecondary,
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _shareSong() {
    HapticFeedback.lightImpact();
    final current = _audioService.currentSong ?? widget.song;
    final title = current['title'] ?? 'Song';
    final artist = current['artist'] ?? 'Artist';
    final appleUrl = current['apple_url'] ?? '';

    final shareText = appleUrl.isNotEmpty
        ? '🎵 Listening to "$title" by $artist on Lix!\n$appleUrl'
        : '🎵 Listening to "$title" by $artist on Lix — Mood-Based Movies & Music!';

    Share.share(shareText, subject: 'Listening to $title');
  }

  void _showSleepTimerSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return ListenableBuilder(
          listenable: _audioService,
          builder: (context, _) {
            final activeMins = _audioService.sleepTimerRemainingMinutes;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sleep Timer',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (activeMins != null)
                        Text(
                          'Active: ~${activeMins}m',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Audio volume smoothly fades out before stopping.',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      _buildTimerChip(ctx, '15 Minutes', 15),
                      _buildTimerChip(ctx, '30 Minutes', 30),
                      _buildTimerChip(ctx, '45 Minutes', 45),
                      _buildTimerChip(ctx, '60 Minutes', 60),
                      if (activeMins != null)
                        ActionChip(
                          avatar: const Icon(Icons.close_rounded, size: 16, color: Colors.redAccent),
                          label: const Text('Turn Off', style: TextStyle(color: Colors.redAccent)),
                          onPressed: () {
                            _audioService.cancelSleepTimer();
                            Navigator.pop(ctx);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTimerChip(BuildContext ctx, String label, int minutes) {
    return ActionChip(
      avatar: const Icon(Icons.bedtime_rounded, size: 16, color: AppTheme.primary),
      label: Text(label),
      onPressed: () {
        _audioService.setSleepTimer(minutes);
        Navigator.pop(ctx);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sleep timer set for $minutes minutes'),
            backgroundColor: AppTheme.primary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _audioService,
      builder: (context, _) {
        final song = _audioService.currentSong ?? widget.song;
        final isPlaying = _audioService.isPlaying;
        final position = _audioService.position;
        final duration = _audioService.duration;
        final isShuffle = _audioService.isShuffle;
        final repeatMode = _audioService.repeatMode;

        if (isPlaying) {
          if (!_rotationController.isAnimating) _rotationController.repeat();
        } else {
          _rotationController.stop();
        }

        final cover = song['cover'] ?? '';
        final hasCover = cover.isNotEmpty;
        final progress = duration.inMilliseconds > 0
            ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
            : 0.0;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                // Top App Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: Theme.of(context).dividerColor.withAlpha(40)),
                          ),
                          child: const Icon(Icons.keyboard_arrow_down_rounded, size: 24),
                        ),
                      ),
                      Column(
                        children: [
                          const Text(
                            'NOW PLAYING',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            song['mood']?.isNotEmpty == true ? '${song['mood']} Mood' : 'Lix Audio',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.share_outlined, size: 20),
                            onPressed: _shareSong,
                          ),
                          GestureDetector(
                            onTap: _likeLoading ? null : _toggleFav,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                shape: BoxShape.circle,
                                border: Border.all(color: Theme.of(context).dividerColor.withAlpha(40)),
                              ),
                              child: Icon(
                                _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                color: _isLiked ? Colors.redAccent : AppTheme.textSecondary,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Spinning Vinyl / Album Artwork with Synesthetic Visualizer Aura
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SynestheticVisualizer(
                        isPlaying: isPlaying,
                        primaryColor: AppTheme.primary,
                        accentColor: const Color(0xFF06B6D4),
                        size: (MediaQuery.of(context).size.width * 0.85).clamp(260.0, 360.0),
                      ),
                      AnimatedBuilder(
                        animation: _rotationController,
                        builder: (_, child) => Transform.rotate(
                          angle: _rotationController.value * 6.28318,
                          child: child,
                        ),
                        child: Hero(
                          tag: 'song_cover_${song['title']}',
                          child: Container(
                            width: (MediaQuery.of(context).size.width * 0.55).clamp(180.0, 260.0),
                            height: (MediaQuery.of(context).size.width * 0.55).clamp(180.0, 260.0),
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
                    ],
                  ),
                ),
                const Spacer(),
                // Title and Artist
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Text(
                        song['title'] ?? '',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        song['artist'] ?? '',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Progress Slider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                          activeTrackColor: AppTheme.primary,
                          inactiveTrackColor: AppTheme.primary.withAlpha(40),
                          thumbColor: AppTheme.primary,
                        ),
                        child: Slider(
                          value: progress,
                          onChanged: (v) {
                            final targetMs = (v * duration.inMilliseconds).toInt();
                            _audioService.seek(Duration(milliseconds: targetMs));
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(position),
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                            ),
                            Text(
                              _formatDuration(duration),
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Player Control Buttons Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Shuffle Button
                      IconButton(
                        icon: Icon(
                          Icons.shuffle_rounded,
                          color: isShuffle ? AppTheme.primary : AppTheme.textSecondary,
                          size: 24,
                        ),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          _audioService.toggleShuffle();
                        },
                      ),
                      // Skip Previous
                      IconButton(
                        icon: const Icon(Icons.skip_previous_rounded, size: 38),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          _audioService.previous();
                          _checkFav();
                        },
                      ),
                      // Play / Pause Hero Button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          _audioService.togglePlayPause();
                        },
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: AppTheme.shadowPrimary,
                          ),
                          child: Icon(
                            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 38,
                          ),
                        ),
                      ),
                      // Skip Next
                      IconButton(
                        icon: const Icon(Icons.skip_next_rounded, size: 38),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          _audioService.next();
                          _checkFav();
                        },
                      ),
                      // Repeat Mode Button
                      IconButton(
                        icon: Icon(
                          repeatMode == AudioRepeatMode.one
                              ? Icons.repeat_one_rounded
                              : Icons.repeat_rounded,
                          color: repeatMode != AudioRepeatMode.off ? AppTheme.primary : AppTheme.textSecondary,
                          size: 24,
                        ),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          _audioService.cycleRepeatMode();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Bottom Secondary Tools (Sleep Timer)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: TextButton.icon(
                    onPressed: _showSleepTimerSheet,
                    icon: Icon(
                      Icons.bedtime_outlined,
                      size: 16,
                      color: _audioService.sleepTimerRemainingMinutes != null
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                    ),
                    label: Text(
                      _audioService.sleepTimerRemainingMinutes != null
                          ? 'Sleep Timer: ${_audioService.sleepTimerRemainingMinutes}m'
                          : 'Sleep Timer',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _audioService.sleepTimerRemainingMinutes != null
                            ? AppTheme.primary
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _artPlaceholder() => Container(
        color: AppTheme.primaryLight,
        child: const Center(
          child: Icon(Icons.music_note_rounded, color: AppTheme.primary, size: 60),
        ),
      );
}
