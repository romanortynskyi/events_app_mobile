class AddEventStepThreeScreenQueries {
  static const String getCategories = '''
    query GET_CATEGORIES(\$shouldReturnAll: Boolean) {
      getCategories(shouldReturnAll: \$shouldReturnAll) {
        items {
          id
          name
        }
      }
    }
  ''';
}
