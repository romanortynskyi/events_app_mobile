import 'package:events_app_mobile/abstract/model.dart';

class Asset extends Model<Asset> {
  late String? src;
  late String? filename;

  Asset({
    this.src,
    this.filename,
  });

  @override
  fromMap(Map<String, dynamic> map) {
    super.fromMap(map);

    src = map['src'];
    filename = map['filename'];

    return this;
  }
}
