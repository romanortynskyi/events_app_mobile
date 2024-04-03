import 'package:equatable/equatable.dart';
import 'package:events_app_mobile/abstract/model.dart';

class UploadUserImageProgress extends Model<UploadUserImageProgress>
    implements Equatable {
  int? total;
  int? loaded;
  String? key;
  String? location;

  UploadUserImageProgress({this.total, this.loaded, this.key, this.location});

  @override
  UploadUserImageProgress fromMap(Map<String, dynamic> map) {
    super.fromMap(map);

    total = map['total'];
    loaded = map['loaded'];
    key = map['key'];
    location = map['location'];

    return this;
  }

  @override
  List<Object?> get props => [
        total,
        loaded,
        key,
        location,
      ];

  @override
  bool? get stringify => true;
}
