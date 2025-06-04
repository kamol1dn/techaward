
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/university_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = true;
  List<University> _universities = [];

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  List<University> get universities => _universities;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final user = await StorageService.getUser();
      final token = await StorageService.getToken();

      if (user != null && token != null) {
        _user = user;
        _isAuthenticated = true;
      }
    } catch (e) {
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _user = await AuthService.login(email, password);
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    try {
      _user = await AuthService.register(userData);
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> loadUniversities() async {
    try {
      _universities = await AuthService.getUniversities();
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  Future<bool> sendOtp(String email) async {
    return await AuthService.sendOtp(email);
  }

  Future<bool> verifyOtp(String email, String otp) async {
    return await AuthService.verifyOtp(email, otp);
  }

  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    _isAuthenticated = false;
    _universities = [];
    notifyListeners();
  }
}