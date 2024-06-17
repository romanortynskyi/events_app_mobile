// ignore_for_file: use_build_context_synchronously

import 'package:events_app_mobile/controllers/add_event_step_four_screen_controller.dart';
import 'package:events_app_mobile/graphql/add_event_step_four_screen/add_event_step_four_screen_queries.dart';
import 'package:events_app_mobile/models/place.dart';
import 'package:events_app_mobile/services/place_service.dart';
import 'package:events_app_mobile/widgets/app_text_field.dart';
import 'package:events_app_mobile/widgets/place_card.dart';
import 'package:events_app_mobile/widgets/touchable_opacity.dart';
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
  final FocusNode _focusNode = FocusNode();

  late AddEventStepFourScreenController _addEventStepFourScreenController;

  String? _defaultQuery;
  List<Place> _places = [];

  void _onQueryChanged(String query) {
    _addEventStepFourScreenController.onQueryChanged(
      context: context,
      skip: 0,
      limit: 10,
      text: query,
      maxImageHeight: 300,
      callback: _onPlacesLoaded,
      fetchPolicy: FetchPolicy.networkOnly,
    );
  }

  void _onContinue() {
    context
        .read<add_event_bloc.AddEventBloc>()
        .add(const add_event_bloc.AddEventIncrementStepRequested());
  }

  void _onPlacePressed(BuildContext context, Place place) {
    _addEventStepFourScreenController.onPlaceSelected(
      context: context,
      placeOriginalId: place.originalId ?? '',
    );
  }

  void _onPlacesLoaded(List<Place> places) {
    setState(() {
      _places = places;
    });
  }

  void _onInit() async {
    PlaceService placeService = PlaceService();

    _addEventStepFourScreenController = AddEventStepFourScreenController(
      placeService: placeService,
      context: context,
    );

    String defaultQuery =
        _addEventStepFourScreenController.getDefaultQuery(context);

    _defaultQuery = defaultQuery;
  }

  void _onChangeDependencies() async {
    if (_defaultQuery!.isEmpty) {
      List<Place> recommendedPlaces =
          await _addEventStepFourScreenController.getRecommendedPlaces(
        context: context,
        graphqlDocument: AddEventStepFourScreenQueries.getRecommendedPlaces,
        skip: 0,
        limit: 10,
        maxImageHeight: 300,
        fetchPolicy: FetchPolicy.cacheFirst,
      );

      _addEventStepFourScreenController.onPlaceSelected(
        context: context,
        placeOriginalId: recommendedPlaces.first.originalId ?? '',
      );

      _onPlacesLoaded(recommendedPlaces);
    } else {
      _onQueryChanged(_defaultQuery!);
    }
  }

  @override
  void initState() {
    super.initState();

    _onInit();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _onChangeDependencies();
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
              AppTextField(
                focusNode: _focusNode,
                borderRadius: 35,
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search for places...',
                maxLines: 1,
                obscureText: false,
                onChanged: _onQueryChanged,
                initialValue: _defaultQuery,
                validator: (String? value) => null,
              ),
              const SizedBox(height: 30),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _places.length,
                itemBuilder: (BuildContext context, int index) {
                  Place place = _places[index];
                  bool isSelected =
                      place.originalId == state.eventInput.placeOriginalId;

                  return TouchableOpacity(
                    onTap: () => _onPlacePressed(context, place),
                    child: PlaceCard(
                      place: place,
                      isSelected: isSelected,
                    ),
                  );
                },
              ).build(context),
            ],
          ),
        );
      },
    );
  }
}
