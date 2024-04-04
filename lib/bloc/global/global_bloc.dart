// ignore_for_file: use_build_context_synchronously

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'global_event.dart';
part 'global_state.dart';

class GlobalBloc extends Bloc<GlobalEvent, GlobalState> {
  GlobalBloc() : super(const GlobalState(shouldGoToProfile: false)) {
    on<SetShouldGoToProfileRequested>(_onSetShouldGoToProfile);
  }

  void _onSetShouldGoToProfile(
    SetShouldGoToProfileRequested event,
    Emitter<GlobalState> emit,
  ) {
    emit(GlobalState(shouldGoToProfile: event.shouldGoToProfile));
  }
}
