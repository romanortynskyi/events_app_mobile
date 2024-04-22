import 'package:events_app_mobile/consts/enums/route_name.dart';
import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:events_app_mobile/models/event.dart';
import 'package:events_app_mobile/models/paginated.dart';
import 'package:events_app_mobile/screens/search_results_screen.dart';
import 'package:events_app_mobile/services/event_service.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class SearchResultsScreenController {
  EventService eventService;

  SearchResultsScreenController({
    required this.eventService,
  });

  Future<List<Event>> searchEvents({
    required BuildContext context,
    required String graphqlDocument,
    required String query,
    required int skip,
    required int limit,
    FetchPolicy fetchPolicy = FetchPolicy.cacheFirst,
  }) async {
    Paginated<Event> paginatedEvents = await eventService.searchEvents(
      context: context,
      graphqlDocument: graphqlDocument,
      query: query,
      skip: skip,
      limit: limit,
      fetchPolicy: fetchPolicy,
    );

    return paginatedEvents.items!.toList();
  }

  Future<Iterable<String>> autocompleteEventsOptionsBuilder({
    required BuildContext context,
    required String graphqlDocument,
    required String query,
    required int skip,
    required int limit,
    FetchPolicy fetchPolicy = FetchPolicy.cacheFirst,
  }) async {
    if (query == '') {
      return const Iterable<String>.empty();
    }

    List<String> options = [];

    Paginated<Event> paginatedEvents = await eventService.autocompleteEvents(
      context: context,
      graphqlDocument: graphqlDocument,
      query: query,
      skip: skip,
      limit: limit,
      fetchPolicy: fetchPolicy,
    );

    List<Event> events = paginatedEvents.items ?? [];
    Set eventTitles = events.map((event) => event.title).toSet();
    eventTitles.forEach((title) => options.add(title));

    return options;
  }

  Widget autocompleteEventsOptionsViewBuilder({
    required BuildContext context,
    required onAutoCompleteSelect,
    required Iterable<String> options,
    required ScrollController scrollController,
  }) {
    return Align(
        alignment: Alignment.topLeft,
        child: Material(
          color: LightThemeColors.grey,
          elevation: 4.0,
          child: SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: scrollController,
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
        ));
  }

  void onAutocompleteSelected(BuildContext context, String text) {
    Navigator.of(context).pushNamed(
      RouteName.searchResults.value,
      arguments: SearchResultsScreenArguments(text),
    );
  }
}
