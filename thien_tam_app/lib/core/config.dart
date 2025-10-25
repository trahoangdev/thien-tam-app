/// App configuration
class AppConfig {
  // API Base URL
  // Use localhost for emulator/web
  // Use your machine's IP for physical device

  // ⚠️ IMPORTANT: Choose the right URL based on your test device:

  // 1. For Web/Desktop:
  //static const String apiBaseUrl = 'http://localhost:4000';

  // 2. For Android Emulator (ĐANG SỬ DỤNG):
  static const String apiBaseUrl = 'http://10.0.2.2:4000';

  // 3. For Physical Device (Mobile):
  //static const String apiBaseUrl = 'http://10.150.0.53:4000'; // ← IP: 10.150.0.53 (cập nhật 25/10/2025)

  static const String appName = 'Thiền Tâm';
  static const String appVersion = '1.0.0';
}
