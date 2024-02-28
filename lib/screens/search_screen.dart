// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:events_app_mobile/consts/global_consts.dart';
import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:events_app_mobile/models/autocomplete_places_result.dart';
import 'package:events_app_mobile/models/event.dart';
import 'package:events_app_mobile/models/geolocation.dart';
import 'package:events_app_mobile/models/paginated.dart';
import 'package:events_app_mobile/screens/event_screen.dart';
import 'package:events_app_mobile/services/geolocation_service.dart';
import 'package:events_app_mobile/services/place_service.dart';
import 'package:events_app_mobile/utils/asset_utils.dart';
import 'package:events_app_mobile/utils/widget_utils.dart';
import 'package:events_app_mobile/widgets/app_autocomplete.dart';
import 'package:events_app_mobile/widgets/home_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:collection/collection.dart';
import 'package:image/image.dart' as images;
import 'package:http/http.dart' as http;

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
        title
        place {
          originalId
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
  bool topBarHeightReceived = false;

  bool _isLoading = true;

  final Map<MarkerId, Marker> _markers = {};

  double _heading = 0;
  Marker _userMarker = const Marker(
    markerId: MarkerId(''),
  );
  Map<int, Uint8List> eventImages = {};

  Timer? _debounceTimer;

  Future<Iterable<AutocompletePlacesResult>> optionsBuilder(
      TextEditingValue textEditingValue) async {
    String text = textEditingValue.text;

    if (text == '') {
      return const Iterable<AutocompletePlacesResult>.empty();
    }

    Paginated<AutocompletePlacesResult> response =
        await PlaceService().autocompletePlaces(
      context: context,
      text: text,
      skip: 0,
      limit: 10,
    );

    return response.items;
  }

  Widget optionsViewBuilder(
    BuildContext context,
    onAutoCompleteSelect,
    Iterable<AutocompletePlacesResult> options,
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
                      AutocompletePlacesResult result =
                          options.elementAt(index);

                      return GestureDetector(
                        onTap: () => {onAutoCompleteSelect(result)},
                        child: const Column(
                          children: [
                            Text('Rynok Square, 23'),
                            Text('Lviv, Ukraine'),
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

  Geolocation? _geolocation;

  Future<Uint8List?> _getEventImage(String src) async {
    var response = await http.get(Uri.parse(src));

    if (response.statusCode == 200) {
      Uint8List bytes = response.bodyBytes;
      var avatarImage = images.decodeImage(bytes);

      if (avatarImage != null) {
        Uint8List markerIconBytes = await AssetUtils.getBytesFromAsset(
          'lib/images/event_marker.png',
          300,
          rootBundle,
        );
        var markerImage = images.decodeImage(markerIconBytes);

        avatarImage = images.copyResize(
          avatarImage,
          width: markerImage!.width ~/ 1.1,
          height: markerImage.height ~/ 1.4,
        );

        var radius = 90;
        int originX = avatarImage.width ~/ 2;
        int originY = avatarImage.height ~/ 2;

        for (int y = -radius; y <= radius; y++) {
          for (int x = -radius; x <= radius; x++) {
            if (x * x + y * y <= radius * radius) {
              markerImage.setPixel(
                originX + x + 8,
                originY + y + 10,
                avatarImage.getPixelSafe(originX + x, originY + y),
              );
            }
          }
        }

        return images.encodePng(markerImage);
      }
    }

    return null;
  }

  void _getCurrentLocation() async {
    if (mounted) {
      Geolocation? geolocation =
          await GeolocationService().getCurrentGeolocation(
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

      await mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 15,
        ),
      ));

      Uint8List markerIconBytes = await AssetUtils.getBytesFromAsset(
        'lib/images/user_marker.png',
        50,
        rootBundle,
      );

      _userMarker = Marker(
        markerId: const MarkerId(''),
        position: LatLng(latitude, longitude),
        icon: BitmapDescriptor.fromBytes(markerIconBytes),
        rotation: _heading,
        anchor: const Offset(0.5, 0.5),
        flat: true,
      );

      if (mounted) {
        setState(() {
          _markers[_userMarker.markerId] = _userMarker;
        });
      }
    }
  }

  _showEventDetails(int id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventScreen(id: id)),
    );
  }

  Event? getEarliestEvent(List<Event> eventList) {
    if (eventList.isEmpty) {
      return null;
    }

    return eventList.reduce(
        (a, b) => a.startDate!.isBefore(b.startDate ?? DateTime.now()) ? a : b);
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
        fetchPolicy: FetchPolicy.networkOnly,
      );

      if (mounted) {
        GraphQLClient client = GraphQLProvider.of(context).value;

        final QueryResult result = await client.query(options);

        if (result.hasException) {
          print('Error: ${result.exception.toString()}');
        } else {
          List<Event> eventsFromBe = result.data?['getEvents']['items']
              .map((eventMap) => Event.fromMap(eventMap))
              .toList()
              .cast<Event>();

          Map<String, List<Event>> groupedEvents =
              groupBy(eventsFromBe, (event) => event.place?.originalId ?? '');

          Map<String, Event> firstEventsByPlace = {};

          for (var entry in groupedEvents.entries) {
            firstEventsByPlace[entry.key] = getEarliestEvent(entry.value)!;
          }

          List<Event> events = firstEventsByPlace.values.toList();

          events.forEach((event) async {
            double latitude = event.place?.location?.latitude ?? 0;
            double longitude = event.place?.location?.longitude ?? 0;

            MarkerId markerId = MarkerId(event.id.toString());
            LatLng position = LatLng(latitude, longitude);

            Uint8List? imageBytes =
                await _getEventImage(event.image?.src ?? '');

            if (imageBytes != null) {
              Marker marker = Marker(
                markerId: markerId,
                position: position,
                onTap: () => {_showEventDetails(event.id ?? -1)},
                icon: BitmapDescriptor.fromBytes(imageBytes),
              );

              if (mounted) {
                setState(() {
                  _markers[markerId] = marker;
                });
              }
            }
          });
        }
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
                      optionsBuilder: optionsBuilder,
                      optionsViewBuilder: optionsViewBuilder,
                      onSelected: (AutocompletePlacesResult selection) {
                        print('You just selected ${selection.originalId}');
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
