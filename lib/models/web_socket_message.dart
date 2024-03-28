import 'package:events_app_mobile/abstract/model.dart';

class WebSocketMessage<T extends Model<T>> {
  late String type;
  late T data;

  WebSocketMessage({
    required this.type,
    required this.data,
  });

  WebSocketMessage.fromMap(Map<String, dynamic> map, T defaultData) {
    type = map['type'];
    data = defaultData.fromMap(map['data']);
  }
}
