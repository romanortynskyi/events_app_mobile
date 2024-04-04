part of 'global_bloc.dart';

class GlobalState extends Equatable {
  @override
  List<Object?> get props => [shouldGoToProfile];

  final bool? shouldGoToProfile;
  const GlobalState({this.shouldGoToProfile});
}
