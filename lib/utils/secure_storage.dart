import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  factory SecureStorageService() => _instance;

  SecureStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Save token
  Future<void> saveUserData(String token, String userType, String userId,
      String userName, String emailAddress) async {
    await _storage.write(key: 'token', value: token);
    await _storage.write(key: 'userType', value: userType);
    await _storage.write(key: 'userId', value: userId);
    await _storage.write(key: 'userName', value: userName);
    await _storage.write(key: 'emailAddress', value: emailAddress);
  }

  // Read token
  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  // Read user type
  Future<String?> getUserType() async {
    return await _storage.read(key: 'userType');
  }

  // Read user id
  Future<String?> getUserId() async {
    return await _storage.read(key: 'userId');
  }

  // Read UserName
    Future<String?> getUserName() async {
    return await _storage.read(key: 'userName');
  }

    // Read EmailAddress
    Future<String?> getEmailAddress() async {
    return await _storage.read(key: 'emailAddress');
  }

  // Delete token
  Future<void> deleteUserData() async {
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'userType');
    await _storage.delete(key: 'userId');
    await _storage.delete(key: 'userName');
    await _storage.delete(key: 'emailAddress');
  }
}
