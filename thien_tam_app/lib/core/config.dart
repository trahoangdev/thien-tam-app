import 'dart:io';
import 'package:flutter/foundation.dart';

/// App configuration with auto-detection for different platforms
class AppConfig {
  // Backend server IP (your machine's local network IP)
  static const String _serverIp = '192.168.1.228';
  static const int _serverPort = 4000;

  /// Automatically detect the correct API URL based on platform
  static String get apiBaseUrl {
    if (kIsWeb) {
      // Web: use localhost
      return 'http://localhost:$_serverPort';
    } else if (Platform.isAndroid) {
      // Check if running on emulator or physical device
      // Emulator: use 10.0.2.2 (Android emulator's special alias for host machine)
      // Physical device: use local network IP
      return _isEmulator
          ? 'http://10.0.2.2:$_serverPort'
          : 'http://$_serverIp:$_serverPort';
    } else if (Platform.isIOS) {
      // iOS Simulator: use localhost
      // Physical device: use local network IP
      return _isEmulator
          ? 'http://localhost:$_serverPort'
          : 'http://$_serverIp:$_serverPort';
    } else {
      // Desktop (Windows/Mac/Linux): use localhost
      return 'http://localhost:$_serverPort';
    }
  }

  /// Detect if running on emulator/simulator
  /// This is a heuristic check - not 100% accurate but works in most cases
  static bool get _isEmulator {
    if (kIsWeb) return false;

    if (Platform.isAndroid) {
      // Android emulator detection
      // Check common emulator properties
      return Platform.environment.containsKey('ANDROID_EMULATOR') ||
          Platform.environment.containsKey('FLUTTER_TEST');
    } else if (Platform.isIOS) {
      // iOS simulator detection
      return Platform.environment.containsKey('SIMULATOR_DEVICE_NAME');
    }

    return false;
  }

  static const String appName = 'Thiền Tâm';
  static const String appVersion = '1.0.0';

  /// For debugging: print current configuration
  static void printConfig() {
    if (kDebugMode) {
      print('🔧 AppConfig:');
      print('   Platform: ${_getPlatformName()}');
      print('   Is Emulator: $_isEmulator');
      print('   API Base URL: $apiBaseUrl');
    }
  }

  static String _getPlatformName() {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }
}
