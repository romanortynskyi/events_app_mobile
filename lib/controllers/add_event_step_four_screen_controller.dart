import 'package:events_app_mobile/graphql/add_event_step_four_screen/add_event_step_four_screen_queries.dart';
import 'package:events_app_mobile/models/autocomplete_places_prediction.dart';
import 'package:events_app_mobile/models/paginated.dart';
import 'package:events_app_mobile/models/place.dart';
import 'package:events_app_mobile/services/place_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:events_app_mobile/bloc/add_event/add_event_bloc.dart'
    as add_event_bloc;

class AddEventStepFourScreenController {
  PlaceService placeService;
  BuildContext context;

  AddEventStepFourScreenController({
    required this.placeService,
    required this.context,
  });

  String getDefaultQuery(BuildContext context) {
    String query = context
            .read<add_event_bloc.AddEventBloc>()
            .state
            .eventInput
            .placeQuery ??
        '';

    return query;
  }

  void onQueryChanged({
    required BuildContext context,
    required String text,
    required int skip,
    required int limit,
    required double maxImageHeight,
    FetchPolicy? fetchPolicy,
    Function? callback,
  }) async {
    context
        .read<add_event_bloc.AddEventBloc>()
        .add(add_event_bloc.AddEventSetPlaceQueryRequested(placeQuery: text));

    Paginated<AutocompletePlacesPrediction> paginatedPlaces =
        await placeService.autocompletePlaces(
      context: context,
      graphqlDocument: AddEventStepFourScreenQueries.autocompletePlaces,
      skip: skip,
      limit: limit,
      query: text,
      maxImageHeight: maxImageHeight,
      fetchPolicy: fetchPolicy,
      shouldGetFromGooglePlaces: true,
    );

    List<Place> places =
        paginatedPlaces.items!.map((AutocompletePlacesPrediction prediction) {
      return Place(
          imgSrc: prediction.imgSrc,
          originalId: prediction.originalId,
          name: prediction.structuredFormatting.secondaryText == null
              ? prediction.structuredFormatting.mainText
              : '${prediction.structuredFormatting.mainText}, ${prediction.structuredFormatting.secondaryText}');
    }).toList();

    callback!(places);
  }

  void onPlaceSelected({
    required BuildContext context,
    required String placeOriginalId,
  }) {
    context.read<add_event_bloc.AddEventBloc>().add(
        add_event_bloc.AddEventSetPlaceOriginalIdRequested(
            placeOriginalId: placeOriginalId));
  }

  Future<List<Place>> getRecommendedPlaces({
    required BuildContext context,
    required String graphqlDocument,
    required int skip,
    required int limit,
    required int maxImageHeight,
    FetchPolicy? fetchPolicy,
  }) async {
    Paginated<Place> paginatedPlaces = await placeService.getRecommendedPlaces(
      context: context,
      graphqlDocument: graphqlDocument,
      skip: skip,
      limit: limit,
      maxImageHeight: maxImageHeight,
      fetchPolicy: fetchPolicy,
    );

    return paginatedPlaces.items ?? [];
  }
}
