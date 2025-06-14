import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/emergency_contact.dart';
import '../models/family_member.dart';
import '../models/user_model.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static const String _tokenKey = 'user_token';
  static const String _userDataKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _emergencyContactsKey = 'emergency_contacts';
  static const String _familyMembersKey = 'family_members';
  static const String _locationSharingKey = 'location_sharing_enabled';

  // Save user token
  static Future<void> saveUserToken(String token) async {
    print('[APP] 🔐 StorageService.saveUserToken() - Starting...');
    print('[APP] 🔐 Token to save: $token');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 🔐 SharedPreferences instance obtained.');

    await prefs.setString(_tokenKey, token);
    print('[APP] 🔐 Token saved successfully: $token');

    await prefs.setBool(_isLoggedInKey, true);
    print('[APP] 🔐 Login state saved: true');
    print('[APP] 🔐 StorageService.saveUserToken() - Completed');
  }

  // Get user token
  static Future<String?> getUserToken() async {
    print('[APP] 🔑 StorageService.getUserToken() - Starting...');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    print('[APP] 🔑 Retrieved token: $token');
    print('[APP] 🔑 StorageService.getUserToken() - Completed');
    return token;
  }

  // Save login user data (from login response)
  static Future<void> saveLoginUserData(Map<String, dynamic> userData) async {
    print('[APP] 👤 StorageService.saveLoginUserData() - Starting...');
    print('[APP] 👤 User data to save: ${json.encode(userData)}');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 👤 SharedPreferences instance obtained');

    await prefs.setString(_userDataKey, json.encode(userData));
    print('[APP] 👤 Login user data saved successfully');
    print('[APP] 👤 StorageService.saveLoginUserData() - Completed');
  }

  // Save registration user data (from registration flow)
  static Future<void> saveUserData(PersonalData personal, MedicalData medical) async {
    print('[APP] 📋 StorageService.saveUserData() - Starting...');
    print('[APP] 📋 Personal data: name=${personal.name}, surname=${personal.surname}, email=${personal.email}');
    print('[APP] 📋 Medical data: bloodType=${medical.bloodType}, allergies=${medical.allergies}');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 📋 SharedPreferences instance obtained');

    final userData = {
      'name': personal.name,
      'surname': personal.surname,
      'email': personal.email,
      'age': personal.age,
      'gender': personal.gender,
      'passport': personal.passport,
      'blood_type': medical.bloodType,
      'allergies': medical.allergies,
      'illness': medical.illness,
      'additional_info': medical.additionalInfo,
    };

    print('[APP] 📋 Saving registration data: ${json.encode(userData)}');
    await prefs.setString(_userDataKey, json.encode(userData));
    print('[APP] 📋 Registration data saved successfully');
    print('[APP] 📋 StorageService.saveUserData() - Completed');
  }

  // Save updated user data (from edit settings)
  static Future<void> saveUpdatedUserData(Map<String, dynamic> userData) async {
    print('[APP] ✏️ StorageService.saveUpdatedUserData() - Starting...');
    print('[APP] ✏️ Updated user data: ${json.encode(userData)}');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] ✏️ SharedPreferences instance obtained');

    await prefs.setString(_userDataKey, json.encode(userData));
    print('[APP] ✏️ Updated user data saved successfully');
    print('[APP] ✏️ StorageService.saveUpdatedUserData() - Completed');
  }

  // Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    print('[APP] 📖 StorageService.getUserData() - Starting...');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 📖 SharedPreferences instance obtained');

    final userDataString = prefs.getString(_userDataKey);
    print('[APP] 📖 Raw user data string: $userDataString');

    if (userDataString != null) {
      final userData = json.decode(userDataString);
      print('[APP] 📖 Decoded user data: $userData');
      print('[APP] 📖 StorageService.getUserData() - Completed with data');
      return userData;
    }

    print('[APP] 📖 No user data found');
    print('[APP] 📖 StorageService.getUserData() - Completed with null');
    return null;
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    print('[APP] 🔍 StorageService.isLoggedIn() - Starting...');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 🔍 SharedPreferences instance obtained');

    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    print('[APP] 🔍 Login status: $isLoggedIn');
    print('[APP] 🔍 StorageService.isLoggedIn() - Completed');

    return isLoggedIn;
  }

  // Emergency Contacts methods
  static Future<void> saveEmergencyContact(EmergencyContact contact) async {
    print('[APP] 🚨 StorageService.saveEmergencyContact() - Starting...');
    print('[APP] 🚨 Contact to save: ${contact.toJson()}');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 🚨 SharedPreferences instance obtained');

    final contacts = await getEmergencyContacts();
    print('[APP] 🚨 Current contacts count: ${contacts.length}');

    // Check if contact already exists (for editing)
    final existingIndex = contacts.indexWhere((c) => c.id == contact.id);
    if (existingIndex != -1) {
      print('[APP] 🚨 Updating existing contact at index: $existingIndex');
      contacts[existingIndex] = contact;
    } else {
      print('[APP] 🚨 Adding new contact');
      contacts.add(contact);
    }

    final contactsJson = contacts.map((c) => c.toJson()).toList();
    print('[APP] 🚨 Contacts to save: ${json.encode(contactsJson)}');

    await prefs.setString(_emergencyContactsKey, json.encode(contactsJson));
    print('[APP] 🚨 Emergency contact saved successfully');
    print('[APP] 🚨 StorageService.saveEmergencyContact() - Completed');
  }

  static Future<List<EmergencyContact>> getEmergencyContacts() async {
    print('[APP] 📞 StorageService.getEmergencyContacts() - Starting...');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 📞 SharedPreferences instance obtained');

    final contactsString = prefs.getString(_emergencyContactsKey);
    print('[APP] 📞 Raw contacts string: $contactsString');

    if (contactsString != null) {
      final contactsJson = json.decode(contactsString) as List;
      print('[APP] 📞 Decoded contacts JSON: $contactsJson');

      final contacts = contactsJson.map((c) => EmergencyContact.fromJson(c)).toList();
      print('[APP] 📞 Parsed ${contacts.length} emergency contacts');
      print('[APP] 📞 StorageService.getEmergencyContacts() - Completed with data');
      return contacts;
    }

    print('[APP] 📞 No emergency contacts found');
    print('[APP] 📞 StorageService.getEmergencyContacts() - Completed with empty list');
    return [];
  }

  static Future<void> removeEmergencyContact(String contactId) async {
    print('[APP] 🗑️ StorageService.removeEmergencyContact() - Starting...');
    print('[APP] 🗑️ Contact ID to remove: $contactId');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 🗑️ SharedPreferences instance obtained');

    final contacts = await getEmergencyContacts();
    print('[APP] 🗑️ Current contacts count: ${contacts.length}');

    contacts.removeWhere((c) => c.id == contactId);
    print('[APP] 🗑️ Contacts after removal: ${contacts.length}');

    final contactsJson = contacts.map((c) => c.toJson()).toList();
    await prefs.setString(_emergencyContactsKey, json.encode(contactsJson));
    print('[APP] 🗑️ Emergency contact removed successfully');
    print('[APP] 🗑️ StorageService.removeEmergencyContact() - Completed');
  }

  static Future<void> clearEmergencyContacts() async {
    print('[APP] 🧹 StorageService.clearEmergencyContacts() - Starting...');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 🧹 SharedPreferences instance obtained');

    await prefs.remove(_emergencyContactsKey);
    print('[APP] 🧹 Emergency contacts cleared successfully');
    print('[APP] 🧹 StorageService.clearEmergencyContacts() - Completed');
  }

  // Family Members methods
  static Future<void> saveFamilyMember(FamilyMember member) async {
    print('[APP] 👨‍👩‍👧‍👦 StorageService.saveFamilyMember() - Starting...');
    print('[APP] 👨‍👩‍👧‍👦 Member to save: ${member.toJson()}');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 👨‍👩‍👧‍👦 SharedPreferences instance obtained');

    final members = await getFamilyMembers();
    print('[APP] 👨‍👩‍👧‍👦 Current members count: ${members.length}');

    // Check if member already exists (for editing)
    final existingIndex = members.indexWhere((m) => m.id == member.id);
    if (existingIndex != -1) {
      print('[APP] 👨‍👩‍👧‍👦 Updating existing member at index: $existingIndex');
      members[existingIndex] = member;
    } else {
      print('[APP] 👨‍👩‍👧‍👦 Adding new member');
      members.add(member);
    }

    final membersJson = members.map((m) => m.toJson()).toList();
    print('[APP] 👨‍👩‍👧‍👦 Members to save: ${json.encode(membersJson)}');

    await prefs.setString(_familyMembersKey, json.encode(membersJson));
    print('[APP] 👨‍👩‍👧‍👦 Family member saved successfully');
    print('[APP] 👨‍👩‍👧‍👦 StorageService.saveFamilyMember() - Completed');
  }

  static Future<List<FamilyMember>> getFamilyMembers() async {
    print('[APP] 👪 StorageService.getFamilyMembers() - Starting...');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 👪 SharedPreferences instance obtained');

    final membersString = prefs.getString(_familyMembersKey);
    print('[APP] 👪 Raw members string: $membersString');

    if (membersString != null) {
      final membersJson = json.decode(membersString) as List;
      print('[APP] 👪 Decoded members JSON: $membersJson');

      final members = membersJson.map((m) => FamilyMember.fromJson(m)).toList();
      print('[APP] 👪 Parsed ${members.length} family members');
      print('[APP] 👪 StorageService.getFamilyMembers() - Completed with data');
      return members;
    }

    print('[APP] 👪 No family members found');
    print('[APP] 👪 StorageService.getFamilyMembers() - Completed with empty list');
    return [];
  }

  static Future<void> removeFamilyMember(String memberId) async {
    print('[APP] ❌ StorageService.removeFamilyMember() - Starting...');
    print('[APP] ❌ Member ID to remove: $memberId');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] ❌ SharedPreferences instance obtained');

    final members = await getFamilyMembers();
    print('[APP] ❌ Current members count: ${members.length}');

    members.removeWhere((m) => m.id == memberId);
    print('[APP] ❌ Members after removal: ${members.length}');

    final membersJson = members.map((m) => m.toJson()).toList();
    await prefs.setString(_familyMembersKey, json.encode(membersJson));
    print('[APP] ❌ Family member removed successfully');
    print('[APP] ❌ StorageService.removeFamilyMember() - Completed');
  }

  static Future<void> updateFamilyMemberLocation(String memberId, LocationData location) async {
    print('[APP] 📍 StorageService.updateFamilyMemberLocation() - Starting...');
    print('[APP] 📍 Member ID: $memberId');
    print('[APP] 📍 Location: ${location.toJson()}');

    final members = await getFamilyMembers();
    print('[APP] 📍 Current members count: ${members.length}');

    final memberIndex = members.indexWhere((m) => m.id == memberId);
    print('[APP] 📍 Member index: $memberIndex');

    if (memberIndex != -1) {
      print('[APP] 📍 Updating member location...');
      final updatedMember = members[memberIndex].copyWith(
        location: location,
        lastSeen: DateTime.now(),
        isOnline: true,
      );
      members[memberIndex] = updatedMember;
      print('[APP] 📍 Member updated: ${updatedMember.toJson()}');

      final prefs = await SharedPreferences.getInstance();
      print('[APP] 📍 SharedPreferences instance obtained');

      final membersJson = members.map((m) => m.toJson()).toList();
      await prefs.setString(_familyMembersKey, json.encode(membersJson));
      print('[APP] 📍 Family member location updated successfully');
    } else {
      print('[APP] 📍 Member not found with ID: $memberId');
    }

    print('[APP] 📍 StorageService.updateFamilyMemberLocation() - Completed');
  }

  static Future<void> updateFamilyMemberStatus(String memberId, bool isOnline) async {
    print('[APP] 🟢 StorageService.updateFamilyMemberStatus() - Starting...');
    print('[APP] 🟢 Member ID: $memberId');
    print('[APP] 🟢 Online status: $isOnline');

    final members = await getFamilyMembers();
    print('[APP] 🟢 Current members count: ${members.length}');

    final memberIndex = members.indexWhere((m) => m.id == memberId);
    print('[APP] 🟢 Member index: $memberIndex');

    if (memberIndex != -1) {
      print('[APP] 🟢 Updating member status...');
      final updatedMember = members[memberIndex].copyWith(
        isOnline: isOnline,
        lastSeen: isOnline ? DateTime.now() : members[memberIndex].lastSeen,
      );
      members[memberIndex] = updatedMember;
      print('[APP] 🟢 Member updated: ${updatedMember.toJson()}');

      final prefs = await SharedPreferences.getInstance();
      print('[APP] 🟢 SharedPreferences instance obtained');

      final membersJson = members.map((m) => m.toJson()).toList();
      await prefs.setString(_familyMembersKey, json.encode(membersJson));
      print('[APP] 🟢 Family member status updated successfully');
    } else {
      print('[APP] 🟢 Member not found with ID: $memberId');
    }

    print('[APP] 🟢 StorageService.updateFamilyMemberStatus() - Completed');
  }

  static Future<void> clearFamilyMembers() async {
    print('[APP] 🧽 StorageService.clearFamilyMembers() - Starting...');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 🧽 SharedPreferences instance obtained');

    await prefs.remove(_familyMembersKey);
    print('[APP] 🧽 Family members cleared successfully');
    print('[APP] 🧽 StorageService.clearFamilyMembers() - Completed');
  }

  // Location sharing settings
  static Future<void> setLocationSharingEnabled(bool enabled) async {
    print('[APP] 🌍 StorageService.setLocationSharingEnabled() - Starting...');
    print('[APP] 🌍 Location sharing enabled: $enabled');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 🌍 SharedPreferences instance obtained');

    await prefs.setBool(_locationSharingKey, enabled);
    print('[APP] 🌍 Location sharing setting saved successfully');
    print('[APP] 🌍 StorageService.setLocationSharingEnabled() - Completed');
  }

  static Future<bool> isLocationSharingEnabled() async {
    print('[APP] 🗺️ StorageService.isLocationSharingEnabled() - Starting...');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 🗺️ SharedPreferences instance obtained');

    final isEnabled = prefs.getBool(_locationSharingKey) ?? false;
    print('[APP] 🗺️ Location sharing enabled: $isEnabled');
    print('[APP] 🗺️ StorageService.isLocationSharingEnabled() - Completed');

    return isEnabled;
  }

  // Clear all data
  static Future<void> clearAll() async {
    print('[APP] 🔥 StorageService.clearAll() - Starting...');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 🔥 SharedPreferences instance obtained');

    await prefs.clear();
    print('[APP] 🔥 All data cleared successfully');
    print('[APP] 🔥 StorageService.clearAll() - Completed');
  }

  static Future<void> init() async {
    print('[APP] 🚀 StorageService.init() - Starting...');

    _prefs = await SharedPreferences.getInstance();
    print('[APP] 🚀 SharedPreferences instance initialized');
    print('[APP] 🚀 StorageService.init() - Completed');
  }
}