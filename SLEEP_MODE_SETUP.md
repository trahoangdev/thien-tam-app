# 🌙 Hướng dẫn Setup Chế độ Ngủ (Sleep Mode)

## 📁 Cấu trúc Files đã tạo

```
lib/features/tts/
├── data/
│   ├── sleep_mode_models.dart       ✅ Models & enums
│   ├── sleep_mode_service.dart      ✅ Service logic
│   └── tts_service.dart
├── presentation/
│   ├── providers/
│   │   └── tts_providers.dart       ✅ Updated với sleepModeServiceProvider
│   └── widgets/
│       ├── sleep_mode_widget.dart   ✅ UI widget
│       └── tts_widget.dart
```

---

## 🎵 Bước 1: Thêm Audio Assets

### Tạo thư mục assets

```bash
mkdir -p thien_tam_app/assets/sounds
```

### Download các file âm thanh (hoặc tạo tạm)

Bạn cần **4 file audio**:

1. **rain.mp3** - Tiếng mưa nhẹ (30s-1min, loop được)
2. **temple.mp3** - Tiếng chuông chùa/thiền (30s-1min, loop được)
3. **nature.mp3** - Tiếng thiên nhiên/chim hót (30s-1min, loop được)
4. **bell.mp3** - Tiếng chuông nhẹ kết thúc (5-10s)

### Nguồn download miễn phí:

- https://freesound.org/ (tìm: "rain", "temple bell", "nature", "singing bowl")
- https://pixabay.com/music/
- https://incompetech.com/music/royalty-free/

### Lưu vào:

```
thien_tam_app/assets/sounds/
├── rain.mp3
├── temple.mp3
├── nature.mp3
└── bell.mp3
```

---

## 📝 Bước 2: Update pubspec.yaml

```yaml
# Thêm vào section flutter:
flutter:
  assets:
    - assets/sounds/
    # Hoặc chi tiết hơn:
    # - assets/sounds/rain.mp3
    # - assets/sounds/temple.mp3
    # - assets/sounds/nature.mp3
    # - assets/sounds/bell.mp3
```

---

## 🔧 Bước 3: Sử dụng trong UI

### Thêm vào trang có TTS (ví dụ: ReadingDetailPage)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../tts/presentation/widgets/sleep_mode_widget.dart';
import '../tts/presentation/providers/tts_providers.dart';

class ReadingDetailPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sleepModeService = ref.watch(sleepModeServiceProvider);

    return Scaffold(
      // ... existing code
      body: Column(
        children: [
          // ... nội dung bài đọc

          // Thêm Sleep Mode Widget
          Padding(
            padding: const EdgeInsets.all(16),
            child: SleepModeWidget(
              sleepModeService: sleepModeService,
            ),
          ),
        ],
      ),
    );
  }
}
```

### Hoặc hiển thị dạng Modal Bottom Sheet

```dart
void _showSleepMode(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: const EdgeInsets.all(16),
      child: SleepModeWidget(
        sleepModeService: ref.read(sleepModeServiceProvider),
      ),
    ),
  );
}

// Trong UI, thêm button:
IconButton(
  icon: const Icon(Icons.nightlight_round),
  onPressed: () => _showSleepMode(context, ref),
  tooltip: 'Chế độ ngủ',
)
```

---

## 🎯 Bước 4: Tích hợp với TTS hiện tại

Nếu muốn sleep mode tự động bật TTS:

```dart
// Trong sleep_mode_service.dart, thêm vào start():

Future<void> start(SleepModeSettings settings, {
  String? readingText,
  TTSService? ttsService,
}) async {
  _settings = settings;
  _state = SleepModeState.preparing;
  _remainingSeconds = settings.autoStopMinutes * 60;
  _currentVolume = 1.0;
  notifyListeners();

  try {
    // Phát bài đọc qua TTS nếu có
    if (readingText != null && ttsService != null) {
      await ttsService.textToSpeech(readingText);
    }

    // Phát âm thanh nền
    if (settings.backgroundSound != BackgroundSound.silence) {
      await _playBackgroundSound(settings.backgroundSound);
    }

    _state = SleepModeState.playing;
    notifyListeners();

    _startAutoStopTimer();

  } catch (e) {
    // ...
  }
}
```

---

## ✨ Tính năng đã implement

✅ **Timer tự động dừng** - Từ 5-120 phút
✅ **Fade out âm lượng** - Giảm dần trong 2 phút cuối
✅ **Tiếng chuông nhẹ** - Kết thúc êm ái
✅ **Âm thanh nền** - Mưa, chùa, thiên nhiên, im lặng
✅ **Điều chỉnh thời gian** - Thêm/bớt 5-15 phút
✅ **Điều chỉnh âm lượng** - Realtime volume control
✅ **UI đẹp** - Gradient theme tối màu
✅ **State management** - Proper ChangeNotifier

---

## 🚀 Chạy thử

```bash
cd thien_tam_app
flutter pub get
flutter run
```

---

## 🎨 Tùy chỉnh thêm (Optional)

### 1. Thêm vibration khi kết thúc

```yaml
# pubspec.yaml
dependencies:
  vibration: ^1.8.4
```

```dart
// Trong sleep_mode_service.dart
import 'package:vibration/vibration.dart';

Future<void> _playGentleBell() async {
  // ... code hiện tại

  // Thêm rung nhẹ
  if (await Vibration.hasVibrator() ?? false) {
    Vibration.vibrate(duration: 500, amplitude: 50);
  }
}
```

### 2. Save settings vào local storage

```dart
// Dùng SharedPreferences hoặc Hive
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveSettings(SleepModeSettings settings) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('sleep_mode_settings', jsonEncode(settings.toJson()));
}

Future<SleepModeSettings> loadSettings() async {
  final prefs = await SharedPreferences.getInstance();
  final json = prefs.getString('sleep_mode_settings');
  if (json != null) {
    return SleepModeSettings.fromJson(jsonDecode(json));
  }
  return SleepModeSettings();
}
```

### 3. Thông báo khi hết giờ

```dart
// Dùng flutter_local_notifications
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> _showCompletionNotification() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  const androidDetails = AndroidNotificationDetails(
    'sleep_mode',
    'Sleep Mode',
    channelDescription: 'Sleep mode completion notifications',
    importance: Importance.low,
    priority: Priority.low,
  );

  const notificationDetails = NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0,
    '🌙 Chế độ ngủ đã kết thúc',
    'Chúc bạn ngủ ngon! 🙏',
    notificationDetails,
  );
}
```

---

## 🐛 Troubleshooting

### Lỗi: "Asset not found"

- Kiểm tra đường dẫn trong pubspec.yaml
- Chạy `flutter clean` và `flutter pub get`
- Restart app

### Lỗi: Audio không phát

- Kiểm tra file audio format (MP3, WAV, AAC)
- Kiểm tra file size không quá lớn
- Test với file audio khác

### Lỗi: Timer không chạy

- Kiểm tra app không bị killed khi background
- Thêm wake lock nếu cần (package: wakelock)

---

## 📱 Demo Flow

1. User mở bài đọc
2. Nhấn icon "Chế độ ngủ" 🌙
3. Chọn settings:
   - Thời gian: 30 phút
   - Fade out: Bật
   - Chuông: Bật
   - Âm thanh: Tiếng mưa
4. Nhấn "Bắt đầu chế độ ngủ"
5. App phát:
   - Bài đọc qua TTS (nếu có)
   - Tiếng mưa nền (loop)
6. Sau 28 phút: Bắt đầu fade out
7. Sau 30 phút: Dừng, phát tiếng chuông nhẹ
8. User ngủ ngon! 😴

---

## 🎉 Hoàn thành!

Bạn đã có tính năng **Chế độ ngủ** hoàn chỉnh!

**Next steps:**

- Test trên thiết bị thật
- Thu thập feedback từ users
- Tối ưu battery usage
- Thêm analytics tracking

Chúc mừng! 🎊
