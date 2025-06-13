import 'package:flutter/material.dart';
class FamilyTrackingScreen extends StatefulWidget {
  const FamilyTrackingScreen({super.key});

  @override
  State<FamilyTrackingScreen> createState() => _FamilyTrackingScreenState();
}

class _FamilyTrackingScreenState extends State<FamilyTrackingScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}






// import 'package:flutter/material.dart';
// import '../../models/family_member.dart';
// import '../../services/storage_service.dart';
// import '../../services/api_service.dart';
//
// class FamilyTrackingScreen extends StatefulWidget {
//   const FamilyTrackingScreen({super.key});
//
//   @override
//   State<FamilyTrackingScreen> createState() => _FamilyTrackingScreenState();
// }
//
// class _FamilyTrackingScreenState extends State<FamilyTrackingScreen> {
//   List<FamilyMember> _familyMembers = [];
//   bool _isLoading = true;
//   bool _locationSharingEnabled = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }
//
//   Future<void> _loadData() async {
//     setState(() => _isLoading = true);
//
//     try {
//       final members = await StorageService.getFamilyMembers();
//       final locationEnabled = await StorageService.isLocationSharingEnabled();
//
//       // Try to get updated locations from server
//       try {
//         final result = await ApiService.getFamilyLocations();
//         if (result['success']) {
//           // Update local storage with server data
//           final serverMembers = result['data'] as List;
//           for (var serverMember in serverMembers) {
//             final member = FamilyMember.fromJson(serverMember);
//             await StorageService.saveFamilyMember(member);
//           }
//           // Reload from storage
//           final updatedMembers = await StorageService.getFamilyMembers();
//           setState(() {
//             _familyMembers = updatedMembers;
//             _locationSharingEnabled = locationEnabled;
//             _isLoading = false;
//           });
//         } else {
//           setState(() {
//             _familyMembers = members;
//             _locationSharingEnabled = locationEnabled;
//             _isLoading = false;
//           });
//         }
//       } catch (e) {
//         setState(() {
//           _familyMembers = members;
//           _locationSharingEnabled = locationEnabled;
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() => _isLoading = false);
//       _showErrorDialog('Failed to load family tracking data: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Family Tracking'),
//         backgroundColor: Colors.blue[600],
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             onPressed: _refreshLocations,
//             icon: Icon(Icons.refresh),
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildLocationSharingToggle(),
//             SizedBox(height: 24),
//             _buildFamilyMembersList(),
//             SizedBox(height: 24),
//             _buildMapPlaceholder(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLocationSharingToggle() {
//     return Card(
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Location Sharing',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue[700],
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Allow family members to see your location',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[600],
//               ),
//             ),
//             SizedBox(height: 16),
//             SwitchListTile(
//               title: Text('Enable Location Sharing'),
//               subtitle: Text(
//                 _locationSharingEnabled
//                     ? 'Your location is visible to family members'
//                     : 'Your location is hidden from family members',
//               ),
//               value: _locationSharingEnabled,
//               onChanged: _toggleLocationSharing,
//               activeColor: Colors.blue[600],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFamilyMembersList() {
//     return Card(
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Family Members',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue[700],
//               ),
//             ),
//             SizedBox(height: 16),
//             _familyMembers.isEmpty
//                 ? _buildEmptyState()
//                 : Column(
//               children: _familyMembers.map((member) => _buildFamilyMemberItem(member)).toList(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Container(
//       padding: EdgeInsets.all(32),
//       child: Center(
//         child: Column(
//           children: [
//             Icon(Icons.family_restroom, size: 48, color: Colors.grey[400]),
//             SizedBox(height: 16),
//             Text(
//               'No family members added yet',
//               style: TextStyle(
//                 color: Colors.grey[600],
//                 fontSize: 16,
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Add family members to start tracking their locations',
//               style: TextStyle(
//                 color: Colors.grey[500],
//                 fontSize: 14,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFamilyMemberItem(FamilyMember member) {
//     return Container(
//         margin: EdgeInsets.only(bottom: 12),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey[300]!),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: ListTile(
//             leading: CircleAvatar(
//               backgroundColor: member.isOnline ? Colors.green[100] : Colors.grey[200],
//               child: Icon(
//                 Icons.person,
//                 color: member.isOnline ? Colors.green[700] : Colors.grey[600],
//               ),
//             ),
//             title: Text(member.name),
//             subtitle: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                 Text(member.relationship),
//             Row(
//               children: [
//                 Icon(
//                   member.isOnline ? Icons.circle : Icons.circle_outlined,
//                   size: 12,
//                   color: member.isOnline ? Colors.green : Colors.grey,
//                 ),
//                 SizedBox(width: 4),
//                 Text(
//                   member.isOnline ? 'Online' : 'Offline',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: member.isOnline ? Colors.green[600] : Colors.grey[600],
//                   ),
//                 ),
//                 if (member.lastSeen != null) ...[
//                   Text(' • '),
//                   Text(
//                     _formatLastSeen(member.lastSeen!),
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//             if (member.location != null) ...[
//         SizedBox(height: 4),
//     Row(
//     children: [
//     Icon(Icons