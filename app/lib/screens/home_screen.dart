
import 'package:flutter/material.dart';
import 'request_help_screen.dart';
import '../services/connectivity_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final isOnline = await ConnectivityService.isOnline();
    setState(() => _isOnline = isOnline);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Services'),
        actions: [
          Icon(_isOnline ? Icons.wifi : Icons.wifi_off),
          SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            if (!_isOnline)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Offline Mode - Limited functionality',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(height: 20),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildServiceCard(
                    'Ambulance',
                    Icons.local_hospital,
                    Colors.red,
                    EmergencyType.ambulance,
                  ),
                  _buildServiceCard(
                    'Fire',
                    Icons.local_fire_department,
                    Colors.orange,
                    EmergencyType.fire,
                  ),
                  _buildServiceCard(
                    'Police',
                    Icons.local_police,
                    Colors.blue,
                    EmergencyType.police,
                  ),
                  _buildServiceCard(
                    'Others',
                    Icons.more_horiz,
                    Colors.grey,
                    EmergencyType.others,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(String title, IconData icon, Color color, EmergencyType type) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RequestHelpScreen(type: type, isOnline: _isOnline)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: color),
            SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

enum EmergencyType { ambulance, fire, police, others }
