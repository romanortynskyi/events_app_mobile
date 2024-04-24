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

class AddEventSetHorizontalImageRequested extends AddEventEvent {
  final File imageFile;

  const AddEventSetHorizontalImageRequested({
    required this.imageFile,
  });
}

class AddEventSetInitialEventInputRequested extends AddEventEvent {
  final EventInput eventInput;

  const AddEventSetInitialEventInputRequested({
    required this.eventInput,
  });
}

class AddEventSetTitleRequested extends AddEventEvent {
  final String title;

  const AddEventSetTitleRequested({
    required this.title,
  });
}

class AddEventSetDescriptionRequested extends AddEventEvent {
  final String description;

  const AddEventSetDescriptionRequested({
    required this.description,
  });
}

class AddEventSetCategoriesRequested extends AddEventEvent {
  final List<int> categories;

  const AddEventSetCategoriesRequested({
    required this.categories,
  });
}
