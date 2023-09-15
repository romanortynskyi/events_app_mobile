import 'package:events_app_mobile/models/location.dart';
import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final String imgSrc;
  final Location? location;

  const HomeHeader({
    super.key,
    required this.imgSrc,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    String locality = location?.locality ?? '';
    String country = location?.country ?? '';
    String locationStr = '$locality, $country';

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Row(
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
          CircleAvatar(
            backgroundImage: NetworkImage(imgSrc),
            radius: 30,
          )
        ],
      ),
    );
  }
}
