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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setBool(_isLoggedInKey, true);
  }

  // Get user token
  static Future<String?> getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Save login user data (from login response)
  static Future<void> saveLoginUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, json.encode(userData));
  }

  // Save registration user data (from registration flow)
  static Future<void> saveUserData(PersonalData personal, MedicalData medical) async {
    final prefs = await SharedPreferences.getInstance();
    final userData = {
      'name': personal.name,
      'surname': personal.surname,
      'phone': personal.phone,
      'age': personal.age,
      'gender': personal.gender,
      'passport': personal.passport,
      'blood_type': medical.bloodType,
      'allergies': medical.allergies,
      'illness': medical.illness,
      'additional_info': medical.additionalInfo,
    };
    await prefs.setString(_userDataKey, json.encode(userData));
  }

  // Save updated user data (from edit settings)
  static Future<void> saveUpdatedUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, json.encode(userData));
  }

  // Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userDataKey);
    if (userDataString != null) {
      return json.decode(userDataString);
    }
    return null;
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Emergency Contacts methods
  static Future<void> saveEmergencyContact(EmergencyContact contact) async {
    final prefs = await SharedPreferences.getInstance();
    final contacts = await getEmergencyContacts();

    // Check if contact already exists (for editing)
    final existingIndex = contacts.indexWhere((c) => c.id == contact.id);
    if (existingIndex != -1) {
      contacts[existingIndex] = contact;
    } else {
      contacts.add(contact);
    }

    final contactsJson = contacts.map((c) => c.toJson()).toList();
    await prefs.setString(_emergencyContactsKey, json.encode(contactsJson));
  }

  static Future<List<EmergencyContact>> getEmergencyContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final contactsString = prefs.getString(_emergencyContactsKey);
    if (contactsString != null) {
      final contactsJson = json.decode(contactsString) as List;
      return contactsJson.map((c) => EmergencyContact.fromJson(c)).toList();
    }
    return [];
  }

  static Future<void> removeEmergencyContact(String contactId) async {
    final prefs = await SharedPreferences.getInstance();
    final contacts = await getEmergencyContacts();
    contacts.removeWhere((c) => c.id == contactId);

    final contactsJson = contacts.map((c) => c.toJson()).toList();
    await prefs.setString(_emergencyContactsKey, json.encode(contactsJson));
  }

  static Future<void> clearEmergencyContacts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_emergencyContactsKey);
  }

  // Family Members methods
  static Future<void> saveFamilyMember(FamilyMember member) async {
    final prefs = await SharedPreferences.getInstance();
    final members = await getFamilyMembers();

    // Check if member already exists (for editing)
    final existingIndex = members.indexWhere((m) => m.id == member.id);
    if (existingIndex != -1) {
      members[existingIndex] = member;
    } else {
      members.add(member);
    }

    final membersJson = members.map((m) => m.toJson()).toList();
    await prefs.setString(_familyMembersKey, json.encode(membersJson));
  }

  static Future<List<FamilyMember>> getFamilyMembers() async {
    final prefs = await SharedPreferences.getInstance();
    final membersString = prefs.getString(_familyMembersKey);
    if (membersString != null) {
      final membersJson = json.decode(membersString) as List;
      return membersJson.map((m) => FamilyMember.fromJson(m)).toList();
    }
    return [];
  }

  static Future<void> removeFamilyMember(String memberId) async {
    final prefs = await SharedPreferences.getInstance();
    final members = await getFamilyMembers();
    members.removeWhere((m) => m.id == memberId);

    final membersJson = members.map((m) => m.toJson()).toList();
    await prefs.setString(_familyMembersKey, json.encode(membersJson));
  }

  static Future<void> updateFamilyMemberLocation(String memberId, LocationData location) async {
    final members = await getFamilyMembers();
    final memberIndex = members.indexWhere((m) => m.id == memberId);
    if (memberIndex != -1) {
      final updatedMember = members[memberIndex].copyWith(
        location: location,
        lastSeen: DateTime.now(),
        isOnline: true,
      );
      members[memberIndex] = updatedMember;

      final prefs = await SharedPreferences.getInstance();
      final membersJson = members.map((m) => m.toJson()).toList();
      await prefs.setString(_familyMembersKey, json.encode(membersJson));
    }
  }

  static Future<void> updateFamilyMemberStatus(String memberId, bool isOnline) async {
    final members = await getFamilyMembers();
    final memberIndex = members.indexWhere((m) => m.id == memberId);
    if (memberIndex != -1) {
      final updatedMember = members[memberIndex].copyWith(
        isOnline: isOnline,
        lastSeen: isOnline ? DateTime.now() : members[memberIndex].lastSeen,
      );
      members[memberIndex] = updatedMember;

      final prefs = await SharedPreferences.getInstance();
      final membersJson = members.map((m) => m.toJson()).toList();
      await prefs.setString(_familyMembersKey, json.encode(membersJson));
    }
  }

  static Future<void> clearFamilyMembers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_familyMembersKey);
  }

  // Location sharing settings
  static Future<void> setLocationSharingEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_locationSharingKey, enabled);
  }

  static Future<bool> isLocationSharingEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_locationSharingKey) ?? false;
  }

  // Clear all data
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
}