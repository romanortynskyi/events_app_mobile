import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:events_app_mobile/abstract/copyable.dart';

class EventInput implements Copyable, Equatable {
  String? placeId;
  String? title;
  String? description;
  DateTime? startDate;
  DateTime? endDate;
  double? ticketPrice;
  File? verticalImage;
  List<int>? categories;

  EventInput({
    this.placeId,
    this.title,
    this.description,
    this.startDate,
    this.endDate,
    this.ticketPrice,
    this.verticalImage,
    this.categories,
  });

  @override
  EventInput copy() => EventInput(
        placeId: placeId,
        title: title,
        description: description,
        startDate: startDate,
        endDate: endDate,
        ticketPrice: ticketPrice,
        verticalImage: verticalImage,
        categories: categories,
      );

  @override
  EventInput copyWith({
    String? placeId,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    double? ticketPrice,
    File? verticalImage,
    List<int>? categories,
  }) {
    File? newVerticalImage;

    if (this.verticalImage == null) {
      newVerticalImage = verticalImage;
    } else if (verticalImage!.path != this.verticalImage!.path) {
      newVerticalImage = verticalImage;
    }

    return EventInput(
      placeId: placeId ?? this.placeId,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      verticalImage: newVerticalImage,
      categories: categories ?? this.categories,
    );
  }

  @override
  List<Object?> get props => [
        placeId,
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
