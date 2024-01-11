import 'dart:async';

import 'package:events_app_mobile/consts/global_consts.dart';
import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:events_app_mobile/graphql/queries/get_geolocation_by_coords.dart';
import 'package:events_app_mobile/models/event.dart';
import 'package:events_app_mobile/models/geolocation.dart';
import 'package:events_app_mobile/utils/widget_utils.dart';
import 'package:events_app_mobile/widgets/app_autocomplete.dart';
import 'package:events_app_mobile/widgets/home_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:location/location.dart';

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
          lat
          lng
        }
        title
        place {
          url
          name
          geometry {
            location {
              lat
              lng
            }
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

  Set<Marker> _markers = {};

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

  Iterable<String> optionsBuilder(TextEditingValue textEditingValue) {
    if (textEditingValue.text == '') {
      return const Iterable<String>.empty();
    }

    return ['hello', 'pryvito'].where((String option) {
      return option.contains(textEditingValue.text.toLowerCase());
    });
  }

  Widget optionsViewBuilder(
    BuildContext context,
    onAutoCompleteSelect,
    Iterable<String> options,
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
                      return GestureDetector(
                        onTap: () =>
                            onAutoCompleteSelect(options.elementAt(index)),
                        child: Text(options.elementAt(index)),
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
  }

  Geolocation? _geolocation;

  void _getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();

    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();

      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();

    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();

      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();

    if (mounted) {
      // ignore: use_build_context_synchronously
      GraphQLClient client = GraphQLProvider.of(context).value;
      var response = await client.query(QueryOptions(
        document: gql(getGeolocationByCoords),
        variables: {
          'latitude': locationData.latitude ?? 0,
          'longitude': locationData.longitude ?? 0,
        },
      ));

      Map<String, dynamic> data = response.data ?? {};
      Geolocation geolocation =
          Geolocation.fromMap(data['getGeolocationByCoords']);

      double latitude = locationData.latitude ?? 0;
      double longitude = locationData.longitude ?? 0;

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

      Marker userMarker = Marker(
        markerId: const MarkerId(''),
        position: LatLng(latitude, longitude),
        icon: BitmapDescriptor.fromBytes(markerIcon),
      );

      setState(() {
        _markers.add(userMarker);
      });
    }
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
          double latitude = event.geolocation?.latLng?.latitude ?? 0;
          double longitude = event.geolocation?.latLng?.longitude ?? 0;

          LatLng position = LatLng(latitude, longitude);
          Marker marker = Marker(
            markerId: MarkerId(event.id.toString()),
            position: position,
          );

          setState(() {
            _markers.add(marker);
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
                    child: AppAutocomplete(
                      textEditingController: _textEditingController,
                      focusNode: _focusNode,
                      borderRadius: 35,
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      hintText: 'Search for locations...',
                      optionsBuilder: optionsBuilder,
                      optionsViewBuilder: optionsViewBuilder,
                      onSelected: (String selection) {
                        debugPrint('You just selected $selection');
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
                  markers: _markers,
                ),
              ),
            ],
          );
  }
}
