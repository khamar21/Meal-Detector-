import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/diet/view/screens/diet_dashboard_screen.dart';
import '../features/history/view/history_page.dart';
import '../features/food_scan/view/screens/food_scan_screen.dart';
import '../features/user_profile/view/screens/profile_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _index = 0;

  final List<Widget> _pages = const [
    FoodScanScreen(),
    DietDashboardScreen(),
    HistoryPage(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.camera_alt_outlined),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            label: 'Diet',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
