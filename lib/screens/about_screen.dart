import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/responsive.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
          'About Lix',
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: CenteredContent(
        maxWidth: 800,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.secondary],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: Text(
                    'L',
                    style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Lix', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Mood-Based Movies & Music', style: TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 24),
              const Text(
                'Lix is a responsive, cross-platform application designed to provide rich movie and music recommendations tailored to your exact emotional state.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
