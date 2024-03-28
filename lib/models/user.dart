import 'package:equatable/equatable.dart';
import 'package:events_app_mobile/abstract/copyable.dart';
import 'package:events_app_mobile/models/asset.dart';
import 'package:events_app_mobile/abstract/model.dart';

class User extends Model<User> implements Copyable, Equatable {
  String? firstName;
  String? lastName;
  String? email;
  String? token;
  Asset? image;

  User({
    required int id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.token,
    this.image,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  User.create();

  @override
  User copy() => User(
        id: super.id ?? -1,
        firstName: firstName,
        lastName: lastName,
        email: email,
        token: token,
        image: image,
      );

  @override
  User copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? token,
    Asset? image,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id ?? -1,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      token: token ?? this.token,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        email,
        token,
        image,
      ];

  @override
  bool? get stringify => true;

  @override
  User fromMap(Map<String, dynamic> map) {
    super.fromMap(map);

    firstName = map['firstName'];
    lastName = map['lastName'];
    email = map['email'];
    token = map['token'];
    image = map['image'] == null ? null : Asset().fromMap(map['image']);

    return this;
  }
}
