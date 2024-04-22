// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:events_app_mobile/bloc/auth/auth_bloc.dart' as auth_bloc;
import 'package:events_app_mobile/consts/enums/route_name.dart';
import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:events_app_mobile/models/upload_user_image_progress.dart';
import 'package:events_app_mobile/models/user.dart';
import 'package:events_app_mobile/widgets/app_button.dart';
import 'package:events_app_mobile/widgets/user_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  void _onChooseImagePressed() async {
    XFile? pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File file = File(pickedFile.path);

      context
          .read<auth_bloc.AuthBloc>()
          .add(auth_bloc.UpdateUserImageRequested(context, file));
    }
  }

  void _onDeleteImagePressed() {}

  void _onSignOut() {
    context.read<auth_bloc.AuthBloc>().add(auth_bloc.SignOutRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<auth_bloc.AuthBloc, auth_bloc.AuthState>(
      listener: (context, state) {
        if (state is auth_bloc.UnAuthenticated) {
          Navigator.of(context).pushReplacementNamed(
            RouteName.main.value,
          );
        } else if (state is auth_bloc.UploadingUserImage) {
          UploadUserImageProgress progress =
              state.uploadImageProgress ?? UploadUserImageProgress();

          int loaded = progress.loaded ?? 0;
          int total = progress.total ?? 1;

          int percentage = (loaded / total).round() * 100;

          String imgSrc = progress.location ?? '';

          if (percentage == 100) {
            context
                .read<auth_bloc.AuthBloc>()
                .add(auth_bloc.UpdateUserImageEndRequested(imgSrc));
          }
        }
      },
      builder: (BuildContext context, auth_bloc.AuthState state) {
        double screenWidth = MediaQuery.of(context).size.width;
        double imageWidth = 200;
        double imageHeight = 200;
        double imageLeft = screenWidth / 2 - imageWidth / 2;

        User? user = state.user;

        Widget deleteImageButton = user?.image == null
            ? const SizedBox()
            : Positioned(
                left: 10,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 2,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: LightThemeColors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed: _onDeleteImagePressed,
                      icon: Icon(
                        Icons.delete,
                        color: LightThemeColors.white,
                      ),
                    ),
                  ),
                ),
              );

        bool isUserImageUpdating = state is auth_bloc.UploadingUserImage;

        Color circleColor = isUserImageUpdating
            ? LightThemeColors.white
            : LightThemeColors.primary;

        return Column(
          children: [
            Stack(
              children: [
                Image.asset('lib/images/profile-background.png'),
                Positioned(
                  bottom: 20,
                  left: imageLeft,
                  child: Stack(
                    children: [
                      UserImage(
                        width: imageWidth,
                        height: imageHeight,
                        imgSrc: user?.image?.src,
                        circleColor: circleColor,
                        firstName: user?.firstName ?? '',
                        lastName: user?.lastName ?? '',
                        isUserImageUpdating: isUserImageUpdating,
                        fontSize: 50,
                        shouldDropShadow: true,
                      ),
                      deleteImageButton,
                      Positioned(
                        right: 10,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 2,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          child: IconButton.filled(
                            onPressed: _onChooseImagePressed,
                            icon: const Icon(Icons.edit),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              child: AppButton(
                text: 'Sign Out',
                onPressed: _onSignOut,
              ),
            ),
          ],
        );
      },
    );
  }
}
