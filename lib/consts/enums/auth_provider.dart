enum AuthProvider {
  email('email'),
  google('google'),
  facebook('facebook');

  final String value;

  const AuthProvider(this.value);
}
