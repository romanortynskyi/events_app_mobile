class SearchResultsScreenQueries {
  static const String searchEvents = """
    query SEARCH_EVENTS(\$input: SearchEventsInput!) {
      searchEvents(input: \$input) {
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
          ticketPrice
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
          ticketPrice
        }
        totalPagesCount
      }
    }
  """;
}
