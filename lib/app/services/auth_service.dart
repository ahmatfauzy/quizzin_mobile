import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends GetxService {
  static const String _tokenKey = 'access_token';
  static const String _userKey = 'user_data';

  late final SharedPreferences _prefs;

  Future<AuthService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  String? get token => _prefs.getString(_tokenKey);

  bool get isLoggedIn => token != null && token!.isNotEmpty;

  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  Future<void> saveUserData(String userJson) async {
    await _prefs.setString(_userKey, userJson);
  }

  String? get userData => _prefs.getString(_userKey);

  Future<void> clearAuth() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
  }
}
