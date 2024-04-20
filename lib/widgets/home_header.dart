import 'package:cached_network_image/cached_network_image.dart';
import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:events_app_mobile/models/geolocation.dart';
import 'package:events_app_mobile/widgets/user_image.dart';
import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final String? imgSrc;
  final String? firstName;
  final String? lastName;
  final Geolocation? geolocation;

  const HomeHeader({
    super.key,
    this.imgSrc,
    this.firstName,
    this.lastName,
    required this.geolocation,
  });

  @override
  Widget build(BuildContext context) {
    String locality = geolocation?.locality ?? '';
    String country = geolocation?.country ?? '';
    String locationStr = '$locality, $country';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Location',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: Colors.grey,
                ),
                Text(
                  locationStr,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        imgSrc == null
            ? const SizedBox()
            : UserImage(
                imgSrc: imgSrc,
                width: 60,
                height: 60,
                circleColor: LightThemeColors.primary,
                firstName: firstName ?? '',
                lastName: lastName ?? '',
                isUserImageUpdating: false,
                fontSize: 12,
              ),
      ],
    );
  }
}
