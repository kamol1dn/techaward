import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/user_model.dart';
import '../../models/emergency_request.dart';
import './url.dart';
import '../../services/storage_service.dart';

import '../../data/dummy_data.dart';

class ApiService {
  static const String baseUrl = Urls.apiBaseUrl;
  static bool useTestServer = true;// Toggle for test server simulation
  static bool online = false;
  ApiService()
  {

  }
  static Future<void> init() async {
    print('[APP] 🚀 ApiService.init() - Starting...');
    print('[APP] 🚀 Base URL: $baseUrl');

    online = await isServerOnline();
    print('[APP] 🚀 Server online status: $online');

    if(online) {
      print('[APP] 🚀 Server is online - using real API');
    } else {
      print('[APP] 🚀 Server is offline - using test server');
    }

    useTestServer = !online;
    print('[APP] 🚀 Use test server: $useTestServer');
    print('[APP] 🚀 ApiService.init() - Completed');
  }

  static Future<bool> isServerOnline() async {
    print('[APP] 🌐 ApiService.isServerOnline() - Starting...');
    print('[APP] 🌐 Checking server: $baseUrl/services/hello/');

    try {
      final response = await http.get(Uri.parse('$baseUrl/services/hello/'));
      print('[APP] 🌐 Server response status: ${response.statusCode}');
      print('[APP] 🌐 Server response body: ${response.body}');

      final isOnline = response.statusCode == 200;
      print('[APP] 🌐 Server is online: $isOnline');
      print('[APP] 🌐 ApiService.isServerOnline() - Completed');
      return isOnline;
    } catch (e) {
      print('[APP] 🌐 Server check failed: $e');
      print('[APP] 🌐 Server is online: false');
      print('[APP] 🌐 ApiService.isServerOnline() - Completed with error');
      return false;
    }
  }

  static Future<Map<String, dynamic>> login(String login, String password) async {
    print('[APP] 🔐 ApiService.login() - Starting...');
    print('[APP] 🔐 Login: $login');
    print('[APP] 🔐 Password: [HIDDEN]');

    await init();
    print('[APP] 🔐 API service initialized');

    if (useTestServer) {
      print('[APP] 🔐 Using test server for login');
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      print('[APP] 🔐 Network delay simulation completed');

      final result = DummyData.simulateLogin(login, password);
      print('[APP] 🔐 Test server response: $result');
      print('[APP] 🔐 ApiService.login() - Completed (test server)');
      return result;
    }

    print('[APP] 🔐 Making HTTP request to: $baseUrl/accounts/login/');
    final requestBody = {'identifier': login, 'password': password};
    print('[APP] 🔐 Request body: $requestBody');

    final response = await http.post(
      Uri.parse('$baseUrl/accounts/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    print('[APP] 🔐 Response status: ${response.statusCode}');
    print('[APP] 🔐 Response body: ${response.body}');

    final result = jsonDecode(response.body);
    print('[APP] 🔐 Parsed response: $result');
    print('[APP] 🔐 ApiService.login() - Completed (real server)');
    return result;
  }


  static Future<Map<String, dynamic>> completeRegistration(
      PersonalData personal,
      MedicalData medical
      )

  async {
    print('[APP] 📋 ApiService.completeRegistration() - Starting...');
    print('[APP] 📋 Personal data: ${personal.toJson()}');
    print('[APP] 📋 Medical data: ${medical.toJson()}');
    await init();

    print('[APP] 📋 API service initialized');

    if (useTestServer) {
      print('[APP] 📋 Using test server for registration');
      await Future.delayed(Duration(seconds: 2));
      print('[APP] 📋 Network delay simulation completed');

      final result = DummyData.simulateRegistration(personal, medical);
      print('[APP] 📋 Test server response: $result');
      print('[APP] 📋 ApiService.completeRegistration() - Completed (test server)');
      return result;
    }

    print('[APP] 📋 Making HTTP request to: $baseUrl/accounts/register/');
    final requestBody = {
      'personal': personal.toJson(),
      'medical': medical.toJson(),
    };
    print('[APP] 📋 Request body: $requestBody');

    final response = await http.post(
      Uri.parse('$baseUrl/accounts/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    print('[APP] 📋 Response status: ${response.statusCode}');
    print('[APP] 📋 Response body: ${response.body}');

    final result = jsonDecode(response.body);
    print('[APP] 📋 Parsed response: $result');
    print('[APP] 📋 ApiService.completeRegistration() - Completed (real server)');
    return result;
  }


  static Future<Map<String, dynamic>> sendEmergencyRequest(EmergencyRequest request) async {
    print('[APP] 🚨 ApiService.sendEmergencyRequest() - Starting...');
    print('[APP] 🚨 Emergency request: ${request.toJson()}');

    if (useTestServer) {
      print('[APP] 🚨 Using test server for emergency request');
      await Future.delayed(Duration(seconds: 2));
      print('[APP] 🚨 Network delay simulation completed');

      final result = DummyData.simulateEmergencyRequest(request);
      print('[APP] 🚨 Test server response: $result');
      print('[APP] 🚨 ApiService.sendEmergencyRequest() - Completed (test server)');
      return result;
    }

    print('[APP] 🚨 Making HTTP request to: $baseUrl/emergency/request');
    final requestBody = request.toJson();
    print('[APP] 🚨 Request body: $requestBody');

    final response = await http.post(
      Uri.parse('$baseUrl/emergency/request'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    print('[APP] 🚨 Response status: ${response.statusCode}');
    print('[APP] 🚨 Response body: ${response.body}');

    final result = jsonDecode(response.body);
    print('[APP] 🚨 Parsed response: $result');
    print('[APP] 🚨 ApiService.sendEmergencyRequest() - Completed (real server)');
    return result;
  }

  static Future<Map<String, dynamic>> updateUserData(Map<String, dynamic> userData) async {
    print('[APP] ✏️ ApiService.updateUserData() - Starting...');
    print('[APP] ✏️ User data to update: $userData');

    await init();
    print('[APP] ✏️ API service initialized');

    if (useTestServer) {
      print('[APP] ✏️ Using test server for user data update');
      await Future.delayed(Duration(seconds: 2)); // Simulate network delay
      print('[APP] ✏️ Network delay simulation completed');

      final result = DummyData.simulateUpdateUserData(userData);
      print('[APP] ✏️ Test server response: $result');
      print('[APP] ✏️ ApiService.updateUserData() - Completed (test server)');
      return result;
    }

    try {
      print('[APP] ✏️ Making HTTP request to: $baseUrl/accounts/profile/update/');
      print('[APP] ✏️ Request body: $userData');
      //final token = await _getToken(); // Get stored JWT token
      final response = await http.put(
        Uri.parse('$baseUrl/accounts/profile/update/'),
        headers: {
          'Content-Type': 'application/json',
          //'Authorization': 'Bearer $token',
          // Add authorization header if needed
          'Authorization': 'Bearer ${await StorageService.getUserToken()}',
        },
        body: jsonEncode(userData),
      );

      print('[APP] ✏️ Response status: ${response.statusCode}');
      print('[APP] ✏️ Response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('[APP] ✏️ Parsed response: $result');
        print('[APP] ✏️ ApiService.updateUserData() - Completed successfully (real server)');
        return result;
      } else {
        final errorResult = {
          'success': false,
          'message': 'Server error: ${response.statusCode}'
        };
        print('[APP] ✏️ Server error response: $errorResult');
        print('[APP] ✏️ ApiService.updateUserData() - Completed with server error');
        return errorResult;
      }
    } catch (e) {
      final errorResult = {
        'success': false,
        'message': 'Network error: $e'
      };
      print('[APP] ✏️ Network error: $e');
      print('[APP] ✏️ Error response: $errorResult');
      print('[APP] ✏️ ApiService.updateUserData() - Completed with network error');
      return errorResult;
    }
  }

  static Future<Map<String, dynamic>> sendOtpToEmail(String email) async {
    await init();
    print('[APP] 📱 ApiService.sendOtp() - Starting...');
    print('[APP] 📱 Email: $email');

    if (useTestServer) {
      print('[APP] 📱 Using test server for OTP');
      await Future.delayed(Duration(seconds: 1));
      print('[APP] 📱 Network delay simulation completed');

      final result = DummyData.simulateSendOtp(email);
      print('[APP] 📱 Test server response: $result');
      print('[APP] 📱 ApiService.sendOtp() - Completed (test server)');
      return result;
    }

    print('[APP] 📱 Making HTTP request to: $baseUrl/services/auth/request-otp/');
    final requestBody = {'email': email};
    print('[APP] 📱 Request body: $requestBody');

    final response = await http.post(
      Uri.parse('$baseUrl/services/auth/request-otp/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    print('[APP] 📱 Response status: ${response.statusCode}');
    print('[APP] 📱 Response body: ${response.body}');

    final result = jsonDecode(response.body);
    print('[APP] 📱 Parsed response: $result');
    print('[APP] 📱 ApiService.sendOtp() - Completed (real server)');
    return result;
  }

  static Future<Map<String, dynamic>> verifyEmailOtp(String email, String otp) async {
    await init();
    print('[APP] ✅ ApiService.verifyOtp() - Starting...');
    print('[APP] ✅ Email: $email');
    print('[APP] ✅ OTP: $otp');

    if (useTestServer) {
      print('[APP] ✅ Using test server for OTP verification');
      await Future.delayed(Duration(seconds: 1));
      print('[APP] ✅ Network delay simulation completed');

      final result = DummyData.simulateVerifyOtp(email, otp);
      print('[APP] ✅ Test server response: $result');
      print('[APP] ✅ ApiService.verifyOtp() - Completed (test server)');
      return result;
    }

    print('[APP] ✅ Making HTTP request to: $baseUrl/services/auth/verify-otp/');
    final requestBody = {'email': email, 'code': otp};
    print('[APP] ✅ Request body: $requestBody');

    final response = await http.post(
      Uri.parse('$baseUrl/services/auth/verify-otp/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    print('[APP] ✅ Response status: ${response.statusCode}');
    print('[APP] ✅ Response body: ${response.body}');

    final result = jsonDecode(response.body);
    print('[APP] ✅ Parsed response: $result');
    print('[APP] ✅ ApiService.verifyOtp() - Completed (real server)');
    return result;
  }



}