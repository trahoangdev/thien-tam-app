import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'today_page.dart';
import 'month_page.dart';
import 'bookmarks_page.dart';
import 'history_page.dart';
import 'settings_page.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/providers/permission_providers.dart'
    as permissions;
import '../../../chat/presentation/pages/zen_master_chat_page.dart';
import '../../../audio/presentation/pages/audio_library_page.dart';
import '../../../books/presentation/pages/books_library_page.dart';

/// Shell chính với Bottom Navigation
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;
  bool _isFabMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isGuestMode = ref.watch(permissions.isGuestModeProvider);
    final canBookmark = ref.watch(permissions.canBookmarkProvider);
    final canViewHistory = ref.watch(permissions.canViewHistoryProvider);

    // Show login page if not authenticated and not in guest mode
    if (authState == AuthState.unauthenticated && !isGuestMode) {
      return LoginPage(
        onGuestAccess: () {
          ref.read(permissions.isGuestModeProvider.notifier).state = true;
        },
      );
    }

    // Show loading while checking auth
    if (authState == AuthState.loading || authState == AuthState.initial) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Đang tải...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onBackground.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Build pages and navigation items based on permissions
    final pages = <Widget>[
      const TodayPageContent(),
      MonthPage(year: DateTime.now().year, month: DateTime.now().month),
    ];

    final navigationItems = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.auto_stories_outlined),
        activeIcon: Icon(Icons.auto_stories),
        label: 'Hôm Nay',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.calendar_month_outlined),
        activeIcon: Icon(Icons.calendar_month),
        label: 'Lịch',
      ),
    ];

    // Add bookmark tab if user has permission
    if (canBookmark) {
      pages.add(const BookmarksPage());
      navigationItems.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.bookmark_border),
          activeIcon: Icon(Icons.bookmark),
          label: 'Yêu Thích',
        ),
      );
    }

    // Add history tab if user has permission
    if (canViewHistory) {
      pages.add(const HistoryPage());
      navigationItems.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.history),
          activeIcon: Icon(Icons.history),
          label: 'Lịch Sử',
        ),
      );
    }
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey.shade600,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          items: navigationItems,
        ),
      ),
      floatingActionButton: _currentIndex == 0 ? _buildSpeedDialMenu() : null,
    );
  }

  Widget _buildSpeedDialMenu() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Menu items (hiển thị khi mở với animation)
        if (_isFabMenuOpen) ...[
          _buildSpeedDialItem(
            icon: Icons.spa,
            label: 'Thiền Sư',
            backgroundColor: Theme.of(context).colorScheme.secondary,
            onTap: () {
              setState(() {
                _isFabMenuOpen = false;
              });
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ZenMasterChatPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildSpeedDialItem(
            icon: Icons.library_music,
            label: 'Audio',
            backgroundColor: Colors.orange,
            onTap: () {
              setState(() {
                _isFabMenuOpen = false;
              });
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AudioLibraryPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildSpeedDialItem(
            icon: Icons.menu_book,
            label: 'Kinh Sách',
            backgroundColor: Colors.deepPurple,
            onTap: () {
              setState(() {
                _isFabMenuOpen = false;
              });
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BooksLibraryPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildSpeedDialItem(
            icon: Icons.settings,
            label: 'Cài Đặt',
            backgroundColor: Theme.of(context).colorScheme.primary,
            onTap: () {
              setState(() {
                _isFabMenuOpen = false;
              });
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
        // Main FAB (luôn hiển thị)
        FloatingActionButton(
          heroTag: 'main_menu',
          onPressed: () {
            setState(() {
              _isFabMenuOpen = !_isFabMenuOpen;
            });
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: AnimatedRotation(
            turns: _isFabMenuOpen ? 0.125 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _isFabMenuOpen ? Icons.close : Icons.menu,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpeedDialItem({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // FAB
        FloatingActionButton(
          heroTag: label,
          mini: true,
          onPressed: onTap,
          backgroundColor: backgroundColor,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ],
    );
  }
}
