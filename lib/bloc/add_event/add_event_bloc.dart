import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:events_app_mobile/inputs/event_input.dart';

part 'add_event_event.dart';
part 'add_event_state.dart';

class AddEventBloc extends Bloc<AddEventEvent, AddEventState> {
  AddEventBloc() : super(Initial(eventInput: EventInput(), step: 0)) {
    on<AddEventIncrementStepRequested>(_onIncrementStep);
    on<AddEventDecrementStepRequested>(_onDecrementStep);

    on<AddEventSetVerticalImageRequested>(_onSetVerticalImage);
    on<AddEventSetHorizontalImageRequested>(_onSetHorizontalImage);

    on<AddEventSetTitleRequested>(_onSetTitleRequested);
    on<AddEventSetDescriptionRequested>(_onSetDescriptionRequested);
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

  void _onSetHorizontalImage(
    AddEventSetHorizontalImageRequested event,
    Emitter<AddEventState> emit,
  ) {
    EventInput newEventInput =
        state.eventInput.copyWith(horizontalImage: event.imageFile);
    emit(SetHorizontalImage(eventInput: newEventInput, step: state.step));
  }

  void _onSetTitleRequested(
    AddEventSetTitleRequested event,
    Emitter<AddEventState> emit,
  ) {
    EventInput newEventInput = state.eventInput.copyWith(title: event.title);
    emit(SetTitle(eventInput: newEventInput, step: state.step));
  }

  void _onSetDescriptionRequested(
    AddEventSetDescriptionRequested event,
    Emitter<AddEventState> emit,
  ) {
    EventInput newEventInput =
        state.eventInput.copyWith(description: event.description);
    emit(SetTitle(eventInput: newEventInput, step: state.step));
  }
}
