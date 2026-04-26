import 'package:flutter/material.dart';
import '../features/upload/upload_screen.dart';
import '../features/documents/documents_screen.dart';
import 'design_system.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final _screens = const [
    UploadScreen(),
    DocumentsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ObsidianColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _TechnicalNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class _TechnicalNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _TechnicalNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ObsidianColors.surfaceContainerLowest,
        border: Border(
          top: BorderSide(color: ObsidianColors.border),
        ),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        backgroundColor: Colors.transparent,
        indicatorColor: ObsidianColors.highlight,
        height: 72,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.upload_rounded, size: 22),
            label: 'INGEST',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_rounded, size: 22),
            label: 'ARCHIVE',
          ),
        ],
      ),
    );
  }
}
