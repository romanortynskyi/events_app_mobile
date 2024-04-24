import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:events_app_mobile/models/autocomplete_places_prediction.dart';
import 'package:events_app_mobile/models/paginated.dart';
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

  Future<Iterable<AutocompletePlacesPrediction>>
      autocompletePlacesOptionsBuilder({
    required BuildContext context,
    required TextEditingValue textEditingValue,
    required String graphqlDocument,
    required String query,
    required int skip,
    required int limit,
    FetchPolicy? fetchPolicy,
  }) async {
    String text = textEditingValue.text;

    if (text == '') {
      return const Iterable<AutocompletePlacesPrediction>.empty();
    }

    Paginated<AutocompletePlacesPrediction> paginatedPlacePredictions =
        await placeService.autocompletePlaces(
      context: context,
      graphqlDocument: graphqlDocument,
      query: query,
      skip: skip,
      limit: limit,
      fetchPolicy: fetchPolicy,
      shouldGetFromGooglePlaces: true,
    );

    return paginatedPlacePredictions.items ?? [];
  }

  Widget autocompletePlacesOptionsViewBuilder({
    required BuildContext context,
    required onAutoCompleteSelect,
    required Iterable<AutocompletePlacesPrediction> options,
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
                  AutocompletePlacesPrediction prediction =
                      options.elementAt(index);

                  if (options.isNotEmpty) {
                    String? secondaryText =
                        prediction.structuredFormatting.secondaryText;

                    return GestureDetector(
                      onTap: () => onAutoCompleteSelect(prediction),
                      child: Column(
                        children: [
                          Text(prediction.structuredFormatting.mainText),
                          secondaryText == null
                              ? const SizedBox()
                              : Text(secondaryText),
                        ],
                      ),
                    );
                  }

                  return null;
                },
              )),
        ));
  }

  void onAutocompleteSelected({
    required BuildContext context,
    required AutocompletePlacesPrediction prediction,
    required TextEditingController textEditingController,
  }) {
    String mainText = prediction.structuredFormatting.mainText;
    String? secondaryText = prediction.structuredFormatting.secondaryText;
    String placeId = prediction.placeId;

    String newText = '';

    if (secondaryText == null) {
      newText = mainText;
    }

    newText = '$mainText, $secondaryText';

    textEditingController.text = newText;
    textEditingController.selection =
        TextSelection.collapsed(offset: newText.length);

    context
        .read<add_event_bloc.AddEventBloc>()
        .add(add_event_bloc.AddEventSetPlaceIdRequested(placeId: placeId));
  }
}
