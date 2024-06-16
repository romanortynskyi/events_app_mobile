class HomeScreenQueries {
  static const String getEvents = """
    query GET_EVENTS(\$skip: Int, \$limit: Int) {
      getEvents(skip: \$skip, limit: \$limit) {
        items {
          id
          verticalImage {
            src
          }
          createdAt
          updatedAt
          title
          place {
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
  """;

  static const String autocompleteEvents = """
    query AUTOCOMPLETE_EVENTS(\$input: AutocompleteEventsInput!) {
      autocompleteEvents(input: \$input) {
        items {
          id
          image {
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
  """;

  static const String getGeolocationByCoords = """
    query GET_GEOLOCATION_BY_COORDS(\$latitude: Float!, \$longitude: Float!) {
      getGeolocationByCoords(latitude: \$latitude, longitude: \$longitude) {
        country
        locality
        placeId
      }
    }
  """;
}
