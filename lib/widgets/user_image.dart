import 'package:cached_network_image/cached_network_image.dart';
import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:events_app_mobile/models/upload_user_image_progress.dart';
import 'package:flutter/material.dart';

class UserImage extends StatelessWidget {
  final double width;
  final double height;
  final Color circleColor;
  final String firstName;
  final String lastName;
  final bool isUserImageUpdating;
  final double fontSize;

  final String? imgSrc;
  final UploadUserImageProgress? uploadImageProgress;
  final bool? shouldDropShadow;

  const UserImage({
    super.key,
    required this.width,
    required this.height,
    required this.circleColor,
    required this.firstName,
    required this.lastName,
    required this.isUserImageUpdating,
    required this.fontSize,
    this.uploadImageProgress,
    this.imgSrc,
    this.shouldDropShadow = false,
  });

  Widget _getCircleContent() {
    int loaded = uploadImageProgress?.loaded ?? 0;
    int total = uploadImageProgress?.total ?? 1;

    int percentage = (loaded / total).round() * 100;

    double progressValue = ((percentage) / 100).floor().toDouble();

    if (isUserImageUpdating) {
      return Center(
        child: SizedBox(
          height: height,
          width: width,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: height,
                width: width,
                child: CircularProgressIndicator(
                  value: progressValue,
                  backgroundColor: LightThemeColors.white,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 50,
                  color: LightThemeColors.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (imgSrc == null && firstName.isNotEmpty && lastName.isNotEmpty) {
      String? firstNameFirstLetter = firstName.characters.first;
      String? lastNameFirstLetter = lastName.characters.first;
      String initials = '$firstNameFirstLetter$lastNameFirstLetter';

      return Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: fontSize,
            color: LightThemeColors.white,
          ),
        ),
      );
    }

    // otherwise user has an image
    if (imgSrc != null) {
      return CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(imgSrc!),
      );
    }

    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: circleColor,
        borderRadius: BorderRadius.circular(200),
        boxShadow: shouldDropShadow!
            ? [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 0),
                ),
              ]
            : null,
      ),
      child: _getCircleContent(),
    );
  }
}
