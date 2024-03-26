// ignore_for_file: use_build_context_synchronously

import 'package:events_app_mobile/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:events_app_mobile/bloc/add_event/add_event_bloc.dart'
    as add_event_bloc;

class AddEventStepThreeScreen extends StatefulWidget {
  const AddEventStepThreeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AddEventStepThreeScreenState();
}

class _AddEventStepThreeScreenState extends State<AddEventStepThreeScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<add_event_bloc.AddEventBloc,
        add_event_bloc.AddEventState>(
      builder: (BuildContext context, add_event_bloc.AddEventState state) {
        return Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              AppButton(
                onPressed: () {},
                text: 'Continue',
              ),
            ],
          ),
        );
      },
    );
  }
}
