import 'package:events_app_mobile/models/user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthState(user: null));

  void setCurrentUser(User user) async {
    emit(AuthState(user: user));
  }
}
