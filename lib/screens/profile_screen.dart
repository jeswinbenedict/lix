import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/app_theme.dart';
import '../core/responsive.dart';
import '../services/language_service.dart';
import 'favourites_screen.dart';
import 'history_screen.dart';
import 'notifications_screen.dart';
import 'language_screen.dart';
import 'help_support_screen.dart';
import 'about_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  LanguageService get _lang => LanguageService.instance;

  List<Map<String, dynamic>> get _menuItems => [
    {
      'icon': Icons.favorite_rounded,
      'label': _lang.translate('Favourites'),
      'color': const Color(0xFFFF2D55),
      'screen': const FavouritesScreen(),
    },
    {
      'icon': Icons.history,
      'label': _lang.translate('History'),
      'color': AppTheme.primary,
      'screen': const HistoryScreen(),
    },
    {
      'icon': Icons.notifications_rounded,
      'label': _lang.translate('Notifications'),
      'color': const Color(0xFFFF9500),
      'screen': const NotificationsScreen(),
    },
    {
      'icon': Icons.language,
      'label': _lang.translate('Language'),
      'color': const Color(0xFF34C759),
      'screen': const LanguageScreen(),
    },
    {
      'icon': Icons.help_rounded,
      'label': _lang.translate('Help & Support'),
      'color': const Color(0xFF30B0C7),
      'screen': const HelpSupportScreen(),
    },
    {
      'icon': Icons.info_rounded,
      'label': _lang.translate('About Lix'),
      'color': AppTheme.textSecondary,
      'screen': const AboutScreen(),
    },
  ];

  void _logout() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lang,
      builder: (context, _) {
        final displayName = _user?.displayName ?? 'Lix User';
        final email = _user?.email ?? 'user@lix.app';

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: AppTheme.surface,
            elevation: 0,
            title: Text(
              _lang.translate('Profile'),
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: AppTheme.heading2(context),
              ),
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
                children: [
                  const SizedBox(height: 24),
                  // User info header card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                      border: Border.all(color: AppTheme.border),
                      boxShadow: AppTheme.shadowSM,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: AppTheme.primary,
                          child: Text(
                            displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                email,
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Settings list options
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                      border: Border.all(color: AppTheme.border),
                      boxShadow: AppTheme.shadowSM,
                    ),
                    child: Column(
                      children: _menuItems.map((item) {
                        return ListTile(
                          leading: Icon(item['icon'] as IconData, color: item['color'] as Color),
                          title: Text(
                            item['label'] as String,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => item['screen'] as Widget),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Log Out Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                      ),
                    ),
                    onPressed: _logout,
                    child: Text(
                      _lang.translate('Logout'),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
