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

/// Shell chính với Bottom Navigation
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

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
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.settings, color: Colors.white),
            )
          : null,
    );
  }
}
