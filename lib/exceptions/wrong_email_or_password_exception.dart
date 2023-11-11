import 'package:events_app_mobile/exceptions/app_exception.dart';
import 'package:flutter/material.dart';

class WrongEmailOrPasswordException extends AppException {
  final BuildContext context;

  WrongEmailOrPasswordException(this.context,
      {super.message = 'Wrong email or password'});
}
