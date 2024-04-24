// ignore_for_file: use_build_context_synchronously

import 'package:events_app_mobile/controllers/add_event_step_four_screen_controller.dart';
import 'package:events_app_mobile/graphql/add_event_step_four_screen/add_event_step_four_screen_queries.dart';
import 'package:events_app_mobile/models/autocomplete_places_result.dart';
import 'package:events_app_mobile/services/place_service.dart';
import 'package:events_app_mobile/widgets/app_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:events_app_mobile/bloc/add_event/add_event_bloc.dart'
    as add_event_bloc;
import 'package:graphql_flutter/graphql_flutter.dart';

class AddEventStepFourScreen extends StatefulWidget {
  const AddEventStepFourScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AddEventStepFourScreenState();
}

class _AddEventStepFourScreenState extends State<AddEventStepFourScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late ScrollController _scrollController;
  late AddEventStepFourScreenController _addEventStepFourScreenController;

  void _onAutocompleteSelected(
      BuildContext context, AutocompletePlacesPrediction prediction) {}

  void _onAutocompleteSubmitted(BuildContext context, String value) {}

  void _onContinue() {
    context
        .read<add_event_bloc.AddEventBloc>()
        .add(const add_event_bloc.AddEventIncrementStepRequested());
  }

  @override
  void initState() {
    super.initState();

    PlaceService placeService = PlaceService();

    _addEventStepFourScreenController = AddEventStepFourScreenController(
      placeService: placeService,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<add_event_bloc.AddEventBloc,
        add_event_bloc.AddEventState>(
      listener: (BuildContext context, add_event_bloc.AddEventState state) {},
      builder: (BuildContext context, add_event_bloc.AddEventState state) {
        return Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            children: [
              AppAutocomplete<AutocompletePlacesPrediction>(
                textEditingController: _textEditingController,
                focusNode: _focusNode,
                borderRadius: 35,
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search for places...',
                maxLines: 1,
                optionsBuilder: (TextEditingValue textEditingValue) =>
                    _addEventStepFourScreenController
                        .autocompletePlacesOptionsBuilder(
                  context: context,
                  textEditingValue: textEditingValue,
                  graphqlDocument:
                      AddEventStepFourScreenQueries.autocompletePlaces,
                  query: _textEditingController.text,
                  skip: 0,
                  limit: 10,
                  fetchPolicy: FetchPolicy.networkOnly,
                ),
                optionsViewBuilder: (
                  BuildContext context,
                  onAutoCompleteSelect,
                  Iterable<AutocompletePlacesPrediction> options,
                ) =>
                    _addEventStepFourScreenController
                        .autocompletePlacesOptionsViewBuilder(
                  context: context,
                  onAutoCompleteSelect: onAutoCompleteSelect,
                  options: options,
                  scrollController: _scrollController,
                ),
                onSelected: (AutocompletePlacesPrediction selection) {
                  _onAutocompleteSelected(context, selection);
                },
                onSubmitted: (String value) {
                  _onAutocompleteSubmitted(context, value);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
