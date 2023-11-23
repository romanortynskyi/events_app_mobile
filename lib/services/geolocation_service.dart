// ignore_for_file: use_build_context_synchronously

import 'package:events_app_mobile/models/geolocation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class GeolocationService {
  Future<Geolocation?> getCurrentGeolocation({
    required String graphqlDocument,
    required BuildContext context,
  }) async {
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

    GraphQLClient client = GraphQLProvider.of(context).value;
    var response = await client.query(QueryOptions(
      document: gql(graphqlDocument),
      variables: {
        'latitude': position?.latitude,
        'longitude': position?.longitude,
      },
    ));

    if (response.data != null) {
      Map<String, dynamic> data = response.data ?? {};

      return Geolocation.fromMap(data['getGeolocationByCoords']);
    }

    return null;
  }
}
