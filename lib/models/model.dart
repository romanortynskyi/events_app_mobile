class Model {
  late int id;
  late DateTime? createdAt;
  late DateTime? updatedAt;

  Model({
    required this.id,
    this.createdAt,
    this.updatedAt,
  });
}
