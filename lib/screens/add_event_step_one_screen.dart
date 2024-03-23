// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:events_app_mobile/bloc/add_event/add_event_bloc.dart'
    as add_event_bloc;
import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:events_app_mobile/utils/widget_utils.dart';
import 'package:events_app_mobile/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class AddEventStepOneScreen extends StatefulWidget {
  const AddEventStepOneScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AddEventStepOneScreenState();
}

class _AddEventStepOneScreenState extends State<AddEventStepOneScreen> {
  final GlobalKey tapToChooseImageTextKey = GlobalKey();
  bool tapToChooseImageTextWidthReceived = false;
  double tapToChooseImageTextWidth = 0;

  final _imagePicker = ImagePicker();

  void _onChooseImagePressed() async {
    XFile? pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File file = File(pickedFile.path);

      context.read<add_event_bloc.AddEventBloc>().add(
          add_event_bloc.AddEventSetVerticalImageRequested(imageFile: file));
    }
  }

  void _onContinue() {
    context
        .read<add_event_bloc.AddEventBloc>()
        .add(const add_event_bloc.AddEventIncrementStepRequested());
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      double newTapToChooseImageTextWidth =
          WidgetUtils.getSize(tapToChooseImageTextKey).height;

      if (!tapToChooseImageTextWidthReceived &&
          newTapToChooseImageTextWidth > 0) {
        setState(() {
          tapToChooseImageTextWidth = newTapToChooseImageTextWidth;
          tapToChooseImageTextWidthReceived = true;
        });
      }
    });

    double screenHeight = MediaQuery.of(context).size.height;
    double imageHeight = screenHeight * 0.6;

    return BlocBuilder<add_event_bloc.AddEventBloc,
            add_event_bloc.AddEventState>(
        builder: (BuildContext context, add_event_bloc.AddEventState state) {
      File? image = state.eventInput.verticalImage;

      return Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: image == null ? _onChooseImagePressed : () {},
              child: Stack(
                alignment: Alignment.center,
                children: [
                  image == null
                      ? Image.asset(
                          'lib/images/image-placeholder-vertical.png',
                          height: imageHeight,
                        )
                      : Image.file(image),
                  Positioned.fill(
                    left: tapToChooseImageTextWidth / 2 - 10,
                    top: imageHeight - 180,
                    child: Text(
                      image == null ? 'Tap to choose an image' : '',
                      key: tapToChooseImageTextKey,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: image == null
                        ? const SizedBox()
                        : GestureDetector(
                            onTap: _onChooseImagePressed,
                            child: Container(
                              height: 50,
                              width: 50,
                              color: LightThemeColors.primary,
                              child: Center(
                                child: Icon(
                                  Icons.edit,
                                  color: LightThemeColors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AppButton(
              isDisabled: image == null,
              onPressed: image == null ? null : _onContinue,
              text: 'Continue',
            ),
          ],
        ),
      );
    });
  }
}
