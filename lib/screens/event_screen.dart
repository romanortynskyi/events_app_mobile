import 'dart:async';

import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:events_app_mobile/models/event.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';

class EventScreen extends StatefulWidget {
  final int id;
  const EventScreen({super.key, required this.id});

  @override
  State<StatefulWidget> createState() => _EventScreenState();
}

String getEventById = """
  query GET_EVENT_BY_ID(\$id: Float!, \$latitude: Float!, \$longitude: Float!) {
    getEventById(id: \$id, latitude: \$latitude, longitude: \$longitude) {
      id
      createdAt
      updatedAt
      placeId
      distance
      title
      description
      startDate
      endDate
      ticketPrice
      image {
        src
      }
      place {
        name
        url
        geometry{
          location {
            lat
            lng
          }
        }
        country
        locality
      }
    }
  }
""";

class _EventScreenState extends State<EventScreen> {
  late Event _event;
  final Completer _mapCompleter = Completer();
  bool _isLoading = true;
  final LatLng _center = const LatLng(0, 0);
  final Set<Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) {
    _mapCompleter.complete(controller);
  }

  Future<Position?> _getCurrentPosition() async {
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

    return position;
  }

  void _getEventById() async {
    GraphQLClient client = GraphQLProvider.of(context).value;

    Position? position = await _getCurrentPosition();

    if (position != null) {
      var response = await client.query(QueryOptions(
        document: gql(getEventById),
        variables: {
          'id': widget.id,
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
      ));

      Map<String, dynamic> data = response.data ?? {};
      Event event = Event.fromMap(data['getEventById']);

      setState(() {
        _event = event;
        _isLoading = false;
        _markers.add(Marker(
            markerId: MarkerId(event.placeId ?? ''),
            position: LatLng(event.location.latLng?.latitude ?? 0,
                event.location.latLng?.longitude ?? 0)));
      });

      final GoogleMapController mapController = await _mapCompleter.future;

      await mapController.moveCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(event.location.latLng?.latitude ?? 0,
              event.location.latLng?.longitude ?? 0),
          zoom: 11,
        ),
      ));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _getEventById();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: LightThemeColors.primary,
            ))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(_event.image.src,
                      height: 300,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover),
                  Container(
                      margin: const EdgeInsets.only(left: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _event.title,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: LightThemeColors.text,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            child: Text(
                              DateFormat('EEE, MMM dd yyyy hh:mm')
                                  .format(_event.startDate),
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
                            _event.description,
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
                              '${_event.distance} m away',
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
                      markers: _markers,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
