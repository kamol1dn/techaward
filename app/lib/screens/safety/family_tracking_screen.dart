// import 'package:flutter/material.dart';
// class FamilyTrackingScreen extends StatefulWidget {
//   const FamilyTrackingScreen({super.key});
//
//   @override
//   State<FamilyTrackingScreen> createState() => _FamilyTrackingScreenState();
// }
//
// class _FamilyTrackingScreenState extends State<FamilyTrackingScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }
//
//

import 'package:flutter/material.dart';
import '../../models/family_member.dart';
import '../../services/storage_service.dart';
import '../../services/api_service.dart';

class FamilyTrackingScreen extends StatefulWidget {
  const FamilyTrackingScreen({super.key});

  @override
  State<FamilyTrackingScreen> createState() => _FamilyTrackingScreenState();
}

class _FamilyTrackingScreenState extends State<FamilyTrackingScreen> {
  List<FamilyMember> _familyMembers = [];
  bool _isLoading = true;
  bool _locationSharingEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final members = await StorageService.getFamilyMembers();
      final locationEnabled = await StorageService.isLocationSharingEnabled();

      // Try to get updated locations from server
      try {
        final result = await ApiService.getFamilyLocations();
        if (result['success']) {
          // Update local storage with server data
          final serverMembers = result['data'] as List;
          for (var serverMember in serverMembers) {
            final member = FamilyMember.fromJson(serverMember);
            await StorageService.saveFamilyMember(member);
          }
          // Reload from storage
          final updatedMembers = await StorageService.getFamilyMembers();
          setState(() {
            _familyMembers = updatedMembers;
            _locationSharingEnabled = locationEnabled;
            _isLoading = false;
          });
        } else {
          setState(() {
            _familyMembers = members;
            _locationSharingEnabled = locationEnabled;
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _familyMembers = members;
          _locationSharingEnabled = locationEnabled;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Failed to load family tracking data: $e');
    }
  }

  Future<void> _refreshLocations() async {
    await _loadData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Locations refreshed')),
    );
  }

  Future<void> _toggleLocationSharing(bool value) async {
    setState(() => _locationSharingEnabled = value);

    try {
      await StorageService.setLocationSharingEnabled(value);

      // Also update on server
      // final result = await ApiService.updateLocationSharing(value);
      // if (!result['success']) {
      //   // Revert on failure
      //   setState(() => _locationSharingEnabled = !value);
      //   _showErrorDialog('Failed to update location sharing settings');
      // }
    } catch (e) {
      // Revert on error
      setState(() => _locationSharingEnabled = !value);
      _showErrorDialog('Failed to update location sharing: $e');
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
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${lastSeen.day}/${lastSeen.month}/${lastSeen.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Family Tracking'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _refreshLocations,
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationSharingToggle(),
            SizedBox(height: 24),
            _buildFamilyMembersList(),
            SizedBox(height: 24),
            _buildMapPlaceholder(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-family-member'),
        backgroundColor: Colors.blue[600],
        child: Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  Widget _buildLocationSharingToggle() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location Sharing',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Allow family members to see your location',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16),
            SwitchListTile(
              title: Text('Enable Location Sharing'),
              subtitle: Text(
                _locationSharingEnabled
                    ? 'Your location is visible to family members'
                    : 'Your location is hidden from family members',
              ),
              value: _locationSharingEnabled,
              onChanged: _toggleLocationSharing,
              activeColor: Colors.blue[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyMembersList() {
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
                  'Family Members',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                Text(
                  '${_familyMembers.length} members',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _familyMembers.isEmpty
                ? _buildEmptyState()
                : Column(
              children: _familyMembers
                  .map((member) => _buildFamilyMemberItem(member))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.family_restroom, size: 48, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No family members added yet',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add family members to start tracking their locations',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/add-family-member'),
              icon: Icon(Icons.person_add),
              label: Text('Add Family Member'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyMemberItem(FamilyMember member) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
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
        title: Text(
          member.name,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              member.relationship,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 4),
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
                  Text(
                    ' • ',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
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
            if (member.location != null) ...[
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 12,
                    color: Colors.blue[600],
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      member.location!.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (member.location != null)
              IconButton(
                icon: Icon(Icons.directions, color: Colors.blue[600]),
                onPressed: () => _openDirections(member),
                tooltip: 'Get directions',
              ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleMemberAction(value, member),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'call',
                  child: Row(
                    children: [
                      Icon(Icons.phone, size: 18),
                      SizedBox(width: 8),
                      Text('Call'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'message',
                  child: Row(
                    children: [
                      Icon(Icons.message, size: 18),
                      SizedBox(width: 8),
                      Text('Message'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Remove', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Card(
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 48, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'Map View',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Family member locations will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _openFullMap,
              child: Text('Open Full Map'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDirections(FamilyMember member) {
    // TODO: Implement directions functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening directions to ${member.name}...')),
    );
  }

  void _openFullMap() {
    // TODO: Navigate to full map screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening full map view...')),
    );
  }

  void _handleMemberAction(String action, FamilyMember member) {
    switch (action) {
      case 'call':
      // TODO: Implement call functionality
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Calling ${member.name}...')),
        );
        break;
      case 'message':
      // TODO: Implement messaging functionality
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Messaging ${member.name}...')),
        );
        break;
      case 'edit':
      // TODO: Navigate to edit member screen
        Navigator.pushNamed(
          context,
          '/edit-family-member',
          arguments: member,
        );
        break;
      case 'remove':
        _confirmRemoveMember(member);
        break;
    }
  }

  void _confirmRemoveMember(FamilyMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Family Member'),
        content: Text('Are you sure you want to remove ${member.name} from your family tracking list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _removeMember(member);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Remove'),
          ),
        ],
      ),
    );
  }

  Future<void> _removeMember(FamilyMember member) async {
    try {
      await StorageService.removeFamilyMember(member.id);

      // // Also remove from server
      // final result = await ApiService.removeFamilyMember(member.id);
      // if (result['success']) {
      //   setState(() {
      //     _familyMembers.removeWhere((m) => m.id == member.id);
      //   });
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('${member.name} removed from family tracking')),
      //   );
      // } else {
      //   _showErrorDialog('Failed to remove family member from server');
      // }
    } catch (e) {
      _showErrorDialog('Failed to remove family member: $e');
    }
  }
}