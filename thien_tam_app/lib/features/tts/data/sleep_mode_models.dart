/// Sleep Mode Settings Model
/// Cài đặt chế độ ngủ với các tùy chọn
class SleepModeSettings {
  final bool enabled; // Bật/tắt chế độ ngủ
  final bool fadeOut; // Từ từ giảm âm lượng
  final int autoStopMinutes; // Tự động dừng sau X phút
  final bool gentleBell; // Kết thúc bằng tiếng chuông nhẹ
  final List<String> peacefulReadingIds; // Các bài đọc an lạc
  final BackgroundSound backgroundSound; // Âm thanh nền

  SleepModeSettings({
    this.enabled = false,
    this.fadeOut = true,
    this.autoStopMinutes = 30,
    this.gentleBell = true,
    this.peacefulReadingIds = const [],
    this.backgroundSound = BackgroundSound.silence,
  });

  SleepModeSettings copyWith({
    bool? enabled,
    bool? fadeOut,
    int? autoStopMinutes,
    bool? gentleBell,
    List<String>? peacefulReadingIds,
    BackgroundSound? backgroundSound,
  }) {
    return SleepModeSettings(
      enabled: enabled ?? this.enabled,
      fadeOut: fadeOut ?? this.fadeOut,
      autoStopMinutes: autoStopMinutes ?? this.autoStopMinutes,
      gentleBell: gentleBell ?? this.gentleBell,
      peacefulReadingIds: peacefulReadingIds ?? this.peacefulReadingIds,
      backgroundSound: backgroundSound ?? this.backgroundSound,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'fadeOut': fadeOut,
      'autoStopMinutes': autoStopMinutes,
      'gentleBell': gentleBell,
      'peacefulReadingIds': peacefulReadingIds,
      'backgroundSound': backgroundSound.name,
    };
  }

  factory SleepModeSettings.fromJson(Map<String, dynamic> json) {
    return SleepModeSettings(
      enabled: json['enabled'] ?? false,
      fadeOut: json['fadeOut'] ?? true,
      autoStopMinutes: json['autoStopMinutes'] ?? 30,
      gentleBell: json['gentleBell'] ?? true,
      peacefulReadingIds: List<String>.from(json['peacefulReadingIds'] ?? []),
      backgroundSound: BackgroundSound.values.firstWhere(
        (e) => e.name == json['backgroundSound'],
        orElse: () => BackgroundSound.silence,
      ),
    );
  }
}

/// Âm thanh nền
enum BackgroundSound {
  rain('mua', 'Tiếng mưa', 'sounds/rain.mp3'),
  temple('chua', 'Tiếng chuông chùa', 'sounds/temple.mp3'),
  nature('thien_nhien', 'Thiên nhiên', 'sounds/nature.mp3'),
  silence('im_lang', 'Im lặng', '');

  final String key;
  final String displayName;
  final String assetPath;

  const BackgroundSound(this.key, this.displayName, this.assetPath);
}

/// Sleep Mode State
enum SleepModeState {
  inactive, // Không hoạt động
  preparing, // Đang chuẩn bị
  playing, // Đang phát
  fadingOut, // Đang giảm âm lượng
  ringingBell, // Đang rung chuông
  stopped, // Đã dừng
}
