import 'package:cached_network_image/cached_network_image.dart';
import 'package:events_app_mobile/models/geolocation.dart';
import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final String? imgSrc;
  final Geolocation? geolocation;

  const HomeHeader({
    super.key,
    this.imgSrc,
    required this.geolocation,
  });

  Widget _getAvatar(String? imgSrc) {
    return imgSrc == null
        ? const SizedBox()
        : CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(imgSrc),
            radius: 30,
          );
  }

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
        _getAvatar(imgSrc),
      ],
    );
  }
}
