// ignore_for_file: use_build_context_synchronously

import 'package:events_app_mobile/models/geolocation.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:location/location.dart';

class GeolocationService {
  Future<Geolocation?> getCurrentGeolocation({
    required String graphqlDocument,
    required BuildContext context,
    required LocationData locationData,
  }) async {
    if (context.mounted) {
      GraphQLClient client = GraphQLProvider.of(context).value;
      var response = await client.query(QueryOptions(
        document: gql(graphqlDocument),
        variables: {
          'latitude': locationData.latitude ?? 0,
          'longitude': locationData.longitude ?? 0,
        },
      ));

      Map<String, dynamic> data = response.data ?? {};
      Geolocation geolocation =
          Geolocation.fromMap(data['getGeolocationByCoords']);

      return geolocation;
    }

    return null;
  }
}
