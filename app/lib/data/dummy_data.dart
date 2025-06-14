import '../models/user_model.dart';
import '../models/emergency_request.dart';
import '../models/emergency_contact.dart';
import '../models/family_member.dart';


class DummyData {
  static Map<String, dynamic> simulateLogin(String login, String password) {
    // Simulate some test users
    if ((login == 'AB1234567' || login == 'test@gmail.com') && password == 'test') {
      return {
        'success': true,
        'token': 'dummy_token_12345',
        'message': 'Login successful',
        'user_data': {
          'name': 'Test',
          'surname': 'User',
          'phone': '+998901234567',
          'email': 'kamoliddinsharopov1@gmail.com',
          'age': 25,
          'gender': 'Male',
          'passport': 'AD1234567',
          'blood_type': 'A+',
          'allergies': 'none',
          'illness': 'none',
          'additional_info': 'none'
        }
      };
    }
    return {
      'success': false,
      'message': 'Invalid credentials',
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

  // New method for simulating user data update
  static Map<String, dynamic> simulateUpdateUserData(Map<String, dynamic> userData) {
    // Simulate validation
    List<String> errors = [];

    if (userData['name']?.toString().isEmpty == true) {
      errors.add('Name is required');
    }
    if (userData['surname']?.toString().isEmpty == true) {
      errors.add('Surname is required');
    }
    if (userData['phone']?.toString().isEmpty == true) {
      errors.add('Phone is required');
    }
    if (userData['age'] == null || userData['age'] < 1 || userData['age'] > 120) {
      errors.add('Invalid age');
    }
    if (userData['passport']?.toString().isEmpty == true) {
      errors.add('Passport is required');
    }

    // Return error if validation fails
    if (errors.isNotEmpty) {
      return {
        'success': false,
        'message': 'Validation failed: ${errors.join(', ')}'
      };
    }

    // Simulate successful update
    return {
      'success': true,
      'message': 'Profile updated successfully',
      'updated_data': userData
    };
  }

  // Emergency Contacts dummy methods
  static Map<String, dynamic> simulateSaveEmergencyContact(EmergencyContact contact) {
    return {
      'success': true,
      'message': 'Emergency contact saved successfully',
      'contact': contact.toJson(),
    };
  }

  static Map<String, dynamic> simulateGetEmergencyContacts() {
    return {
      'success': true,
      'contacts': [
        {
          'id': 'ec_1',
          'name': 'John Doe',
          'phone': '+998901234567',
          'relationship': 'Father',
          'is_primary': true,
          'created_at': DateTime.now().subtract(Duration(days: 30)).toIso8601String(),
        },
        {
          'id': 'ec_2',
          'name': 'Jane Smith',
          'phone': '+998907654321',
          'relationship': 'Sister',
          'is_primary': false,
          'created_at': DateTime.now().subtract(Duration(days: 15)).toIso8601String(),
        },
      ],
    };
  }

  static Map<String, dynamic> simulateDeleteEmergencyContact(String contactId) {
    return {
      'success': true,
      'message': 'Emergency contact deleted successfully',
    };
  }

  // Family Members dummy methods
  static Map<String, dynamic> simulateSaveFamilyMember(FamilyMember member) {
    return {
      'success': true,
      'message': 'Family member saved successfully',
      'member': member.toJson(),
    };
  }

  static Map<String, dynamic> simulateGetFamilyMembers() {
    return {
      'success': true,
      'members': [
        {
          'id': 'fm_1',
          'name': 'Mom',
          'phone': '+998901111111',
          'relationship': 'Mother',
          'is_online': true,
          'last_seen': DateTime.now().subtract(Duration(minutes: 5)).toIso8601String(),
          'location': {
            'latitude': 41.2995,
            'longitude': 69.2401,
            'address': 'Tashkent, Uzbekistan',
            'timestamp': DateTime.now().subtract(Duration(minutes: 5)).toIso8601String(),
          },
          'can_track_me': true,
          'can_i_track': true,
          'created_at': DateTime.now().subtract(Duration(days: 60)).toIso8601String(),
        },
        {
          'id': 'fm_2',
          'name': 'Dad',
          'phone': '+998902222222',
          'relationship': 'Father',
          'is_online': false,
          'last_seen': DateTime.now().subtract(Duration(hours: 2)).toIso8601String(),
          'location': {
            'latitude': 41.3111,
            'longitude': 69.2797,
            'address': 'Chilanzar, Tashkent',
            'timestamp': DateTime.now().subtract(Duration(hours: 2)).toIso8601String(),
          },
          'can_track_me': true,
          'can_i_track': true,
          'created_at': DateTime.now().subtract(Duration(days: 45)).toIso8601String(),
        },
        {
          'id': 'fm_3',
          'name': 'Brother',
          'phone': '+998903333333',
          'relationship': 'Brother',
          'is_online': true,
          'last_seen': DateTime.now().subtract(Duration(minutes: 1)).toIso8601String(),
          'location': {
            'latitude': 41.2647,
            'longitude': 69.2163,
            'address': 'Yunusabad, Tashkent',
            'timestamp': DateTime.now().subtract(Duration(minutes: 1)).toIso8601String(),
          },
          'can_track_me': false,
          'can_i_track': true,
          'created_at': DateTime.now().subtract(Duration(days: 20)).toIso8601String(),
        },
      ],
    };
  }

  static Map<String, dynamic> simulateDeleteFamilyMember(String memberId) {
    return {
      'success': true,
      'message': 'Family member removed successfully',
    };
  }

  static Map<String, dynamic> simulateSendFamilyInvite(String phone, String name) {
    return {
      'success': true,
      'message': 'Family invite sent successfully',
      'invite_id': 'inv_${DateTime.now().millisecondsSinceEpoch}',
    };
  }

  static Map<String, dynamic> simulateUpdateLocation(LocationData location) {
    return {
      'success': true,
      'message': 'Location updated successfully',
      'location': location.toJson(),
    };
  }

  static Map<String, dynamic> simulateGetFamilyLocations() {
    return {
      'success': true,
      'locations': [
        {
          'member_id': 'fm_1',
          'name': 'Mom',
          'location': {
            'latitude': 41.2995,
            'longitude': 69.2401,
            'address': 'Tashkent, Uzbekistan',
            'timestamp': DateTime.now().subtract(Duration(minutes: 5)).toIso8601String(),
          },
          'is_online': true,
        },
        {
          'member_id': 'fm_2',
          'name': 'Dad',
          'location': {
            'latitude': 41.3111,
            'longitude': 69.2797,
            'address': 'Chilanzar, Tashkent',
            'timestamp': DateTime.now().subtract(Duration(hours: 2)).toIso8601String(),
          },
          'is_online': false,
        },
        {
          'member_id': 'fm_3',
          'name': 'Brother',
          'location': {
            'latitude': 41.2647,
            'longitude': 69.2163,
            'address': 'Yunusabad, Tashkent',
            'timestamp': DateTime.now().subtract(Duration(minutes: 1)).toIso8601String(),
          },
          'is_online': true,
        },
      ],
    };
  }

  static Map<String, dynamic> simulateTestEmergencyNotification() {
    return {
      'success': true,
      'message': 'Test emergency notification sent to all emergency contacts',
      'notified_contacts': [
        {
          'name': 'John Doe',
          'phone': '+998901234567',
          'status': 'sent',
        },
        {
          'name': 'Jane Smith',
          'phone': '+998907654321',
          'status': 'sent',
        },
      ],
    };
  }


}