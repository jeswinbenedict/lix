import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_theme.dart';
import '../core/responsive.dart';
import '../services/tmdb_service.dart';
import '../services/music_api_service.dart';
import 'movie_detail_screen.dart';
import 'music_player_screen.dart';

class VibeMatcherScreen extends StatefulWidget {
  const VibeMatcherScreen({super.key});

  @override
  State<VibeMatcherScreen> createState() => _VibeMatcherScreenState();
}

class _VibeMatcherScreenState extends State<VibeMatcherScreen> {
  int _step = 0;
  String _place = 'Home';
  String _time = '1 Hour';
  String _targetVibe = 'High Energy';

  bool _isMatching = false;
  Map<String, String>? _matchedMovie;
  Map<String, String>? _matchedSong;

  final List<Map<String, dynamic>> _q1Options = [
    {'title': 'At Home / Cozy', 'icon': Icons.home_rounded, 'value': 'Home'},
    {'title': 'Commuting / Travel', 'icon': Icons.directions_bus_rounded, 'value': 'Commute'},
    {'title': 'Workout / Gym', 'icon': Icons.fitness_center_rounded, 'value': 'Workout'},
    {'title': 'Chilling Out', 'icon': Icons.weekend_rounded, 'value': 'Chill'},
  ];

  final List<Map<String, dynamic>> _q2Options = [
    {'title': '15 Minutes (Quick)', 'icon': Icons.timer_rounded, 'value': 'Quick'},
    {'title': '1 Hour (Standard)', 'icon': Icons.access_time_rounded, 'value': '1 Hour'},
    {'title': 'Full Evening (Deep)', 'icon': Icons.nightlight_rounded, 'value': 'Full'},
  ];

  final List<Map<String, dynamic>> _q3Options = [
    {'title': 'High Energy & Action', 'icon': Icons.bolt_rounded, 'value': 'Motivated'},
    {'title': 'Relax & Calm Down', 'icon': Icons.spa_rounded, 'value': 'Anxious'},
    {'title': 'Feel Good & Laugh', 'icon': Icons.sentiment_very_satisfied_rounded, 'value': 'Happy'},
    {'title': 'Romantic & Heartfelt', 'icon': Icons.favorite_rounded, 'value': 'Romantic'},
  ];

  Future<void> _computeMatch() async {
    setState(() {
      _step = 3;
      _isMatching = true;
    });

    try {
      final movies = await TmdbService.getMoviesByMood(_targetVibe);
      final songs = await MusicApiService.getSongsByMood(_targetVibe);

      if (mounted) {
        setState(() {
          _matchedMovie = movies.isNotEmpty ? movies.first : null;
          _matchedSong = songs.isNotEmpty ? songs.first : null;
          _isMatching = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isMatching = false);
    }
  }

  Widget _buildQuizCard({
    required String title,
    required String subtitle,
    required List<Map<String, dynamic>> options,
    required String selectedValue,
    required ValueChanged<String> onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, letterSpacing: -0.4),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
        const SizedBox(height: 24),
        ...options.map((opt) {
          final isSelected = opt['value'] == selectedValue;
          final icon = opt['icon'] as IconData;
          final label = opt['title'] as String;
          final val = opt['value'] as String;

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onSelect(val);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryLight : AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                border: Border.all(
                  color: isSelected ? AppTheme.primary : AppTheme.border,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected ? AppTheme.shadowPrimary : AppTheme.shadowSM,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary : AppTheme.shimmerBase,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: isSelected ? Colors.white : AppTheme.primary, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 22),
                ],
              ),
            ),
          );
        }),
      ],
    );
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
        title: const Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: AppTheme.primary, size: 22),
            SizedBox(width: 8),
            Text('Vibe Matcher Quiz', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w800, fontSize: 18)),
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
          maxWidth: 680,
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Step Progress Indicator
              if (_step < 3)
                Row(
                  children: List.generate(3, (idx) {
                    final isActive = idx <= _step;
                    return Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.only(right: idx < 2 ? 8 : 0),
                        height: 6,
                        decoration: BoxDecoration(
                          color: isActive ? AppTheme.primary : AppTheme.border,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }),
                ),

              const SizedBox(height: 28),

              // Question Steps
              if (_step == 0)
                _buildQuizCard(
                  title: 'Step 1 of 3',
                  subtitle: 'Where are you right now?',
                  options: _q1Options,
                  selectedValue: _place,
                  onSelect: (v) => setState(() => _place = v),
                ),

              if (_step == 1)
                _buildQuizCard(
                  title: 'Step 2 of 3',
                  subtitle: 'How much time do you have?',
                  options: _q2Options,
                  selectedValue: _time,
                  onSelect: (v) => setState(() => _time = v),
                ),

              if (_step == 2)
                _buildQuizCard(
                  title: 'Step 3 of 3',
                  subtitle: 'What vibe are you chasing?',
                  options: _q3Options,
                  selectedValue: _targetVibe,
                  onSelect: (v) => setState(() => _targetVibe = v),
                ),

              if (_step < 3) const SizedBox(height: 24),

              // Navigation Buttons
              if (_step < 3)
                Row(
                  children: [
                    if (_step > 0)
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMD)),
                          ),
                          onPressed: () => setState(() => _step--),
                          child: const Text('Back', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    if (_step > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMD)),
                        ),
                        onPressed: () {
                          if (_step < 2) {
                            setState(() => _step++);
                          } else {
                            _computeMatch();
                          }
                        },
                        child: Text(_step == 2 ? 'Find My Match ✨' : 'Continue', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),

              // Reveal Match Screen
              if (_step == 3) ...[
                if (_isMatching)
                  const Padding(
                    padding: EdgeInsets.all(60.0),
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: AppTheme.primary),
                        SizedBox(height: 16),
                        Text('Lix AI is computing your perfect match...', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )
                else ...[
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                      border: Border.all(color: AppTheme.primary.withAlpha(40), width: 1.5),
                      boxShadow: AppTheme.shadowMD,
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.star_rounded, color: Colors.white, size: 36),
                        ),
                        const SizedBox(height: 14),
                        const Text('Your Perfect Match Is Ready!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                        const SizedBox(height: 4),
                        Text('Curated for $_place • $_time • $_targetVibe', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                        const SizedBox(height: 24),

                        // Matched Movie Card
                        if (_matchedMovie != null) ...[
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text('🎬 #1 MATCHED MOVIE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: AppTheme.primary)),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: _matchedMovie!)),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.background,
                                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                                border: Border.all(color: AppTheme.border),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: (_matchedMovie!['poster'] ?? '').isNotEmpty
                                        ? Image.network(_matchedMovie!['poster']!, width: 60, height: 80, fit: BoxFit.cover)
                                        : Container(width: 60, height: 80, color: AppTheme.shimmerBase, child: const Icon(Icons.movie)),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(_matchedMovie!['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        const SizedBox(height: 4),
                                        Text('⭐ ${_matchedMovie!['rating']} • ${_matchedMovie!['year']}', style: const TextStyle(color: AppTheme.warning, fontSize: 13, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.primary),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Matched Song Card
                        if (_matchedSong != null) ...[
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text('🎵 #1 MATCHED SONG', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: AppTheme.primary)),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => MusicPlayerScreen(song: _matchedSong!)),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.background,
                                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                                border: Border.all(color: AppTheme.border),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: (_matchedSong!['cover'] ?? '').isNotEmpty
                                        ? Image.network(_matchedSong!['cover']!, width: 60, height: 60, fit: BoxFit.cover)
                                        : Container(width: 60, height: 60, color: AppTheme.primaryLight, child: const Icon(Icons.music_note, color: AppTheme.primary)),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(_matchedSong!['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                        const SizedBox(height: 2),
                                        Text(_matchedSong!['artist'] ?? '', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.play_circle_fill_rounded, size: 36, color: AppTheme.primary),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMD)),
                    ),
                    onPressed: () => setState(() => _step = 0),
                    child: const Text('Retake Quiz 🔄', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ],

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
