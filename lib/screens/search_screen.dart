// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:ui' as ui;

import 'package:events_app_mobile/consts/global_consts.dart';
import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:events_app_mobile/models/autocomplete_places_prediction.dart';
import 'package:events_app_mobile/models/autocomplete_places_response.dart';
import 'package:events_app_mobile/models/event.dart';
import 'package:events_app_mobile/models/geolocation.dart';
import 'package:events_app_mobile/screens/event_screen.dart';
import 'package:events_app_mobile/services/geolocation_service.dart';
import 'package:events_app_mobile/services/place_service.dart';
import 'package:events_app_mobile/utils/widget_utils.dart';
import 'package:events_app_mobile/widgets/app_autocomplete.dart';
import 'package:events_app_mobile/widgets/home_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

String getGeolocationByCoords = """
  query GET_GEOLOCATION_BY_COORDS(\$latitude: Float!, \$longitude: Float!) {
    getGeolocationByCoords(latitude: \$latitude, longitude: \$longitude) {
      country
      locality
      placeId
      latitude
      longitude
    }
  }
""";

String getEvents = '''
  query GET_EVENTS(\$bounds: GetEventsBounds) {
    getEvents(bounds: \$bounds) {
      items {
        id
        image {
          src
        }
        createdAt
        updatedAt
        placeId
        geolocation {
          latitude
          longitude
        }
        title
        place {
          googleMapsUri
          location {
            latitude
            longitude
          }
        }
        description
        startDate
        endDate
        ticketPrice
      }
      totalPagesCount
    }
  }
''';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final GlobalKey topBarKey = GlobalKey();
  double topBarHeight = 0;

  bool _isLoading = true;

  final Map<MarkerId, Marker> _markers = {};

  double _heading = 0;
  Marker _userMarker = const Marker(
    markerId: MarkerId(''),
  );

  Timer? _debounceTimer;

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();

    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<Iterable<AutocompletePlacesPrediction>> optionsBuilder(
      TextEditingValue textEditingValue) async {
    String text = textEditingValue.text;

    if (text == '') {
      return const Iterable<AutocompletePlacesPrediction>.empty();
    }

    AutocompletePlacesResponse response =
        await PlaceService().autocompletePlaces(
      context: context,
      text: text,
      skip: 0,
      limit: 10,
    );

    return response.items ??
        const Iterable<AutocompletePlacesPrediction>.empty();
  }

  Widget optionsViewBuilder(
    BuildContext context,
    onAutoCompleteSelect,
    Iterable<AutocompletePlacesPrediction> options,
  ) {
    return Container(
      margin: const EdgeInsets.only(left: 20),
      child: Align(
          alignment: Alignment.topLeft,
          child: Material(
            color: LightThemeColors.grey,
            elevation: 4.0,
            child: SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(8.0),
                  itemCount: options.length,
                  separatorBuilder: (context, i) {
                    return const Divider();
                  },
                  itemBuilder: (BuildContext context, int index) {
                    if (options.isNotEmpty) {
                      AutocompletePlacesPrediction prediction =
                          options.elementAt(index);

                      return GestureDetector(
                        onTap: () => {onAutoCompleteSelect(prediction)},
                        child: Column(
                          children: [
                            Text(prediction.structuredFormatting?.mainText ??
                                ''),
                            Text(prediction
                                    .structuredFormatting?.secondaryText ??
                                '')
                          ],
                        ),
                      );
                    }

                    return null;
                  },
                )),
          )),
    );
  }

  final Completer<GoogleMapController> _completer = Completer();

  final LatLng _center = const LatLng(0, 0);

  void _onMapCreated(GoogleMapController controller) {
    _completer.complete(controller);
    _getEvents();
  }

  @override
  void initState() {
    super.initState();

    _getCurrentLocation();

    FlutterCompass.events!.listen((CompassEvent event) {
      setState(() {
        _heading = event.heading ?? 0;

        Marker updatedMarker = _userMarker.copyWith(
          rotationParam: _heading,
        );

        _markers[_userMarker.markerId] = updatedMarker;
      });
    });
  }

  Geolocation? _geolocation;

  void _getCurrentLocation() async {
    Geolocation? geolocation = await GeolocationService().getCurrentGeolocation(
      graphqlDocument: getGeolocationByCoords,
      context: context,
    );

    double latitude = geolocation?.latitude ?? 0;
    double longitude = geolocation?.longitude ?? 0;

    if (mounted) {
      setState(() {
        _geolocation = geolocation;
        _isLoading = false;
      });
    }

    final GoogleMapController mapController = await _completer.future;

    await mapController.moveCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 11,
      ),
    ));

    Uint8List markerIcon =
        await getBytesFromAsset('lib/images/user_marker.png', 50);

    _userMarker = Marker(
      markerId: const MarkerId(''),
      position: LatLng(latitude, longitude),
      icon: BitmapDescriptor.fromBytes(markerIcon),
      rotation: _heading,
      anchor: const Offset(0.5, 0.5),
      flat: true,
    );

    setState(() {
      _markers[_userMarker.markerId] = _userMarker;
    });
  }

  _showEventDetails(int id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventScreen(id: id)),
    );
  }

  void _getEvents() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      GoogleMapController controller = await _completer.future;
      LatLngBounds currentPosition = await controller.getVisibleRegion();

      LatLng southwest = currentPosition.southwest;
      LatLng northeast = currentPosition.northeast;

      final QueryOptions options = QueryOptions(
        document: gql(getEvents),
        variables: {
          'bounds': {
            'xMin': southwest.longitude,
            'yMin': southwest.latitude,
            'xMax': northeast.longitude,
            'yMax': northeast.latitude,
          },
        },
      );

      GraphQLClient client = GraphQLProvider.of(context).value;

      final QueryResult result = await client.query(options);

      if (result.hasException) {
        print('Error: ${result.exception.toString()}');
      } else {
        List<Event> events = result.data?['getEvents']['items']
            .map((eventMap) => Event.fromMap(eventMap))
            .toList()
            .cast<Event>();

        events.forEach((event) {
          double latitude = event.location?.latitude ?? 0;
          double longitude = event.location?.longitude ?? 0;

          MarkerId markerId = MarkerId(event.id.toString());
          LatLng position = LatLng(latitude, longitude);
          Marker marker = Marker(
            markerId: markerId,
            position: position,
            onTap: () => {_showEventDetails(event.id ?? -1)},
          );

          setState(() {
            _markers[markerId] = marker;
          });
        });
      }
    });
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

      setState(() {
        topBarHeight = newTopBarHeight;
      });
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
                    child: AppAutocomplete<AutocompletePlacesPrediction>(
                      textEditingController: _textEditingController,
                      focusNode: _focusNode,
                      borderRadius: 35,
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      hintText: 'Search for locations...',
                      optionsBuilder: optionsBuilder,
                      optionsViewBuilder: optionsViewBuilder,
                      onSelected: (AutocompletePlacesPrediction selection) {
                        print('You just selected ${selection.placeId}');
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
