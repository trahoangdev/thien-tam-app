# Thiền Tâm - Bài Đọc Phật Giáo Theo Ngày

Ứng dụng Flutter hỗ trợ đọc bài Phật giáo hằng ngày với thông báo nhắc nhở.

## Tính năng

✅ **Bài đọc hôm nay** - Xem bài đọc của ngày hiện tại
✅ **Xem theo tháng** - Danh sách bài đọc trong tháng
✅ **Tìm kiếm** - Tìm bài đọc theo từ khóa
✅ **Bài ngẫu nhiên** - Đọc bài bất kỳ
✅ **Offline cache** - Đọc bài đã lưu khi mất mạng
✅ **Thông báo hằng ngày** - Nhắc đọc lúc 7:00 sáng
✅ **Giao diện đẹp** - Material Design 3

## Công nghệ

- **Flutter** 3.9+
- **Riverpod** - State management
- **Dio** - HTTP client
- **Hive** - Local storage & cache
- **flutter_local_notifications** - Daily reminders

## Cài đặt

### 1. Clone và cài dependencies

```bash
cd thien_tam_app
flutter pub get
```

### 2. Cấu hình API endpoint (tùy chọn)

Mặc định app sẽ kết nối tới `http://10.0.2.2:4000` (localhost cho Android emulator).

Để thay đổi, chạy với:

```bash
flutter run --dart-define=API_BASE=http://your-api-url
```

### 3. Chạy app

```bash
# Android emulator/device
flutter run

# iOS simulator
flutter run -d ios
```

## Build

### Android APK

```bash
flutter build apk --release
```

APK sẽ nằm trong `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (cho Play Store)

```bash
flutter build appbundle --release
```

## Cấu trúc dự án

```
lib/
├── main.dart                          # Entry point
├── core/
│   ├── env.dart                       # Environment config
│   ├── http.dart                      # Dio HTTP client
│   └── notifications.dart             # Notification setup
└── features/
    └── readings/
        ├── data/
        │   ├── models/
        │   │   └── reading.dart       # Reading model
        │   ├── reading_api.dart       # API calls
        │   └── reading_repo.dart      # Repository (API + Cache)
        └── presentation/
            ├── providers/
            │   └── reading_providers.dart  # Riverpod providers
            └── pages/
                ├── today_page.dart         # Trang chính
                ├── detail_page.dart        # Chi tiết bài đọc
                ├── month_page.dart         # Danh sách tháng
                └── search_page.dart        # Tìm kiếm
```

## Lưu ý

- Backend phải chạy trước khi test app
- Notifications cần quyền trên Android 13+ (sẽ tự động xin khi app khởi động)
- Cache được lưu bằng Hive, tự động xóa khi uninstall app

## Screenshots

(Thêm screenshots sau khi build app)

## License

MIT
