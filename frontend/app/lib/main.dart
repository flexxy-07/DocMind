import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'features/upload/upload_screen.dart';
import 'features/documents/documents_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          Brightness.light, // light icons for dark background
      statusBarBrightness: Brightness.dark, // iOS
    ),
  );

  runApp(const ProviderScope(child: DocMindApp()));
}

class DocMindApp extends StatelessWidget {
  const DocMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DocMind',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),

      home: const _AppShell(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// APP SHELL
//
// Holds the bottom navigation bar and the two main screens.
//
// We use IndexedStack instead of switching widgets outright.
// IndexedStack keeps ALL screens in the tree at once — only
// the selected one is visible. This means:
//   - Screen state is preserved when switching tabs
//   - The Documents list doesn't re-fetch every time you switch
//   - Providers with autoDispose stay alive while in the stack
//
// If you used Navigator.push per tab, each screen would
// rebuild from scratch every time. IndexedStack avoids that.
// ─────────────────────────────────────────────────────────────

class _AppShell extends ConsumerStatefulWidget {
  const _AppShell();

  @override
  ConsumerState<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<_AppShell> {
  int _currentIndex = 0;

  // The two main screens — instantiated once, kept alive
  static const _screens = [UploadScreen(), DocumentsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,

      // IndexedStack shows only the screen at _currentIndex
      // but keeps all screens mounted and alive
      body: IndexedStack(index: _currentIndex, children: _screens),

      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}



class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
        // Subtle top shadow so it lifts off the content
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        backgroundColor: Colors.transparent,
        elevation: 0,
        height: 64,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.upload_file_outlined),
            selectedIcon: Icon(Icons.upload_file_rounded),
            label: 'Upload',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder_rounded),
            label: 'Documents',
          ),
        ],
      ),
    );
  }
}
