import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _version = '1.0.0';
  static const _buildNo = '1';
  static const _year = '2026';
  static const _email = 'support@lixapp.com';
  static const _privacy = 'https://lixapp.com/privacy';
  static const _terms = 'https://lixapp.com/terms';

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero Header ──────────────────────────────
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
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
              'About Lix',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primary.withValues(alpha: 0.2),
                      AppTheme.secondary.withValues(alpha: 0.1),
                      AppTheme.background,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 48),
                    // App Logo
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primary, AppTheme.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.45),
                            blurRadius: 24,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'L',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Lix',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mood-Based Movies & Music',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusFull,
                        ),
                        border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'Version $_version (Build $_buildNo)',
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.horizontalPadding(context),
                vertical: 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Mission Statement ──────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                      border: Border.all(color: AppTheme.border),
                      boxShadow: AppTheme.shadowSM,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.format_quote_rounded,
                          color: AppTheme.primary.withValues(alpha: 0.4),
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Lix understands how you feel and curates the perfect movies and music to match your mood — making every moment more meaningful.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: AppTheme.bodyRegular(context),
                            height: 1.7,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── What Powers Lix ────────────────────
                  Text(
                    'What Powers Lix',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: AppTheme.heading2(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTechGrid(context),

                  const SizedBox(height: 24),

                  // ── Key Features ───────────────────────
                  Text(
                    'Key Features',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: AppTheme.heading2(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._features.map(
                    (f) => _buildFeatureTile(
                      context,
                      f['icon'] as IconData,
                      f['title'] as String,
                      f['desc'] as String,
                      f['color'] as Color,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── App Stats ──────────────────────────
                  Text(
                    'App Info',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: AppTheme.heading2(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                      border: Border.all(color: AppTheme.border),
                      boxShadow: AppTheme.shadowSM,
                    ),
                    child: Column(
                      children: [
                        _infoRow('Version', _version, Icons.tag_rounded),
                        _divider(),
                        _infoRow(
                          'Build Number',
                          _buildNo,
                          Icons.build_outlined,
                        ),
                        _divider(),
                        _infoRow(
                          'Release Year',
                          _year,
                          Icons.calendar_today_rounded,
                        ),
                        _divider(),
                        _infoRow(
                          'Platform',
                          'Android & iOS',
                          Icons.phone_android_rounded,
                        ),
                        _divider(),
                        _infoRow(
                          'Data Source',
                          'TMDB + Deezer',
                          Icons.cloud_outlined,
                        ),
                        _divider(),
                        _infoRow('Backend', 'Firebase', Icons.storage_rounded),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Legal & Links ──────────────────────
                  Text(
                    'Legal',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: AppTheme.heading2(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                      border: Border.all(color: AppTheme.border),
                      boxShadow: AppTheme.shadowSM,
                    ),
                    child: Column(
                      children: [
                        _linkRow(
                          context,
                          Icons.privacy_tip_outlined,
                          'Privacy Policy',
                          AppTheme.primary,
                          () => _launch(_privacy),
                        ),
                        _divider(),
                        _linkRow(
                          context,
                          Icons.description_outlined,
                          'Terms of Service',
                          AppTheme.secondary,
                          () => _launch(_terms),
                        ),
                        _divider(),
                        _linkRow(
                          context,
                          Icons.email_outlined,
                          'Contact: $_email',
                          AppTheme.moodMotivated,
                          () => _launch('mailto:$_email'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Acknowledgements ───────────────────
                  Text(
                    'Acknowledgements',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: AppTheme.heading2(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                      border: Border.all(color: AppTheme.border),
                      boxShadow: AppTheme.shadowSM,
                    ),
                    child: Column(
                      children: [
                        _ackTile(
                          context,
                          '🎬',
                          'TMDB',
                          'Movie data provided by The Movie Database API',
                        ),
                        const SizedBox(height: 12),
                        _ackTile(
                          context,
                          '🎵',
                          'Deezer',
                          'Music previews powered by Deezer API',
                        ),
                        const SizedBox(height: 12),
                        _ackTile(
                          context,
                          '🔥',
                          'Firebase',
                          'Backend, auth & storage by Google Firebase',
                        ),
                        const SizedBox(height: 12),
                        _ackTile(
                          context,
                          '💙',
                          'Flutter',
                          'Built with Flutter by Google',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Footer ─────────────────────────────
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primary, AppTheme.secondary],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: Text(
                              'L',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Made with ❤️ by Team Lix',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: AppTheme.caption(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '© $_year Lix. All rights reserved.',
                          style: TextStyle(
                            color: AppTheme.textSecondary.withValues(alpha: 0.5),
                            fontSize: AppTheme.caption(context) - 1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tech Stack Grid ──────────────────────────────────
  Widget _buildTechGrid(BuildContext context) {
    final tech = [
      {
        'icon': '🎬',
        'name': 'TMDB',
        'desc': 'Movies',
        'color': AppTheme.primary,
      },
      {
        'icon': '🎵',
        'name': 'Deezer',
        'desc': 'Music',
        'color': AppTheme.secondary,
      },
      {
        'icon': '🔥',
        'name': 'Firebase',
        'desc': 'Backend',
        'color': AppTheme.warning,
      },
      {
        'icon': '💙',
        'name': 'Flutter',
        'desc': 'UI',
        'color': AppTheme.moodSad,
      },
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: tech.map((t) {
        final color = t['color'] as Color;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            border: Border.all(color: AppTheme.border),
            boxShadow: AppTheme.shadowSM,
          ),
          child: Row(
            children: [
              Text(t['icon'] as String, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    t['name'] as String,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    t['desc'] as String,
                    style: TextStyle(color: color, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  static const _features = [
    {
      'icon': Icons.mood_rounded,
      'title': 'Mood Detection',
      'desc': 'Select your mood and get instant personalised recommendations',
      'color': AppTheme.moodMotivated,
    },
    {
      'icon': Icons.movie_filter_rounded,
      'title': 'Smart Movie Picks',
      'desc': 'Thousands of movies curated by TMDB based on your emotion',
      'color': AppTheme.primary,
    },
    {
      'icon': Icons.music_note_rounded,
      'title': '30s Music Previews',
      'desc': 'Listen to Deezer song previews directly inside the app',
      'color': AppTheme.secondary,
    },
    {
      'icon': Icons.favorite_rounded,
      'title': 'Favourites',
      'desc': 'Save songs and movies to your personal favourites list',
      'color': AppTheme.error,
    },
    {
      'icon': Icons.history_rounded,
      'title': 'Watch History',
      'desc': 'Track everything you have watched and listened to',
      'color': AppTheme.moodBored,
    },
    {
      'icon': Icons.cloud_sync_rounded,
      'title': 'Cloud Sync',
      'desc': 'Your data stays in sync across all your devices via Firebase',
      'color': AppTheme.moodAnxious,
    },
  ];

  Widget _buildFeatureTile(
    BuildContext context,
    IconData icon,
    String title,
    String desc,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadowSM,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: AppTheme.bodyRegular(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: AppTheme.caption(context),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 18),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _linkRow(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: AppTheme.bodyRegular(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.open_in_new_rounded,
              color: AppTheme.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _ackTile(
    BuildContext context,
    String emoji,
    String name,
    String desc,
  ) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: AppTheme.bodyRegular(context),
                ),
              ),
              Text(
                desc,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: AppTheme.caption(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider() =>
      Divider(height: 1, color: AppTheme.border, indent: 16, endIndent: 16);
}
