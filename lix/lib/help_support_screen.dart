import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_theme.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  int? _expandedFaq;

  final List<Map<String, String>> _faqs = const [
    {
      'q': 'How does mood-based recommendation work?',
      'a':
          'Lix analyses your selected mood and uses TMDB & Deezer APIs to fetch movies and songs that best match your emotional state. Each mood maps to specific genres and vibes.',
    },
    {
      'q': 'Why is the 30-second preview not playing?',
      'a':
          'Some songs on Deezer do not have a public preview available. This is a restriction from the music provider. Try a different song or check your internet connection.',
    },
    {
      'q': 'How do I add a song or movie to Favourites?',
      'a':
          'Tap the heart ❤️ icon on any song player screen or movie detail screen. Your favourites are saved to your account and synced across devices via Firebase.',
    },
    {
      'q': 'Where is my Watch History saved?',
      'a':
          'Your watch history is stored securely in Firebase Firestore under your account. It includes both songs and movies you have opened, with timestamps.',
    },
    {
      'q': 'Can I use Lix without signing in?',
      'a':
          'No. Lix requires a Google account to personalise your experience, save favourites, history, and sync your preferences across devices.',
    },
    {
      'q': 'How do I change the app language?',
      'a':
          'Go to Profile → Language and select from 22 Indian languages or 20 major foreign languages. Your preference is saved locally on your device.',
    },
    {
      'q': 'Is my data safe?',
      'a':
          'Yes. Lix uses Firebase Authentication and Firestore with strict security rules. We never share your personal data with third parties.',
    },
    {
      'q': 'How do I report a bug or give feedback?',
      'a':
          'Use the "Send Feedback" option below or email us directly at support@lixapp.com. We respond within 24–48 hours.',
    },
  ];

  final List<Map<String, dynamic>> _contactOptions = [
    {
      'icon': Icons.email_outlined,
      'label': 'Email Support',
      'desc': 'support@lixapp.com',
      'color': AppTheme.primary,
      'action': 'email',
    },
    {
      'icon': Icons.chat_bubble_outline_rounded,
      'label': 'Live Chat',
      'desc': 'Usually replies in minutes',
      'color': AppTheme.moodMotivated,
      'action': 'chat',
    },
    {
      'icon': Icons.bug_report_outlined,
      'label': 'Report a Bug',
      'desc': 'Help us improve Lix',
      'color': AppTheme.error,
      'action': 'bug',
    },
    {
      'icon': Icons.star_outline_rounded,
      'label': 'Rate the App',
      'desc': 'Love Lix? Leave a review!',
      'color': AppTheme.warning,
      'action': 'rate',
    },
  ];

  Future<void> _handleContact(String action) async {
    HapticFeedback.lightImpact();
    switch (action) {
      case 'email':
        final uri = Uri.parse('mailto:support@lixapp.com?subject=Lix Support');
        if (await canLaunchUrl(uri)) await launchUrl(uri);
        break;
      case 'chat':
      case 'bug':
        final uri = Uri.parse(
          'mailto:support@lixapp.com?subject=Bug Report - Lix App',
        );
        if (await canLaunchUrl(uri)) await launchUrl(uri);
        break;
      case 'rate':
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Rating coming soon on Play Store!'),
              backgroundColor: AppTheme.primary,
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              ),
            ),
          );
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Help & Support',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.horizontalPadding(context),
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Banner ────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary.withOpacity(0.15),
                    AppTheme.secondary.withOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: AppTheme.primary,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'How can we help?',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: AppTheme.heading2(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Browse FAQs or reach out to our\nsupport team anytime.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: AppTheme.bodyRegular(context),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Contact Options ────────────────────────
            Text(
              'Contact Us',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: AppTheme.heading2(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: _contactOptions.map((opt) {
                final color = opt['color'] as Color;
                return GestureDetector(
                  onTap: () => _handleContact(opt['action'] as String),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                      border: Border.all(color: AppTheme.border),
                      boxShadow: AppTheme.shadowSM,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusSM,
                            ),
                          ),
                          child: Icon(
                            opt['icon'] as IconData,
                            color: color,
                            size: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          opt['label'] as String,
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: AppTheme.caption(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          opt['desc'] as String,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: AppTheme.caption(context) - 1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            // ── FAQs ───────────────────────────────────
            Row(
              children: [
                Text(
                  'FAQs',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: AppTheme.heading2(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Text(
                    '${_faqs.length}',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ...List.generate(_faqs.length, (i) {
              final isOpen = _expandedFaq == i;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _expandedFaq = isOpen ? null : i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isOpen
                        ? AppTheme.primary.withOpacity(0.05)
                        : AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    border: Border.all(
                      color: isOpen
                          ? AppTheme.primary.withOpacity(0.3)
                          : AppTheme.border,
                    ),
                    boxShadow: AppTheme.shadowSM,
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: isOpen
                                    ? AppTheme.primary
                                    : AppTheme.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    color: isOpen
                                        ? Colors.white
                                        : AppTheme.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _faqs[i]['q']!,
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: AppTheme.bodyRegular(context),
                                  fontWeight: isOpen
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                            Icon(
                              isOpen
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: isOpen
                                  ? AppTheme.primary
                                  : AppTheme.textSecondary,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                      if (isOpen)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(54, 0, 16, 16),
                          child: Text(
                            _faqs[i]['a']!,
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: AppTheme.bodyRegular(context),
                              height: 1.6,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 28),

            // ── Still need help ────────────────────────
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
                  const Icon(
                    Icons.headset_mic_outlined,
                    color: AppTheme.primary,
                    size: 32,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Still need help?',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: AppTheme.bodyLarge(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Our team is available 24/7',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: AppTheme.caption(context),
                    ),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => _handleContact('email'),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                        boxShadow: AppTheme.shadowPrimary,
                      ),
                      child: const Text(
                        'Contact Support',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
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
  }
}
