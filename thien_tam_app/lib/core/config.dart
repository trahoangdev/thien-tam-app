import 'dart:io';
import 'package:flutter/foundation.dart';

/// App configuration with auto-detection for different platforms
class AppConfig {
  // Backend server configuration
  // Best practice: Use localhost/emulator for development
  static const int _serverPort = 4000;

  /// Automatically detect the correct API URL based on platform
  static String get apiBaseUrl {
    if (kIsWeb) {
      // Web: use localhost
      return 'http://localhost:$_serverPort';
    } else if (Platform.isAndroid) {
      // Android Emulator: use 10.0.2.2 (special alias for host machine's localhost)
      // This is the recommended approach for development
      return 'http://10.0.2.2:$_serverPort';
    } else if (Platform.isIOS) {
      // iOS Simulator: use localhost
      return 'http://localhost:$_serverPort';
    } else {
      // Desktop (Windows/Mac/Linux): use localhost
      return 'http://localhost:$_serverPort';
    }
  }

  static const String appName = 'Thiền Tâm';
  static const String appVersion = '1.0.0';

  // Supabase configuration (use --dart-define to override in builds)
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue:
        'https://wulpbapjkreegmqqxpat.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind1bHBiYXBqa3JlZWdtcXF4cGF0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5OTM1OTQsImV4cCI6MjA3MzU2OTU5NH0.tjOlUpUdw_9UrueQORK-Uem0kA9DHN1eumBBrb6v0iI',
  );

  /// For debugging: print current configuration
  static void printConfig() {
    if (kDebugMode) {
      print('🔧 AppConfig:');
      print('   Platform: ${_getPlatformName()}');
      print('   API Base URL: $apiBaseUrl');
      print('   Supabase configured: ${supabaseUrl.isNotEmpty}');
      print('   Note: Using emulator/localhost for development');
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
