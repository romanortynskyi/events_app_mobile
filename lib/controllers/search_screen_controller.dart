// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:typed_data';

import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:events_app_mobile/models/autocomplete_places_result.dart';
import 'package:events_app_mobile/models/event.dart';
import 'package:events_app_mobile/models/geolocation.dart';
import 'package:events_app_mobile/models/get_events_bounds.dart';
import 'package:events_app_mobile/models/paginated.dart';
import 'package:events_app_mobile/screens/event_screen.dart';
import 'package:events_app_mobile/services/event_service.dart';
import 'package:events_app_mobile/services/geolocation_service.dart';
import 'package:events_app_mobile/services/location_service.dart';
import 'package:events_app_mobile/services/place_service.dart';
import 'package:events_app_mobile/utils/asset_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as images;

class SearchScreenController {
  BuildContext context;
  LocationService locationService;
  GeolocationService geolocationService;
  EventService eventService;
  PlaceService placeService;
  AssetBundle rootBundle;

  SearchScreenController({
    required this.context,
    required this.locationService,
    required this.geolocationService,
    required this.placeService,
    required this.eventService,
    required this.rootBundle,
  });

  Future<Geolocation?> getCurrentGeolocation(
      String graphqlDocument, Function callback) async {
    LocationData? locationData = await locationService.getCurrentLocation();

    if (locationData != null) {
      Geolocation? geolocation = await geolocationService.getCurrentGeolocation(
        graphqlDocument: graphqlDocument,
        context: context,
        locationData: locationData,
      );

      if (geolocation != null) {
        callback(geolocation);

        return geolocation;
      }
    }

    return null;
  }

  Future<void> animateMap(
    Completer<GoogleMapController> completer,
    Geolocation geolocation,
  ) async {
    final GoogleMapController mapController = await completer.future;

    double latitude = geolocation.latitude ?? 0;
    double longitude = geolocation.longitude ?? 0;

    await mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 15,
      ),
    ));
  }

  Future<Marker> getUserMarker({
    required AssetBundle rootBundle,
    required Geolocation geolocation,
    required double heading,
  }) async {
    Uint8List markerIconBytes = await AssetUtils.getBytesFromAsset(
      'lib/images/user_marker.png',
      50,
      rootBundle,
    );

    double latitude = geolocation.latitude ?? 0;
    double longitude = geolocation.longitude ?? 0;

    Marker marker = Marker(
      markerId: const MarkerId(''),
      position: LatLng(latitude, longitude),
      icon: BitmapDescriptor.fromBytes(markerIconBytes),
      rotation: heading,
      anchor: const Offset(0.5, 0.5),
      flat: true,
    );

    return marker;
  }

  Event? _getEarliestEvent(List<Event> eventList) {
    if (eventList.isEmpty) {
      return null;
    }

    return eventList.reduce(
        (a, b) => a.startDate!.isBefore(b.startDate ?? DateTime.now()) ? a : b);
  }

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

  _showEventDetails(int id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventScreen(id: id)),
    );
  }

  Future<void> getEvents({
    required String graphqlDocument,
    required Completer<GoogleMapController> completer,
    Timer? debounceTimer,
    Function(Marker)? onMarkerCreated,
  }) async {
    if (debounceTimer?.isActive ?? false) {
      debounceTimer?.cancel();
    }

    debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      GoogleMapController controller = await completer.future;
      LatLngBounds currentPosition = await controller.getVisibleRegion();

      LatLng southwest = currentPosition.southwest;
      LatLng northeast = currentPosition.northeast;

      Paginated<Event> paginatedEvents = await eventService.getEvents(
        context: context,
        graphqlDocument: graphqlDocument,
        bounds: GetEventsBounds(
          xMin: southwest.longitude,
          yMin: southwest.latitude,
          xMax: northeast.longitude,
          yMax: northeast.latitude,
        ),
      );

      if (context.mounted) {
        List<Event> eventsFromBe = paginatedEvents.items ?? [];

        Map<String, List<Event>> groupedEvents =
            groupBy(eventsFromBe, (event) => event.place?.originalId ?? '');

        Map<String, Event> firstEventsByPlace = {};

        for (var entry in groupedEvents.entries) {
          firstEventsByPlace[entry.key] = _getEarliestEvent(entry.value)!;
        }

        List<Event> events = firstEventsByPlace.values.toList();

        events.forEach((event) async {
          double latitude = event.place?.location?.latitude ?? 0;
          double longitude = event.place?.location?.longitude ?? 0;

          MarkerId markerId = MarkerId(event.id.toString());
          LatLng position = LatLng(latitude, longitude);

          Uint8List? imageBytes = await _getEventImage(event.image?.src ?? '');

          if (imageBytes != null) {
            Marker marker = Marker(
              markerId: markerId,
              position: position,
              onTap: () => {_showEventDetails(event.id ?? -1)},
              icon: BitmapDescriptor.fromBytes(imageBytes),
            );

            onMarkerCreated!(marker);
          }
        });
      }
    });
  }

  Future<Iterable<AutocompletePlacesResult>> optionsBuilder(
      TextEditingValue textEditingValue) async {
    String text = textEditingValue.text;

    if (text == '') {
      return const Iterable<AutocompletePlacesResult>.empty();
    }

    Paginated<AutocompletePlacesResult> response =
        await placeService.autocompletePlaces(
      context: context,
      text: text,
      skip: 0,
      limit: 10,
    );

    return response.items ?? [];
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
}
