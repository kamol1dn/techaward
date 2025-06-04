
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/university_model.dart';

class StorageService {
  static const String _userKey = 'user_data';
  static const String _tokenKey = 'auth_token';
  static const String _universitiesKey = 'universities';
  static const String _isFirstTimeKey = 'is_first_time';

  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveUniversities(List<University> universities) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> universityJsonList = universities
        .map((university) => jsonEncode(university.toJson()))
        .toList();
    await prefs.setStringList(_universitiesKey, universityJsonList);
  }
  static const bool testMode = true;
  static Future<List<University>> getUniversities() async {
    if (testMode) {
      // Dummy data for testing
      return [
        University(id: '1', name: 'Test University A'),
        University(id: '2', name: 'Test University B'),
        University(id: '3', name: 'Test University C'),
      ];
    }


    final prefs = await SharedPreferences.getInstance();
    final List<String>? universityJsonList = prefs.getStringList(_universitiesKey);
    if (universityJsonList != null) {
      return universityJsonList
          .map((json) => University.fromJson(jsonDecode(json)))
          .toList();
    }
    return [];
  }

  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isFirstTimeKey) ?? true;
  }

  static Future<void> setNotFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isFirstTimeKey, false);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}