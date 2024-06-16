class EventScreenQueries {
  static const String getEventById = """
    query GET_EVENT_BY_ID(\$id: Float!, \$originId: String!) {
      getEventById(id: \$id, originId: \$originId) {
        id
        createdAt
        updatedAt
        distance
        title
        description
        startDate
        endDate
        minTicketPrice
        horizontalImage {
          src
        }
        place {
          originalId
          googleMapsUri
          location {
            latitude
            longitude
          }
        }
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
