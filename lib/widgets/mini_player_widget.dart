import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_theme.dart';
import '../services/global_audio_service.dart';
import '../screens/music_player_screen.dart';

/// Sleek iOS 18 / Dynamic Island-style floating mini audio player
class MiniPlayerWidget extends StatelessWidget {
  const MiniPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GlobalAudioService.instance,
      builder: (context, _) {
        final audio = GlobalAudioService.instance;
        final song = audio.currentSong;

        if (song == null) return const SizedBox.shrink();

        final title = song['title'] ?? 'Unknown Track';
        final artist = song['artist'] ?? 'Unknown Artist';
        final coverUrl = song['cover'] ?? '';
        final isPlaying = audio.isPlaying;
        final progress = audio.duration.inMilliseconds > 0
            ? (audio.position.inMilliseconds / audio.duration.inMilliseconds).clamp(0.0, 1.0)
            : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => MusicPlayerScreen(
                    song: song,
                    playlist: audio.playlist,
                  ),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                      child: child,
                    );
                  },
                ),
              );
            },
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withAlpha(245),
                borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                border: Border.all(
                  color: AppTheme.primary.withAlpha(50),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withAlpha(30),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                child: Stack(
                  children: [
                    // Progress Bar at bottom of capsule
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 2.5,
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                      ),
                    ),
                    // Content Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          // Album Artwork Thumbnail
                          Hero(
                            tag: 'song_cover_${song['title']}',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                width: 42,
                                height: 42,
                                child: coverUrl.isNotEmpty
                                    ? Image.network(
                                        coverUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => _buildPlaceholderIcon(),
                                      )
                                    : _buildPlaceholderIcon(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Track Details
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  artist,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Skip Previous Button
                          IconButton(
                            icon: const Icon(Icons.skip_previous_rounded, size: 22),
                            color: AppTheme.textPrimary,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              audio.previous();
                            },
                          ),
                          // Play / Pause Capsule Action
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              shape: BoxShape.circle,
                              boxShadow: AppTheme.shadowPrimary,
                            ),
                            child: IconButton(
                              icon: Icon(
                                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                audio.togglePlayPause();
                              },
                            ),
                          ),
                          // Skip Next Button
                          IconButton(
                            icon: const Icon(Icons.skip_next_rounded, size: 22),
                            color: AppTheme.textPrimary,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              audio.next();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      color: AppTheme.primaryLight,
      child: const Icon(Icons.music_note_rounded, color: AppTheme.primary, size: 22),
    );
  }
}
