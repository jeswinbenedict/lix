import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // ✅ NEW
import 'firebase_options.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'app_theme.dart';
import 'theme_service.dart';
import 'language_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await ThemeService().init();
  await LanguageService().init();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const LixApp());
}

class LixApp extends StatelessWidget {
  const LixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService(),
      builder: (context, _) => ListenableBuilder(
        listenable: LanguageService(),
        builder: (context, _) => MaterialApp(
          title: 'Lix',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeService().themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          locale: LanguageService().locale,
          supportedLocales: LanguageService.supportedLocales,
          localizationsDelegates: const [
            // ✅ NEW
            GlobalMaterialLocalizations.delegate, // ✅ NEW
            GlobalWidgetsLocalizations.delegate, // ✅ NEW
            GlobalCupertinoLocalizations.delegate, // ✅ NEW
          ], // ✅ NEW
          home: const _AuthGate(),
        ),
      ),
    );
  }
}

// ── Auth Gate ─────────────────────────────────────────────────
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppTheme.background,
            body: Center(
              child: CircularProgressIndicator(
                color: AppTheme.primary,
                strokeWidth: 2.5,
              ),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
