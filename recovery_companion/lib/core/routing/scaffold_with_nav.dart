import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/theme_ext.dart';
import 'app_routes.dart';

/// Root shell: a persistent bottom navigation bar wrapping the five primary
/// branches, plus an always-available, calm SOS entry point.
///
/// Clinical principle: in-the-moment help must be reachable from anywhere in
/// one tap — cravings pass in minutes, so the support button is persistent.
class ScaffoldWithNav extends StatelessWidget {
  const ScaffoldWithNav({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      // Tapping the current tab returns it to its initial route.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'sos',
        tooltip: 'Open support tools for a craving',
        backgroundColor: context.palette.support,
        foregroundColor: context.palette.onSupport,
        onPressed: () => context.pushNamed(AppRoute.sos.name),
        icon: const Icon(Icons.favorite),
        label: const Text('Support now'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.spa_outlined),
            selectedIcon: Icon(Icons.spa),
            label: 'Activities',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Companion',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.self_improvement_outlined),
            selectedIcon: Icon(Icons.self_improvement),
            label: 'Me',
          ),
        ],
      ),
    );
  }
}
