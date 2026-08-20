import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_theme.dart';
import '../core/responsive.dart';
import '../widgets/synesthetic_visualizer.dart';
import '../services/global_audio_service.dart';

class BrainwavePreset {
  final String name;
  final String frequency;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color primaryColor;
  final Color accentColor;
  final String previewTrack;

  const BrainwavePreset({
    required this.name,
    required this.frequency,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.accentColor,
    required this.previewTrack,
  });
}

/// Neural Brainwave & Ambient Soundscape Synthesizer Studio
class BrainwaveStudioScreen extends StatefulWidget {
  const BrainwaveStudioScreen({super.key});

  @override
  State<BrainwaveStudioScreen> createState() => _BrainwaveStudioScreenState();
}

class _BrainwaveStudioScreenState extends State<BrainwaveStudioScreen> {
  int _selectedPresetIndex = 0;
  bool _isPlaying = false;
  double _rainVolume = 0.6;
  double _noiseVolume = 0.4;
  double _droneVolume = 0.8;
  final int _sessionMinutes = 20;
  Timer? _sessionTimer;
  int _secondsRemaining = 0;

  final List<BrainwavePreset> _presets = const [
    BrainwavePreset(
      name: 'Alpha Flow',
      frequency: '10.0 Hz',
      subtitle: 'Flow State & Focus',
      description: 'Synchronizes neural activity for effortless deep work, coding, and reading.',
      icon: Icons.bolt_rounded,
      primaryColor: Color(0xFF6366F1),
      accentColor: Color(0xFF06B6D4),
      previewTrack: 'https://cdn.pixabay.com/download/audio/2022/05/27/audio_1808fbf07a.mp3?filename=lofi-study-112191.mp3',
    ),
    BrainwavePreset(
      name: 'Theta Zen',
      frequency: '6.0 Hz',
      subtitle: 'Meditation & Calm',
      description: 'Promotes deep emotional healing, visualization, and rapid stress dissipation.',
      icon: Icons.self_improvement_rounded,
      primaryColor: Color(0xFF8B5CF6),
      accentColor: Color(0xFFEC4899),
      previewTrack: 'https://cdn.pixabay.com/download/audio/2022/03/15/audio_c8c8a73467.mp3?filename=meditation-piano-9824.mp3',
    ),
    BrainwavePreset(
      name: 'Delta Sleep',
      frequency: '2.5 Hz',
      subtitle: 'Deep Restorative Sleep',
      description: 'Slow-wave oscillations that trigger physical restoration and deep REM cycles.',
      icon: Icons.bedtime_rounded,
      primaryColor: Color(0xFF3B82F6),
      accentColor: Color(0xFF10B981),
      previewTrack: 'https://cdn.pixabay.com/download/audio/2021/09/06/audio_9bc539a2d8.mp3?filename=sleep-music-11756.mp3',
    ),
    BrainwavePreset(
      name: 'Gamma Peak',
      frequency: '40.0 Hz',
      subtitle: 'Peak Cognitive Bandwidth',
      description: 'High-frequency binding across brain regions for complex synthesis and ideation.',
      icon: Icons.psychology_rounded,
      primaryColor: Color(0xFFF59E0B),
      accentColor: Color(0xFFEF4444),
      previewTrack: 'https://cdn.pixabay.com/download/audio/2022/01/18/audio_d0a13f69d2.mp3?filename=ambient-piano-amp-strings-10711.mp3',
    ),
  ];

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  void _togglePlayback() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _startSessionTimer();
        final preset = _presets[_selectedPresetIndex];
        GlobalAudioService.instance.playSong({
          'title': preset.name,
          'artist': 'Neural Soundscape (${preset.frequency})',
          'preview': preset.previewTrack,
          'cover': '',
          'mood': 'Alpha',
        });
      } else {
        _sessionTimer?.cancel();
        GlobalAudioService.instance.pause();
      }
    });
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _secondsRemaining = _sessionMinutes * 60;
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _isPlaying = false);
        GlobalAudioService.instance.pause();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  String _formatTimer(int totalSecs) {
    final m = (totalSecs ~/ 60).toString().padLeft(2, '0');
    final s = (totalSecs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final preset = _presets[_selectedPresetIndex];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new, size: 18),
        ),
        title: const Row(
          children: [
            Icon(Icons.psychology_outlined, color: AppTheme.primary, size: 22),
            SizedBox(width: 8),
            Text(
              'Neural Soundscape Studio',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: CenteredContent(
          maxWidth: 800,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Visualizer Core
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SynestheticVisualizer(
                        isPlaying: _isPlaying,
                        primaryColor: preset.primaryColor,
                        accentColor: preset.accentColor,
                        size: 260,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(preset.icon, color: preset.primaryColor, size: 36),
                          const SizedBox(height: 6),
                          Text(
                            preset.frequency,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            _isPlaying ? _formatTimer(_secondsRemaining) : '${_sessionMinutes}m Session',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Preset Name & Info
                Text(
                  preset.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  preset.subtitle,
                  style: TextStyle(
                    color: preset.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    preset.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 24),

                // Main Play/Pause Button
                GestureDetector(
                  onTap: _togglePlayback,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [preset.primaryColor, preset.accentColor],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: preset.primaryColor.withAlpha(90),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Preset Selector Cards
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Select Brainwave State',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _presets.length,
                    itemBuilder: (context, idx) {
                      final p = _presets[idx];
                      final isSelected = idx == _selectedPresetIndex;

                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _selectedPresetIndex = idx;
                            if (_isPlaying) {
                              _isPlaying = false;
                              _togglePlayback();
                            }
                          });
                        },
                        child: Container(
                          width: 140,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? p.primaryColor.withAlpha(25)
                                : Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                            border: Border.all(
                              color: isSelected ? p.primaryColor : Theme.of(context).dividerColor.withAlpha(40),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(p.icon, color: isSelected ? p.primaryColor : AppTheme.textSecondary, size: 24),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isSelected ? p.primaryColor : Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    p.frequency,
                                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 28),

                // Real-time Soundscape Layer Mixer
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Multi-Layer Ambient Sound Mixing',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                    border: Border.all(color: Theme.of(context).dividerColor.withAlpha(40)),
                  ),
                  child: Column(
                    children: [
                      _buildMixerSlider(
                        icon: Icons.water_drop_rounded,
                        label: 'Rain & Waterfall Layer',
                        value: _rainVolume,
                        color: const Color(0xFF06B6D4),
                        onChanged: (v) => setState(() => _rainVolume = v),
                      ),
                      const SizedBox(height: 12),
                      _buildMixerSlider(
                        icon: Icons.graphic_eq_rounded,
                        label: 'Pink Noise Resonance',
                        value: _noiseVolume,
                        color: const Color(0xFFEC4899),
                        onChanged: (v) => setState(() => _noiseVolume = v),
                      ),
                      const SizedBox(height: 12),
                      _buildMixerSlider(
                        icon: Icons.waves_rounded,
                        label: 'Deep Isochronic Drone',
                        value: _droneVolume,
                        color: preset.primaryColor,
                        onChanged: (v) => setState(() => _droneVolume = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMixerSlider({
    required IconData icon,
    required String label,
    required double value,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          flex: 4,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              activeTrackColor: color,
              thumbColor: color,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
            ),
            child: Slider(
              value: value,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
