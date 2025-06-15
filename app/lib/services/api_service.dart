import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/emergency_request.dart';
import '../models/emergency_contact.dart';
import '../models/family_member.dart';
import '../data/dummy_data.dart';

class ApiService {
  static const String baseUrl = 'https://0919-213-230-114-31.ngrok-free.app/api/v1';
  static bool useTestServer = true;// Toggle for test server simulation
  static bool online = false;

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
    final requestBody = {'email': login, 'password': password};
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

    print('[APP] 📋 Making HTTP request to: $baseUrl/accounts/register');
    final requestBody = {
      'personal': personal.toJson(),
      'medical': medical.toJson(),
    };
    print('[APP] 📋 Request body: $requestBody');

    final response = await http.post(
      Uri.parse('$baseUrl/accounts/register'),
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

  // New method for updating user data
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

      final response = await http.put(
        Uri.parse('$baseUrl/accounts/profile/update/'),
        headers: {
          'Content-Type': 'application/json',
          // Add authorization header if needed
          // 'Authorization': 'Bearer ${await StorageService.getUserToken()}',
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

  // Emergency Contacts API methods
  static Future<Map<String, dynamic>> saveEmergencyContact(EmergencyContact contact) async {
    print('[APP] 📞 ApiService.saveEmergencyContact() - Starting...');
    print('[APP] 📞 Contact to save: ${contact.toJson()}');

    await init();
    print('[APP] 📞 API service initialized');

    if (useTestServer) {
      print('[APP] 📞 Using test server for emergency contact save');
      await Future.delayed(Duration(seconds: 1));
      print('[APP] 📞 Network delay simulation completed');

      final result = DummyData.simulateSaveEmergencyContact(contact);
      print('[APP] 📞 Test server response: $result');
      print('[APP] 📞 ApiService.saveEmergencyContact() - Completed (test server)');
      return result;
    }

    print('[APP] 📞 Making HTTP request to: $baseUrl/safety/emergency-contacts/');
    final requestBody = contact.toJson();
    print('[APP] 📞 Request body: $requestBody');

    final response = await http.post(
      Uri.parse('$baseUrl/safety/emergency-contacts/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    print('[APP] 📞 Response status: ${response.statusCode}');
    print('[APP] 📞 Response body: ${response.body}');

    final result = jsonDecode(response.body);
    print('[APP] 📞 Parsed response: $result');
    print('[APP] 📞 ApiService.saveEmergencyContact() - Completed (real server)');
    return result;
  }

  static Future<Map<String, dynamic>> getEmergencyContacts() async {
    print('[APP] 📋 ApiService.getEmergencyContacts() - Starting...');

    await init();
    print('[APP] 📋 API service initialized');

    if (useTestServer) {
      print('[APP] 📋 Using test server for emergency contacts retrieval');
      await Future.delayed(Duration(seconds: 1));
      print('[APP] 📋 Network delay simulation completed');

      final result = DummyData.simulateGetEmergencyContacts();
      print('[APP] 📋 Test server response: $result');
      print('[APP] 📋 ApiService.getEmergencyContacts() - Completed (test server)');
      return result;
    }

    print('[APP] 📋 Making HTTP request to: $baseUrl/safety/emergency-contacts/');

    final response = await http.get(
      Uri.parse('$baseUrl/safety/emergency-contacts/'),
      headers: {'Content-Type': 'application/json'},
    );

    print('[APP] 📋 Response status: ${response.statusCode}');
    print('[APP] 📋 Response body: ${response.body}');

    final result = jsonDecode(response.body);
    print('[APP] 📋 Parsed response: $result');
    print('[APP] 📋 ApiService.getEmergencyContacts() - Completed (real server)');
    return result;
  }

  static Future<Map<String, dynamic>> deleteEmergencyContact(String contactId) async {
    print('[APP] 🗑️ ApiService.deleteEmergencyContact() - Starting...');
    print('[APP] 🗑️ Contact ID to delete: $contactId');

    await init();
    print('[APP] 🗑️ API service initialized');

    if (useTestServer) {
      print('[APP] 🗑️ Using test server for emergency contact deletion');
      await Future.delayed(Duration(seconds: 1));
      print('[APP] 🗑️ Network delay simulation completed');

      final result = DummyData.simulateDeleteEmergencyContact(contactId);
      print('[APP] 🗑️ Test server response: $result');
      print('[APP] 🗑️ ApiService.deleteEmergencyContact() - Completed (test server)');
      return result;
    }

    print('[APP] 🗑️ Making HTTP request to: $baseUrl/safety/emergency-contacts/$contactId/');

    final response = await http.delete(
      Uri.parse('$baseUrl/safety/emergency-contacts/$contactId/'),
      headers: {'Content-Type': 'application/json'},
    );

    print('[APP] 🗑️ Response status: ${response.statusCode}');
    print('[APP] 🗑️ Response body: ${response.body}');

    final result = jsonDecode(response.body);
    print('[APP] 🗑️ Parsed response: $result');
    print('[APP] 🗑️ ApiService.deleteEmergencyContact() - Completed (real server)');
    return result;
  }

  // Family Members API methods
  static Future<Map<String, dynamic>> saveFamilyMember(FamilyMember member) async {
    print('[APP] 👥 ApiService.saveFamilyMember() - Starting...');
    print('[APP] 👥 Member to save: ${member.toJson()}');

    await init();
    print('[APP] 👥 API service initialized');

    if (useTestServer) {
      print('[APP] 👥 Using test server for family member save');
      await Future.delayed(Duration(seconds: 1));
      print('[APP] 👥 Network delay simulation completed');

      final result = DummyData.simulateSaveFamilyMember(member);
      print('[APP] 👥 Test server response: $result');
      print('[APP] 👥 ApiService.saveFamilyMember() - Completed (test server)');
      return result;
    }

    print('[APP] 👥 Making HTTP request to: $baseUrl/safety/family-members/');
    final requestBody = member.toJson();
    print('[APP] 👥 Request body: $requestBody');

    final response = await http.post(
      Uri.parse('$baseUrl/safety/family-members/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    print('[APP] 👥 Response status: ${response.statusCode}');
    print('[APP] 👥 Response body: ${response.body}');

    final result = jsonDecode(response.body);
    print('[APP] 👥 Parsed response: $result');
    print('[APP] 👥 ApiService.saveFamilyMember() - Completed (real server)');
    return result;
  }

  static Future<Map<String, dynamic>> getFamilyMembers() async {
    print('[APP] 👪 ApiService.getFamilyMembers() - Starting...');

    await init();
    print('[APP] 👪 API service initialized');

    if (useTestServer) {
      print('[APP] 👪 Using test server for family members retrieval');
      await Future.delayed(Duration(seconds: 1));
      print('[APP] 👪 Network delay simulation completed');

      final result = DummyData.simulateGetFamilyMembers();
      print('[APP] 👪 Test server response: $result');
      print('[APP] 👪 ApiService.getFamilyMembers() - Completed (test server)');
      return result;
    }

    print('[APP] 👪 Making HTTP request to: $baseUrl/safety/family-members/');

    final response = await http.get(
      Uri.parse('$baseUrl/safety/family-members/'),
      headers: {'Content-Type': 'application/json'},
    );

    print('[APP] 👪 Response status: ${response.statusCode}');
    print('[APP] 👪 Response body: ${response.body}');

    final result = jsonDecode(response.body);
    print('[APP] 👪 Parsed response: $result');
    print('[APP] 👪 ApiService.getFamilyMembers() - Completed (real server)');
    return result;
  }

  static Future<Map<String, dynamic>> deleteFamilyMember(String memberId) async {
    print('[APP] ❌ ApiService.deleteFamilyMember() - Starting...');
    print('[APP] ❌ Member ID to delete: $memberId');

    await init();
    print('[APP] ❌ API service initialized');

    if (useTestServer) {
      print('[APP] ❌ Using test server for family member deletion');
      await Future.delayed(Duration(seconds: 1));
      print('[APP] ❌ Network delay simulation completed');

      final result = DummyData.simulateDeleteFamilyMember(memberId);
      print('[APP] ❌ Test server response: $result');
      print('[APP] ❌ ApiService.deleteFamilyMember() - Completed (test server)');
      return result;
    }

    print('[APP] ❌ Making HTTP request to: $baseUrl/safety/family-members/$memberId/');

    final response = await http.delete(
      Uri.parse('$baseUrl/safety/family-members/$memberId/'),
      headers: {'Content-Type': 'application/json'},
    );

    print('[APP] ❌ Response status: ${response.statusCode}');
    print('[APP] ❌ Response body: ${response.body}');

    final result = jsonDecode(response.body);
    print('[APP] ❌ Parsed response: $result');
    print('[APP] ❌ ApiService.deleteFamilyMember() - Completed (real server)');
    return result;
  }

  static Future<Map<String, dynamic>> sendFamilyInvite(String phone, String name) async {
    print('[APP] 💌 ApiService.sendFamilyInvite() - Starting...');
    print('[APP] 💌 Phone: $phone');
    print('[APP] 💌 Name: $name');

    await init();
    print('[APP] 💌 API service initialized');

    if (useTestServer) {
      print('[APP] 💌 Using test server for family invite');
      await Future.delayed(Duration(seconds: 1));
      print('[APP] 💌 Network delay simulation completed');

      final result = DummyData.simulateSendFamilyInvite(phone, name);
      print('[APP] 💌 Test server response: $result');
      print('[APP] 💌 ApiService.sendFamilyInvite() - Completed (test server)');
      return result;
    }

    print('[APP] 💌 Making HTTP request to: $baseUrl/safety/family-invite/');
    final requestBody = {
      'phone': phone,
      'name': name,
    };
    print('[APP] 💌 Request body: $requestBody');

    final response = await http.post(
      Uri.parse('$baseUrl/safety/family-invite/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    print('[APP] 💌 Response status: ${response.statusCode}');
    print('[APP] 💌 Response body: ${response.body}');

    final result = jsonDecode(response.body);
    print('[APP] 💌 Parsed response: $result');
    print('[APP] 💌 ApiService.sendFamilyInvite() - Completed (real server)');
    return result;
  }

  static Future<Map<String, dynamic>> updateLocation(LocationData location) async {
    print('[APP] 📍 ApiService.updateLocation() - Starting...');
    print('[APP] 📍 Location to update: ${location.toJson()}');

    await init();
    print('[APP] 📍 API service initialized');

    if (useTestServer) {
      print('[APP] 📍 Using test server for location update');
      await Future.delayed(Duration(seconds: 1));
      print('[APP] 📍 Network delay simulation completed');

      final result = DummyData.simulateUpdateLocation(location);
      print('[APP] 📍 Test server response: $result');
      print('[APP] 📍 ApiService.updateLocation() - Completed (test server)');
      return result;
    }

    print('[APP] 📍 Making HTTP request to: $baseUrl/safety/update-location/');
    final requestBody = location.toJson();
    print('[APP] 📍 Request body: $requestBody');

    final response = await http.post(
      Uri.parse('$baseUrl/safety/update-location/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    print('[APP] 📍 Response status: ${response.statusCode}');
    print('[APP] 📍 Response body: ${response.body}');

    final result = jsonDecode(response.body);
    print('[APP] 📍 Parsed response: $result');
    print('[APP] 📍 ApiService.updateLocation() - Completed (real server)');
    return result;
  }

  static Future<Map<String, dynamic>> getFamilyLocations() async {
    print('[APP] 🗺️ ApiService.getFamilyLocations() - Starting...');

    await init();
    print('[APP] 🗺️ API service initialized');

    if (useTestServer) {
      print('[APP] 🗺️ Using test server for family locations retrieval');
      await Future.delayed(Duration(seconds: 1));
      print('[APP] 🗺️ Network delay simulation completed');

      final result = DummyData.simulateGetFamilyLocations();
      print('[APP] 🗺️ Test server response: $result');
      print('[APP] 🗺️ ApiService.getFamilyLocations() - Completed (test server)');
      return result;
    }

    print('[APP] 🗺️ Making HTTP request to: $baseUrl/safety/family-locations/');

    final response = await http.get(
      Uri.parse('$baseUrl/safety/family-locations/'),
      headers: {'Content-Type': 'application/json'},
    );

    print('[APP] 🗺️ Response status: ${response.statusCode}');
    print('[APP] 🗺️ Response body: ${response.body}');

    final result = jsonDecode(response.body);
    print('[APP] 🗺️ Parsed response: $result');
    print('[APP] 🗺️ ApiService.getFamilyLocations() - Completed (real server)');
    return result;
  }

  static Future<Map<String, dynamic>> sendTestEmergencyNotification() async {
    print('[APP] 🧪 ApiService.sendTestEmergencyNotification() - Starting...');

    await init();
    print('[APP] 🧪 API service initialized');

    if (useTestServer) {
      print('[APP] 🧪 Using test server for test emergency notification');
      await Future.delayed(Duration(seconds: 2));
      print('[APP] 🧪 Network delay simulation completed');

      final result = DummyData.simulateTestEmergencyNotification();
      print('[APP] 🧪 Test server response: $result');
      print('[APP] 🧪 ApiService.sendTestEmergencyNotification() - Completed (test server)');
      return result;
    }

    print('[APP] 🧪 Making HTTP request to: $baseUrl/safety/test-emergency-notification/');

    final response = await http.post(
      Uri.parse('$baseUrl/safety/test-emergency-notification/'),
      headers: {'Content-Type': 'application/json'},
    );

    print('[APP] 🧪 Response status: ${response.statusCode}');
    print('[APP] 🧪 Response body: ${response.body}');

    final result = jsonDecode(response.body);
    print('[APP] 🧪 Parsed response: $result');
    print('[APP] 🧪 ApiService.sendTestEmergencyNotification() - Completed (real server)');
    return result;
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