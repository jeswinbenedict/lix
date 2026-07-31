import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_theme.dart';
import '../core/responsive.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final List<Map<String, String>> _faqs = const [
    {
      'q': 'How does mood-based recommendation work?',
      'a': 'Lix analyses your selected mood and uses TMDB & iTunes APIs to fetch movies and songs that best match your emotional state.',
    },
    {
      'q': 'Why is the 30-second preview not playing?',
      'a': 'Some songs on iTunes/Deezer do not have a public preview available. Try a different song or check your internet connection.',
    },
    {
      'q': 'How do I add a song or movie to Favourites?',
      'a': 'Tap the heart icon on any song player screen or movie detail screen.',
    },
    {
      'q': 'How do I change the app language?',
      'a': 'Go to Profile → Language and select your preferred language.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary, size: 18),
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: CenteredContent(
        maxWidth: 800,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Frequently Asked Questions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...List.generate(_faqs.length, (i) {
                return ExpansionTile(
                  title: Text(_faqs[i]['q']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(_faqs[i]['a']!, style: const TextStyle(color: AppTheme.textSecondary, height: 1.5)),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.email, color: Colors.white),
                label: const Text('Contact Support via Email', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: () async {
                  final uri = Uri.parse('mailto:support@lixapp.com?subject=Lix Support');
                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
