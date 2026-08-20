import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lix/services/recommendation_service.dart';
import 'package:lix/services/global_audio_service.dart';
import 'package:lix/services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    const MethodChannel globalChannel = MethodChannel('xyz.luan/audioplayers.global');
    const MethodChannel playerChannel = MethodChannel('xyz.luan/audioplayers');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(globalChannel, (MethodCall methodCall) async {
      return 1;
    });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(playerChannel, (MethodCall methodCall) async {
      return 1;
    });
  });

  group('RecommendationService Mood Detection Tests', () {
    test('Detects mood from exact keywords', () {
      expect(RecommendationService.detectMood('I feel very happy today'), 'Happy');
      expect(RecommendationService.detectMood('Feeling sad and down'), 'Sad');
      expect(RecommendationService.detectMood('So anxious about tomorrow'), 'Anxious');
      expect(RecommendationService.detectMood('I am so bored at home'), 'Bored');
      expect(RecommendationService.detectMood('Time to hit the gym, feeling motivated'), 'Motivated');
      expect(RecommendationService.detectMood('Going on a romantic date with my love'), 'Romantic');
    });

    test('Detects mood from emojis', () {
      expect(RecommendationService.detectMood('Today was amazing 🎉✨'), 'Happy');
      expect(RecommendationService.detectMood('Terrible day 😭💔'), 'Sad');
      expect(RecommendationService.detectMood('Need to calm down 😰🧘‍♂️'), 'Anxious');
      expect(RecommendationService.detectMood('Nothing to do 🥱😴'), 'Bored');
      expect(RecommendationService.detectMood('Let us crush this workout 💪🔥⚡'), 'Motivated');
      expect(RecommendationService.detectMood('Thinking of you ❤️🥰🌹'), 'Romantic');
    });

    test('Detects mood from contextual phrases', () {
      expect(RecommendationService.detectMood('I want upbeat dance music'), 'Happy');
      expect(RecommendationService.detectMood('Had a painful heartbreak'), 'Sad');
      expect(RecommendationService.detectMood('Help me meditate and soothe my nerves'), 'Anxious');
      expect(RecommendationService.detectMood('Such a tedious slow day with nothing to do'), 'Bored');
      expect(RecommendationService.detectMood('Time to hustle and stay on the grind'), 'Motivated');
      expect(RecommendationService.detectMood('Looking for a slow dance with my sweetheart'), 'Romantic');
    });

    test('Defaults to Happy for neutral or empty input', () {
      expect(RecommendationService.detectMood(''), 'Happy');
      expect(RecommendationService.detectMood('hello there'), 'Happy');
    });
  });

  group('GlobalAudioService Queue and Control Tests', () {
    late GlobalAudioService audioService;

    setUp(() {
      audioService = GlobalAudioService.instance;
    });

    test('Initial audio service state is clean', () {
      expect(audioService.isShuffle, isFalse);
      expect(audioService.repeatMode, AudioRepeatMode.off);
      expect(audioService.sleepTimerRemainingMinutes, isNull);
    });

    test('Shuffle toggle functions correctly', () {
      audioService.toggleShuffle();
      expect(audioService.isShuffle, isTrue);
      audioService.toggleShuffle();
      expect(audioService.isShuffle, isFalse);
    });

    test('Cycle repeat mode progresses correctly through off -> all -> one -> off', () {
      // Ensure starting at off
      if (audioService.repeatMode != AudioRepeatMode.off) {
        while (audioService.repeatMode != AudioRepeatMode.off) {
          audioService.cycleRepeatMode();
        }
      }
      expect(audioService.repeatMode, AudioRepeatMode.off);

      audioService.cycleRepeatMode();
      expect(audioService.repeatMode, AudioRepeatMode.all);

      audioService.cycleRepeatMode();
      expect(audioService.repeatMode, AudioRepeatMode.one);

      audioService.cycleRepeatMode();
      expect(audioService.repeatMode, AudioRepeatMode.off);
    });

    test('Sleep timer setting and cancellation', () {
      audioService.setSleepTimer(30);
      expect(audioService.sleepTimerRemainingMinutes, isNotNull);
      expect(audioService.sleepTimerRemainingMinutes! >= 29, isTrue);

      audioService.cancelSleepTimer();
      expect(audioService.sleepTimerRemainingMinutes, isNull);
    });
  });

  group('ThemeService Tests', () {
    test('Theme service initializes and toggles correctly', () async {
      SharedPreferences.setMockInitialValues({'isDarkMode': false});
      final themeService = ThemeService.instance;
      await themeService.init();

      expect(themeService.isDark, isFalse);

      await themeService.toggleTheme();
      expect(themeService.isDark, isTrue);

      await themeService.setDark(false);
      expect(themeService.isDark, isFalse);
    });
  });
}
