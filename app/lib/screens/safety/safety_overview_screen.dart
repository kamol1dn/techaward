import 'package:flutter/material.dart';
import '../../models/emergency_contact.dart';
import '../../models/family_member.dart';
import '../../services/storage_service.dart';
import '../../services/api_service.dart';
// import 'add_emergency_contact_screen.dart';
import 'add_family_member_screen.dart';
import 'emergency_contact_screen.dart';
import 'family_tracking_screen.dart';

class SafetyOverviewScreen extends StatefulWidget {
  const SafetyOverviewScreen({super.key});

  @override
  State<SafetyOverviewScreen> createState() => _SafetyOverviewScreenState();
}

class _SafetyOverviewScreenState extends State<SafetyOverviewScreen> {
  List<EmergencyContact> _emergencyContacts = [];
  List<FamilyMember> _familyMembers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final contacts = await StorageService.getEmergencyContacts();
      final family = await StorageService.getFamilyMembers();

      setState(() {
        _emergencyContacts = contacts;
        _familyMembers = family;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Failed to load data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Safety Overview'),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEmergencyContactsSection(),
            SizedBox(height: 24),
            _buildFamilyTrackingSection(),
            SizedBox(height: 24),
            _buildQuickActionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContactsSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Emergency Contacts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
                IconButton(
                  onPressed: _addEmergencyContact,
                  icon: Icon(Icons.add, color: Colors.red[700]),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'These contacts will be notified when you request emergency services',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16),
            _emergencyContacts.isEmpty
                ? _buildEmptyState('No emergency contacts added', Icons.contact_emergency)
                : Column(
              children: _emergencyContacts.map((contact) => _buildEmergencyContactItem(contact)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyTrackingSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Family Tracking',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                IconButton(
                  onPressed: _addFamilyMember,
                  icon: Icon(Icons.add, color: Colors.blue[700]),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Track family members\' locations and let them track yours',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16),
            _familyMembers.isEmpty
                ? _buildEmptyState('No family members added', Icons.family_restroom)
                : Column(
              children: [
                ..._familyMembers.map((member) => _buildFamilyMemberItem(member)).toList(),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openFamilyTracking,
                    icon: Icon(Icons.map),
                    label: Text('View Family Map'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _testEmergencyNotification,
                    icon: Icon(Icons.notifications_active),
                    label: Text('Test Emergency Alert'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareMyLocation,
                    icon: Icon(Icons.share_location),
                    label: Text('Share Location'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      padding: EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContactItem(EmergencyContact contact) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red[100],
          child: Icon(Icons.person, color: Colors.red[700]),
        ),
        title: Text(contact.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(contact.phone),
            Text(
              contact.relationship,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _editEmergencyContact(contact),
              icon: Icon(Icons.edit, color: Colors.blue[600]),
            ),
            IconButton(
              onPressed: () => _deleteEmergencyContact(contact),
              icon: Icon(Icons.delete, color: Colors.red[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyMemberItem(FamilyMember member) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: member.isOnline ? Colors.green[100] : Colors.grey[200],
          child: Icon(
            Icons.person,
            color: member.isOnline ? Colors.green[700] : Colors.grey[600],
          ),
        ),
        title: Text(member.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(member.phone),
            Row(
              children: [
                Icon(
                  member.isOnline ? Icons.circle : Icons.circle_outlined,
                  size: 12,
                  color: member.isOnline ? Colors.green : Colors.grey,
                ),
                SizedBox(width: 4),
                Text(
                  member.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    color: member.isOnline ? Colors.green[600] : Colors.grey[600],
                  ),
                ),
                if (member.lastSeen != null) ...[
                  Text(' • '),
                  Text(
                    _formatLastSeen(member.lastSeen!),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _editFamilyMember(member),
              icon: Icon(Icons.edit, color: Colors.blue[600]),
            ),
            IconButton(
              onPressed: () => _deleteFamilyMember(member),
              icon: Icon(Icons.delete, color: Colors.red[600]),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  // Action methods
  Future<void> _addEmergencyContact() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEmergencyContactScreen()),
    );
    if (result == true) {
      _loadData();
    }
  }

  Future<void> _editEmergencyContact(EmergencyContact contact) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEmergencyContactScreen(contact: contact),
      ),
    );
    if (result == true) {
      _loadData();
    }
  }

  Future<void> _deleteEmergencyContact(EmergencyContact contact) async {
    final confirmed = await _showConfirmDialog(
      'Delete Emergency Contact',
      'Are you sure you want to delete ${contact.name}?',
    );
    if (confirmed) {
      await StorageService.removeEmergencyContact(contact.id);
      _loadData();
    }
  }

  Future<void> _addFamilyMember() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddFamilyMemberScreen()),
    );
    if (result == true) {
      _loadData();
    }
  }

  Future<void> _editFamilyMember(FamilyMember member) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFamilyMemberScreen(member: member),
      ),
    );
    if (result == true) {
      _loadData();
    }
  }

  Future<void> _deleteFamilyMember(FamilyMember member) async {
    final confirmed = await _showConfirmDialog(
      'Remove Family Member',
      'Are you sure you want to remove ${member.name}?',
    );
    if (confirmed) {
      await StorageService.removeFamilyMember(member.id);
      _loadData();
    }
  }

  Future<void> _openFamilyTracking() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FamilyTrackingScreen()),
    );
  }

  Future<void> _testEmergencyNotification() async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await ApiService.sendTestEmergencyNotification();
      Navigator.pop(context); // Close loading

      if (result['success']) {
        _showSuccessDialog('Test notification sent to all emergency contacts');
      } else {
        _showErrorDialog(result['message'] ?? 'Failed to send test notification');
      }
    } catch (e) {
      Navigator.pop(context); // Close loading
      _showErrorDialog('Failed to send test notification: $e');
    }
  }

  Future<void> _shareMyLocation() async {
    // TODO: Implement location sharing
    _showInfoDialog('Location sharing feature will be implemented');
  }

  // Helper methods
  Future<bool> _showConfirmDialog(String title, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;
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

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success'),
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

  void _showInfoDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Info'),
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