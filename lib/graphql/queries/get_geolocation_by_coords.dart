String getGeolocationByCoords = """
  query GET_GEOLOCATION_BY_COORDS(\$latitude: Float!, \$longitude: Float!) {
    getGeolocationByCoords(latitude: \$latitude, longitude: \$longitude) {
      country
      locality
    }
  }
""";
