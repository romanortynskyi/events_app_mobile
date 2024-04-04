import 'package:flutter/widgets.dart';

part of 'global_bloc.dart';

abstract class GlobalEvent extends Equatable {
  const GlobalEvent();

  @override
  List<Object> get props => [];
}

class SetShouldGoToProfileRequested extends GlobalEvent {
  final bool shouldGoToProfile;

  const SetShouldGoToProfileRequested({
    required this.shouldGoToProfile,
  });
}
