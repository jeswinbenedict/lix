import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';
import 'theme_service.dart';

class DarkModeScreen extends StatefulWidget {
  const DarkModeScreen({super.key});

  @override
  State<DarkModeScreen> createState() => _DarkModeScreenState();
}

class _DarkModeScreenState extends State<DarkModeScreen> {
  final _themeService = ThemeService();

  final List<Map<String, dynamic>> _options = [
    {
      'label': 'Dark Mode',
      'desc': 'Easy on the eyes at night',
      'icon': Icons.dark_mode_outlined,
      'value': true,
      'color': AppTheme.moodAnxious,
    },
    {
      'label': 'Light Mode',
      'desc': 'Bright and clean look',
      'icon': Icons.light_mode_outlined,
      'value': false,
      'color': AppTheme.warning,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeService,
      builder: (context, _) {
        final isDark = _themeService.isDark;

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: AppTheme.background,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.border),
                ),
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppTheme.textPrimary,
                  size: 22,
                ),
              ),
            ),
            title: const Text(
              'Appearance',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.horizontalPadding(context),
              vertical: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Preview Card ───────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                          : [const Color(0xFFF8F9FA), const Color(0xFFE9ECEF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                    border: Border.all(color: AppTheme.border),
                    boxShadow: AppTheme.shadowSM,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        isDark
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        size: 56,
                        color: isDark ? AppTheme.moodAnxious : AppTheme.warning,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isDark ? 'Dark Mode On' : 'Light Mode On',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: AppTheme.heading2(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isDark
                            ? 'Easier on your eyes in low light'
                            : 'Perfect for bright environments',
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black45,
                          fontSize: AppTheme.bodyRegular(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      // Mini UI preview
                      _buildMiniPreview(isDark),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                Text(
                  'Choose Theme',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: AppTheme.heading2(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // ── Theme Options ──────────────────────
                ..._options.map((opt) {
                  final isSelected = isDark == (opt['value'] as bool);
                  final color = opt['color'] as Color;
                  return GestureDetector(
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      await _themeService.setDark(opt['value'] as bool);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withOpacity(0.08)
                            : AppTheme.surface,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                        border: Border.all(
                          color: isSelected
                              ? color.withOpacity(0.4)
                              : AppTheme.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                        boxShadow: AppTheme.shadowSM,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              opt['icon'] as IconData,
                              color: color,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  opt['label'] as String,
                                  style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: AppTheme.bodyLarge(context),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  opt['desc'] as String,
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: AppTheme.caption(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? color : Colors.transparent,
                              border: Border.all(
                                color: isSelected ? color : AppTheme.border,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 13,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 28),

                // ── Quick Toggle ───────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    border: Border.all(color: AppTheme.border),
                    boxShadow: AppTheme.shadowSM,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusSM,
                          ),
                        ),
                        child: const Icon(
                          Icons.compare_rounded,
                          color: AppTheme.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dark Mode',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: AppTheme.bodyRegular(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              isDark ? 'Currently on' : 'Currently off',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: AppTheme.caption(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: isDark,
                        onChanged: (v) async {
                          HapticFeedback.lightImpact();
                          await _themeService.setDark(v);
                        },
                        activeThumbColor: AppTheme.primary,
                        activeTrackColor: AppTheme.primary.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // info note
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    border: Border.all(
                      color: AppTheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: AppTheme.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Your theme preference is saved automatically and will persist across app restarts.',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: AppTheme.caption(context),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMiniPreview(bool isDark) {
    final bg = isDark ? const Color(0xFF0F0F1A) : Colors.white;
    final card = isDark ? const Color(0xFF1C1C2E) : const Color(0xFFF1F3F5);
    final txt = isDark ? Colors.white : Colors.black87;
    final sub = isDark ? Colors.white38 : Colors.black38;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.music_note_rounded,
              color: AppTheme.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 8,
                  width: 100,
                  decoration: BoxDecoration(
                    color: txt.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  height: 6,
                  width: 70,
                  decoration: BoxDecoration(
                    color: sub,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: card, shape: BoxShape.circle),
            child: Icon(
              Icons.play_arrow_rounded,
              color: AppTheme.primary,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}
