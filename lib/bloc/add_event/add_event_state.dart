part of 'add_event_bloc.dart';

abstract class AddEventState extends Equatable {
  @override
  List<Object?> get props => [eventInput, step, errorMessage];

  final EventInput eventInput;
  final int step;
  final String? errorMessage;

  const AddEventState({
    required this.eventInput,
    required this.step,
    this.errorMessage,
  });
}

class Initial extends AddEventState {
  const Initial({
    required super.step,
    required super.eventInput,
    super.errorMessage,
  });
}

class SetVerticalImage extends AddEventState {
  const SetVerticalImage({
    required super.step,
    required super.eventInput,
    super.errorMessage,
  });
}

class SetHorizontalImage extends AddEventState {
  const SetHorizontalImage({
    required super.step,
    required super.eventInput,
    super.errorMessage,
  });
}

class SetTitle extends AddEventState {
  const SetTitle({
    required super.step,
    required super.eventInput,
    super.errorMessage,
  });
}

class SetDescription extends AddEventState {
  const SetDescription({
    required super.step,
    required super.eventInput,
    super.errorMessage,
  });
}

class SetCategories extends AddEventState {
  const SetCategories({
    required super.step,
    required super.eventInput,
    super.errorMessage,
  });
}

class SetPlaceId extends AddEventState {
  const SetPlaceId({
    required super.step,
    required super.eventInput,
    super.errorMessage,
  });
}

class SetPlaceQuery extends AddEventState {
  const SetPlaceQuery({
    required super.step,
    required super.eventInput,
    super.errorMessage,
  });
}

class SetStep extends AddEventState {
  const SetStep({
    required super.step,
    required super.eventInput,
    super.errorMessage,
  });
}
