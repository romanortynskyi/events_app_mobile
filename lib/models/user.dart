import 'package:events_app_mobile/models/model.dart';

class User extends Model {
  late String firstName;
  late String lastName;
  String? email;
  String? token;

  User({
    required int id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.token,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  User.fromMap(Map<String, dynamic> map)
      : super(
          id: map['id'],
          createdAt: map['createdAt'],
          updatedAt: map['updatedAt'],
        ) {
    firstName = map['firstName'];
    lastName = map['lastName'];
    email = map['email'];
    token = map['token'];
  }
}
