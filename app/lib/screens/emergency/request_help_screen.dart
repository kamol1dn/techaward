
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../../models/emergency_request.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import 'home_screen.dart';

class RequestHelpScreen extends StatefulWidget {
  final EmergencyType type;
  final bool isOnline;

  RequestHelpScreen({required this.type, required this.isOnline});

  @override
  _RequestHelpScreenState createState() => _RequestHelpScreenState();
}

class _RequestHelpScreenState extends State<RequestHelpScreen> {
  bool _isForMe = true;
  final _detailsController = TextEditingController();
  final _locationController = TextEditingController();
  String? _imagePath;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request ${_getServiceName()} Help'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Who needs help?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: Text('Me'),
                      value: true,
                      groupValue: _isForMe,
                      onChanged: (value) => setState(() => _isForMe = value!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: Text('Someone else'),
                      value: false,
                      groupValue: _isForMe,
                      onChanged: (value) => setState(() => _isForMe = value!),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              if (!_isForMe) ...[
                TextFormField(
                  controller: _detailsController,
                  decoration: InputDecoration(
                    labelText: 'Additional Details',
                    hintText: 'Describe the situation...',
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16),

                if (widget.isOnline) ...[
                  ElevatedButton.icon(
                    onPressed: _takePicture,
                    icon: Icon(Icons.camera_alt),
                    label: Text(_imagePath == null ? 'Take Photo' : 'Photo Taken'),
                  ),
                  SizedBox(height: 16),
                ],
              ],

              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  hintText: 'Current location will be used if empty',
                ),
              ),

              SizedBox(height: 32),

              if (widget.isOnline)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendOnlineRequest,
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Send Emergency Request'),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _sendOfflineRequest,
                    child: Text('Send via SMS'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getServiceName() {
    switch (widget.type) {
      case EmergencyType.ambulance: return 'Ambulance';
      case EmergencyType.fire: return 'Fire';
      case EmergencyType.police: return 'Police';
      case EmergencyType.others: return 'Other';
    }
  }

  Future<void> _takePicture() async {
    // TODO: Implement camera functionality
    setState(() => _imagePath = 'dummy_path.jpg');
  }

  Future<void> _sendOnlineRequest() async {
    setState(() => _isLoading = true);

    final userData = await StorageService.getUserData();
    final request = EmergencyRequest(
      type: widget.type,
      isForMe: _isForMe,
      details: _detailsController.text,
      location: _locationController.text.isEmpty ? 'Current Location' : _locationController.text,
      imagePath: _imagePath,
      userData: _isForMe ? userData : null,
    );

    try {
      final result = await ApiService.sendEmergencyRequest(request);
      if (result['success']) {
        _showSuccessDialog('Emergency request sent successfully!');
      }
    } catch (e) {
      _showErrorDialog('Failed to send request');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _sendOfflineRequest() async {
    final userData = await StorageService.getUserData();
    final smsData = {
      'type': _getServiceName(),
      'for_me': _isForMe,
      'details': _detailsController.text,
      'location': _locationController.text.isEmpty ? 'Current Location' : _locationController.text,
      if (_isForMe && userData != null) 'user': {
        'name': '${userData['name']} ${userData['surname']}',
        'phone': userData['phone'],
        'blood_type': userData['blood_type'],
        'allergies': userData['allergies'],
      }
    };

    final smsText = 'EMERGENCY: ${jsonEncode(smsData)}';
    final uri = Uri(scheme: 'sms', path: '102', queryParameters: {'body': smsText});

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showErrorDialog('Cannot open SMS app');
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Success'),
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
        title: Text('Error'),
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
}
