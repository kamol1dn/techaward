import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/user_model.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static const String _tokenKey = 'user_token';
  static const String _userDataKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _emergencyContactsKey = 'emergency_contacts';

  static const String _locationSharingKey = 'location_sharing_enabled';

  // Save user token
  static Future<void> saveUserToken(String token) async {
    print('[APP] 🔐 StorageService.saveUserToken() - Starting...');
    print('[APP] 🔐 Token to save: $token');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 🔐 SharedPreferences instance obtained.');

    await prefs.setString(_tokenKey, token);
    print('[APP] 🔐 Token saved successfully: $token');

    await prefs.setBool(_isLoggedInKey, true);
    print('[APP] 🔐 Login state saved: true');
    print('[APP] 🔐 StorageService.saveUserToken() - Completed');
  }

  // Get user token
  static Future<String?> getUserToken() async {
    print('[APP] 🔑 StorageService.getUserToken() - Starting...');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    print('[APP] 🔑 Retrieved token: $token');
    print('[APP] 🔑 StorageService.getUserToken() - Completed');
    return token;
  }

  // Save login user data (from login response)
  static Future<void> saveLoginUserData(Map<String, dynamic> userData) async {
    print('[APP] 👤 StorageService.saveLoginUserData() - Starting...');
    print('[APP] 👤 User data to save: ${json.encode(userData)}');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 👤 SharedPreferences instance obtained');

    await prefs.setString(_userDataKey, json.encode(userData));
    print('[APP] 👤 Login user data saved successfully');
    print('[APP] 👤 StorageService.saveLoginUserData() - Completed');
  }

  // Save registration user data (from registration flow)
  static Future<void> saveUserData(PersonalData personal, MedicalData medical) async {
    print('[APP] 📋 StorageService.saveUserData() - Starting...');
    print('[APP] 📋 Personal data: name=${personal.name}, surname=${personal.surname}, email=${personal.email}');
    print('[APP] 📋 Medical data: bloodType=${medical.bloodType}, allergies=${medical.allergies}');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 📋 SharedPreferences instance obtained');

    final userData = {
      'name': personal.name,
      'surname': personal.surname,
      'email': personal.email,
      'age': personal.age,
      'gender': personal.gender,
      'passport': personal.passport,
      'blood_type': medical.bloodType,
      'allergies': medical.allergies,
      'illness': medical.illness,
      'additional_info': medical.additionalInfo,
    };

    print('[APP] 📋 Saving registration data: ${json.encode(userData)}');
    await prefs.setString(_userDataKey, json.encode(userData));
    print('[APP] 📋 Registration data saved successfully');
    print('[APP] 📋 StorageService.saveUserData() - Completed');
  }

  // Save updated user data (from edit settings)
  static Future<void> saveUpdatedUserData(Map<String, dynamic> userData) async {
    print('[APP] ✏️ StorageService.saveUpdatedUserData() - Starting...');
    print('[APP] ✏️ Updated user data: ${json.encode(userData)}');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] ✏️ SharedPreferences instance obtained');

    await prefs.setString(_userDataKey, json.encode(userData));
    print('[APP] ✏️ Updated user data saved successfully');
    print('[APP] ✏️ StorageService.saveUpdatedUserData() - Completed');
  }

  // Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    print('[APP] 📖 StorageService.getUserData() - Starting...');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 📖 SharedPreferences instance obtained');

    final userDataString = prefs.getString(_userDataKey);
    print('[APP] 📖 Raw user data string: $userDataString');

    if (userDataString != null) {
      final userData = json.decode(userDataString);
      print('[APP] 📖 Decoded user data: $userData');
      print('[APP] 📖 StorageService.getUserData() - Completed with data');
      return userData;
    }

    print('[APP] 📖 No user data found');
    print('[APP] 📖 StorageService.getUserData() - Completed with null');
    return null;
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    print('[APP] 🔍 StorageService.isLoggedIn() - Starting...');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 🔍 SharedPreferences instance obtained');

    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    print('[APP] 🔍 Login status: $isLoggedIn');
    print('[APP] 🔍 StorageService.isLoggedIn() - Completed');

    return isLoggedIn;
  }


  // Clear all data
  static Future<void> clearAll() async {
    print('[APP] 🔥 StorageService.clearAll() - Starting...');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 🔥 SharedPreferences instance obtained');

    await prefs.clear();
    print('[APP] 🔥 All data cleared successfully');
    print('[APP] 🔥 StorageService.clearAll() - Completed');
  }

  static Future<void> init() async {
    print('[APP] 🚀 StorageService.init() - Starting...');

    _prefs = await SharedPreferences.getInstance();
    print('[APP] 🚀 SharedPreferences instance initialized');
    print('[APP] 🚀 StorageService.init() - Completed');
  }
}