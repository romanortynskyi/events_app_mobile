// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:events_app_mobile/controllers/event_screen_controller.dart';
import 'package:events_app_mobile/graphql/home_screen/event_screen_queries.dart';
import 'package:events_app_mobile/models/event.dart';
import 'package:events_app_mobile/models/geolocation.dart';
import 'package:events_app_mobile/services/event_service.dart';
import 'package:events_app_mobile/services/geolocation_service.dart';
import 'package:events_app_mobile/services/location_service.dart';
import 'package:events_app_mobile/utils/distance_format_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class EventScreen extends StatefulWidget {
  final int id;
  const EventScreen({super.key, required this.id});

  @override
  State<StatefulWidget> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  late Event? _event = null;
  final Completer _mapCompleter = Completer();
  bool _isLoadingEvent = true;
  final LatLng _center = const LatLng(0, 0);
  final Set<Marker> _markers = {};

  bool _isLoadingGeolocation = true;

  late EventScreenController _eventScreenController;

  @override
  void initState() {
    super.initState();

    LocationService locationService = LocationService();
    GeolocationService geolocationService = GeolocationService();
    EventService eventService = EventService();

    _eventScreenController = EventScreenController(
      context: context,
      locationService: locationService,
      geolocationService: geolocationService,
      eventService: eventService,
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapCompleter.complete(controller);
  }

  void _onGeolocationLoaded(Geolocation geolocation) {
    if (mounted) {
      setState(() {
        _isLoadingGeolocation = false;
      });
    }
  }

  void _onEventLoaded(Event event) {
    if (mounted) {
      setState(() {
        _event = event;
        _isLoadingEvent = false;
        _markers.add(Marker(
            markerId: MarkerId(event.place?.originalId ?? ''),
            position: LatLng(event.place?.location?.latitude ?? 0,
                event.place?.location?.longitude ?? 0)));
      });
    }
  }

  Future<void> _didChangeDependencies() async {
    Geolocation? geolocation =
        await _eventScreenController.getCurrentGeolocation(
      graphqlDocument: EventScreenQueries.getGeolocationByCoords,
    );

    if (geolocation != null) {
      _onGeolocationLoaded(geolocation);

      _eventScreenController.getEventById(
        id: widget.id,
        originId: geolocation.placeId ?? '',
        mapCompleter: _mapCompleter,
        callback: _onEventLoaded,
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    String formattedDistance =
        DistanceFormatUtils.format(_event?.distance?.toDouble() ?? 0);

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
                  // Image.network(_event?.image?.src ?? '',
                  //     height: 300,
                  //     width: MediaQuery.of(context).size.width,
                  //     fit: BoxFit.cover),
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
                              '$formattedDistance away',
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
