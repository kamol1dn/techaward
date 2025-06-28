import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/user_model.dart';
import '../../models/emergency_request.dart';
import './url.dart';
import '../../services/storage_service.dart';
import '../../data/dummy_data.dart';

class ApiService {
  static const String baseUrl = Urls.apiBaseUrl;
  static bool useTestServer = true;
  static bool online = false;

  String? _accessToken;
  String? _refreshToken;

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Static instance for easy access
  static ApiService get instance => _instance;

  // Initialize the service
  Future<void> _init() async {
    print('[APP] 🚀 ApiService.init() - Starting...');
    print('[APP] 🚀 Base URL: $baseUrl');

    // Load tokens from storage
    await _loadTokens();

    online = await _isServerOnline();
    print('[APP] 🚀 Server online status: $online');

    if (online) {
      print('[APP] 🚀 Server is online - using real API');
    } else {
      print('[APP] 🚀 Server is offline - using test server');
    }

    useTestServer = !online;
    print('[APP] 🚀 Use test server: $useTestServer');
    print('[APP] 🚀 ApiService.init() - Completed');
  }

  // Token management
  Future<void> _loadTokens() async {
    _accessToken = await StorageService.getUserToken();
    _refreshToken = await StorageService.getRefreshToken();
    print('[APP] 🔑 Tokens loaded from storage');
  }

  Future<void> _setTokens(String accessToken, String refreshToken) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    await StorageService.saveUserToken(accessToken);
    await StorageService.saveRefreshToken(refreshToken);
    print('[APP] 🔑 Tokens saved to storage');
  }

 // String? get accessToken => _accessToken;
 // String? get refreshToken => _refreshToken;

  Future<void> _clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    await StorageService.clearUserToken();
    await StorageService.clearRefreshToken();
    print('[APP] 🔑 Tokens cleared from storage');
  }

  bool get _isAuthenticated => _accessToken != null;

  // Server connectivity check
  Future<bool> _isServerOnline() async {
    print('[APP] 🌐 ApiService.isServerOnline() - Starting...');
    print('[APP] 🌐 Checking server: $baseUrl/services/hello/');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/services/hello/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));

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

  // Make authenticated requests with automatic token refresh
  Future<http.Response?> _makeRequest(
      String endpoint, {
        String method = 'GET',
        Map<String, dynamic>? body,
        Map<String, String>? additionalHeaders,
        String? customBaseUrl,
      }) async {
    final headers = {
      'Content-Type': 'application/json',
      ...?additionalHeaders,
    };

    // Add Authorization header if we have a token
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    final uri = Uri.parse('${customBaseUrl ?? baseUrl}$endpoint');

    try {
      http.Response response;

      switch (method.toLowerCase()) {
        case 'post':
          response = await http.post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'put':
          response = await http.put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'delete':
          response = await http.delete(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        default:
          response = await http.get(uri, headers: headers);
      }

      // If token expired, try to refresh
      if (response.statusCode == 401 && _refreshToken != null) {
        print('[APP] 🔄 Token expired, attempting refresh...');
        final refreshed = await _refreshAccessToken();

        if (refreshed) {
          // Retry the original request with new token
          headers['Authorization'] = 'Bearer $_accessToken';

          switch (method.toLowerCase()) {
            case 'post':
              response = await http.post(
                uri,
                headers: headers,
                body: body != null ? jsonEncode(body) : null,
              );
              break;
            case 'put':
              response = await http.put(
                uri,
                headers: headers,
                body: body != null ? jsonEncode(body) : null,
              );
              break;
            case 'delete':
              response = await http.delete(
                uri,
                headers: headers,
                body: body != null ? jsonEncode(body) : null,
              );
              break;
            default:
              response = await http.get(uri, headers: headers);
          }
        } else {
          // Refresh failed, clear tokens
          await _clearTokens();
          print('[APP] 🔄 Token refresh failed, user needs to login again');
          return null;
        }
      }

      return response;
    } catch (error) {
      print('[APP] ❌ Request failed: $error');
      rethrow;
    }
  }

  // Refresh access token
  Future<bool> _refreshAccessToken() async {
    if (_refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/accounts/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': _refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['access_token'] != null) {
          _accessToken = data['access_token'];
          await StorageService.saveUserToken(_accessToken!);
          print('[APP] 🔄 Token refreshed successfully');
          return true;
        }
      }
      print('[APP] 🔄 Token refresh failed');
      return false;
    } catch (error) {
      print('[APP] 🔄 Token refresh error: $error');
      return false;
    }
  }

  // STATIC METHODS - These can be called directly from screens

  // Authentication methods
  static Future<Map<String, dynamic>> login(String identifier, String password) async {
    print('[APP] 🔐 ApiService.login() - Starting...');
    print('[APP] 🔐 Identifier: $identifier');
    print('[APP] 🔐 Password: [HIDDEN]');

    await _instance._init();
    print('[APP] 🔐 API service initialized');

    if (useTestServer) {
      print('[APP] 🔐 Using test server for login');
      await Future.delayed(Duration(seconds: 1));
      print('[APP] 🔐 Network delay simulation completed');

      final result = DummyData.simulateLogin(identifier, password);

      if (result['success'] == true) {
        await _instance._setTokens(
          result['access_token'] ?? '',
          result['refresh_token'] ?? '',
        );
      }

      print('[APP] 🔐 Test server response: $result');
      print('[APP] 🔐 ApiService.login() - Completed (test server)');
      return result;
    }

    try {
      final response = await _instance._makeRequest(
        '/accounts/login/',
        method: 'POST',
        body: {
          'identifier': identifier,
          'password': password,
        },
      );

      if (response == null) {
        return {
          'success': false,
          'message': 'Authentication required',
        };
      }

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        await _instance._setTokens(
          data['access_token'] ?? '',
          data['refresh_token'] ?? '',
        );
        return {
          'success': true,
          'userData': data['user_data'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'],
          'errors': data['errors'],
        };
      }
    } catch (error) {
      print('[APP] 🔐 Login failed: $error');
      return {
        'success': false,
        'message': 'Network error during login',
      };
    }
  }

  static Future<Map<String, dynamic>> register(PersonalData personal, MedicalData medical) async {
    print('[APP] 📋 ApiService.register() - Starting...');
    print('[APP] 📋 Personal data: ${personal.toJson()}');
    print('[APP] 📋 Medical data: ${medical.toJson()}');

    await _instance._init();
    print('[APP] 📋 API service initialized');

    if (useTestServer) {
      print('[APP] 📋 Using test server for registration');
      await Future.delayed(Duration(seconds: 2));
      print('[APP] 📋 Network delay simulation completed');

      final result = DummyData.simulateRegistration(personal, medical);

      if (result['success'] == true) {
        await _instance._setTokens(
          result['access_token'] ?? '',
          result['refresh_token'] ?? '',
        );
      }

      print('[APP] 📋 Test server response: $result');
      print('[APP] 📋 ApiService.register() - Completed (test server)');
      return result;
    }

    try {
      final response = await _instance._makeRequest(
        '/accounts/register/',
        method: 'POST',
        body: {
          'personal': personal.toJson(),
          'medical': medical.toJson(),
        },
      );

      if (response == null) {
        return {
          'success': false,
          'message': 'Network error during registration',
        };
      }

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        await _instance._setTokens(
          data['access_token'] ?? '',
          data['refresh_token'] ?? '',
        );
        return {
          'success': true,
          'userData': data['user_data'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'],
          'errors': data['errors'],
        };
      }
    } catch (error) {
      print('[APP] 📋 Registration failed: $error');
      return {
        'success': false,
        'message': 'Network error during registration',
      };
    }
  }

  static Future<void> logout() async {
    print('[APP] 🚪 ApiService.logout() - Starting...');

    try {
      if (_instance._refreshToken != null) {
        await _instance._makeRequest(
          '$baseUrl/accounts/logout/',
          method: 'POST',
          body: {'refresh_token': _instance._refreshToken},
        );
      }
    } catch (error) {
      print('[APP] 🚪 Logout request failed: $error');
    } finally {
      await _instance._clearTokens();
      print('[APP] 🚪 ApiService.logout() - Completed');
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    print('[APP] 👤 ApiService.getProfile() - Starting...');

    try {
      final response = await _instance._makeRequest('$baseUrl/accounts/profile/', method: 'GET',);

      if (response != null && response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('[APP] 👤 Profile fetched successfully');
        return data;
      }

      return {
        'success': false,
        'message': 'Failed to fetch profile'
      };
    } catch (error) {
      print('[APP] 👤 Get profile failed: $error');
      return {
        'success': false,
        'message': 'Network error'
      };
    }
  }

  static Future<Map<String, dynamic>> updateUserData(Map<String, dynamic> profileData) async {
    print('[APP] ✏️ ApiService.updateProfile() - Starting...');
    print('[APP] ✏️ Profile data: $profileData');

    await _instance._init();
    print('[APP] ✏️ API service initialized');

    if (useTestServer) {
      print('[APP] ✏️ Using test server for profile update');
      await Future.delayed(Duration(seconds: 2));
      print('[APP] ✏️ Network delay simulation completed');

      final result = DummyData.simulateUpdateUserData(profileData);
      print('[APP] ✏️ Test server response: $result');
      print('[APP] ✏️ ApiService.updateProfile() - Completed (test server)');
      return result;
    }

    try {
      final response = await _instance._makeRequest(
        '/accounts/profile/',
        method: 'PUT',
        body: profileData,
      );

      if (response == null) {
        return {
          'success': false,
          'message': 'Authentication required'
        };
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('[APP] ✏️ Profile updated successfully');
        return data;
      } else {
        final errorData = jsonDecode(response.body);
        print('[APP] ✏️ Profile update failed: ${response.statusCode}');
        return errorData;
      }
    } catch (error) {
      print('[APP] ✏️ Update profile failed: $error');
      return {
        'success': false,
        'message': 'Network error'
      };
    }
  }

  // Emergency request
  static Future<Map<String, dynamic>> sendEmergencyRequest(EmergencyRequest request) async {
    await _instance._init();
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

    try {
      final response = await _instance._makeRequest(
        '/emergency/request',
        method: 'POST',
        body: request.toJson(),
        customBaseUrl: Urls.apiEmergencyBaseUrl,
      );

      if (response == null) {
        return {
          'success': false,
          'message': 'Authentication required'
        };
      }

      final data = jsonDecode(response.body);
      print('[APP] 🚨 Emergency request sent successfully');
      return data;
    } catch (error) {
      print('[APP] 🚨 Emergency request failed: $error');
      return {
        'success': false,
        'message': 'Network error'
      };
    }
  }

  // OTP methods
  static Future<Map<String, dynamic>> sendOtpToEmail(String email) async {
    await _instance._init();
    print('[APP] 📱 ApiService.sendOtpToEmail() - Starting...');
    print('[APP] 📱 Email: $email');

    if (useTestServer) {
      print('[APP] 📱 Using test server for OTP');
      await Future.delayed(Duration(seconds: 1));
      print('[APP] 📱 Network delay simulation completed');

      final result = DummyData.simulateSendOtp(email);
      print('[APP] 📱 Test server response: $result');
      print('[APP] 📱 ApiService.sendOtpToEmail() - Completed (test server)');
      return result;
    }

    try {
      final response = await _instance._makeRequest(
        '/services/auth/request-otp/',
        method: 'POST',
        body: {'email': email},
      );

      if (response == null) {
        return {
          'success': false,
          'message': 'Network error'
        };
      }

      final data = jsonDecode(response.body);
      print('[APP] 📱 OTP sent successfully');
      return data;
    } catch (error) {
      print('[APP] 📱 Send OTP failed: $error');
      return {
        'success': false,
        'message': 'Network error'
      };
    }
  }

  static Future<Map<String, dynamic>> verifyEmailOtp(String email, String otp) async {
    await _instance._init();
    print('[APP] ✅ ApiService.verifyEmailOtp() - Starting...');
    print('[APP] ✅ Email: $email');
    print('[APP] ✅ OTP: $otp');

    if (useTestServer) {
      print('[APP] ✅ Using test server for OTP verification');
      await Future.delayed(Duration(seconds: 1));
      print('[APP] ✅ Network delay simulation completed');

      final result = DummyData.simulateVerifyOtp(email, otp);
      print('[APP] ✅ Test server response: $result');
      print('[APP] ✅ ApiService.verifyEmailOtp() - Completed (test server)');
      return result;
    }

    try {
      final response = await _instance._makeRequest(
        '/services/auth/verify-otp/',
        method: 'POST',
        body: {'email': email, 'code': otp},
      );

      if (response == null) {
        return {
          'success': false,
          'message': 'Network error'
        };
      }

      final data = jsonDecode(response.body);
      print('[APP] ✅ OTP verified successfully');
      return data;
    } catch (error) {
      print('[APP] ✅ Verify OTP failed: $error');
      return {
        'success': false,
        'message': 'Network error'
      };
    }
  }

  // Static getters for accessing singleton properties
  static bool get isAuthenticated => _instance._isAuthenticated;
  static String? get accessToken => _instance._accessToken;
  static String? get refreshToken => _instance._refreshToken;
}
