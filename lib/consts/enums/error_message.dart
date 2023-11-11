enum ErrorMessage {
  wrongEmailOrPassword('WRONG_EMAIL_OR_PASSWORD'),
  emailAlreadyExists('EMAIL_ALREADY_EXISTS');

  final String value;

  const ErrorMessage(this.value);
}
