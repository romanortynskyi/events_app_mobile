import 'dart:math' as math;

class CoordinateUtils {
  static const double R = 6371; // Earth's radius in kilometers
  static const double lon0 =
      0; // Central meridian (you can choose a specific value)

  static double degreesToRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }

  static double convertLongitudeToMC(double longitude) {
    return R * (longitude - lon0);
  }

  static double convertLatitudeToMC(double latitude) {
    return R * math.log(math.tan(math.pi / 4 + degreesToRadians(latitude) / 2));
  }
}
