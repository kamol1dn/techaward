
import 'package:flutter/material.dart';
import '../main_screen.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';

class RegisterMedicalScreen extends StatefulWidget {
  final PersonalData personalData;

  const RegisterMedicalScreen({super.key, required this.personalData});

  @override
  _RegisterMedicalScreenState createState() => _RegisterMedicalScreenState();
}

class _RegisterMedicalScreenState extends State<RegisterMedicalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _allergiesController = TextEditingController();
  final _illnessController = TextEditingController();
  final _additionalInfoController = TextEditingController();

  String _bloodType = 'Unknown';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register (2/2)')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _bloodType,
                  decoration: InputDecoration(labelText: 'Blood Type'),
                  items: ['Unknown', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                      .map((String value) => DropdownMenuItem<String>(value: value, child: Text(value)))
                      .toList(),
                  onChanged: (value) => setState(() => _bloodType = value!),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _allergiesController,
                  decoration: InputDecoration(
                    labelText: 'Allergies',
                    hintText: 'Enter "none" if no allergies',
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _illnessController,
                  decoration: InputDecoration(labelText: 'Ongoing Illness'),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _additionalInfoController,
                  decoration: InputDecoration(labelText: 'Additional Information (Optional)'),
                  maxLines: 3,
                ),
                SizedBox(height: 32),

                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _completeRegistration,
                  child: Text('Complete Registration'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _completeRegistration() async {
    setState(() => _isLoading = true);

    final medicalData = MedicalData(
      bloodType: _bloodType,
      allergies: _allergiesController.text.isEmpty ? 'none' : _allergiesController.text,
      illness: _illnessController.text,
      additionalInfo: _additionalInfoController.text,
    );

    try {
      final result = await ApiService.completeRegistration(widget.personalData, medicalData);

      if (result['success']) {
        await StorageService.saveUserToken(result['token']);
        await StorageService.saveUserData(widget.personalData, medicalData);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => _LoadingScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration failed')));
    }

    setState(() => _isLoading = false);
  }
}

class _LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<_LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _simulateSync();
  }

  Future<void> _simulateSync() async {
    await Future.delayed(Duration(seconds: 2));
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => _SuccessScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Syncing with server...'),
          ],
        ),
      ),
    );
  }
}

class _SuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 100, color: Colors.green),
            SizedBox(height: 20),
            Text('Registration Successful!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainScreen())),
              child: Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}