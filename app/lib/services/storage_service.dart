
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveUserToken(String token) async {
    await _prefs!.setString('user_token', token);
  }

  static String? getUserToken() {
    return _prefs!.getString('user_token');
  }

  static Future<void> saveUserData(PersonalData personal, MedicalData medical) async {
    final userData = {
      ...personal.toJson(),
      ...medical.toJson(),
    };
    await _prefs!.setString('user_data', jsonEncode(userData));
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final userDataStr = _prefs!.getString('user_data');
    if (userDataStr == null) return null;
    return jsonDecode(userDataStr);
  }

  static Future<void> clearAll() async {
    await _prefs!.clear();
  }

  static bool isLoggedIn() {
    return _prefs!.containsKey('user_token');
  }
}