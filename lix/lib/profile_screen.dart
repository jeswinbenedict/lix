import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_theme.dart';
import 'favourites_screen.dart';
import 'history_screen.dart';
import 'notifications_screen.dart';
import 'dark_mode_screen.dart';
import 'language_screen.dart';
import 'help_support_screen.dart';
import 'about_screen.dart';
import 'language_service.dart'; // ✅ ADD

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  final LanguageService _lang = LanguageService(); // ✅ single instance

  final List<Map<String, dynamic>> _stats = const [
    {
      'labelKey': 'Movies\nWatched', // keep as-is (not in translation map)
      'value': '24',
      'icon': Icons.movie_outlined,
      'color': AppTheme.primary,
    },
    {
      'labelKey': 'Songs\nPlayed',
      'value': '58',
      'icon': Icons.music_note,
      'color': AppTheme.secondary,
    },
    {
      'labelKey': 'Moods\nTracked',
      'value': '12',
      'icon': Icons.mood,
      'color': AppTheme.moodMotivated,
    },
  ];

  final List<Map<String, dynamic>> _favouriteMoods = const [
    {
      'mood': 'Happy',
      'emoji': '😊',
      'count': '8 times',
      'color': AppTheme.moodHappy,
    },
    {
      'mood': 'Motivated',
      'emoji': '💪',
      'count': '6 times',
      'color': AppTheme.moodMotivated,
    },
    {
      'mood': 'Romantic',
      'emoji': '😍',
      'count': '4 times',
      'color': AppTheme.moodRomantic,
    },
  ];

  // ✅ Use translation keys for labels
  List<Map<String, dynamic>> get _menuItems => [
    {
      'icon': Icons.favorite_border,
      'labelKey': 'Favourites',
      'color': AppTheme.secondary,
      'action': 'favourites',
    },
    {
      'icon': Icons.history,
      'labelKey': 'History',
      'color': AppTheme.primary,
      'action': 'history',
    },
    {
      'icon': Icons.notifications_outlined,
      'labelKey': 'Notifications',
      'color': AppTheme.moodMotivated,
      'action': 'notifications',
    },
    {
      'icon': Icons.language,
      'labelKey': 'Language',
      'color': AppTheme.moodSad,
      'action': 'language',
    },
    {
      'icon': Icons.dark_mode_outlined,
      'labelKey': 'Dark Mode',
      'color': AppTheme.moodAnxious,
      'action': 'darkmode',
    },
    {
      'icon': Icons.help_outline,
      'labelKey': 'Help & Support',
      'color': AppTheme.moodBored,
      'action': 'help',
    },
    {
      'icon': Icons.info_outline,
      'labelKey': 'About Lix',
      'color': AppTheme.warning,
      'action': 'about',
    },
  ];

  void _logout() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        ),
        title: Text(
          _lang.translate('Logout'),
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: AppTheme.heading2(context),
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: AppTheme.bodyRegular(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: AppTheme.bodyRegular(context),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              ),
              elevation: 0,
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await FirebaseAuth.instance.signOut();
            },
            child: Text(
              _lang.translate('Logout'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuTap(Map<String, dynamic> item) {
    HapticFeedback.lightImpact();
    final action = item['action'] as String? ?? 'soon';

    switch (action) {
      case 'favourites':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FavouritesScreen()),
        );
        break;
      case 'history':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HistoryScreen()),
        );
        break;
      case 'notifications':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
        );
        break;
      case 'language':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LanguageScreen()),
        );
        break;
      case 'darkmode':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DarkModeScreen()),
        );
        break;
      case 'help':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
        );
        break;
      case 'about':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AboutScreen()),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_lang.translate(item['labelKey'])} coming soon!'),
            backgroundColor: AppTheme.primary,
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Wrap entire screen with ListenableBuilder — rebuilds on language change
    return ListenableBuilder(
      listenable: _lang,
      builder: (context, _) {
        final displayName = _user?.displayName ?? 'Lix User';
        final email = _user?.email ?? 'user@lix.app';
        final photoUrl = _user?.photoURL;
        final hPad = AppTheme.horizontalPadding(context);
        final avatarR = AppTheme.avatarSize(context);

        return Scaffold(
          backgroundColor: AppTheme.background,
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // ── Profile Header ───────────────────────────
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(hPad, 56, hPad, 28),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    border: Border(bottom: BorderSide(color: AppTheme.border)),
                    boxShadow: AppTheme.shadowSM,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.background,
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusMD,
                                ),
                                border: Border.all(color: AppTheme.border),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                size: 16,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Profile', // Profile not in translation map — add if needed
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: AppTheme.heading2(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 40),
                        ],
                      ),

                      SizedBox(height: AppTheme.sectionGap(context) * 0.8),

                      // Avatar
                      Stack(
                        children: [
                          Container(
                            width: avatarR * 1.6,
                            height: avatarR * 1.6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.primary.withOpacity(0.3),
                                width: 3,
                              ),
                              boxShadow: AppTheme.shadowPrimary,
                              color: AppTheme.primaryLight,
                              image: photoUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(photoUrl),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: photoUrl == null
                                ? Center(
                                    child: Text(
                                      displayName.isNotEmpty
                                          ? displayName[0].toUpperCase()
                                          : 'L',
                                      style: TextStyle(
                                        color: AppTheme.primary,
                                        fontSize: AppTheme.heading1(context),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: GestureDetector(
                              onTap: () =>
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'Edit profile coming soon!',
                                      ),
                                      backgroundColor: AppTheme.primary,
                                      duration: const Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppTheme.radiusMD,
                                        ),
                                      ),
                                    ),
                                  ),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.surface,
                                    width: 2,
                                  ),
                                  boxShadow: AppTheme.shadowPrimary,
                                ),
                                child: const Icon(
                                  Icons.edit_outlined,
                                  color: Colors.white,
                                  size: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: AppTheme.sectionGap(context) * 0.5),

                      Text(
                        displayName,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: AppTheme.heading1(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: AppTheme.bodyRegular(context),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Premium Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                          ),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusFull,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.warning.withOpacity(0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.white,
                              size: 15,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Premium Member',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: AppTheme.bodyRegular(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppTheme.sectionGap(context) * 0.7),

                // ── Stats Row ────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: Row(
                    children: List.generate(_stats.length, (i) {
                      final stat = _stats[i];
                      final color = stat['color'] as Color;
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(
                            right: i < _stats.length - 1 ? 10 : 0,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusLG,
                            ),
                            border: Border.all(color: color.withOpacity(0.25)),
                            boxShadow: AppTheme.shadowSM,
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  stat['icon'] as IconData,
                                  color: color,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                stat['value'],
                                style: TextStyle(
                                  color: color,
                                  fontSize: AppTheme.heading2(context),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                stat['labelKey'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: AppTheme.caption(context),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                SizedBox(height: AppTheme.sectionGap(context)),

                // ── Top Moods ────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _lang.translate('Your Top Moods'), // ✅ translated
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: AppTheme.heading2(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(_favouriteMoods.length, (i) {
                          final item = _favouriteMoods[i];
                          final color = item['color'] as Color;
                          return Expanded(
                            child: Container(
                              margin: EdgeInsets.only(
                                right: i < _favouriteMoods.length - 1 ? 10 : 0,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusLG,
                                ),
                                border: Border.all(
                                  color: color.withOpacity(0.3),
                                ),
                                boxShadow: AppTheme.shadowSM,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    item['emoji'],
                                    style: TextStyle(
                                      fontSize: AppTheme.isSmall(context)
                                          ? 24
                                          : 28,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item['mood'],
                                    style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: AppTheme.bodyRegular(context),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item['count'],
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: AppTheme.caption(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppTheme.sectionGap(context)),

                // ── Settings Menu ─────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _lang.translate('Settings'), // ✅ translated
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: AppTheme.heading2(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._menuItems.map((item) => _buildMenuItem(item)),
                    ],
                  ),
                ),

                SizedBox(height: AppTheme.sectionGap(context) * 0.7),

                // ── Logout ────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: GestureDetector(
                    onTap: _logout,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                        border: Border.all(
                          color: AppTheme.error.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.logout_outlined,
                            color: AppTheme.error,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _lang.translate('Logout'), // ✅ translated
                            style: TextStyle(
                              color: AppTheme.error,
                              fontSize: AppTheme.bodyLarge(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
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

  Widget _buildMenuItem(Map<String, dynamic> item) {
    final color = item['color'] as Color;
    return GestureDetector(
      onTap: () => _handleMenuTap(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              ),
              child: Icon(item['icon'] as IconData, color: color, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                _lang.translate(item['labelKey']), // ✅ translated
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: AppTheme.bodyRegular(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
