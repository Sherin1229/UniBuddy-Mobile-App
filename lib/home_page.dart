import 'package:flutter/material.dart';
import 'features/resource_sharing/presentation/pages/resource_library_page.dart';
import 'features/assignment_help/presentation/pages/assignment_help_page.dart';
import 'features/study_group/presentation/pages/study_group_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    ResourceLibraryPage(),
    AssignmentHelpPage(),
    StudyGroupPage(),
  ];

  @override
  Widget build(BuildContext context) {
    const Color primaryBrand = Color(0xFF0F766E);
    
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
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
        ],
      ),
    );
  }
}
