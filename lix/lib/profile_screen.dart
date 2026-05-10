import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'favourites_screen.dart';
import 'history_screen.dart';
import 'notifications_screen.dart';
import 'dark_mode_screen.dart';
import 'language_screen.dart';
import 'help_support_screen.dart';
import 'about_screen.dart';
import 'language_service.dart';
import 'home_screen.dart';
import 'movies_screen.dart';
import 'music_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color _purple = Color(0xFF7C3AED);
  static const Color _bgColor = Color(0xFFF2F2F7);
  static const Color _cardBg = Color(0xFFFFFFFF);
  static const Color _textDark = Color(0xFF1C1C1E);
  static const Color _textGrey = Color(0xFF8E8E93);

  final User? _user = FirebaseAuth.instance.currentUser;

  // ✅ Fixed: use singleton instead of new instance
  LanguageService get _lang => LanguageService.instance;

  int _selectedNav = 3;

  static const List<Map<String, dynamic>> _stats = [
    {'label': 'Movies\nWatched', 'value': '142', 'color': Color(0xFF7C3AED)},
    {'label': 'Songs\nPlayed', 'value': '389', 'color': Color(0xFFE91E8C)},
    {'label': 'Moods\nTracked', 'value': '68', 'color': Color(0xFFFF9500)},
  ];

  static const List<Map<String, dynamic>> _favouriteMoods = [
    {
      'mood': 'Happy',
      'emoji': '⭐',
      'count': '47 times',
      'color': Color(0xFFFFCC00),
    },
    {
      'mood': 'Motivated',
      'emoji': '🎵',
      'count': '32 times',
      'color': Color(0xFF7C3AED),
    },
    {
      'mood': 'Romantic',
      'emoji': '💗',
      'count': '21 times',
      'color': Color(0xFFFF2D55),
    },
  ];

  List<Map<String, dynamic>> get _menuItems => [
    {
      'icon': Icons.favorite_rounded,
      'label': 'Favourites',
      'color': const Color(0xFFFF2D55),
      'action': 'favourites',
    },
    {
      'icon': Icons.history,
      'label': 'History',
      'color': const Color(0xFF7C3AED),
      'action': 'history',
    },
    {
      'icon': Icons.notifications_rounded,
      'label': 'Notifications',
      'color': const Color(0xFFFF9500),
      'action': 'notifications',
    },
    {
      'icon': Icons.language,
      'label': 'Language',
      'color': const Color(0xFF34C759),
      'action': 'language',
    },
    {
      'icon': Icons.dark_mode_rounded,
      'label': 'Dark Mode',
      'color': const Color(0xFF1C1C1E),
      'action': 'darkmode',
    },
    {
      'icon': Icons.help_rounded,
      'label': 'Help and Support',
      'color': const Color(0xFF30B0C7),
      'action': 'help',
    },
    {
      'icon': Icons.info_rounded,
      'label': 'About Lix',
      'color': const Color(0xFF8E8E93),
      'action': 'about',
    },
  ];

  // ✅ Fixed: duplicate _ parameter names → __, __
  Route _slideRoute(Widget page) => PageRouteBuilder(
    pageBuilder: (_, animation, _) => page,
    transitionsBuilder: (_, animation, _, child) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    ),
    transitionDuration: const Duration(milliseconds: 300),
  );

  void _logout() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Log Out',
          style: TextStyle(color: _textDark, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: _textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: _textGrey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseAuth.instance.signOut();
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _handleMenuTap(Map<String, dynamic> item) {
    HapticFeedback.lightImpact();
    switch (item['action'] as String) {
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
            content: Text('${item['label']} coming soon!'),
            backgroundColor: _purple,
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lang,
      builder: (context, _) {
        final displayName = _user?.displayName ?? 'Lix User';
        final email = _user?.email ?? 'user@lix.app';
        final photoUrl = _user?.photoURL;

        return Scaffold(
          backgroundColor: _bgColor,
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // ── Profile Header ─────────────────────────
                Container(
                  width: double.infinity,
                  color: _cardBg,
                  padding: const EdgeInsets.fromLTRB(16, 56, 16, 24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.pop(context);
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                size: 18,
                                color: _textDark,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            'Profile',
                            style: TextStyle(
                              color: _textDark,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 26),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Avatar
                      Stack(
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFB06BF5), Color(0xFF7C3AED)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              image: photoUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(photoUrl),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: _purple.withOpacity(0.35),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: photoUrl == null
                                ? Center(
                                    child: Text(
                                      displayName.isNotEmpty
                                          ? displayName[0].toUpperCase()
                                          : 'L',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 34,
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
                                      backgroundColor: _purple,
                                      duration: const Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: _purple,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: _cardBg, width: 2),
                                ),
                                child: const Icon(
                                  Icons.edit_outlined,
                                  color: Colors.white,
                                  size: 11,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Text(
                        displayName,
                        style: const TextStyle(
                          color: _textDark,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.4,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        email,
                        style: const TextStyle(color: _textGrey, fontSize: 13),
                      ),

                      const SizedBox(height: 14),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                          ),
                          borderRadius: BorderRadius.circular(99),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Premium Member',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Stats Row ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _cardBg,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: List.generate(_stats.length, (i) {
                        final stat = _stats[i];
                        final color = stat['color'] as Color;
                        final isLast = i == _stats.length - 1;
                        return Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: !isLast
                                  ? const Border(
                                      right: BorderSide(
                                        color: Color(0xFFE5E5EA),
                                        width: 1,
                                      ),
                                    )
                                  : null,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            child: Column(
                              children: [
                                Text(
                                  stat['value'] as String,
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  stat['label'] as String,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: _textGrey,
                                    fontSize: 11,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Your Top Moods ─────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _lang.translate('Your Top Moods'),
                        style: const TextStyle(
                          color: _textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(_favouriteMoods.length, (i) {
                          final item = _favouriteMoods[i];
                          final isLast = i == _favouriteMoods.length - 1;
                          return Expanded(
                            child: Container(
                              margin: EdgeInsets.only(right: isLast ? 0 : 10),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: _cardBg,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    item['emoji'] as String,
                                    style: const TextStyle(fontSize: 26),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _lang.translate(item['mood'] as String),
                                    style: const TextStyle(
                                      color: _textDark,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item['count'] as String,
                                    style: const TextStyle(
                                      color: _textGrey,
                                      fontSize: 11,
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

                const SizedBox(height: 20),

                // ── Settings ───────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _lang.translate('Settings'),
                        style: const TextStyle(
                          color: _textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: _cardBg,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: List.generate(_menuItems.length, (i) {
                            final item = _menuItems[i];
                            final isLast = i == _menuItems.length - 1;
                            return _buildMenuItem(item, isLast: isLast);
                          }),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Log Out ────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: _logout,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.redAccent.withOpacity(0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            color: Colors.redAccent,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Log Out',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
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
          bottomNavigationBar: _buildBottomNav(context),
        );
      },
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item, {bool isLast = false}) {
    final color = item['color'] as Color;
    return GestureDetector(
      onTap: () => _handleMenuTap(item),
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    _lang.translate(item['label'] as String),
                    style: const TextStyle(
                      color: _textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: _textGrey, size: 18),
              ],
            ),
          ),
          if (!isLast)
            const Divider(
              height: 1,
              thickness: 1,
              indent: 64,
              endIndent: 0,
              color: Color(0xFFF2F2F7),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.movie_outlined, 'label': 'Movies'},
      {'icon': Icons.music_note_outlined, 'label': 'Music'},
      {'icon': Icons.person_rounded, 'label': 'Profile'},
    ];

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: _cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final isActive = _selectedNav == i;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _selectedNav = i);
                if (i == 0) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    _slideRoute(const HomeScreen()),
                    (r) => false,
                  );
                }
                if (i == 1) {
                  Navigator.pushReplacement(
                    context,
                    _slideRoute(MoviesScreen(mood: 'Happy')),
                  );
                }
                if (i == 2) {
                  Navigator.pushReplacement(
                    context,
                    _slideRoute(MusicScreen(mood: 'Happy')),
                  );
                }
              },
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    items[i]['icon'] as IconData,
                    color: isActive ? _purple : _textGrey,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _lang.translate(items[i]['label'] as String),
                    style: TextStyle(
                      color: isActive ? _purple : _textGrey,
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isActive ? 18 : 0,
                    height: isActive ? 3 : 0,
                    decoration: BoxDecoration(
                      color: _purple,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
