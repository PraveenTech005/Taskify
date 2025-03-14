import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:taskify/screens/tasks.dart';
import 'package:taskify/screens/home.dart';
import 'package:taskify/screens/settings.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 0; // Index of the selected tab

  // List of screens/pages corresponding to each tab
  final List<Widget> _pages = [
    const Home(key: PageStorageKey('home')),
    const Tasks(key: PageStorageKey('tasks')),
    const Settings(key: PageStorageKey('settings')),
  ];

  // Function to handle tab changes
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Display the selected screen
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
        child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Color.fromRGBO(21, 21, 21, 1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  width: 2.0)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: GNav(
              backgroundColor: Colors.transparent,
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
              color: Theme.of(context).brightness == Brightness.dark
                  ? Color.fromRGBO(125, 125, 125, 1)
                  : Colors.black,
              activeColor: Colors.white,
              tabBackgroundColor: const Color.fromRGBO(43, 50, 208, 1),
              gap: 10,
              onTabChange: _onItemTapped, // Callback for tab changes
              tabs: const [
                GButton(icon: Icons.home, text: "Home"),
                GButton(
                  icon: Icons.checklist_rounded,
                  text: "Tasks",
                ),
                GButton(
                  icon: Icons.settings,
                  text: "Settings",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
