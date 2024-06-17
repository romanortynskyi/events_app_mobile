import 'package:cached_network_image/cached_network_image.dart';
import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:events_app_mobile/models/place.dart';
import 'package:events_app_mobile/widgets/event_details.dart';
import 'package:events_app_mobile/widgets/event_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PlaceCard extends StatelessWidget {
  final Place place;
  final bool isSelected;

  const PlaceCard({
    super.key,
    required this.place,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: isSelected
          ? BoxDecoration(
              border: Border.all(color: LightThemeColors.primary, width: 4),
              borderRadius: const BorderRadius.all(Radius.circular(20)),
            )
          : null,
      padding: isSelected ? const EdgeInsets.all(15) : null,
      margin: const EdgeInsets.only(bottom: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
                imageUrl: place.imgSrc ?? '',
                height: 300,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover),
          ),
          const SizedBox(height: 30),
          Text(
            place.name ?? '',
          ),
          const SizedBox(height: 15),
          Text(
            'Predicted sales: ${place.predictedSalesPercentage}%',
          ),
        ],
      ),
    );
  }
}
