import 'package:flutter/material.dart';
import 'features/resource_sharing/presentation/pages/resource_library_page.dart';
import 'features/resource_sharing/presentation/pages/resource_form_page.dart';
import 'features/assignment_help/presentation/pages/assignment_help_page.dart';
import 'features/study_groups/presentation/pages/study_group_list_screen.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/assignment_help/presentation/pages/help_request_form_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final GlobalKey<NavigatorState> _studyGroupNavKey = GlobalKey<NavigatorState>();
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const ResourceLibraryPage(),
      const AssignmentHelpPage(),
      PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          final nav = _studyGroupNavKey.currentState;
          if (nav != null && nav.canPop()) {
            nav.pop();
          }
        },
        child: Navigator(
          key: _studyGroupNavKey,
          onGenerateRoute: (settings) => MaterialPageRoute(
            builder: (_) => const StudyGroupListScreen(),
          ),
        ),
      ),
      const SettingsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBrand = Color(0xFF0F766E);

    Widget? fab;
    if (_currentIndex == 0) {
      fab = FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ResourceFormPage()),
          );
        },
        backgroundColor: primaryBrand,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.upload_file_outlined),
        label: const Text('Upload'),
      );
    } else if (_currentIndex == 1) {
      fab = FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const HelpRequestFormPage(),
            ),
          );
        },
        backgroundColor: primaryBrand,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Post Help Request'),
      );
    }

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButton: fab,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xF2FFFFFF),
        surfaceTintColor: Colors.transparent,
        elevation: 10,
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        indicatorColor: primaryBrand.withOpacity(0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books, color: primaryBrand),
            label: 'Resources',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment, color: primaryBrand),
            label: 'Help Seeking',
          ),
          NavigationDestination(
            icon: Icon(Icons.group_outlined),
            selectedIcon: Icon(Icons.group, color: primaryBrand),
            label: 'Study Group',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: primaryBrand),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
