import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:events_app_mobile/screens/add_event_screen.dart';
import 'package:events_app_mobile/screens/home_screen.dart';
import 'package:events_app_mobile/screens/search_screen.dart';
import 'package:events_app_mobile/screens/profile_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  final icons = [
    Icon(
      Icons.home,
      size: 30,
      color: LightThemeColors.white,
    ),
    Icon(
      Icons.search_outlined,
      size: 30,
      color: LightThemeColors.white,
    ),
    Icon(
      Icons.add,
      size: 30,
      color: LightThemeColors.white,
    ),
    Icon(
      Icons.person,
      size: 30,
      color: LightThemeColors.white,
    ),
  ];

  final items = const [
    HomeScreen(),
    SearchScreen(),
    AddEventScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightThemeColors.white,
      bottomNavigationBar: CurvedNavigationBar(
        items: icons,
        color: const Color(0xFFA491D3),
        backgroundColor: LightThemeColors.white,
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
