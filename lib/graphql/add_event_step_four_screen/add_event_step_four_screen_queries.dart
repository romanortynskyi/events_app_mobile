class AddEventStepFourScreenQueries {
  static const String autocompletePlaces = '''
    query AUTOCOMPLETE_PLACES(\$input: AutocompletePlacesInput!) {
      autocompletePlaces(input: \$input) {
        items {
          placeId
          structuredFormatting {
            mainText
            mainTextMatchedSubstrings {
              length
              offset
            }
            secondaryText
          }
        }
        totalPagesCount
      }
    }
  ''';
}
