import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/emergency_request.dart';
import '../models/emergency_contact.dart';
import '../models/family_member.dart';
import '../data/dummy_data.dart';

class ApiService {
  static const String baseUrl = 'https://9c50-213-230-116-6.ngrok-free.app/api/v1';
  static bool useTestServer = true;// Toggle for test server simulation
  static bool online = false;
  static Future<void> init() async
  {
    online = await isServerOnline();
    if(online) {
      print("Online");
    }
    useTestServer = !online;
  }
  static Future<bool> isServerOnline() async
  {
    try {
      final response = await http.get(Uri.parse('$baseUrl/services/hello/'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> login(String login, String password) async {
    await init();
    if (useTestServer) {
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      return DummyData.simulateLogin(login, password);
    }

    final response = await http.post(
      Uri.parse('$baseUrl/accounts/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': login, 'password': password}),
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
    await init();
    if (useTestServer) {
      await Future.delayed(Duration(seconds: 2));
      return DummyData.simulateRegistration(personal, medical);
    }

    final response = await http.post(
      Uri.parse('$baseUrl/services/register'),
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

  // New method for updating user data
  static Future<Map<String, dynamic>> updateUserData(Map<String, dynamic> userData) async {
    await init();
    if (useTestServer) {
      await Future.delayed(Duration(seconds: 2)); // Simulate network delay
      return DummyData.simulateUpdateUserData(userData);
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/accounts/profile/update/'),
        headers: {
          'Content-Type': 'application/json',
          // Add authorization header if needed
          // 'Authorization': 'Bearer ${await StorageService.getUserToken()}',
        },
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }


  // Emergency Contacts API methods
  static Future<Map<String, dynamic>> saveEmergencyContact(EmergencyContact contact) async {
    await init();
    if (useTestServer) {
      await Future.delayed(Duration(seconds: 1));
      return DummyData.simulateSaveEmergencyContact(contact);
    }

    final response = await http.post(
      Uri.parse('$baseUrl/safety/emergency-contacts/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(contact.toJson()),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getEmergencyContacts() async {
    await init();
    if (useTestServer) {
      await Future.delayed(Duration(seconds: 1));
      return DummyData.simulateGetEmergencyContacts();
    }

    final response = await http.get(
      Uri.parse('$baseUrl/safety/emergency-contacts/'),
      headers: {'Content-Type': 'application/json'},
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteEmergencyContact(String contactId) async {
    await init();
    if (useTestServer) {
      await Future.delayed(Duration(seconds: 1));
      return DummyData.simulateDeleteEmergencyContact(contactId);
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/safety/emergency-contacts/$contactId/'),
      headers: {'Content-Type': 'application/json'},
    );

    return jsonDecode(response.body);
  }

  // Family Members API methods
  static Future<Map<String, dynamic>> saveFamilyMember(FamilyMember member) async {
    await init();
    if (useTestServer) {
      await Future.delayed(Duration(seconds: 1));
      return DummyData.simulateSaveFamilyMember(member);
    }

    final response = await http.post(
      Uri.parse('$baseUrl/safety/family-members/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(member.toJson()),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getFamilyMembers() async {
    await init();
    if (useTestServer) {
      await Future.delayed(Duration(seconds: 1));
      return DummyData.simulateGetFamilyMembers();
    }

    final response = await http.get(
      Uri.parse('$baseUrl/safety/family-members/'),
      headers: {'Content-Type': 'application/json'},
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteFamilyMember(String memberId) async {
    await init();
    if (useTestServer) {
      await Future.delayed(Duration(seconds: 1));
      return DummyData.simulateDeleteFamilyMember(memberId);
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/safety/family-members/$memberId/'),
      headers: {'Content-Type': 'application/json'},
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> sendFamilyInvite(String phone, String name) async {
    await init();
    if (useTestServer) {
      await Future.delayed(Duration(seconds: 1));
      return DummyData.simulateSendFamilyInvite(phone, name);
    }

    final response = await http.post(
      Uri.parse('$baseUrl/safety/family-invite/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
        'name': name,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateLocation(LocationData location) async {
    await init();
    if (useTestServer) {
      await Future.delayed(Duration(seconds: 1));
      return DummyData.simulateUpdateLocation(location);
    }

    final response = await http.post(
      Uri.parse('$baseUrl/safety/update-location/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(location.toJson()),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getFamilyLocations() async {
    await init();
    if (useTestServer) {
      await Future.delayed(Duration(seconds: 1));
      return DummyData.simulateGetFamilyLocations();
    }

    final response = await http.get(
      Uri.parse('$baseUrl/safety/family-locations/'),
      headers: {'Content-Type': 'application/json'},
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> sendTestEmergencyNotification() async {
    await init();
    if (useTestServer) {
      await Future.delayed(Duration(seconds: 2));
      return DummyData.simulateTestEmergencyNotification();
    }

    final response = await http.post(
      Uri.parse('$baseUrl/safety/test-emergency-notification/'),
      headers: {'Content-Type': 'application/json'},
    );

    return jsonDecode(response.body);
  }
}