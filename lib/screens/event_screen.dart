// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:events_app_mobile/graphql/queries/get_geolocation_by_coords.dart';
import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:events_app_mobile/models/event.dart';
import 'package:events_app_mobile/models/geolocation.dart';
import 'package:events_app_mobile/services/event_service.dart';
import 'package:events_app_mobile/services/geolocation_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class EventScreen extends StatefulWidget {
  final int id;
  const EventScreen({super.key, required this.id});

  @override
  State<StatefulWidget> createState() => _EventScreenState();
}

String getEventById = """
  query GET_EVENT_BY_ID(\$id: Float!, \$originId: String!) {
    getEventById(id: \$id, originId: \$originId) {
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
  late Event? _event = null;
  final Completer _mapCompleter = Completer();
  bool _isLoadingEvent = true;
  final LatLng _center = const LatLng(0, 0);
  final Set<Marker> _markers = {};

  bool _isLoadingGeolocation = true;

  void _onMapCreated(GoogleMapController controller) {
    _mapCompleter.complete(controller);
  }

  Future<Geolocation?> _getCurrentLocation() async {
    if (mounted) {
      Geolocation? geolocation =
          await GeolocationService().getCurrentGeolocation(
        context: context,
        graphqlDocument: getGeolocationByCoords,
      );

      return geolocation;
    }

    return null;
  }

  Future<void> _getEventById() async {
    Geolocation? geolocation = await _getCurrentLocation();

    setState(() {
      _isLoadingGeolocation = false;
    });

    if (geolocation != null) {
      Event? event = await EventService().getEventById(
        id: widget.id,
        originId: geolocation.placeId ?? '',
        context: context,
        graphqlDocument: getEventById,
      );

      setState(() {
        _event = event;
        _isLoadingEvent = false;
        _markers.add(Marker(
            markerId: MarkerId(event?.placeId ?? ''),
            position: LatLng(event?.location?.latitude ?? 0,
                event?.location?.longitude ?? 0)));
      });

      final GoogleMapController mapController = await _mapCompleter.future;

      CameraUpdate cameraUpdate = CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
              event?.location?.latitude ?? 0, event?.location?.longitude ?? 0),
          zoom: 11,
        ),
      );

      await mapController.moveCamera(cameraUpdate);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _getEventById();
  }

  @override
  Widget build(BuildContext context) {
    print('event: ');
    print(_event);
    return Scaffold(
      body: _isLoadingEvent || _isLoadingGeolocation
          ? Center(
              child: CircularProgressIndicator(
              color: LightThemeColors.primary,
            ))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(_event?.image?.src ?? '',
                      height: 300,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover),
                  Container(
                      margin: const EdgeInsets.only(left: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _event?.title ?? '',
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
                                  .format(_event?.startDate ?? DateTime.now()),
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
                            _event?.description ?? '',
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
                              '${_event?.distance} m away',
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
