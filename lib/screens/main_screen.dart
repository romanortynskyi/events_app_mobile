import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:events_app_mobile/consts/global_consts.dart';
import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:events_app_mobile/managers/web_socket_manager.dart';
import 'package:events_app_mobile/models/user.dart';
import 'package:events_app_mobile/models/web_socket_message.dart';
import 'package:events_app_mobile/screens/add_event_screen.dart';
import 'package:events_app_mobile/screens/home_screen.dart';
import 'package:events_app_mobile/screens/login_screen.dart';
import 'package:events_app_mobile/screens/search_screen.dart';
import 'package:events_app_mobile/screens/profile_screen.dart';
import 'package:events_app_mobile/bloc/auth/auth_bloc.dart' as auth_bloc;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  bool _letIndexChange(int index) {
    User? user = context.read<auth_bloc.AuthBloc>().state.user;

    if (index == items.length - 1 && user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );

      return false;
    } else {
      setState(() {
        _index = index;
      });
    }

    return true;
  }

  void onInit() async {
    WebSocketManager? wsManager = await WebSocketManager.getInstance(
      onMessage: (WebSocketMessage message) {
        print(message);
      },
    );
  }

  @override
  void initState() {
    super.initState();

    onInit();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<auth_bloc.AuthBloc, auth_bloc.AuthState>(
      builder: (BuildContext context, auth_bloc.AuthState state) => Scaffold(
        backgroundColor: LightThemeColors.white,
        bottomNavigationBar: CurvedNavigationBar(
          items: icons,
          color: LightThemeColors.primary,
          backgroundColor: LightThemeColors.white,
          height: GlobalConsts.bottomNavigationBarHeight,
          index: _index,
          letIndexChange: _letIndexChange,
        ),
        body: SafeArea(
          child: items[_index],
        ),
      ),
    );
  }
}
