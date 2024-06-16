import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:events_app_mobile/abstract/copyable.dart';

class EventInput implements Copyable, Equatable {
  final String? placeOriginalId;
  final String? placeQuery;
  final String? title;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? ticketPrice;
  final File? verticalImage;
  final File? horizontalImage;
  final List<int>? categories;

  EventInput({
    this.placeOriginalId,
    this.placeQuery,
    this.title,
    this.description,
    this.startDate,
    this.endDate,
    this.ticketPrice,
    this.verticalImage,
    this.horizontalImage,
    this.categories,
  });

  @override
  EventInput copy() => EventInput(
        placeOriginalId: placeOriginalId,
        title: title,
        description: description,
        startDate: startDate,
        endDate: endDate,
        ticketPrice: ticketPrice,
        verticalImage: verticalImage,
        horizontalImage: horizontalImage,
        categories: categories,
      );

  @override
  EventInput copyWith({
    String? placeOriginalId,
    String? placeQuery,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    double? ticketPrice,
    File? verticalImage,
    File? horizontalImage,
    List<int>? categories,
  }) {
    File? newVerticalImage = this.verticalImage;
    File? newHorizontalImage = this.horizontalImage;

    if (verticalImage != null) {
      newVerticalImage = verticalImage;
    }

    if (horizontalImage != null) {
      newHorizontalImage = horizontalImage;
    }

    return EventInput(
      placeOriginalId: placeOriginalId ?? this.placeOriginalId,
      placeQuery: placeQuery ?? this.placeQuery,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      verticalImage: newVerticalImage,
      horizontalImage: newHorizontalImage,
      categories: categories ?? this.categories,
    );
  }

  @override
  List<Object?> get props => [
        placeOriginalId,
        title,
        description,
        startDate,
        endDate,
        ticketPrice,
        verticalImage,
        categories,
      ];

  @override
  bool? get stringify => true;
}
