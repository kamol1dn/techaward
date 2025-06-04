
import '../models/user_model.dart';
import '../models/university_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  static Future<User?> login(String email, String password) async {
    try {
      final response = await ApiService.login(email, password);
      final user = User.fromJson(response['user']);
      final token = response['token'];

      await StorageService.saveUser(user);
      await StorageService.saveToken(token);

      return user;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  static Future<User?> register(Map<String, dynamic> userData) async {
    try {
      final response = await ApiService.register(userData);
      final user = User.fromJson(response['user']);
      final token = response['token'];

      await StorageService.saveUser(user);
      await StorageService.saveToken(token);

      return user;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  static Future<List<University>> getUniversities() async {
    try {
      // First check cached universities
      List<University> cachedUniversities = await StorageService.getUniversities();
      if (cachedUniversities.isNotEmpty) {
        return cachedUniversities;
      }

      // Fetch from API if not cached
      final universities = await ApiService.getUniversities();
      await StorageService.saveUniversities(universities);
      return universities;
    } catch (e) {
      throw Exception('Failed to load universities: ${e.toString()}');
    }
  }

  static Future<bool> sendOtp(String email) async {
    return await ApiService.sendOtp(email);
  }

  static Future<bool> verifyOtp(String email, String otp) async {
    return await ApiService.verifyOtp(email, otp);
  }

  static Future<void> logout() async {
    await StorageService.clearAll();
  }
}