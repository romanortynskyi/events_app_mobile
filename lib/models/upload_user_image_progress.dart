import 'package:events_app_mobile/abstract/model.dart';

class UploadUserImageProgress extends Model<UploadUserImageProgress> {
  int? total;
  int? loaded;
  String? key;
  String? location;

  @override
  UploadUserImageProgress fromMap(Map<String, dynamic> map) {
    super.fromMap(map);

    total = map['total'];
    loaded = map['loaded'];
    key = map['key'];
    location = map['location'];

    return this;
  }
}
