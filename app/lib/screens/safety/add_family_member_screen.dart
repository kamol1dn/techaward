import 'package:flutter/material.dart';
import '../../models/family_member.dart';
import '../../services/storage_service.dart';
import '../../services/api_service.dart';

class AddFamilyMemberScreen extends StatefulWidget {
  final FamilyMember? member;

  const AddFamilyMemberScreen({super.key, this.member});

  @override
  State<AddFamilyMemberScreen> createState() => _AddFamilyMemberScreenState();
}

class _AddFamilyMemberScreenState extends State<AddFamilyMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedRelationship = 'Family';
  bool _isLoading = false;

  final List<String> _relationships = [
    'Family',
    'Father',
    'Mother',
    'Brother',
    'Sister',
    'Spouse',
    'Child',
    'Son',
    'Daughter',
    'Grandparent',
    'Grandchild',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.member != null) {
      _nameController.text = widget.member!.name;
      _phoneController.text = widget.member!.phone;
      _selectedRelationship = widget.member!.relationship;
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
    final isEditing = widget.member != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Family Member' : 'Add Family Member'),
        backgroundColor: Colors.blue[600],
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
                        'Family Member Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
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
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.blue[700],
                        size: 32,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Family Location Tracking',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'This family member will be able to see your location and you will be able to see theirs. They will receive an invitation to join your family group.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[600],
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
                  onPressed: _isLoading ? null : _saveFamilyMember,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                    isEditing ? 'Update Family Member' : 'Add Family Member',
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

  Future<void> _saveFamilyMember() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final member = FamilyMember(
        id: widget.member?.id ?? 'fm_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        relationship: _selectedRelationship,
        isOnline: widget.member?.isOnline ?? false,
        lastSeen: widget.member?.lastSeen,
        location: widget.member?.location,
        createdAt: widget.member?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        isInvitePending: widget.member?.isInvitePending ?? true,
      );

      // Save to local storage
      await StorageService.saveFamilyMember(member);

      // Try to save to server and send invite
      try {
        final result = await ApiService.saveFamilyMember(member);
        if (result['success']) {
          // Send invite if it's a new member
          if (widget.member == null) {
            await ApiService.sendFamilyInvite(member.phone, member.name);
          }
        } else {
          _showWarningDialog('Family member saved locally, but could not sync with server');
        }
      } catch (e) {
        _showWarningDialog('Family member saved locally, will sync when online');
      }

      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Failed to save family member: $e');
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