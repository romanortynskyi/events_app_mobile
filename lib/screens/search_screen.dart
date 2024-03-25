// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:events_app_mobile/consts/global_consts.dart';
import 'package:events_app_mobile/controllers/search_screen_controller.dart';
import 'package:events_app_mobile/graphql/search_screen/search_screen_queries.dart';
import 'package:events_app_mobile/models/autocomplete_places_result.dart';
import 'package:events_app_mobile/models/geolocation.dart';
import 'package:events_app_mobile/services/event_service.dart';
import 'package:events_app_mobile/services/geolocation_service.dart';
import 'package:events_app_mobile/services/location_service.dart';
import 'package:events_app_mobile/services/place_service.dart';
import 'package:events_app_mobile/utils/widget_utils.dart';
import 'package:events_app_mobile/widgets/app_autocomplete.dart';
import 'package:events_app_mobile/widgets/home_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late SearchScreenController _searchScreenController;

  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final GlobalKey topBarKey = GlobalKey();
  double topBarHeight = 0;
  bool topBarHeightReceived = false;

  bool _isLoading = true;

  final Map<MarkerId, Marker> _markers = {};

  double _heading = 0;
  Marker _userMarker = const Marker(
    markerId: MarkerId(''),
  );
  Map<int, Uint8List> eventImages = {};

  Timer? _debounceTimer;

  final Completer<GoogleMapController> _completer = Completer();

  final LatLng _center = const LatLng(0, 0);

  void _onMapCreated(GoogleMapController controller) {
    _completer.complete(controller);
    _getEvents();
  }

  void _onGeolocationLoaded(Geolocation geolocation) {
    if (mounted) {
      setState(() {
        _geolocation = geolocation;
        _isLoading = false;
      });
    }
  }

  void _onUserMarkerCreated(Marker userMarker) {
    if (mounted) {
      setState(() {
        _userMarker = userMarker;
        _markers[_userMarker.markerId] = userMarker;
      });
    }
  }

  void _onMarkerCreated(Marker marker) {
    if (mounted) {
      setState(() {
        _markers[marker.markerId] = marker;
      });
    }
  }

  void onInit() async {
    Geolocation? geolocation =
        await _searchScreenController.getCurrentGeolocation(
      SearchScreenQueries.getGeolocationByCoords,
      _onGeolocationLoaded,
    );

    if (geolocation != null) {
      await _searchScreenController.animateMap(_completer, geolocation);

      Marker userMarker = await _searchScreenController.getUserMarker(
        rootBundle: rootBundle,
        geolocation: geolocation,
        heading: _heading,
      );

      _onUserMarkerCreated(userMarker);

      FlutterCompass.events!.listen((CompassEvent event) {
        if (mounted) {
          setState(() {
            _heading = event.heading ?? 0;

            Marker updatedMarker = _userMarker.copyWith(
              rotationParam: _heading,
            );

            _markers[_userMarker.markerId] = updatedMarker;
          });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();

    EventService eventService = EventService();
    LocationService locationService = LocationService();
    GeolocationService geolocationService = GeolocationService();
    PlaceService placeService = PlaceService();

    _searchScreenController = SearchScreenController(
      context: context,
      eventService: eventService,
      locationService: locationService,
      geolocationService: geolocationService,
      placeService: placeService,
      rootBundle: rootBundle,
    );

    onInit();
  }

  Geolocation? _geolocation;

  void _getEvents() {
    _searchScreenController.getEvents(
      graphqlDocument: SearchScreenQueries.getEvents,
      completer: _completer,
      onMarkerCreated: _onMarkerCreated,
    );
  }

  void _onCameraMove(CameraPosition cameraPosition) async {
    _getEvents();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      double newTopBarHeight = WidgetUtils.getSize(topBarKey).height;

      if (!topBarHeightReceived && newTopBarHeight > 0) {
        setState(() {
          topBarHeight = newTopBarHeight;
          topBarHeightReceived = true;
        });
      }
    });

    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Column(
            children: [
              Column(
                key: topBarKey,
                children: [
                  Container(
                    margin: const EdgeInsets.all(20),
                    child: HomeHeader(
                      imgSrc: 'https://source.unsplash.com/random/',
                      geolocation: _geolocation,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      right: 20,
                      bottom: 20,
                      left: 20,
                    ),
                    child: AppAutocomplete<AutocompletePlacesResult>(
                      textEditingController: _textEditingController,
                      focusNode: _focusNode,
                      borderRadius: 35,
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      hintText: 'Search for locations...',
                      optionsBuilder: _searchScreenController.optionsBuilder,
                      optionsViewBuilder:
                          _searchScreenController.optionsViewBuilder,
                      onSelected: (AutocompletePlacesResult selection) {
                        print('You just selected ${selection.originalId}');
                      },
                      onSubmitted: (String value) {
                        print('You just selected $value');
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height -
                    topBarHeight -
                    GlobalConsts.bottomNavigationBarHeight * 2,
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  onCameraMove: _onCameraMove,
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 11,
                  ),
                  markers: _markers.values.toSet(),
                ),
              ),
            ],
          );
  }
}
