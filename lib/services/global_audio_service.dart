import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'history_service.dart';

enum AudioRepeatMode { off, all, one }

/// Singleton service managing global music playback, state, queue, and sleep timer.
class GlobalAudioService extends ChangeNotifier {
  static final GlobalAudioService _instance = GlobalAudioService._internal();
  factory GlobalAudioService() => _instance;
  static GlobalAudioService get instance => _instance;

  final AudioPlayer _player = AudioPlayer();
  AudioPlayer get player => _player;

  Map<String, String>? _currentSong;
  Map<String, String>? get currentSong => _currentSong;

  List<Map<String, String>> _playlist = [];
  List<Map<String, String>> get playlist => List.unmodifiable(_playlist);

  int _currentIndex = -1;
  int get currentIndex => _currentIndex;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  Duration _position = Duration.zero;
  Duration get position => _position;

  Duration _duration = Duration.zero;
  Duration get duration => _duration;

  bool _isShuffle = false;
  bool get isShuffle => _isShuffle;

  AudioRepeatMode _repeatMode = AudioRepeatMode.off;
  AudioRepeatMode get repeatMode => _repeatMode;

  // Sleep Timer
  Timer? _sleepTimer;
  Timer? _fadeTimer;
  DateTime? _sleepTimerEndTime;
  DateTime? get sleepTimerEndTime => _sleepTimerEndTime;
  int? get sleepTimerRemainingMinutes {
    if (_sleepTimerEndTime == null) return null;
    final diff = _sleepTimerEndTime!.difference(DateTime.now()).inMinutes;
    return diff >= 0 ? diff + 1 : 0;
  }

  GlobalAudioService._internal() {
    _initAudioListeners();
  }

  void _initAudioListeners() {
    _player.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });

    _player.onPositionChanged.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _player.onDurationChanged.listen((dur) {
      _duration = dur;
      notifyListeners();
    });

    _player.onPlayerComplete.listen((_) {
      _handleTrackCompleted();
    });
  }

  void _handleTrackCompleted() {
    if (_repeatMode == AudioRepeatMode.one) {
      _player.seek(Duration.zero);
      _player.resume();
    } else {
      next();
    }
  }

  Future<void> playSong(Map<String, String> song, {List<Map<String, String>>? playlist}) async {
    _currentSong = song;
    if (playlist != null && playlist.isNotEmpty) {
      _playlist = List.from(playlist);
      _currentIndex = _playlist.indexWhere((s) => s['title'] == song['title'] && s['artist'] == song['artist']);
      if (_currentIndex == -1) {
        _playlist.insert(0, song);
        _currentIndex = 0;
      }
    } else if (!_playlist.any((s) => s['title'] == song['title'])) {
      _playlist = [song];
      _currentIndex = 0;
    }

    final previewUrl = song['preview'] ?? '';
    if (previewUrl.isNotEmpty) {
      try {
        await _player.stop();
        await _player.setVolume(1.0);
        await _player.play(UrlSource(previewUrl));
        _isPlaying = true;
      } catch (e) {
        debugPrint('GlobalAudioService play error: $e');
      }
    }

    // Save to playback history
    HistoryService.addSongHistory(song);
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      if (_position >= _duration && _duration > Duration.zero) {
        await _player.seek(Duration.zero);
      }
      await _player.resume();
    }
    notifyListeners();
  }

  Future<void> pause() async {
    await _player.pause();
    notifyListeners();
  }

  Future<void> resume() async {
    await _player.resume();
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
    notifyListeners();
  }

  Future<void> next() async {
    if (_playlist.isEmpty) return;

    if (_isShuffle && _playlist.length > 1) {
      int nextIdx;
      do {
        nextIdx = Random().nextInt(_playlist.length);
      } while (nextIdx == _currentIndex);
      _currentIndex = nextIdx;
    } else {
      if (_currentIndex < _playlist.length - 1) {
        _currentIndex++;
      } else if (_repeatMode == AudioRepeatMode.all) {
        _currentIndex = 0;
      } else {
        await _player.stop();
        _isPlaying = false;
        notifyListeners();
        return;
      }
    }

    await playSong(_playlist[_currentIndex], playlist: _playlist);
  }

  Future<void> previous() async {
    if (_playlist.isEmpty) return;

    if (_position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }

    if (_currentIndex > 0) {
      _currentIndex--;
    } else if (_repeatMode == AudioRepeatMode.all) {
      _currentIndex = _playlist.length - 1;
    } else {
      await seek(Duration.zero);
      return;
    }

    await playSong(_playlist[_currentIndex], playlist: _playlist);
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    notifyListeners();
  }

  void cycleRepeatMode() {
    switch (_repeatMode) {
      case AudioRepeatMode.off:
        _repeatMode = AudioRepeatMode.all;
        break;
      case AudioRepeatMode.all:
        _repeatMode = AudioRepeatMode.one;
        break;
      case AudioRepeatMode.one:
        _repeatMode = AudioRepeatMode.off;
        break;
    }
    notifyListeners();
  }

  // ── Sleep Timer with Smooth Fade-Out ────────────────────
  void setSleepTimer(int minutes) {
    cancelSleepTimer();
    if (minutes <= 0) return;

    _sleepTimerEndTime = DateTime.now().add(Duration(minutes: minutes));
    notifyListeners();

    final totalSeconds = minutes * 60;
    final fadeStartSeconds = max(0, totalSeconds - 30); // Start fade-out in last 30s

    _sleepTimer = Timer(Duration(seconds: fadeStartSeconds), () {
      _startVolumeFadeOut();
    });
  }

  void _startVolumeFadeOut() {
    double currentVolume = 1.0;
    const steps = 30;
    final interval = const Duration(seconds: 1);

    _fadeTimer = Timer.periodic(interval, (timer) async {
      currentVolume -= (1.0 / steps);
      if (currentVolume <= 0.05) {
        timer.cancel();
        await _player.stop();
        await _player.setVolume(1.0);
        _isPlaying = false;
        _sleepTimerEndTime = null;
        notifyListeners();
      } else {
        await _player.setVolume(currentVolume);
      }
    });
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _fadeTimer?.cancel();
    _fadeTimer = null;
    _sleepTimerEndTime = null;
    _player.setVolume(1.0);
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    _sleepTimer?.cancel();
    _fadeTimer?.cancel();
    super.dispose();
  }
}
