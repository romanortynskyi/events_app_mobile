import 'package:events_app_mobile/abstract/model.dart';

class Category extends Model<Category> {
  String? name;

  Category({
    required int id,
    this.name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  Category.create();

  @override
  Category fromMap(Map<String, dynamic> map) {
    super.fromMap(map);

    name = map['name'];

    return this;
  }
}
