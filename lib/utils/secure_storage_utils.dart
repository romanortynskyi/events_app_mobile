import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageUtils {
  static const FlutterSecureStorage storage = FlutterSecureStorage();

  static Future<void> setItem(String key, String? value) async {
    await storage.write(key: key, value: value);
  }

  static Future<dynamic> getItem(String key) async {
    return await storage.read(key: key);
  }
}
