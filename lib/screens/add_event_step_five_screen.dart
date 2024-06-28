// ignore_for_file: use_build_context_synchronously

import 'package:events_app_mobile/controllers/add_event_step_five_screen_controller.dart';
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
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AddEventStepFiveScreen extends StatefulWidget {
  const AddEventStepFiveScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AddEventStepFiveScreenState();
}

class _AddEventStepFiveScreenState extends State<AddEventStepFiveScreen> {
  late AddEventStepFiveScreenController _addEventStepFiveScreenController;

  void _onInit() async {
    // PlaceService placeService = PlaceService();

    // _addEventStepFourScreenController = AddEventStepFourScreenController(
    //   placeService: placeService,
    //   context: context,
    // );
  }

  void _onChangeDependencies() async {}

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
          child: CardField(
            onCardChanged: (card) {
              print(card);
            },
          ),
        );
      },
    );
  }
}
