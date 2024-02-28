import 'package:events_app_mobile/models/autocomplete_places_result.dart';
import 'package:events_app_mobile/models/paginated.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

String autocompletePlacesQuery = '''
  query AUTOCOMPLETE_PLACES(\$input: AutocompletePlacesInput!) {
    autocompletePlaces(input: \$input) {
      items {
        place {
          originalId
        }
      }
    }
  }
''';

class PlaceService {
  Future<Paginated<AutocompletePlacesResult>> autocompletePlaces({
    required BuildContext context,
    required String text,
    required int skip,
    required int limit,
  }) async {
    GraphQLClient client = GraphQLProvider.of(context).value;
    var response = await client.query(QueryOptions(
      document: gql(autocompletePlacesQuery),
      variables: {
        'input': {
          'query': text,
          'skip': skip,
          'limit': limit,
        },
      },
    ));

    Map<String, dynamic>? data = response.data;

    if (data == null) {
      print('exception: ');
      print(response.exception?.graphqlErrors[0].message);
      throw Exception();
    } else {
      List<AutocompletePlacesResult> places = data['autocompletePlaces']
              ['items']
          .map((item) => AutocompletePlacesResult.fromMap(item));
      int totalPagesCount = data['autocompletePlaces']['totalPagesCount'];

      Paginated<AutocompletePlacesResult> paginatedPlaces =
          Paginated<AutocompletePlacesResult>(
              items: places, totalPagesCount: totalPagesCount);

      return paginatedPlaces;
    }
  }
}
