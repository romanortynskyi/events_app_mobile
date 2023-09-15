import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:events_app_mobile/models/asset.dart';
import 'package:events_app_mobile/models/event.dart';
import 'package:events_app_mobile/models/location.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:latlng/latlng.dart' as latlng;

class EventScreen extends StatefulWidget {
  const EventScreen(int id, {super.key});

  @override
  State<StatefulWidget> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  Event event = Event(
    id: 5,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    description:
        '''Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.''',
    title: 'some cool event',
    startDate: DateTime(2024),
    endDate: DateTime(2024),
    image: Asset(
      src:
          'https://images.unsplash.com/photo-1687360441387-0179af118555?ixlib=rb-4.0.3&ixid=M3wxMjA3fDF8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1854&q=80',
    ),
    location: Location(
      latLng: const latlng.LatLng(34, 45),
      locality: 'Kyiv',
      country: 'Ukraine',
    ),
  );

  late GoogleMapController mapController;
  final LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: <Widget>[
                Image.network(event.image.src,
                    height: 300,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Column(
                    children: [
                      Text(
                        event.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: LightThemeColors.text,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            Container(
                margin: const EdgeInsets.only(left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: Text(
                        DateFormat('EEE, MMM DD yyyy hh:mm')
                            .format(event.startDate),
                        style: TextStyle(
                          color: LightThemeColors.text,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                      ),
                      child: Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: LightThemeColors.text,
                        ),
                      ),
                    ),
                    Text(
                      event.description,
                      style: TextStyle(
                        color: LightThemeColors.text,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                      ),
                      child: Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: LightThemeColors.text,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: Text(
                        '15.8 km away',
                        style: TextStyle(
                          color: LightThemeColors.text,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )),
            SizedBox(
              height: MediaQuery.of(context).size.width,
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 11,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId(''),
                    position: _center,
                    // icon: BitmapDescriptor
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
