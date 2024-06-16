class SearchScreenQueries {
  static const String getGeolocationByCoords = """
    query GET_GEOLOCATION_BY_COORDS(\$latitude: Float!, \$longitude: Float!) {
      getGeolocationByCoords(latitude: \$latitude, longitude: \$longitude) {
        country
        locality
        placeId
        latitude
        longitude
      }
    }
  """;

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

  static const String getEvents = '''
    query GET_EVENTS(\$shouldReturnSoonest: Boolean) {
      getEvents(shouldReturnSoonest: \$shouldReturnSoonest) {
        items {
          id
          verticalImage {
            src
          }
          createdAt
          updatedAt
          title
          place {
            originalId
            googleMapsUri
            location {
              latitude
              longitude
            }
          }
          description
          startDate
          endDate
          minTicketPrice
        }
        totalPagesCount
      }
    }
  ''';
}
