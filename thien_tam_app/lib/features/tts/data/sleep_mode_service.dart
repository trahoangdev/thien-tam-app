import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'sleep_mode_models.dart';

/// Sleep Mode Service
/// Quản lý chế độ ngủ với timer, fade out, background sounds
class SleepModeService extends ChangeNotifier {
  SleepModeSettings _settings = SleepModeSettings();
  SleepModeState _state = SleepModeState.inactive;
  Timer? _autoStopTimer;
  Timer? _fadeOutTimer;
  double _currentVolume = 0.35; // Giảm xuống 35% để giọng đọc nổi bật hơn
  int _remainingSeconds = 0;

  // Audio players
  final AudioPlayer _backgroundPlayer = AudioPlayer();
  final AudioPlayer _bellPlayer = AudioPlayer();

  SleepModeSettings get settings => _settings;
  SleepModeState get state => _state;
  double get currentVolume => _currentVolume;
  int get remainingSeconds => _remainingSeconds;
  int get remainingMinutes => (_remainingSeconds / 60).ceil();

  SleepModeService() {
    _initializeAudioPlayers();
  }

  /// Initialize audio players with proper audio context
  Future<void> _initializeAudioPlayers() async {
    // Configure background player to mix with other audio (TTS)
    await _backgroundPlayer.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus:
              AndroidAudioFocus.none, // Don't request focus - allow mixing
        ),
      ),
    );

    // Configure bell player
    await _bellPlayer.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.notification,
          audioFocus: AndroidAudioFocus.none, // Don't request focus
        ),
      ),
    );
  }

  /// Khởi động chế độ ngủ
  Future<void> start(SleepModeSettings settings) async {
    _settings = settings;
    _state = SleepModeState.preparing;
    _remainingSeconds = settings.autoStopMinutes * 60;
    _currentVolume = 0.35; // Đặt volume nền ở 35%
    notifyListeners();

    try {
      // Phát âm thanh nền nếu có
      if (settings.backgroundSound != BackgroundSound.silence) {
        await _playBackgroundSound(settings.backgroundSound);
      }

      _state = SleepModeState.playing;
      notifyListeners();

      // Bắt đầu timer tự động dừng
      _startAutoStopTimer();
    } catch (e) {
      debugPrint('Error starting sleep mode: $e');
      _state = SleepModeState.inactive;
      notifyListeners();
    }
  }

  /// Dừng chế độ ngủ
  Future<void> stop() async {
    _autoStopTimer?.cancel();
    _fadeOutTimer?.cancel();

    await _backgroundPlayer.stop();
    await _bellPlayer.stop();

    _state = SleepModeState.stopped;
    _currentVolume = 0.35; // Reset về 35%
    _remainingSeconds = 0;
    notifyListeners();

    // Reset về inactive sau 1 giây
    Future.delayed(const Duration(seconds: 1), () {
      _state = SleepModeState.inactive;
      notifyListeners();
    });
  }

  /// Bắt đầu timer tự động dừng
  void _startAutoStopTimer() {
    _autoStopTimer?.cancel();

    // Update mỗi giây
    _autoStopTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingSeconds--;
      notifyListeners();

      // Bắt đầu fade out khi còn 2 phút
      if (_settings.fadeOut && _remainingSeconds == 120) {
        _startFadeOut();
      }

      // Hết giờ
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _onAutoStopComplete();
      }
    });
  }

  /// Bắt đầu fade out (giảm dần âm lượng)
  void _startFadeOut() {
    if (_state != SleepModeState.playing) return;

    _state = SleepModeState.fadingOut;
    notifyListeners();

    _fadeOutTimer?.cancel();

    // Giảm âm lượng dần trong 2 phút (120 giây)
    const fadeSteps = 60; // Giảm 60 bước
    const stepDuration = Duration(seconds: 2); // Mỗi 2 giây
    const volumeDecrement = 0.35 / fadeSteps; // Giảm từ 35% về 0

    _fadeOutTimer = Timer.periodic(stepDuration, (timer) {
      _currentVolume -= volumeDecrement;

      if (_currentVolume < 0) {
        _currentVolume = 0;
      }

      _backgroundPlayer.setVolume(_currentVolume);
      notifyListeners();

      if (_currentVolume <= 0 || _remainingSeconds <= 0) {
        timer.cancel();
      }
    });
  }

  /// Khi hết giờ tự động dừng
  Future<void> _onAutoStopComplete() async {
    _fadeOutTimer?.cancel();

    // Dừng âm thanh nền
    await _backgroundPlayer.stop();

    // Rung chuông nhẹ nếu được bật
    if (_settings.gentleBell) {
      await _playGentleBell();
    } else {
      await stop();
    }
  }

  /// Phát âm thanh nền
  Future<void> _playBackgroundSound(BackgroundSound sound) async {
    if (sound.assetPath.isEmpty) return;

    try {
      await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
      await _backgroundPlayer.setVolume(_currentVolume);
      await _backgroundPlayer.play(AssetSource(sound.assetPath));
    } catch (e) {
      debugPrint('Error playing background sound: $e');
    }
  }

  /// Phát tiếng chuông nhẹ
  Future<void> _playGentleBell() async {
    _state = SleepModeState.ringingBell;
    notifyListeners();

    try {
      await _bellPlayer.setReleaseMode(ReleaseMode.release);
      await _bellPlayer.setVolume(0.4); // Volume nhẹ (40%)
      await _bellPlayer.play(AssetSource('sounds/bell.mp3'));

      // Dừng sau khi chuông hết
      _bellPlayer.onPlayerComplete.listen((_) {
        stop();
      });
    } catch (e) {
      debugPrint('Error playing bell: $e');
      await stop();
    }
  }

  /// Cập nhật settings
  void updateSettings(SleepModeSettings newSettings) {
    _settings = newSettings;
    notifyListeners();
  }

  /// Thêm thời gian (gia hạn)
  void addTime(int minutes) {
    _remainingSeconds += minutes * 60;
    notifyListeners();
  }

  /// Giảm thời gian
  void reduceTime(int minutes) {
    _remainingSeconds -= minutes * 60;
    if (_remainingSeconds < 0) {
      _remainingSeconds = 0;
    }
    notifyListeners();
  }

  /// Set volume thủ công
  void setVolume(double volume) {
    _currentVolume = volume.clamp(0.0, 1.0);
    _backgroundPlayer.setVolume(_currentVolume);
    notifyListeners();
  }

  @override
  void dispose() {
    _autoStopTimer?.cancel();
    _fadeOutTimer?.cancel();
    _backgroundPlayer.dispose();
    _bellPlayer.dispose();
    super.dispose();
  }
}
