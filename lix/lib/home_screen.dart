import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'movies_screen.dart';
import 'music_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'app_theme.dart';
import 'language_service.dart'; // ✅ ADD

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LanguageService _lang = LanguageService(); // ✅ ADD

  // ✅ Mood labels are kept in English as keys (used to fetch movies/music)
  // but displayed via translate() so they show in selected language
  final List<Map<String, dynamic>> _moods = const [
    {'label': 'Happy', 'emoji': '😊', 'color': AppTheme.moodHappy},
    {'label': 'Sad', 'emoji': '😢', 'color': AppTheme.moodSad},
    {'label': 'Anxious', 'emoji': '😰', 'color': AppTheme.moodAnxious},
    {'label': 'Bored', 'emoji': '😴', 'color': AppTheme.moodBored},
    {'label': 'Motivated', 'emoji': '💪', 'color': AppTheme.moodMotivated},
    {'label': 'Romantic', 'emoji': '😍', 'color': AppTheme.moodRomantic},
  ];

  Route _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, animation, _) => page,
      transitionsBuilder: (_, animation, _, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  Route _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Wrap entire screen — rebuilds whenever language changes
    return ListenableBuilder(
      listenable: _lang,
      builder: (context, _) {
        final hPad = AppTheme.horizontalPadding(context);
        final user = FirebaseAuth.instance.currentUser;
        final name =
            (user?.displayName != null && user!.displayName!.isNotEmpty)
            ? user.displayName!.split(' ').first
            : 'there';
        final photo = user?.photoURL;
        final columns = AppTheme.gridColumns(context);

        return Scaffold(
          backgroundColor: AppTheme.background,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, $name 👋',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: AppTheme.bodyRegular(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'How are you feeling?',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: AppTheme.heading1(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            _slideRoute(const ProfileScreen()),
                          );
                        },
                        child: Container(
                          width: AppTheme.avatarSize(context),
                          height: AppTheme.avatarSize(context),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryLight,
                            boxShadow: AppTheme.shadowSM,
                            border: Border.all(
                              color: AppTheme.primary.withOpacity(0.3),
                              width: 2,
                            ),
                            image: photo != null
                                ? DecorationImage(
                                    image: NetworkImage(photo),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: photo == null
                              ? Center(
                                  child: Text(
                                    name.isNotEmpty
                                        ? name[0].toUpperCase()
                                        : 'L',
                                    style: TextStyle(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: AppTheme.heading2(context),
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Subtitle ────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 0),
                  child: Text(
                    'Pick a mood to get personalized picks 🎬🎵',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: AppTheme.bodyRegular(context),
                    ),
                  ),
                ),

                SizedBox(height: AppTheme.sectionGap(context)),

                // ── Mood Grid ───────────────────────────────
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: hPad),
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: AppTheme.isXSmall(context)
                            ? 1.1
                            : 1.2,
                      ),
                      itemCount: _moods.length,
                      itemBuilder: (ctx, index) {
                        final mood = _moods[index];
                        final color = mood['color'] as Color;
                        return _MoodCard(
                          emoji: mood['emoji'],
                          // ✅ translate the mood label for display
                          label: _lang.translate(mood['label']),
                          color: color,
                          // ✅ pass original English label to mood options
                          onTap: () => _showMoodOptions(ctx, mood['label']),
                        );
                      },
                    ),
                  ),
                ),

                // ── Bottom Nav ──────────────────────────────
                Container(
                  margin: EdgeInsets.fromLTRB(hPad, 8, hPad, 16),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                    boxShadow: AppTheme.shadowMD,
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    children: [
                      _navItem(
                        context,
                        icon: Icons.movie_outlined,
                        label: _lang.translate('Movies'), // ✅
                        color: AppTheme.primary,
                        onTap: () => Navigator.push(
                          context,
                          _slideRoute(MoviesScreen(mood: 'Happy')),
                        ),
                      ),
                      _navItem(
                        context,
                        icon: Icons.music_note_outlined,
                        label: _lang.translate('Music'), // ✅
                        color: AppTheme.secondary,
                        onTap: () => Navigator.push(
                          context,
                          _slideRoute(MusicScreen(mood: 'Happy')),
                        ),
                      ),
                      _navItem(
                        context,
                        icon: Icons.chat_bubble_outline,
                        label: _lang.translate('Chat'), // ✅
                        color: AppTheme.accent,
                        onTap: () =>
                            Navigator.push(context, _slideRoute(ChatScreen())),
                      ),
                      _navItem(
                        context,
                        icon: Icons.person_outline,
                        label: _lang.translate('Profile'), // ✅
                        color: AppTheme.warning,
                        onTap: () => Navigator.push(
                          context,
                          _slideRoute(const ProfileScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _navItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: AppTheme.isSmall(context) ? 10 : 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: AppTheme.caption(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMoodOptions(BuildContext context, String moodKey) {
    HapticFeedback.mediumImpact();
    final emojiMap = {
      'Happy': '😊',
      'Sad': '😢',
      'Anxious': '😰',
      'Bored': '😴',
      'Motivated': '💪',
      'Romantic': '😍',
    };
    final emoji = emojiMap[moodKey] ?? '🎭';
    // ✅ translate mood label for display, keep moodKey in English for API
    final moodDisplay = _lang.translate(moodKey);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXL),
        ),
      ),
      builder: (sheetCtx) {
        final hPad = AppTheme.horizontalPadding(context);
        return Padding(
          padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
              ),
              SizedBox(height: AppTheme.sectionGap(context) * 0.7),
              Text(
                '$emoji  $moodDisplay?', // ✅ translated mood name
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: AppTheme.heading2(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'What would you like today?',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: AppTheme.bodyRegular(context),
                ),
              ),
              SizedBox(height: AppTheme.sectionGap(context)),
              Row(
                children: [
                  _sheetBtn(
                    context,
                    label: '🎬 ${_lang.translate('Movies')}', // ✅
                    color: AppTheme.primary,
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      Navigator.push(
                        context,
                        _fadeRoute(MoviesScreen(mood: moodKey)),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  _sheetBtn(
                    context,
                    label: '🎵 ${_lang.translate('Music')}', // ✅
                    color: AppTheme.secondary,
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      Navigator.push(
                        context,
                        _fadeRoute(MusicScreen(mood: moodKey)),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  _sheetBtn(
                    context,
                    label: '💬 ${_lang.translate('Chat')}', // ✅
                    color: AppTheme.accent,
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      Navigator.push(context, _slideRoute(ChatScreen()));
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sheetBtn(
    BuildContext context, {
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: AppTheme.bodyRegular(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Mood Card ─────────────────────────────────────────────────
class _MoodCard extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MoodCard({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          boxShadow: AppTheme.shadowSM,
        ),
        child: Stack(
          children: [
            Positioned(
              top: -10,
              right: -10,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    emoji,
                    style: TextStyle(
                      fontSize: AppTheme.isXSmall(context) ? 32 : 38,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    label, // ✅ already translated before passing in
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: AppTheme.bodyLarge(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 3,
                    width: 24,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
