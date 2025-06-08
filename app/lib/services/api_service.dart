
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/emergency_request.dart';
import '../data/dummy_data.dart';

class ApiService {
  static const String baseUrl = 'https://api.emergency-services.uz';
  static bool useTestServer = true; // Toggle for test server simulation

  static Future<Map<String, dynamic>> login(String login, String password) async {
    if (useTestServer) {
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      return DummyData.simulateLogin(login, password);
    }

    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'login': login, 'password': password}),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> sendOtp(String phone) async {
    if (useTestServer) {
      await Future.delayed(Duration(seconds: 1));
      return DummyData.simulateSendOtp(phone);
    }

    final response = await http.post(
      Uri.parse('$baseUrl/auth/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    if (useTestServer) {
      await Future.delayed(Duration(seconds: 1));
      return DummyData.simulateVerifyOtp(phone, otp);
    }

    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'otp': otp}),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> completeRegistration(
      PersonalData personal,
      MedicalData medical
      ) async {
    if (useTestServer) {
      await Future.delayed(Duration(seconds: 2));
      return DummyData.simulateRegistration(personal, medical);
    }

    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'personal': personal.toJson(),
        'medical': medical.toJson(),
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> sendEmergencyRequest(EmergencyRequest request) async {
    if (useTestServer) {
      await Future.delayed(Duration(seconds: 2));
      return DummyData.simulateEmergencyRequest(request);
    }

    final response = await http.post(
      Uri.parse('$baseUrl/emergency/request'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    return jsonDecode(response.body);
  }
}