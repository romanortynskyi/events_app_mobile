// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:events_app_mobile/utils/widget_utils.dart';
import 'package:events_app_mobile/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddEventStepTwoScreen extends StatefulWidget {
  const AddEventStepTwoScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AddEventStepTwoScreenState();
}

class _AddEventStepTwoScreenState extends State<AddEventStepTwoScreen> {
  final GlobalKey tapToChooseImageTextKey = GlobalKey();
  bool tapToChooseImageTextWidthReceived = false;
  double tapToChooseImageTextWidth = 0;

  File? _image;
  final _imagePicker = ImagePicker();

  void _onChooseImagePressed() async {
    XFile? pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      double newTapToChooseImageTextWidth =
          WidgetUtils.getSize(tapToChooseImageTextKey).width;

      if (!tapToChooseImageTextWidthReceived &&
          newTapToChooseImageTextWidth > 0) {
        setState(() {
          tapToChooseImageTextWidth = newTapToChooseImageTextWidth;
          tapToChooseImageTextWidthReceived = true;
        });
      }
    });

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          GestureDetector(
            onTap: _image == null ? _onChooseImagePressed : () {},
            child: Stack(
              alignment: Alignment.center,
              children: [
                _image == null
                    ? Image.asset('lib/images/image-placeholder-horizontal.png')
                    : Image.file(_image ?? File('')),
                Positioned(
                  left: tapToChooseImageTextWidth / 2 - 10,
                  top: 180,
                  child: _image == null
                      ? Text(
                          'Tap to choose an image',
                          key: tapToChooseImageTextKey,
                        )
                      : const SizedBox(),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: _image == null
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
            onPressed: () {},
            text: 'Continue',
          ),
        ],
      ),
    );
  }
}
