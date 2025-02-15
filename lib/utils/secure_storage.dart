import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  factory SecureStorageService() => _instance;

  SecureStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Save token
  Future<void> saveUserData(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  // Read token
  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  // Delete token
  Future<void> deleteUserData() async {
    await _storage.delete(key: 'token');
  }
}
