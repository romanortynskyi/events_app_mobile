import 'package:events_app_mobile/models/autocomplete_places_response.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

String autocompletePlacesQuery = '''
  query AUTOCOMPLETE_PLACES(\$input: AutocompletePlacesInput!) {
    autocompletePlaces(input: \$input) {
      items {
        description
        matchedSubstrings {
          offset
          length
        }
        placeId
        structuredFormatting {
          mainText
          mainTextMatchedSubstrings {
            length
            offset
          }
          secondaryText
        }
        terms {
          offset
          value
        }
        types
      }
    }
  }
''';

class PlaceService {
  Future<AutocompletePlacesResponse> autocompletePlaces({
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
      AutocompletePlacesResponse autocompletePlacesResponse =
          AutocompletePlacesResponse.fromMap(data['autocompletePlaces']);

      return autocompletePlacesResponse;
    }
  }
}
