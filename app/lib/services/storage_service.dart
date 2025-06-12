import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static const String _tokenKey = 'user_token';
  static const String _userDataKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  // Save user token
  static Future<void> saveUserToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setBool(_isLoggedInKey, true);
  }

  // Get user token
  static Future<String?> getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Save login user data (from login response)
  static Future<void> saveLoginUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, json.encode(userData));
  }

  // Save registration user data (from registration flow)
  static Future<void> saveUserData(PersonalData personal, MedicalData medical) async {
    final prefs = await SharedPreferences.getInstance();
    final userData = {
      'name': personal.name,
      'surname': personal.surname,
      'phone': personal.phone,
      'age': personal.age,
      'gender': personal.gender,
      'passport': personal.passport,
      'blood_type': medical.bloodType,
      'allergies': medical.allergies,
      'illness': medical.illness,
      'additional_info': medical.additionalInfo,
    };
    await prefs.setString(_userDataKey, json.encode(userData));
  }

  // Save updated user data (from edit settings)
  static Future<void> saveUpdatedUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, json.encode(userData));
  }

  // Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userDataKey);
    if (userDataString != null) {
      return json.decode(userDataString);
    }
    return null;
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Clear all data
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
}