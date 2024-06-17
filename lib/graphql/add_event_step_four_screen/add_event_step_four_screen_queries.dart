class AddEventStepFourScreenQueries {
  static const String getRecommendedPlaces = '''
    query GET_RECOMMENDED_PLACES(\$skip: Int!, \$limit: Int!, \$maxImageHeight: Float!) {
      getRecommendedPlaces(skip: \$skip, limit: \$limit, maxImageHeight: \$maxImageHeight) {
        items {
          id
          originalId
          name
          imgSrc
          predictedSalesPercentage
        }
      }
    }
  ''';

  static const String autocompletePlaces = '''
    query AUTOCOMPLETE_PLACES(\$input: AutocompletePlacesInput!) {
      autocompletePlaces(input: \$input) {
        items {
          imgSrc
          originalId
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
