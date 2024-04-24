// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:events_app_mobile/bloc/add_event/add_event_bloc.dart'
    as add_event_bloc;

class AddEventStepTwoScreenController {
  void onChooseImagePressed(
      BuildContext context, ImagePicker imagePicker) async {
    XFile? pickedFile =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File file = File(pickedFile.path);

      context.read<add_event_bloc.AddEventBloc>().add(
          add_event_bloc.AddEventSetHorizontalImageRequested(imageFile: file));
    }
  }

  void onContinuePressed(BuildContext context) {
    context
        .read<add_event_bloc.AddEventBloc>()
        .add(const add_event_bloc.AddEventIncrementStepRequested());
  }
}
