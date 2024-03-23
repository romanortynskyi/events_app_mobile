import 'package:flutter/widgets.dart';

part of 'add_event_bloc.dart';

abstract class AddEventEvent extends Equatable {
  const AddEventEvent();

  @override
  List<Object> get props => [];
}

class AddEventIncrementStepRequested extends AddEventEvent {
  const AddEventIncrementStepRequested();
}

class AddEventDecrementStepRequested extends AddEventEvent {
  const AddEventDecrementStepRequested();
}

class AddEventSetVerticalImageRequested extends AddEventEvent {
  final File imageFile;

  const AddEventSetVerticalImageRequested({
    required this.imageFile,
  });
}

class AddEventSetInitialEventInputRequested extends AddEventEvent {
  final EventInput eventInput;

  const AddEventSetInitialEventInputRequested({
    required this.eventInput,
  });
}
