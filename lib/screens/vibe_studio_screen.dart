import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_theme.dart';
import '../core/responsive.dart';
import '../services/vibe_mixer_service.dart';
import 'movie_detail_screen.dart';
import 'music_player_screen.dart';

class VibeStudioScreen extends StatefulWidget {
  const VibeStudioScreen({super.key});

  @override
  State<VibeStudioScreen> createState() => _VibeStudioScreenState();
}

class _VibeStudioScreenState extends State<VibeStudioScreen> {
  String _primaryMood = 'Happy';
  String _secondaryMood = 'Motivated';
  double _ratio = 0.7; // 70% Primary, 30% Secondary

  bool _isMixing = false;
  List<Map<String, String>> _mixedMovies = [];
  List<Map<String, String>> _mixedSongs = [];

  final List<String> _moods = const [
    'Happy',
    'Sad',
    'Anxious',
    'Bored',
    'Motivated',
    'Romantic',
  ];

  @override
  void initState() {
    super.initState();
    _generateMix();
  }

  Future<void> _generateMix() async {
    setState(() => _isMixing = true);
    try {
      final res = await VibeMixerService.mixVibes(
        primaryMood: _primaryMood,
        secondaryMood: _secondaryMood,
        primaryRatio: _ratio,
      );
      if (mounted) {
        setState(() {
          _mixedMovies = res['movies'] ?? [];
          _mixedSongs = res['songs'] ?? [];
          _isMixing = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isMixing = false);
    }
  }

  Widget _buildMoodSelector({
    required String title,
    required String selectedMood,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _moods.length,
            itemBuilder: (context, index) {
              final m = _moods[index];
              final isSel = m == selectedMood;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  selected: isSel,
                  label: Text(m),
                  selectedColor: AppTheme.primary,
                  backgroundColor: AppTheme.surface,
                  labelStyle: TextStyle(
                    color: isSel ? Colors.white : AppTheme.textPrimary,
                    fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: isSel ? AppTheme.primary : AppTheme.border,
                    ),
                  ),
                  onSelected: (val) {
                    if (val) {
                      HapticFeedback.lightImpact();
                      onSelected(m);
                      _generateMix();
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryPercent = (_ratio * 100).round();
    final secondaryPercent = 100 - primaryPercent;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary, size: 18),
        ),
        title: const Row(
          children: [
            Icon(Icons.tune_rounded, color: AppTheme.primary, size: 22),
            SizedBox(width: 8),
            Text(
              'Vibe Studio (AI Mixer)',
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppTheme.border),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: CenteredContent(
          maxWidth: 800,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // ── Apple Hero Studio Card ───────────────────────
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                  border: Border.all(color: AppTheme.border),
                  boxShadow: AppTheme.shadowMD,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: AppTheme.shadowPrimary,
                          ),
                          child: const Center(
                            child: Icon(Icons.equalizer_rounded, color: Colors.white, size: 24),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Dual Mood Mixer',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Blend two vibes to craft custom movie & music recommendations',
                                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Primary Mood Selector
                    _buildMoodSelector(
                      title: 'Primary Mood ($primaryPercent%)',
                      selectedMood: _primaryMood,
                      onSelected: (m) => setState(() => _primaryMood = m),
                    ),
                    const SizedBox(height: 18),

                    // Secondary Mood Selector
                    _buildMoodSelector(
                      title: 'Secondary Mood ($secondaryPercent%)',
                      selectedMood: _secondaryMood,
                      onSelected: (m) => setState(() => _secondaryMood = m),
                    ),
                    const SizedBox(height: 24),

                    // Ratio Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$_primaryMood ($primaryPercent%)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primary)),
                        Text('$_secondaryMood ($secondaryPercent%)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.secondary)),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 6,
                        activeTrackColor: AppTheme.primary,
                        inactiveTrackColor: AppTheme.secondary.withAlpha(100),
                        thumbColor: AppTheme.primary,
                      ),
                      child: Slider(
                        value: _ratio,
                        onChanged: (val) {
                          setState(() => _ratio = val);
                        },
                        onChangeEnd: (_) {
                          HapticFeedback.selectionClick();
                          _generateMix();
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Mixed Movies Section ───────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mixed Movie Picks',
                    style: TextStyle(
                      fontSize: AppTheme.heading3(context),
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (_isMixing)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 240,
                child: _mixedMovies.isEmpty
                    ? const Center(child: Text('No movies mixed yet', style: TextStyle(color: AppTheme.textSecondary)))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _mixedMovies.length,
                        itemBuilder: (context, index) {
                          final movie = _mixedMovies[index];
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
                            ),
                            child: Container(
                              width: 140,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                                border: Border.all(color: AppTheme.border),
                                boxShadow: AppTheme.shadowSM,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusMD)),
                                      child: (movie['poster'] ?? '').isNotEmpty
                                          ? Image.network(movie['poster']!, fit: BoxFit.cover, width: double.infinity)
                                          : Container(color: AppTheme.shimmerBase, child: const Icon(Icons.movie, color: AppTheme.primary)),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      movie['title'] ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 28),

              // ── Mixed Songs Section ────────────────────────
              Text(
                'Hybrid Music Playlist',
                style: TextStyle(
                  fontSize: AppTheme.heading3(context),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _mixedSongs.length,
                itemBuilder: (context, index) {
                  final song = _mixedSongs[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                      border: Border.all(color: AppTheme.border),
                      boxShadow: AppTheme.shadowSM,
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: (song['cover'] ?? '').isNotEmpty
                            ? Image.network(song['cover']!, width: 44, height: 44, fit: BoxFit.cover)
                            : Container(width: 44, height: 44, color: AppTheme.primaryLight, child: const Icon(Icons.music_note, color: AppTheme.primary)),
                      ),
                      title: Text(song['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(song['artist'] ?? '', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      trailing: const Icon(Icons.play_circle_fill_rounded, color: AppTheme.primary, size: 30),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MusicPlayerScreen(
                            song: song,
                            playlist: _mixedSongs,
                            currentIndex: index,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
