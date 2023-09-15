import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:events_app_mobile/screens/home_screen.dart';
import 'package:events_app_mobile/screens/map_screen.dart';
import 'package:events_app_mobile/screens/profile_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  final icons = const [
    Icon(Icons.home, size: 30),
    Icon(Icons.search_outlined, size: 30),
    Icon(Icons.person, size: 30),
  ];

  final items = const [
    HomeScreen(),
    MapScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        items: icons,
        color: const Color(0xFFA491D3),
        backgroundColor: Colors.transparent,
        height: 70,
        index: _index,
        onTap: (value) {
          setState(() {
            _index = value;
          });
        },
      ),
      body: SafeArea(
        child: items[_index],
      ),
    );
  }
}
