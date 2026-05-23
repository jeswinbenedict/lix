import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'app_theme.dart';
import 'theme_service.dart';
import 'language_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
    debugPrint('✅ .env loaded successfully');
    debugPrint('✅ dotenv keys: ${dotenv.env.keys.toList()}');
    debugPrint(
      '✅ GEMINI_API_KEY present: ${dotenv.env.containsKey('GEMINI_API_KEY')}',
    );
    debugPrint('✅ GEMINI_API_KEY raw: ${dotenv.env['GEMINI_API_KEY']}');
    debugPrint(
      '✅ GEMINI_API_KEY not empty: ${(dotenv.env['GEMINI_API_KEY'] ?? '').trim().isNotEmpty}',
    );
    debugPrint(
      '✅ GEMINI_API_KEY length: ${(dotenv.env['GEMINI_API_KEY'] ?? '').length}',
    );
  } catch (e, st) {
    debugPrint('🔴 Failed to load .env: $e');
    debugPrint('🔴 .env stack: $st');
  }

  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('🔴 FLUTTER ERROR: ${details.exception}');
    debugPrint('🔴 STACK: ${details.stack}');
  };

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized');
  } catch (e) {
    debugPrint('⚠️ Firebase init skipped: $e');
  }

  await ThemeService.instance.init();
  debugPrint('✅ ThemeService done');

  await LanguageService.instance.init();
  debugPrint('✅ LanguageService done');

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  debugPrint('✅ Calling runApp...');
  runApp(const LixApp());
}

class LixApp extends StatelessWidget {
  const LixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, _) => ListenableBuilder(
        listenable: LanguageService.instance,
        builder: (context, _) => MaterialApp(
          title: 'Lix',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeService.instance.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          locale: LanguageService.instance.locale,
          supportedLocales: LanguageService.supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const _AuthGate(),
        ),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        debugPrint(
          '🔵 Auth state: ${snapshot.connectionState}, hasData: ${snapshot.hasData}, error: ${snapshot.error}',
        );

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

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: AppTheme.background,
            body: Center(
              child: Text(
                'Auth error: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          debugPrint('✅ User logged in → HomeScreen');
          return const HomeScreen();
        }

        debugPrint('✅ No user → LoginScreen');
        return const LoginScreen();
      },
    );
  }
}
