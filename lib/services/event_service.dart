import 'package:events_app_mobile/models/event.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class EventService {
  Future<Event?> getEventById({
    required int id,
    required String originId,
    required BuildContext context,
    required String graphqlDocument,
  }) async {
    GraphQLClient client = GraphQLProvider.of(context).value;
    var response = await client.query(QueryOptions(
      document: gql(graphqlDocument),
      variables: {
        'id': id,
        'originId': originId,
      },
    ));
    print('originId' + originId);
    Map<String, dynamic>? data = response.data;

    if (data == null) {
      print('exception: ');
      print(response.exception?.graphqlErrors[0].message);
    } else {
      Event event = Event.fromMap(data['getEventById']);

      return event;
    }

    return null;
  }
}
