import 'package:events_app_mobile/models/autocomplete_places_prediction.dart';
import 'package:events_app_mobile/models/paginated.dart';
import 'package:events_app_mobile/models/place.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class PlaceService {
  Future<Paginated<AutocompletePlacesPrediction>> autocompletePlaces({
    required BuildContext context,
    required String graphqlDocument,
    required String query,
    required int skip,
    required int limit,
    bool shouldGetFromGooglePlaces = false,
    FetchPolicy? fetchPolicy = FetchPolicy.cacheFirst,
    double? maxImageHeight,
  }) async {
    GraphQLClient client = GraphQLProvider.of(context).value;
    var response = await client.query(QueryOptions(
      document: gql(graphqlDocument),
      variables: {
        'input': {
          'query': query,
          'skip': skip,
          'limit': limit,
          'shouldGetFromGooglePlaces': shouldGetFromGooglePlaces,
          'maxImageHeight': maxImageHeight,
        },
      },
    ));

    Map<String, dynamic>? data = response.data;

    if (data == null) {
      print('exception: ');
      print(response.exception?.graphqlErrors[0].message);
      throw Exception();
    } else {
      List<AutocompletePlacesPrediction> places = data['autocompletePlaces']
              ['items']
          .map((item) => AutocompletePlacesPrediction.fromMap(item))
          .toList()
          .cast<AutocompletePlacesPrediction>();
      int totalPagesCount = data['autocompletePlaces']['totalPagesCount'];

      Paginated<AutocompletePlacesPrediction> paginatedPlaces =
          Paginated<AutocompletePlacesPrediction>(
        items: places,
        totalPagesCount: totalPagesCount,
      );

      return paginatedPlaces;
    }
  }

  Future<Paginated<Place>> getRecommendedPlaces({
    required BuildContext context,
    required String graphqlDocument,
    required int skip,
    required int limit,
    required int maxImageHeight,
    FetchPolicy? fetchPolicy = FetchPolicy.cacheFirst,
  }) async {
    GraphQLClient client = GraphQLProvider.of(context).value;
    var response = await client.query(QueryOptions(
      document: gql(graphqlDocument),
      variables: {
        'skip': skip,
        'limit': limit,
        'maxImageHeight': maxImageHeight,
      },
    ));

    Map<String, dynamic>? data = response.data;

    if (data == null) {
      print('exception: ');
      print(response.exception?.graphqlErrors[0].message);
      throw Exception();
    } else {
      List<Place> places = data['getRecommendedPlaces']['items']
          .map((item) => Place.fromMap(item))
          .toList()
          .cast<Place>();
      int? totalPagesCount = data['getRecommendedPlaces']['totalPagesCount'];

      Paginated<Place> paginatedPlaces = Paginated<Place>(
        items: places,
        totalPagesCount: totalPagesCount,
      );

      return paginatedPlaces;
    }
  }
}
