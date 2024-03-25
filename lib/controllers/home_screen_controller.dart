// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:events_app_mobile/models/event.dart';
import 'package:events_app_mobile/models/geolocation.dart';
import 'package:events_app_mobile/models/month.dart';
import 'package:events_app_mobile/models/paginated.dart';
import 'package:events_app_mobile/screens/event_screen.dart';
import 'package:events_app_mobile/services/event_service.dart';
import 'package:events_app_mobile/services/geolocation_service.dart';
import 'package:events_app_mobile/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

class HomeScreenController {
  EventService eventService;
  LocationService locationService;
  GeolocationService geolocationService;
  BuildContext context;

  HomeScreenController({
    required this.eventService,
    required this.locationService,
    required this.geolocationService,
    required this.context,
  });

  Future<List<Event>> _getEventsFromBe({
    required String graphqlDocument,
    required int skip,
    required int limit,
    FetchPolicy? fetchPolicy,
  }) async {
    Paginated<Event>? response = await eventService.getEvents(
      context: context,
      graphqlDocument: graphqlDocument,
      skip: skip,
      limit: limit,
      fetchPolicy: fetchPolicy,
    );

    return response.items ?? [];
  }

  Future<List<Event>> _autocompleteEventsFromBe({
    required String graphqlDocument,
    required String query,
    required int skip,
    required int limit,
    FetchPolicy? fetchPolicy,
  }) async {
    Paginated<Event>? response = await eventService.autocompleteEvents(
      context: context,
      graphqlDocument: graphqlDocument,
      query: query,
      skip: skip,
      limit: limit,
      fetchPolicy: fetchPolicy,
    );

    return response.items ?? [];
  }

  Future<void> getEvents({
    required String graphqlDocument,
    required int skip,
    required int limit,
    FetchPolicy? fetchPolicy,
    Function? callback,
  }) async {
    List<Event> events = await _getEventsFromBe(
      graphqlDocument: graphqlDocument,
      skip: skip,
      limit: limit,
      fetchPolicy: fetchPolicy,
    );

    callback!(events);
  }

  List<Month> getMonths(List<Event> events, List<Month> prevMonths) {
    if (events.isEmpty) {
      return prevMonths;
    }

    Set<String> uniqueMonthNames = events
        .map((event) =>
            DateFormat('MMM yyyy').format(event.startDate ?? DateTime.now()))
        .toSet();

    List<Month> months = uniqueMonthNames.map((monthName) {
      List<Event> eventsByMonth = events
          .where((event) =>
              DateFormat('MMM yyyy')
                  .format(event.startDate ?? DateTime.now()) ==
              monthName)
          .toList();

      return Month(
        name: monthName,
        events: eventsByMonth,
      );
    }).toList();

    if (prevMonths.isNotEmpty) {
      Month lastMonthFromState = prevMonths.last;
      Month firstMonthFromResponse =
          months.where((month) => month.name == lastMonthFromState.name).first;
      Month updatedLastMonth = Month(
        name: lastMonthFromState.name,
        events: [
          ...lastMonthFromState.events,
          ...firstMonthFromResponse.events,
        ],
      );

      List<Month> updatedMonths = [
        ...prevMonths.where((month) => month.name != updatedLastMonth.name),
        updatedLastMonth,
        ...months.sublist(1),
      ];

      return updatedMonths;
    }

    return months;
  }

  Future<void> getCurrentGeolocation(
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
      }
    }
  }

  Future<Iterable<String>> autocompleteEventsOptionsBuilder({
    required TextEditingValue textEditingValue,
    required String graphqlDocument,
    required String query,
    required int skip,
    required int limit,
    FetchPolicy? fetchPolicy,
  }) async {
    String text = textEditingValue.text;

    if (text == '') {
      return const Iterable<String>.empty();
    }

    List<String> options = [];

    List<Event> events = await _autocompleteEventsFromBe(
      graphqlDocument: graphqlDocument,
      query: query,
      skip: skip,
      limit: limit,
      fetchPolicy: fetchPolicy,
    );

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

  void onEventPressed(BuildContext context, Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventScreen(id: event.id ?? -1)),
    );
  }
}
