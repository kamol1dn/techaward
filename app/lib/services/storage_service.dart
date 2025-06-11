
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

  static Future<void> saveLoginUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();

    // Save individual user data fields
    await prefs.setString('user_name', userData['name'] ?? '');
    await prefs.setString('user_surname', userData['surname'] ?? '');
    await prefs.setString('user_phone', userData['phone'] ?? '');
    await prefs.setInt('user_age', userData['age'] ?? 0);
    await prefs.setString('user_gender', userData['gender'] ?? '');
    await prefs.setString('user_passport', userData['passport'] ?? '');
    await prefs.setString('user_blood_type', userData['blood_type'] ?? '');
    await prefs.setString('user_allergies', userData['allergies'] ?? '');
    await prefs.setString('user_illness', userData['illness'] ?? '');
    await prefs.setString('user_additional_info', userData['additional_info'] ?? '');
  }
}