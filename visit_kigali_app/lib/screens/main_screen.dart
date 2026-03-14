import 'package:flutter/material.dart';
import './directory/directory_screen.dart';
import './my_listings/my_listings_screen.dart';
import './map/map_view_screen.dart';
import './settings/settings_screen.dart';

/// MainScreen - The heart of the app!
/// This implements BottomNavigationBar with 4 required screens per rubric:
/// 1. Directory (all listings)
/// 2. My Listings (user's own listings)
/// 3. Map View (listings on Google Maps)
/// 4. Settings (profile & notifications)
/// 
/// Navigation pattern: Keep screens in memory for smooth switching
/// Learned this approach from Flutter docs - better UX than pushing/popping!
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Track which tab is currently selected (0 = Directory, 1 = My Listings, etc.)
  int _currentIndex = 0;

  // List of screens - indexed to match bottom nav items
  // All screens stay in memory (IndexedStack pattern)
  final List<Widget> _screens = [
    const DirectoryScreen(),     // 0 - Shows ALL listings with search/filter
    const MyListingsScreen(),    // 1 - Shows only user's listings with edit/delete
    const MapViewScreen(),       // 2 - Google Maps view of all listings
    const SettingsScreen(),      // 3 - User profile and app settings
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Display the currently selected screen
      // This rebuilds when _currentIndex changes
      body: _screens[_currentIndex],
      
      // Bottom Navigation Bar - required by rubric
      // Using 'fixed' type so all labels always show (better UX for 4 items)
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          // Switch to tapped tab
          setState(() {
            _currentIndex = index;
          });
        },
        // Styling - blue for selected, gray for unselected
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Directory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business_center), // Changed to be more relevant
            label: 'My Listings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}