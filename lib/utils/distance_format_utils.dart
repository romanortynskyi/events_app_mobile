class DistanceFormatUtils {
  static String toKilometers(double meters) {
    double distanceInKilometers = meters / 1000;

    return '${distanceInKilometers.toStringAsFixed(1)} km';
  }

  static String toMeters(double meters) {
    return '$meters m';
  }

  static String format(double meters) {
    if (meters < 1000) {
      return toMeters(meters);
    }

    return toKilometers(meters);
  }
}
