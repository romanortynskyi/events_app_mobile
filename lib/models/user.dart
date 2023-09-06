class User {
  late String firstName;
  late String lastName;
  String? email;
  String? token;

  User({
    required this.firstName,
    required this.lastName,
    this.email,
    this.token,
  });

  User.fromMap(Map<String, dynamic> map) {
    firstName = map['firstName'];
    lastName = map['lastName'];
    email = map['email'];
    token = map['token'];
  }
}
