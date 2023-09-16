import 'dart:async';

import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:events_app_mobile/graphql/queries/get_geolocation_by_coords.dart';
import 'package:events_app_mobile/models/location.dart';
import 'package:events_app_mobile/widgets/app_autocomplete.dart';
import 'package:events_app_mobile/widgets/home_header.dart';
import 'package:events_app_mobile/widgets/touchable_opacity.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<StatefulWidget> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isLoading = true;

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

  void onClearSearch() {
    _textEditingController.clear();
  }

  Completer<GoogleMapController> _completer = Completer();

  LatLng _center = const LatLng(0, 0);

  void _onMapCreated(GoogleMapController controller) {
    _completer.complete(controller);
  }

  @override
  void initState() {
    super.initState();

    _getCurrentLocation();
  }

  Location? _location;

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

      Map<String, dynamic> data = response.data ?? {};
      Location location = Location.fromMap(data['getGeolocationByCoords']);

      double latitude = location.latLng?.latitude ?? 0;
      double longitude = location.latLng?.longitude ?? 0;

      setState(() {
        _location = location;
        _isLoading = false;
      });

      final GoogleMapController mapController = await _completer.future;

      await mapController.moveCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 11,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : SingleChildScrollView(
            child: Column(
              children: [
                HomeHeader(
                  imgSrc: 'https://source.unsplash.com/random/',
                  location: _location,
                ),
                const SizedBox(height: 20),
                AppAutocomplete<String>(
                  textEditingController: _textEditingController,
                  focusNode: _focusNode,
                  borderRadius: 35,
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  suffixIcon: _textEditingController.text.isNotEmpty
                      ? TouchableOpacity(
                          onTap: onClearSearch,
                          child: const Icon(Icons.close),
                        )
                      : null,
                  hintText: 'Search for locations...',
                  optionsBuilder: optionsBuilder,
                  optionsViewBuilder: optionsViewBuilder,
                  onSelected: (String selection) {
                    debugPrint('You just selected $selection');
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: MediaQuery.of(context).size.height - 298,
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _center,
                      zoom: 11,
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
