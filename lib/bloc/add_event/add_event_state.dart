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

class SetStep extends AddEventState {
  const SetStep({
    required super.step,
    required super.eventInput,
    super.errorMessage,
  });
}
