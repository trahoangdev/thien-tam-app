import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'features/readings/presentation/pages/main_shell.dart';
import 'features/notifications/data/notification_service.dart';
import 'core/settings_providers.dart';
import 'core/config.dart';
import 'features/admin/presentation/pages/admin_login_page.dart';
import 'features/admin/presentation/pages/admin_home_page.dart';
import 'features/admin/presentation/pages/admin_readings_list_page.dart';
import 'features/admin/presentation/pages/admin_reading_form_page.dart';
import 'features/auth/presentation/providers/auth_providers.dart';
import 'features/auth/presentation/pages/splash_page.dart';

// Cache provider
final cacheProvider = Provider<Box>((ref) => throw UnimplementedError());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: '.env');

  // Initialize Hive
  await Hive.initFlutter();
  final cache = await Hive.openBox('cache');

  // Initialize date formatting for Vietnamese
  await initializeDateFormatting('vi', null);

  // Initialize notifications
  await NotificationService().initialize();

  // Print API configuration for debugging
  AppConfig.printConfig();

  runApp(
    ProviderScope(
      overrides: [cacheProvider.overrideWithValue(cache)],
      child: const App(),
    ),
  );
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    // Initialize auth service
    ref.read(authServiceProvider).initialize();

    return MaterialApp(
      title: 'Thiền Tâm - Bài Đọc Theo Ngày',
      debugShowCheckedModeBanner: false,

      // Localization
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('vi', 'VN'), Locale('en', 'US')],
      locale: const Locale('vi', 'VN'),

      // Theme mode from settings
      themeMode: themeMode,

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB8956A), // Vàng gỗ nhạt
          brightness: Brightness.light,
          primary: const Color(0xFF8B6F47), // Tối hơn để có contrast tốt
          secondary: const Color(0xFFA67C52), // Nâu đồng
          surface: const Color(0xFFF9F5F0), // Kem nhạt, không chói
          background: const Color(0xFFF4EFE4), // Be sáng như giấy cổ
          onPrimary: Colors.white, // Text trên primary color
          onSecondary: Colors.white, // Text trên secondary color
          onSurface: const Color(0xFF2D2D2D), // Text tối trên surface
          onBackground: const Color(0xFF2D2D2D), // Text tối trên background
          surfaceVariant: const Color(0xFFF0E6D2), // Surface variant cho cards
          onSurfaceVariant: const Color(
            0xFF4A4A4A,
          ), // Text trên surface variant
        ),
        fontFamily: 'serif',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
          headlineSmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
          bodyLarge: TextStyle(fontSize: 16, height: 1.8, letterSpacing: 0.3),
          bodyMedium: TextStyle(fontSize: 14, height: 1.6, letterSpacing: 0.2),
        ),
        cardTheme: const CardThemeData(
          elevation: 0.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          color: Color(0xFFF0E6D2), // Sử dụng surfaceVariant cho cards
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB8956A),
          brightness: Brightness.dark,
          primary: const Color(0xFFD4B896), // Sáng hơn một chút cho dark mode
          secondary: const Color(0xFFC19A6B),
          surface: const Color(0xFF2C2416),
          background: const Color(0xFF1A1410),
          onPrimary: const Color(0xFF1A1410), // Text tối trên primary
          onSecondary: const Color(0xFF1A1410), // Text tối trên secondary
          onSurface: const Color(0xFFE8E0D0), // Text sáng trên surface
          onBackground: const Color(0xFFE8E0D0), // Text sáng trên background
          surfaceVariant: const Color(0xFF3A3224), // Surface variant cho cards
          onSurfaceVariant: const Color(
            0xFFD4C4A8,
          ), // Text trên surface variant
        ),
        fontFamily: 'serif',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
          headlineSmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
          bodyLarge: TextStyle(fontSize: 16, height: 1.8, letterSpacing: 0.3),
          bodyMedium: TextStyle(fontSize: 14, height: 1.6, letterSpacing: 0.2),
        ),
        cardTheme: const CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          color: Color(0xFF3A3224), // Sử dụng surfaceVariant cho dark mode
        ),
      ),
      home: const SplashPage(),
      routes: {
        '/main': (context) => const MainShell(),
        '/admin/login': (context) => const AdminLoginPage(),
        '/admin/home': (context) => const AdminHomePage(),
        '/admin/readings': (context) => const AdminReadingsListPage(),
        '/admin/readings/create': (context) => const AdminReadingFormPage(),
      },
    );
  }
}
