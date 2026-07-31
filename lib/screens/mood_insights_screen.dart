import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/responsive.dart';
import '../services/mood_analytics_service.dart';

class MoodInsightsScreen extends StatefulWidget {
  const MoodInsightsScreen({super.key});

  @override
  State<MoodInsightsScreen> createState() => _MoodInsightsScreenState();
}

class _MoodInsightsScreenState extends State<MoodInsightsScreen> {
  Map<String, int> _counts = {};
  int _streak = 1;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final dist = await MoodAnalyticsService.getMoodDistribution();
    final strk = await MoodAnalyticsService.getVibeStreak();
    if (mounted) {
      setState(() {
        _counts = dist;
        _streak = strk;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _counts.values.fold(0, (sum, val) => sum + val);

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
            Icon(Icons.bar_chart_rounded, color: AppTheme.primary, size: 22),
            SizedBox(width: 8),
            Text('Mood Insights & Analytics', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w800, fontSize: 18)),
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
          maxWidth: 720,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Streak & Quick Stats Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                        boxShadow: AppTheme.shadowPrimary,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 28),
                          const SizedBox(height: 10),
                          Text('$_streak Days', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 2),
                          const Text('Active Vibe Streak', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                        border: Border.all(color: AppTheme.border),
                        boxShadow: AppTheme.shadowSM,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.bolt_rounded, color: AppTheme.warning, size: 28),
                          const SizedBox(height: 10),
                          Text('$total Logged', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 26, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 2),
                          const Text('Total Vibe Interactions', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Mood Distribution Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                  border: Border.all(color: AppTheme.border),
                  boxShadow: AppTheme.shadowSM,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('MOOD DISTRIBUTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppTheme.textSecondary)),
                    const SizedBox(height: 18),
                    if (_loading)
                      const Center(child: CircularProgressIndicator())
                    else
                      ..._counts.entries.map((entry) {
                        final mood = entry.key;
                        final count = entry.value;
                        final ratio = total > 0 ? count / total : 0.0;
                        final percent = (ratio * 100).round();

                        Color color;
                        switch (mood) {
                          case 'Happy': color = AppTheme.moodHappy; break;
                          case 'Sad': color = AppTheme.moodSad; break;
                          case 'Anxious': color = AppTheme.moodAnxious; break;
                          case 'Bored': color = AppTheme.moodBored; break;
                          case 'Motivated': color = AppTheme.moodMotivated; break;
                          default: color = AppTheme.moodRomantic;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(mood, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary)),
                                  Text('$count ($percent%)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: ratio,
                                  minHeight: 8,
                                  backgroundColor: AppTheme.border,
                                  valueColor: AlwaysStoppedAnimation<Color>(color),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Lix AI Health & Energy Tip
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                  border: Border.all(color: AppTheme.primary.withAlpha(40)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: AppTheme.primary, size: 28),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Lix Vibe Insight', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.primary)),
                          SizedBox(height: 4),
                          Text('You tend to feel most motivated on weekdays. Use Vibe Studio to blend Happy + Motivated for maximum focus!', style: TextStyle(fontSize: 13, color: AppTheme.textPrimary, height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
