abstract class Model<T extends Model<T>> {
  int? id;
  DateTime? createdAt;
  DateTime? updatedAt;

  T fromMap(Map<String, dynamic> map) {
    id = map['id'];
    createdAt =
        map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null;
    updatedAt =
        map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null;

    return this as T;
  }

  Model({
    this.id,
    this.createdAt,
    this.updatedAt,
  });
}
