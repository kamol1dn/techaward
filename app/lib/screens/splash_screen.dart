
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'quick_numbers_screen.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_hospital, size: 100, color: Colors.red),
            SizedBox(height: 20),
            Text('Emergency Services', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen())),
              child: Text('Login / Register'),
            ),
            SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuickNumbersScreen())),
              child: Text('Quick Numbers / Tutorials'),
            ),
          ],
        ),
      ),
    );
  }
}