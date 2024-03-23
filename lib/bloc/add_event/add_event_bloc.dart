import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:events_app_mobile/inputs/event_input.dart';

part 'add_event_event.dart';
part 'add_event_state.dart';

class AddEventBloc extends Bloc<AddEventEvent, AddEventState> {
  AddEventBloc() : super(Initial(eventInput: EventInput(), step: 0)) {
    on<AddEventSetVerticalImageRequested>(_onSetVerticalImage);
    on<AddEventIncrementStepRequested>(_onIncrementStep);
    on<AddEventDecrementStepRequested>(_onDecrementStep);
  }

  void _onIncrementStep(
    AddEventIncrementStepRequested event,
    Emitter<AddEventState> emit,
  ) async {
    emit(SetStep(eventInput: state.eventInput, step: state.step + 1));
  }

  void _onDecrementStep(
    AddEventDecrementStepRequested event,
    Emitter<AddEventState> emit,
  ) async {
    emit(SetStep(eventInput: state.eventInput, step: state.step - 1));
  }

  void _onSetVerticalImage(
    AddEventSetVerticalImageRequested event,
    Emitter<AddEventState> emit,
  ) async {
    EventInput newEventInput =
        state.eventInput.copyWith(verticalImage: event.imageFile);
    emit(SetVerticalImage(eventInput: newEventInput, step: state.step));
  }
}
