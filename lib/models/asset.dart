import 'package:events_app_mobile/models/model.dart';

class Asset extends Model {
  late String src;
  late String? filename;

  Asset({
    required this.src,
    this.filename,
  });

  Asset.fromMap(Map<String, dynamic> map)
      : super(
          id: map['id'],
          createdAt: map['createdAt'],
          updatedAt: map['updatedAt'],
        ) {
    src = map['src'];
    filename = map['filename'];
  }
}
