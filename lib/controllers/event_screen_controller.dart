// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:events_app_mobile/graphql/home_screen/event_screen_queries.dart';
import 'package:events_app_mobile/models/event.dart';
import 'package:events_app_mobile/models/geolocation.dart';
import 'package:events_app_mobile/services/event_service.dart';
import 'package:events_app_mobile/services/geolocation_service.dart';
import 'package:events_app_mobile/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:location/location.dart';

class EventScreenController {
  BuildContext context;
  LocationService locationService;
  GeolocationService geolocationService;
  EventService eventService;

  EventScreenController({
    required this.context,
    required this.locationService,
    required this.geolocationService,
    required this.eventService,
  });

  Future<Geolocation?> getCurrentGeolocation(
      {required String graphqlDocument}) async {
    LocationData? locationData = await locationService.getCurrentLocation();

    if (locationData != null) {
      Geolocation? geolocation = await geolocationService.getCurrentGeolocation(
        context: context,
        graphqlDocument: graphqlDocument,
        locationData: locationData,
      );

      return geolocation;
    }

    return null;
  }

  Future<Event?> _getEventByIdFromBe({
    required String graphqlDocument,
    required int id,
    required String originId,
    FetchPolicy? fetchPolicy,
  }) async {
    Event? response = await eventService.getEventById(
      context: context,
      graphqlDocument: graphqlDocument,
      fetchPolicy: fetchPolicy,
      id: id,
      originId: originId,
    );

    return response;
  }

  Future<void> getEventById({
    required int id,
    required String originId,
    required Completer mapCompleter,
    Function(Event)? callback,
  }) async {
    Event? event = await _getEventByIdFromBe(
      id: id,
      originId: originId,
      graphqlDocument: EventScreenQueries.getEventById,
    );

    if (event != null) {
      callback!(event);

      final GoogleMapController mapController = await mapCompleter.future;

      CameraUpdate cameraUpdate = CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(event.place?.location?.latitude ?? 0,
              event.place?.location?.longitude ?? 0),
          zoom: 15,
        ),
      );

      await mapController.moveCamera(cameraUpdate);
    }
  }
}
