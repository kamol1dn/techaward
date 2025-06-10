
import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await StorageService.getUserData();
    setState(() => userData = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Settings')),
      body: userData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('User Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Name: ${userData!['name']} ${userData!['surname']}'),
                    Text('Phone: ${userData!['phone']}'),
                    Text('Age: ${userData!['age']}'),
                    Text('Gender: ${userData!['gender']}'),
                    Text('Passport: ${userData!['passport']}'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Medical Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Blood Type: ${userData!['blood_type']}'),
                    Text('Allergies: ${userData!['allergies']}'),
                    Text('Illness: ${userData!['illness'] ?? 'None'}'),
                    if (userData!['additional_info']?.isNotEmpty == true)
                      Text('Additional: ${userData!['additional_info']}'),
                  ],
                ),
              ),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await StorageService.clearAll();
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }
}