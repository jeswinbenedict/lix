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

  void _logout() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: const Text(
          'Log Out',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: const Text(
          'Are you sure you want to log out of your account?',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size(100, 44),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseAuth.instance.signOut();
            },
            child: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8, top: 20),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadowSM,
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required Color iconBgColor,
    required String title,
    String? subtitle,
    Widget? trailingWidget,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                // iOS Squircle Icon Container
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: iconBgColor.withAlpha(50),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                trailingWidget ??
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFFCBD5E1),
                      size: 22,
                    ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            indent: 66,
            endIndent: 16,
            color: Color(0xFFF1F5F9),
          ),
      ],
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
                fontWeight: FontWeight.w800,
                fontSize: AppTheme.heading2(context),
                letterSpacing: -0.4,
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
              maxWidth: 700,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  // Apple Hero Profile Header Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                      border: Border.all(color: AppTheme.border),
                      boxShadow: AppTheme.shadowSM,
                    ),
                    child: Row(
                      children: [
                        // Avatar with Gradient Ring
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: AppTheme.shadowPrimary,
                          ),
                          child: CircleAvatar(
                            radius: 34,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 32,
                              backgroundColor: AppTheme.primaryLight,
                              child: Text(
                                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                                style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      displayName,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.textPrimary,
                                        letterSpacing: -0.4,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryLight,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'Member',
                                      style: TextStyle(
                                        color: AppTheme.primary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                email,
                                style: const TextStyle(
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

                  // Section 1: My Content
                  _buildSectionHeader(_lang.translate('Library & Saved Content')),
                  _buildSettingsGroup([
                    _buildSettingsItem(
                      icon: Icons.favorite_rounded,
                      iconBgColor: const Color(0xFFDC2626),
                      title: _lang.translate('Favorites'),
                      subtitle: 'Saved movies and audio tracks',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FavouritesScreen()),
                      ),
                    ),
                    _buildSettingsItem(
                      icon: Icons.history_rounded,
                      iconBgColor: AppTheme.primary,
                      title: _lang.translate('Watch & Playback History'),
                      subtitle: 'Recent activity logs',
                      showDivider: false,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HistoryScreen()),
                      ),
                    ),
                  ]),

                  // Section 2: Preferences
                  _buildSectionHeader(_lang.translate('Preferences & Configuration')),
                  _buildSettingsGroup([
                    _buildSettingsItem(
                      icon: Icons.notifications_rounded,
                      iconBgColor: const Color(0xFFD97706),
                      title: _lang.translate('Notifications'),
                      subtitle: 'System alerts and recommendations',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                      ),
                    ),
                    _buildSettingsItem(
                      icon: Icons.language_rounded,
                      iconBgColor: const Color(0xFF059669),
                      title: _lang.translate('Language'),
                      trailingWidget: Row(
                        children: [
                          Text(
                            _lang.language,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFFCBD5E1),
                            size: 22,
                          ),
                        ],
                      ),
                      showDivider: false,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LanguageScreen()),
                      ),
                    ),
                  ]),

                  // Section 3: Support & Info
                  _buildSectionHeader(_lang.translate('Support & Legal Information')),
                  _buildSettingsGroup([
                    _buildSettingsItem(
                      icon: Icons.help_rounded,
                      iconBgColor: const Color(0xFF0EA5E9),
                      title: _lang.translate('Help & Support'),
                      subtitle: 'Technical assistance and documentation',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                      ),
                    ),
                    _buildSettingsItem(
                      icon: Icons.info_rounded,
                      iconBgColor: const Color(0xFF64748B),
                      title: _lang.translate('About Lix'),
                      subtitle: 'Version 2.0.0 (Build 2026)',
                      showDivider: false,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AboutScreen()),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Section 4: iOS Destructive Action Group (Log Out)
                  _buildSettingsGroup([
                    _buildSettingsItem(
                      icon: Icons.logout_rounded,
                      iconBgColor: const Color(0xFFDC2626),
                      title: _lang.translate('Sign Out'),
                      trailingWidget: const SizedBox.shrink(),
                      showDivider: false,
                      onTap: _logout,
                    ),
                  ]),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
