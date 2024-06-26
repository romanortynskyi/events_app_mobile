import 'package:events_app_mobile/models/event.dart';
import 'package:events_app_mobile/models/paginated.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class EventService {
  Future<Paginated<Event>> getEvents({
    required BuildContext context,
    required String graphqlDocument,
    int? skip,
    int? limit,
    bool? shouldReturnSoonest = false,
    FetchPolicy? fetchPolicy,
  }) async {
    GraphQLClient client = GraphQLProvider.of(context).value;

    Map<String, dynamic> variables = {};

    if (skip != null && limit != null) {
      variables.addAll({
        'skip': skip,
        'limit': limit,
      });
    } else if (shouldReturnSoonest != null) {
      variables.addAll({
        'shouldReturnSoonest': shouldReturnSoonest,
      });
    }

    var response = await client.query(QueryOptions(
      document: gql(graphqlDocument),
      variables: variables,
      fetchPolicy: fetchPolicy ?? FetchPolicy.networkOnly,
    ));

    if (response.hasException) {
      throw Exception(response.exception!.graphqlErrors[0].message);
    }

    List<Event> events = response.data!['getEvents']['items']
        .map((map) => Event().fromMap(map))
        .toList()
        .cast<Event>();
    int totalPagesCount = response.data!['getEvents']['totalPagesCount'];

    return Paginated<Event>(items: events, totalPagesCount: totalPagesCount);
  }

  Future<Event?> getEventById({
    required int id,
    required String originId,
    required BuildContext context,
    required String graphqlDocument,
    FetchPolicy? fetchPolicy = FetchPolicy.cacheFirst,
  }) async {
    GraphQLClient client = GraphQLProvider.of(context).value;
    var response = await client.query(QueryOptions(
      document: gql(graphqlDocument),
      variables: {
        'id': id,
        'originId': originId,
      },
      fetchPolicy: fetchPolicy,
    ));

    Map<String, dynamic>? data = response.data;

    if (data == null) {
      print('exception: ');
      print(response.exception?.graphqlErrors[0].message);
    } else {
      Event event = Event().fromMap(data['getEventById']);

      return event;
    }

    return null;
  }

  Future<Paginated<Event>> autocompleteEvents({
    required BuildContext context,
    required String graphqlDocument,
    required String query,
    required int skip,
    required int limit,
    FetchPolicy? fetchPolicy = FetchPolicy.cacheFirst,
  }) async {
    GraphQLClient client = GraphQLProvider.of(context).value;
    var response = await client.query(QueryOptions(
      document: gql(graphqlDocument),
      variables: {
        'input': {
          'query': query,
          'skip': skip,
          'limit': limit,
        },
      },
      fetchPolicy: fetchPolicy,
    ));

    if (response.hasException) {
      throw Exception(response.exception?.graphqlErrors[0].message);
    }

    List<Event> events = response.data!['autocompleteEvents']['items']
        .map((map) => Event().fromMap(map))
        .toList()
        .cast<Event>();
    int totalPagesCount =
        response.data!['autocompleteEvents']['totalPagesCount'];

    return Paginated<Event>(items: events, totalPagesCount: totalPagesCount);
  }

  Future<Paginated<Event>> searchEvents({
    required BuildContext context,
    required String graphqlDocument,
    required String query,
    required int skip,
    required int limit,
    FetchPolicy? fetchPolicy = FetchPolicy.cacheFirst,
  }) async {
    GraphQLClient client = GraphQLProvider.of(context).value;
    var response = await client.query(QueryOptions(
      document: gql(graphqlDocument),
      variables: {
        'input': {
          'query': query,
          'skip': skip,
          'limit': limit,
        },
      },
      fetchPolicy: fetchPolicy,
    ));

    List<Event> events = response.data!['searchEvents']['items']
        .map((item) => Event().fromMap(item))
        .toList()
        .cast<Event>();
    int totalPagesCount = response.data!['searchEvents']['totalPagesCount'];

    Paginated<Event> paginatedEvents = Paginated(
      items: events,
      totalPagesCount: totalPagesCount,
    );

    return paginatedEvents;
  }
}
