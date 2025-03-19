import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/scan_section.dart';
import '../widgets/datasets_section.dart';
import '../widgets/profile_section.dart';

class HomeScreenContainer extends StatefulWidget {
  const HomeScreenContainer({super.key});

  @override
  State<HomeScreenContainer> createState() => _HomeScreenContainerState();
}

class _HomeScreenContainerState extends State<HomeScreenContainer> {
  int _selectedIndex = 0;
  late List<Widget> _screens;

  final List<String> _titles = [
    'Scan',
    'Datasets',
    'Profile',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize screens with the navigation callback
    _screens = [
      const ScanSection(),
      DatasetsSection(
        onScanButtonPressed: () {
          setState(() {
            _selectedIndex = 0; // Navigate to Scan tab
          });
        },
      ),
      const ProfileSection(),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Now it's safe to access Theme.of(context)
    _updateSystemUIOverlayStyle();
  }

  void _updateSystemUIOverlayStyle() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: isDarkMode ? Colors.grey.shade900 : Colors.green.shade600,
      systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.light,
    ));
  }

  @override
  Widget build(BuildContext context) {
    // It's also safe to access Theme.of(context) here
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          selectedItemColor: Colors.green.shade700,
          unselectedItemColor: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
          backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt_outlined),
              activeIcon: Icon(Icons.camera_alt),
              label: 'Scan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Datasets',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          elevation: 0,
        ),
      ),
    );
  }
}

