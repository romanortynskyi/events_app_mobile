import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:events_app_mobile/graphql/queries/get_geolocation_by_coords.dart';
import 'package:events_app_mobile/screens/home_screen.dart';
import 'package:events_app_mobile/screens/map_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
    Text('profile'),
  ];

  void _getCurrentLocation() async {
    LocationPermission permission;
    Position? position;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Denied');
      } else {
        position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
      }
    } else {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    }

    if (position != null) {
      // ignore: use_build_context_synchronously
      GraphQLClient client = GraphQLProvider.of(context).value;
      var response = await client.query(QueryOptions(
        document: gql(getGeolocationByCoords),
        variables: {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
      ));

      print(response);
    }
  }

  @override
  void initState() {
    super.initState();

    _getCurrentLocation();
  }

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
