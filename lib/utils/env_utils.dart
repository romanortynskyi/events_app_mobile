import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvUtils {
  static String getEnv(String key) {
    return dotenv.env[key] ?? '';
  }
}
