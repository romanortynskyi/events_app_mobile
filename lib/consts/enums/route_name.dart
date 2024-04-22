enum RouteName {
  main('/'),
  login('/login'),
  signUp('/sign-up'),
  profile('/profile'),
  searchResults('/search-results'),
  event('/event');

  final String value;

  const RouteName(this.value);
}
