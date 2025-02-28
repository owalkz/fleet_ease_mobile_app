import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  static SharedPreferences? _preferences;  // The SharedPreferences instance.

  // Keys for storing user details
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserAccountType = 'user_account_type';
  static const String keyTripId = 'trip_id';

  /// Initialize SharedPreferences (must be called before using it)
  static Future<void> init() async {
    // Initialize the SharedPreferences instance
    _preferences = await SharedPreferences.getInstance();
  }

  /// Save user details
  static Future<void> saveUserDetails(String name, String email, String accountType) async {
    await _preferences?.setString(_keyUserName, name);
    await _preferences?.setString(_keyUserEmail, email);
    await _preferences?.setString(_keyUserAccountType, accountType);
  }

  /// Save trip id
  static Future<void> saveTripDetails(String tripId) async {
    await _preferences?.setString(keyTripId, tripId);
  }

  /// Get user name
  static String? getUserName() {
    return _preferences?.getString(_keyUserName);
  }

  /// Get user email
  static String? getUserEmail() {
    return _preferences?.getString(_keyUserEmail);
  }

  /// Get user account type
  static String? getUserAccountType() {
    return _preferences?.getString(_keyUserAccountType);
  }

  /// Get tripId
  static String? getTripId() {
    return _preferences?.getString(keyTripId);
  }

  /// Remove tripId (for endTrip)
  static Future<void> clearTripDetails() async {
    await _preferences?.remove(keyTripId);
  }

  /// Remove user details (for logout)
  static Future<void> clearUserDetails() async {
    await _preferences?.remove(_keyUserName);
    await _preferences?.remove(_keyUserEmail);
    await _preferences?.remove(_keyUserAccountType);
    await _preferences?.remove(keyTripId);
  }

  // New Method for accessing SharedPreferences in background services
  static Future<SharedPreferences> getPreferences() async {
    // Ensure that we return a valid instance of SharedPreferences.
    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
    }
    return _preferences!;
  }
}
