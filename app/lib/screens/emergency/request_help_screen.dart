import 'package:flutter/material.dart';
import 'package:talaba_plus/language/language_controller.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../../models/emergency_request.dart';
import '../../models/family_models.dart';

import '../../services/api/api_service.dart';
import '../../services/api/family_api_service.dart';
import '../../services/storage_service.dart';
import '../../services/family_storage_service.dart';
import 'home_screen.dart';

enum HelpRequestType { me, other, familyMember }

class RequestHelpScreen extends StatefulWidget {
  final EmergencyType type;
  final bool isOnline;

  const RequestHelpScreen({super.key, required this.type, required this.isOnline});

  @override
  _RequestHelpScreenState createState() => _RequestHelpScreenState();
}

class _RequestHelpScreenState extends State<RequestHelpScreen> {
  HelpRequestType _requestType = HelpRequestType.me;
  final _detailsController = TextEditingController();
  final _locationController = TextEditingController();
  String? _imagePath;
  bool _isLoading = false;

  // Family members data
  List<FamilyMember> _familyMembers = [];
  FamilyMember? _selectedFamilyMember;
  bool _loadingFamilyMembers = false;

  @override
  void initState() {
    super.initState();
    _loadFamilyMembers();
  }

  Future<void> _loadFamilyMembers() async {
    setState(() => _loadingFamilyMembers = true);

    try {
      // Try to get family members from local storage first
      final localMembers = await FamilyStorageService.getFamilyMembers();

      if (localMembers.isNotEmpty) {
        setState(() {
          _familyMembers = localMembers;
          _loadingFamilyMembers = false;
        });
      } else if (widget.isOnline) {
        // If no local data and online, try to fetch from API
        final response = await FamilyApiService.getSelectableMembers();

        if (response['success'] == true && response['data'] != null) {
          final List<dynamic> membersData = response['data']['members'] ?? [];
          final members = membersData.map((data) => FamilyMember.fromJson(data)).toList();

          setState(() {
            _familyMembers = members;
            _loadingFamilyMembers = false;
          });
        } else {
          setState(() => _loadingFamilyMembers = false);
        }
      } else {
        setState(() => _loadingFamilyMembers = false);
      }
    } catch (e) {
      print('Error loading family members: $e');
      setState(() => _loadingFamilyMembers = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getServiceName()),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  LanguageController.get('who_needs_help') ?? 'Who needs help?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
              SizedBox(height: 8),

              // Help request type selection
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<HelpRequestType>(
                      title: Text(
                          LanguageController.get('me')),
                      value: HelpRequestType.me,
                      groupValue: _requestType,
                      onChanged: (value) => setState(() {
                        _requestType = value!;
                        _selectedFamilyMember = null;
                      }),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<HelpRequestType>(
                      title: Text(
                          LanguageController.get('other_person')),
                      value: HelpRequestType.other,
                      groupValue: _requestType,
                      onChanged: (value) => setState(() {
                        _requestType = value!;
                        _selectedFamilyMember = null;
                      }),
                    ),
                  ),
                ],
              ),

              // Family member option
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<HelpRequestType>(
                      title: Text(
                          LanguageController.get('family_member')),
                      value: HelpRequestType.familyMember,
                      groupValue: _requestType,
                      onChanged: _familyMembers.isEmpty ? null : (value) => setState(() {
                        _requestType = value!;
                        _selectedFamilyMember = null;
                      }),
                    ),
                  ),
                  if (_loadingFamilyMembers)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),

              // Show family members dropdown if family member is selected
              if (_requestType == HelpRequestType.familyMember) ...[
                SizedBox(height: 16),
                if (_familyMembers.isEmpty)
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            LanguageController.get('no_family_members_found') ?? 'No family members found.',
                            style: TextStyle(color: Colors.orange.shade800),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  DropdownButtonFormField<FamilyMember>(
                    decoration: InputDecoration(
                      //labelText: 'Select Family Member',
                      labelText: LanguageController.get('select_family_member') ?? 'Select Family Member',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedFamilyMember,
                    items: _familyMembers.map((member) {
                      return DropdownMenuItem<FamilyMember>(
                        value: member,
                        child: Text('${member.name} (${member.relation})'),
                      );
                    }).toList(),
                    onChanged: (FamilyMember? newValue) {
                      setState(() => _selectedFamilyMember = newValue);
                    },
                    validator: (value) {
                      if (_requestType == HelpRequestType.familyMember && value == null) {
                        //return 'Please select a family member';
                        return LanguageController.get('please_select_family_member');
                      }
                      return null;
                    },
                  ),
              ],

              SizedBox(height: 20),

              // Additional details section
              if (_requestType != HelpRequestType.me) ...[
                TextFormField(
                  controller: _detailsController,
                  decoration: InputDecoration(
                    // labelText: 'Additional Details',
                    labelText: LanguageController.get('additional_details'),

                    hintText: _requestType == HelpRequestType.familyMember
                       // ? 'Describe what happened to your family member...'
                       // : 'Describe the situation...',
                      ? LanguageController.get('describe_family_member')
                      : LanguageController.get('describe_situation'),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16),

                // Photo taking section (placeholder for now)
                if (widget.isOnline) ...[
                  ElevatedButton.icon(
                    onPressed: _takePicture,
                    icon: Icon(Icons.camera_alt),
                    label: Text(
                        _imagePath == null
                            ? LanguageController.get('take_photo')
                            : LanguageController.get('photo_taken')
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _imagePath == null ? null : Colors.green,
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ],

              // Location field
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: LanguageController.get('location'),
                  hintText: 'Current location will be used if empty',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),

              SizedBox(height: 32),

              // Submit buttons
              if (widget.isOnline)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canSubmitRequest() && !_isLoading ? _sendOnlineRequest : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        SizedBox(width: 8),
                        //Text('Sending Emergency Request...'),
                        Text(LanguageController.get('sending_emergency_request')),
                      ],
                    ) : Text(
                        //'Send Emergency Request',
                        LanguageController.get('send_emergency_request'),
                        style: TextStyle(fontSize: 16)
                        ),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canSubmitRequest() ? _sendOfflineRequest : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sms),
                        SizedBox(width: 8),
                        Text('Send via SMS', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool _canSubmitRequest() {
    if (_requestType == HelpRequestType.familyMember) {
      return _selectedFamilyMember != null;
    }
    return true;
  }

  String _getServiceName() {
    switch (widget.type) {
      case EmergencyType.ambulance:
        return LanguageController.get('type_ambulance') ?? 'Ambulance';
      case EmergencyType.fire:
        return LanguageController.get('type_fire') ?? 'Fire';
      case EmergencyType.police:
        return LanguageController.get('type_police') ?? 'Police';
      case EmergencyType.car_accident:
        return LanguageController.get('type_car_accident') ?? 'Car Accident';
      case EmergencyType.others:
        return LanguageController.get('type_other') ?? 'Other';
    }
  }

  Future<void> _takePicture() async {
    // TODO: Implement camera functionality
    setState(() => _imagePath = 'dummy_path.jpg');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Photo feature will be implemented soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _sendOnlineRequest() async {
    setState(() => _isLoading = true);

    try {
      final userData = await StorageService.getUserData();

      // Prepare request data based on request type
      Map<String, dynamic> requestData = {
        'type': widget.type.toString(),
        'request_type': _requestType.toString(),
        'details': _detailsController.text,
        'location': _locationController.text.isEmpty ? 'Current Location' : _locationController.text,
        'image_path': _imagePath,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Add specific data based on request type
      switch (_requestType) {
        case HelpRequestType.me:
          requestData['user_data'] = userData;
          break;
        case HelpRequestType.other:
        // No specific user data for others
          break;
        case HelpRequestType.familyMember:
          if (_selectedFamilyMember != null) {
            requestData['family_member'] = _selectedFamilyMember!.toJson();
          }
          break;
      }

      // Create emergency request (you may need to modify EmergencyRequest model)
      final request = EmergencyRequest(
        type: widget.type,
        isForMe: _requestType == HelpRequestType.me,
        details: _detailsController.text,
        location: _locationController.text.isEmpty ? 'Current Location' : _locationController.text,
        imagePath: _imagePath,
        userData: _requestType == HelpRequestType.me ? userData : null,
      );

      final result = await ApiService.sendEmergencyRequest(request);

      if (result['success'] == true) {
        _showSuccessDialog('Emergency request sent successfully!');
      } else {
        _showErrorDialog(result['message'] ?? 'Failed to send request');
      }
    } catch (e) {
      _showErrorDialog('Failed to send request: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendOfflineRequest() async {
    try {
      final userData = await StorageService.getUserData();

      Map<String, dynamic> smsData = {
        'type': _getServiceName(),
        'request_type': _getRequestTypeString(),
        'details': _detailsController.text,
        'location': _locationController.text.isEmpty ? 'Current Location' : _locationController.text,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Add specific data based on request type
      switch (_requestType) {
        case HelpRequestType.me:
          if (userData != null) {
            smsData['user'] = {
              'name': '${userData['name']} ${userData['surname']}',
              'phone': userData['phone'],
              'blood_type': userData['blood_type'],
              'allergies': userData['allergies'],
            };
          }
          break;
        case HelpRequestType.other:
        // No specific user data for others
          break;
        case HelpRequestType.familyMember:
          if (_selectedFamilyMember != null) {
            smsData['family_member'] = {
              'name': _selectedFamilyMember!.name,
              'relation': _selectedFamilyMember!.relation,
              'phone': _selectedFamilyMember!.phone,
            };
          }
          break;
      }

      final smsText = 'EMERGENCY: ${jsonEncode(smsData)}';
      final uri = Uri(scheme: 'sms', path: '102', queryParameters: {'body': smsText});

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        _showSuccessDialog('SMS app opened. Please send the emergency message.');
      } else {
        _showErrorDialog('Cannot open SMS app');
      }
    } catch (e) {
      _showErrorDialog('Failed to prepare SMS: $e');
    }
  }

  String _getRequestTypeString() {
    switch (_requestType) {
      case HelpRequestType.me:
        return 'Self';
      case HelpRequestType.other:
        return 'Other Person';
      case HelpRequestType.familyMember:
        return 'Family Member: ${_selectedFamilyMember?.name ?? 'Unknown'}';
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Success'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _detailsController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}