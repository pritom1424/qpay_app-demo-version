import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureKeyManager {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();
  static Future<void> writeValue(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {}
  }

  static Future<String?> readValue(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      return null;
    }
  }
}
