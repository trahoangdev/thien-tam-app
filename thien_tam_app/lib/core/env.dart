import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration
///
/// Loads configuration from .env file for better security.
/// Never commit .env file to version control!
class Env {
  /// API base URL
  /// For Android Emulator: http://10.0.2.2:4000
  /// For Physical Device: use your computer's local IP
  /// For iOS Simulator: http://localhost:4000
  static String get apiBaseUrl =>
      dotenv.get('API_BASE_URL', fallback: 'http://10.0.2.2:4000');

  /// Supabase URL
  /// Get from: https://supabase.com/dashboard/project/_/settings/api
  static String get supabaseUrl => dotenv.get('SUPABASE_URL', fallback: '');

  /// Supabase Anon Key (public key, safe for client-side)
  /// Get from: https://supabase.com/dashboard/project/_/settings/api
  static String get supabaseAnonKey =>
      dotenv.get('SUPABASE_ANON_KEY', fallback: '');
}
