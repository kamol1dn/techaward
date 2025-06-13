import 'package:flutter/material.dart';
import '../../models/emergency_contact.dart';
import '../../services/storage_service.dart';
import '../../services/api_service.dart';

class AddEmergencyContactScreen extends StatefulWidget {
  final EmergencyContact? contact;

  const AddEmergencyContactScreen({super.key, this.contact});

  @override
  State<AddEmergencyContactScreen> createState() => _AddEmergencyContactScreenState();
}

class _AddEmergencyContactScreenState extends State<AddEmergencyContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedRelationship = 'Family';
  bool _isPrimary = false;
  bool _isLoading = false;

  final List<String> _relationships = [
    'Family',
    'Father',
    'Mother',
    'Brother',
    'Sister',
    'Spouse',
    'Child',
    'Friend',
    'Colleague',
    'Neighbor',
    'Doctor',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.contact != null) {
      _nameController.text = widget.contact!.name;
      _phoneController.text = widget.contact!.phone;
      _selectedRelationship = widget.contact!.relationship;
      _isPrimary = widget.contact!.isPrimary;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.contact != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Emergency Contact' : 'Add Emergency Contact'),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contact Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                          hintText: '+998901234567',
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a phone number';
                          }
                          if (!RegExp(r'^\+998\d{9}$').hasMatch(value.trim())) {
                            return 'Please enter a valid Uzbek phone number (+998XXXXXXXXX)';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedRelationship,
                        decoration: InputDecoration(
                          labelText: 'Relationship',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.family_restroom),
                        ),
                        items: _relationships.map((relationship) {
                          return DropdownMenuItem(
                            value: relationship,
                            child: Text(relationship),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRelationship = value!;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      CheckboxListTile(
                        title: Text('Primary Contact'),
                        subtitle: Text('This contact will be notified first in emergencies'),
                        value: _isPrimary,
                        onChanged: (value) {
                          setState(() {
                            _isPrimary = value ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Card(
                color: Colors.orange[50],
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.orange[700],
                        size: 32,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Emergency Contact Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'This contact will be automatically notified when you request emergency services. Make sure they are someone you trust and who can help in critical situations.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveContact,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                    isEditing ? 'Update Contact' : 'Add Contact',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final contact = EmergencyContact(
        id: widget.contact?.id ?? 'ec_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        relationship: _selectedRelationship,
        isPrimary: _isPrimary,
        createdAt: widget.contact?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to local storage
      await StorageService.saveEmergencyContact(contact);

      // Try to save to server
      try {
        final result = await ApiService.saveEmergencyContact(contact);
        if (!result['success']) {
          // Server save failed, but local save succeeded
          _showWarningDialog('Contact saved locally, but could not sync with server');
        }
      } catch (e) {
        // Server not available, local save succeeded
        _showWarningDialog('Contact saved locally, will sync when online');
      }

      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Failed to save contact: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showWarningDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Warning'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}