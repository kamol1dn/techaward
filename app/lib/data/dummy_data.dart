import '../models/user_model.dart';
import '../models/emergency_request.dart';

class DummyData {
  static Map<String, dynamic> simulateLogin(String login, String password) {
    // Simulate some test users
    if ((login == 'test' || login == 'kamol') && password == '1') {
      return {
        'success': true,
        'token': 'dummy_token_12345',
        'message': 'Login successful',
        'user_data': {
          'name': 'Test',
          'surname': 'User',
          'phone': '+998901234567',
          'age': 25,
          'gender': 'Male',
          'passport': 'AD1234567',
          'blood_type': 'A+',
          'allergies': 'none',
          'illness': '',
          'additional_info': ''
        }
      };
    }
    return {
      'success': false,
      'message': 'Invalid credentials'
    };
  }

  static Map<String, dynamic> simulateSendOtp(String phone) {
    return {
      'success': true,
      'message': 'OTP sent successfully'
    };
  }

  static Map<String, dynamic> simulateVerifyOtp(String phone, String otp) {
    // Accept any 4-digit OTP for testing
    if (otp == '1234') {
      return {
        'success': true,
        'registration_token': 'reg_token_1234'
      };
    }
    return {
      'success': false,
      'message': 'Invalid OTP'
    };
  }

  static Map<String, dynamic> simulateRegistration(PersonalData personal, MedicalData medical) {
    return {
      'success': true,
      'token': 'user_token_1234',
      'message': 'Registration completed successfully'
    };
  }

  static Map<String, dynamic> simulateEmergencyRequest(EmergencyRequest request) {
    return {
      'success': true,
      'request_id': 'ER${DateTime.now().millisecondsSinceEpoch}',
      'message': 'Emergency request received and being processed'
    };
  }
}